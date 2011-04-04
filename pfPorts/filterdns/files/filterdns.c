/*
 * Copyright (C) 2009 - 2011 Ermal Luçi
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 * OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <sys/types.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/refcount.h>
#include <sys/queue.h>

#include <net/if.h>
#include <net/pfvar.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/ip_fw.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <pthread.h>
#include <syslog.h>
#include <stdarg.h>
#include <err.h>
#include <sysexits.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>

#include "filterdns.h"

static int interval = 30;
static int dev = -1;
static int debug = 0;

static void pf_tableentry(struct thread_data *, struct in_addr, int);
static void ipfw_tableentry(struct thread_data *, struct in_addr, int);
static int host_dns(struct thread_data *);
static int filterdns_clean_table(struct thread_data *);

void *check_hostname(void *arg);
void clear_config(void);

#define DELETE 1
#define ADD 2


#if 0
static void
flush_table(char *tablename)
{
        struct pfioc_table      io;

        memset(&io, 0, sizeof(io));
        if (strlcpy(io.pfrio_table.pfrt_name, tablename,
            sizeof(io.pfrio_table.pfrt_name)) >=
            sizeof(io.pfrio_table.pfrt_name))
		return; /* XXX */
        /* pfctl -Tflush */
        if (ioctl(dev, DIOCRCLRADDRS, &io) == -1)
                syslog(LOG_WARNING, "Cannot flush table %s addresses", tablename);
}
#endif

static int
add_table_entry(struct table_entry *rnh, struct in_addr addr, struct thread_data *thrdata)
{
	struct table *ent, *tmp;
	char buffer[256];

	TAILQ_FOREACH(tmp, rnh, entry) {
		if (addr.s_addr == tmp->addr.sin_addr.s_addr) {
			if (debug >= 2)
				syslog(LOG_WARNING, "entry %s exists in table %s", inet_ntoa_r(tmp->addr.sin_addr, buffer, sizeof buffer), thrdata->tablename);
			refcount_acquire(&tmp->refcnt);
			return (EEXIST);
		}
	}

	ent = calloc(1, sizeof(*ent));
	if (ent == NULL) {
		if (debug >= 1)
			syslog(LOG_WARNING, "Failed to allocate new entry for table %s.", thrdata->tablename);
		return (ENOMEM);
	}
	ent->addr.sin_addr = addr;
	refcount_init(&ent->refcnt, 1);
	refcount_acquire(&ent->refcnt);
	TAILQ_INSERT_HEAD(rnh, ent, entry);
	if (thrdata->type == PF_TYPE) {
		if (debug >= 2)
			syslog(LOG_WARNING, "adding entry %s to table %s on host %s", inet_ntoa_r(addr, buffer, sizeof buffer), thrdata->tablename, thrdata->hostname);
		pf_tableentry(thrdata, addr, ADD);
	}
	if (thrdata->type == IPFW_TYPE) {
		if (debug >= 2)	
			syslog(LOG_WARNING, "adding entry %s to table %s on host %s", inet_ntoa_r(addr, buffer, sizeof buffer), thrdata->tablename, thrdata->hostname);
		ipfw_tableentry(thrdata, addr, ADD);
	}
	
	return (0);
}

static int
filterdns_clean_table(struct thread_data *thrdata)
{
	struct table *e, *tmp;
	char buffer[256];

	TAILQ_FOREACH_SAFE(e, thrdata->rnh, entry, tmp) {
		if (refcount_release(&e->refcnt)) {
			if (thrdata->type == PF_TYPE) {
				if (debug >= 2)
				syslog(LOG_WARNING, "clearing entry %s from table %s on host %s", inet_ntoa_r(e->addr.sin_addr, buffer, sizeof buffer), thrdata->tablename, thrdata->hostname);
				pf_tableentry(thrdata, e->addr.sin_addr, DELETE);
			}
			if (thrdata->type == IPFW_TYPE) {
				if (debug >= 2)
					syslog(LOG_WARNING, "clearing entry %s from table %s on host %s", inet_ntoa_r(e->addr.sin_addr, buffer, sizeof buffer), thrdata->tablename, thrdata->hostname);
				ipfw_tableentry(thrdata, e->addr.sin_addr, DELETE);
			}
			TAILQ_REMOVE(thrdata->rnh, e, entry);
			free(e);
		}
	}

	return (0);
}

static void
init_table(struct table_entry *rnh)
{
	TAILQ_INIT(rnh);
}

static int
host_dns(struct thread_data *hostd)
{
        struct addrinfo          hints, *res0, *res;
        int                      error, cnt = 0;
	char buffer[256];

	res0 = NULL;
        bzero(&hints, sizeof(hints));
        hints.ai_family = PF_UNSPEC;
        hints.ai_socktype = SOCK_DGRAM; /* DUMMY */
        error = getaddrinfo(hostd->hostname, NULL, &hints, &res0);
        if (error == EAI_AGAIN) {
		if (debug >= 1)
			syslog(LOG_WARNING, "failed to resolve host %s will retry later again.", hostd->hostname);
		if (res0 != NULL)
			freeaddrinfo(res0);
                return (0);
	}
        if (error) {
		if (debug >= 1)
                	syslog(LOG_WARNING, "host_dns: failed looking up \"%s\": %s", hostd->hostname,
                    		gai_strerror(error));
		if (res0 != NULL)
			freeaddrinfo(res0);
                return (-1);
        }

        for (res = res0; res; res = res->ai_next) {
                if (res->ai_family == AF_INET) {
			if (debug >= 2)
				syslog(LOG_WARNING, "found entry %s for %s", inet_ntoa_r(((struct sockaddr_in *)res->ai_addr)->sin_addr, buffer, sizeof buffer), hostd->tablename);
			if (!add_table_entry(hostd->rnh, ((struct sockaddr_in *)
			    res->ai_addr)->sin_addr, hostd))
                		cnt++;
                }
        }
        freeaddrinfo(res0);
        return (cnt);
}

static void
ipfw_tableentry(struct thread_data *ipfwd, struct in_addr address, int action)
{
	ipfw_table_entry ent;
	static int s = -1;

	bzero(&ent, sizeof(ent));
	ent.masklen = ipfwd->mask;
	ent.tbl = ipfwd->tablenr;
	ent.addr = address.s_addr;
	ent.value = ipfwd->pipe; /* XXX */

	if (s == -1)
		s = socket(AF_INET, SOCK_RAW, IPPROTO_RAW);
	if (s < 0)
		return;

	setsockopt(s, IPPROTO_IP, action == ADD ? IP_FW_TABLE_ADD : IP_FW_TABLE_DEL, (void *)&ent, sizeof(ent));
}

static void
pf_tableentry(struct thread_data *pfd, struct in_addr address, int action)
{
	struct pfioc_table io;
	struct pfr_table table;
	struct pfr_addr addr;
	u_int32_t addrmask = 0;
	int i;

	bzero(&table, sizeof(table));
	if (strlcpy(table.pfrt_name, pfd->tablename,
		sizeof(table.pfrt_name)) >= sizeof(table.pfrt_name)) {
		if (debug >= 1)
			syslog(LOG_WARNING, "could not add address to table %s", pfd->tablename);
		return;
	}
	
	bzero(&addr, sizeof(addr));
	addr.pfra_af = AF_INET;
	addr.pfra_net = pfd->mask;
	if (pfd->mask < 32) {
		for (i = 31; i > 31 - pfd->mask; --i)
                	addrmask |= (1 << i);
               	addrmask = htonl(addrmask);
		addr.pfra_ip4addr.s_addr = ((u_int32_t)address.s_addr) & addrmask;
	} else
		addr.pfra_ip4addr = address;
	
	bzero(&io, sizeof io);
        io.pfrio_table = table;
        io.pfrio_buffer = &addr;
        io.pfrio_esize = sizeof(addr);
        io.pfrio_size = 1;

	if (action == DELETE) {
		 if (ioctl(dev, DIOCRDELADDRS, &io))
			if (debug >= 2)
				syslog(LOG_WARNING, "failed to delete address from table %s.", pfd->tablename);
	} else if (action == ADD) {
		if (ioctl(dev, DIOCRADDADDRS, &io))
			if (debug >= 2)
				syslog(LOG_WARNING, "failed to add address to table %s with errno %d.", pfd->tablename, errno);
	}
}

void *check_hostname(void *arg)
{
	struct table_entry rnh;
	struct thread_data *thrd = arg;
	struct timespec ts;
        char *p, *q;
	int firstrun = 0, tmp;
	int howmuch, error1;

        ts.tv_sec = interval;
        ts.tv_nsec = 0;
	
	if (!thrd->hostname)
		return (NULL);

	init_table(&rnh);


        if ((p = strrchr(thrd->hostname, '/')) != NULL) {
                thrd->mask = strtol(p+1, &q, 0);
                if (!q || *q || thrd->mask > 32 || q == (p+1)) {
			if (debug >= 1)
                        	syslog(LOG_WARNING, "invalid netmask '%s' for hostname %s\n", p, thrd->hostname);
                        return (NULL);
                }
		tmp = strlen(p) + 1;
		thrd->hostname[tmp] = '\0'; 
		q = thrd->hostname + tmp + 1;
		free(q);
        } else {
		thrd->mask = 32;
	}

	thrd->rnh = &rnh;

	if (debug >= 2)
		syslog(LOG_WARNING, "Found hostname %s with netmask %d.", thrd->hostname, thrd->mask);

	//flush_table(thrd->tablename);

	for (;;) {

		howmuch = host_dns(thrd);	
		if (debug >= 2)
			syslog(LOG_WARNING, "Found %d entries for %s", howmuch, thrd->hostname);

		if (!firstrun) {
			firstrun++;
			if (debug >= 3)
				syslog(LOG_WARNING, "Not cleaning table %s host %s. ", thrd->tablename, thrd->hostname);
		} else {
			if (howmuch > 0 && thrd->cmd != NULL) {
				error1 = system(thrd->cmd);
				if (debug >= 2)
					syslog(LOG_WARNING, "Ran command %s with exit status %d because a dns change on hostname %s was detected.", thrd->cmd, error1, thrd->hostname);
			}
			filterdns_clean_table(thrd);
			if (debug >= 3)
				syslog(LOG_WARNING, "cleaning table %s host %s. ", thrd->tablename, thrd->hostname);
		}
		nanosleep(&ts, NULL);
	}

	filterdns_clean_table(thrd);
	//flush_table(thrd->tablename);

	return (NULL);
}

static void
handle_signal(int sig)
{
        switch(sig) {
        case SIGHUP:
        case SIGTERM:
		clear_config();
                break;
        default:
		if (debug >= 3)
                	syslog(LOG_WARNING, "unhandled signal");
        }
}

void
clear_config()
{
	struct thread_data *thr;
	struct table *a;

	while ((thr = TAILQ_FIRST(&thread_list)) != NULL) {
		TAILQ_REMOVE(&thread_list, thr, next);
		while ((a = TAILQ_FIRST(thr->rnh)) != NULL) {
			TAILQ_REMOVE(thr->rnh, a, entry);
			free(a);
		}
		if (thr->hostname)
			free(thr->hostname);
		if (thr->tablename)
			free(thr->tablename);
		if (thr->thr_pid)
			pthread_cancel(thr->thr_pid);
		free(thr);
	}
}

static void filterdns_usage(void) {
	
	fprintf(stderr, "usage: filterdns -f -p pidfile -i interval -c filecfg -d debuglevel\n");
	exit(4);
}

int main(int argc, char *argv[]) {
	struct thread_data *thr;
	int error, ch;
	char *file, *pidfile;
	FILE *pidfd;
	sig_t sig_error;
	int foreground = 0;

	file = NULL;
	pidfile = NULL;

	while ((ch = getopt(argc, argv, "c:d:fi:p:")) != -1) {
		switch (ch) {
		case 'c':
			file = optarg;
			break;
		case 'd':
			debug = atoi(optarg);
			break;
		case 'f':
			foreground = 1;
			break;
		case 'i':
			interval = atoi(optarg);
			if (interval < 1) {
				fprintf(stderr, "Invalid interval %d\n", interval);
				return (3);
			}
			break;
		case 'p':
			pidfile = optarg;
			break;
		default:
			fprintf(stderr, "Wrong option: %c given!", ch);
			return (ch);
			break;
		}
	}

	if (file == NULL) {
		fprintf(stderr, "Configuration file is mandatory!");
		filterdns_usage();
		return (-1);
	}

        (void)freopen("/dev/null", "w", stdout);
        (void)freopen("/dev/null", "w", stdin);
	closefrom(3);

	TAILQ_INIT(&thread_list);
        if (parse_config(file)) {
                syslog(LOG_ERR, "unable to open configuration file");
                return (EX_OSERR);
        }

	dev = open("/dev/pf", O_RDWR);
	if (dev < 0)
		errx(1, "Could not open device.");

	/* go into background */
	if (!foreground && daemon(0, 0) == -1) {
		printf("error in daemon\n");
		exit(1);
	}

	if (pidfile) {
		/* write PID to file */
		pidfd = fopen(pidfile, "w");
		if (pidfd) {
			fprintf(pidfd, "%d\n", getpid());
			fclose(pidfd);
		} else
			syslog(LOG_WARNING, "could not open pid file");
	}

	/*
         * Catch SIGHUP in order to reread configuration file.
         */
	sig_error = signal(SIGHUP, handle_signal);
        if (sig_error == SIG_ERR)
                err(EX_OSERR, "unable to set signal handler");
        sig_error = signal(SIGTERM, handle_signal);
        if (sig_error == SIG_ERR)
                err(EX_OSERR, "unable to set signal handler");

	TAILQ_FOREACH(thr, &thread_list, next) {
		error = pthread_create(&thr->thr_pid, NULL, check_hostname, thr);
		if (error != 0) {
			if (debug >= 1)
				syslog(LOG_ERR, "Unable to create monitoring thread for host %s", thr->hostname);
		}
	}
	TAILQ_FOREACH(thr, &thread_list, next)
		pthread_join(thr->thr_pid, NULL);
	
	clear_config();

	return (0);
}

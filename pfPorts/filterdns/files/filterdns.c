/*
	Copyright (C) 2009 Ermal Luçi
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	1. Redistributions of source code must retain the above copyright notice,
	   this list of conditions and the following disclaimer.
	
	2. Redistributions in binary form must reproduce the above copyright
	   notice, this list of conditions and the following disclaimer in the
	   documentation and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
	INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
	AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
	OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.

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

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>
#include <libutil.h>
#include <pthread.h>
#include <syslog.h>
#include <stdarg.h>
#include <err.h>
#include <sysexits.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>


static int running = 0;
static int interval = 0;
static int dev = -1;
static int debug = 0;

#define DELETE 1
#define ADD 2

struct table {
	struct sockaddr_in	addr;
	u_int refcnt;
	TAILQ_ENTRY(table) entry;
};
TAILQ_HEAD(table_entry, table);

struct thread_data {
	struct table_entry *rnh;
	char *tablename;
	char *hostname;
	int mask;
};

static void
pf_tableentry(char *tablename, in_addr_t address, int mask, int action);
void *check_hostname(void *arg);

void usage(void);

void
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

static int
add_table_entry(struct table_entry *rnh, in_addr_t addr, struct thread_data *data)
{
	struct table *ent, *tmp;
	char buffer[256];

	ent = calloc(1, sizeof(*ent));
	if (ent == NULL) {
		if (debug >= 1)
			syslog(LOG_WARNING, "Failed to allocate new entry for table %s.", data->tablename);
		return (ENOMEM);
	}
	ent->addr.sin_addr.s_addr = addr;
	refcount_init(&ent->refcnt, 1);
	refcount_acquire(&ent->refcnt);
	TAILQ_FOREACH(tmp, rnh, entry) {
		if (addr == tmp->addr.sin_addr.s_addr) {
			if (debug >= 2)
				syslog(LOG_WARNING, "entry %s exists in table %s", inet_ntoa_r(ent->addr.sin_addr, buffer, sizeof buffer), data->tablename);
			refcount_acquire(&tmp->refcnt);
			free(ent);
			return (EEXIST);
		}
	}

	if (debug >= 2)
		syslog(LOG_WARNING, "adding entry %s to table %s", data->tablename, inet_ntoa_r(ent->addr.sin_addr, buffer, sizeof buffer));
	TAILQ_INSERT_HEAD(rnh, ent, entry);

	pf_tableentry(data->tablename, addr, data->mask, ADD);
	
	return (0);
}

static int
clean_table(struct thread_data *data)
{
	struct table *ent, *tmp;
	char buffer[256];

	TAILQ_FOREACH_SAFE(ent, data->rnh, entry, tmp) {
		if (refcount_release(&ent->refcnt)) {
			if (debug >= 2)
				syslog(LOG_WARNING, "clearing entry %s from table %s on host %s", inet_ntoa_r(ent->addr.sin_addr, buffer, sizeof buffer), data->tablename, data->hostname);
			pf_tableentry(data->tablename, ent->addr.sin_addr.s_addr, data->mask, DELETE);
			TAILQ_REMOVE(data->rnh, ent, entry);
			free(ent);
		}
	}

	return (0);
}

static int
init_table(struct table_entry *rnh)
{
	TAILQ_INIT(rnh);
}

static int
host_dns(struct thread_data *data)
{
        struct addrinfo          hints, *res0, *res;
        int                      error, cnt = 0;
	char buffer[256];

        bzero(&hints, sizeof(hints));
        hints.ai_family = PF_UNSPEC;
        hints.ai_socktype = SOCK_DGRAM; /* DUMMY */
        error = getaddrinfo(data->hostname, NULL, &hints, &res0);
        if (error == EAI_AGAIN) {
		if (debug >= 1)
			syslog(LOG_WARNING, "failed to resolve host %s will retry later again.", data->hostname);
                return (0);
	}
        if (error) {
		if (debug >= 1)
                	syslog(LOG_WARNING, "host_dns: could not parse \"%s\": %s", data->hostname,
                    		gai_strerror(error));
                return (-1);
        }

        for (res = res0; res; res = res->ai_next) {
                if (res->ai_family == AF_INET) {
			if (debug >= 2)
				syslog(LOG_WARNING, "found entry %s for %s", inet_ntoa_r(((struct sockaddr_in *)res->ai_addr)->sin_addr, buffer, sizeof buffer), data->tablename);
			add_table_entry(data->rnh, ((struct sockaddr_in *)
			    res->ai_addr)->sin_addr.s_addr, data);
                cnt++;
                }
        }
        freeaddrinfo(res0);
        return (cnt);
}

static void
pf_tableentry(char *tablename, in_addr_t address, int mask, int action)
{
	struct pfioc_table io;
	struct pfr_table table;
	struct pfr_addr addr;
	u_int32_t addrmask = 0;
	int i;

	bzero(&table, sizeof(table));
	if (strlcpy(table.pfrt_name, tablename,
		sizeof(table.pfrt_name)) >= sizeof(table.pfrt_name)) {
		if (debug >= 1)
			syslog(LOG_WARNING, "could not add address to table %s", tablename);
		return;
	}
	
	bzero(&addr, sizeof(addr));
	addr.pfra_af = AF_INET;
	addr.pfra_net = mask;
	if (mask < 32) {
		for (i = 31; i > 31-mask; --i)
                	addrmask |= (1 << i);
               	addrmask = htonl(addrmask);
		addr.pfra_ip4addr.s_addr = ((u_int32_t)address) & addrmask;
	} else
		addr.pfra_ip4addr.s_addr = address;
	
	bzero(&io, sizeof io);
        io.pfrio_table = table;
        io.pfrio_buffer = &addr;
        io.pfrio_esize = sizeof(addr);
        io.pfrio_size = 1;

	if (action == DELETE) {
		 if (ioctl(dev, DIOCRDELADDRS, &io))
			if (debug >= 2)
				syslog(LOG_WARNING, "failed to delete address from table %s.", tablename);
	} else if (action == ADD) {
		if (ioctl(dev, DIOCRADDADDRS, &io))
			if (debug >= 2)
				syslog(LOG_WARNING, "failed to add address to table %s with errno %d.", tablename, errno);
	}
}

void *check_hostname(void *arg)
{
	struct table_entry rnh;
	struct thread_data data;
	struct timespec ts;
	properties local = (properties) arg;
        char *p, *q, *ps;
	int firstrun = 0;
	int howmuch;

        ts.tv_sec = interval;
        ts.tv_nsec = 0;
	
	if (!local->name || !local->value)
		return;
	init_table(&rnh);


        if ((p = strrchr(local->name, '/')) != NULL) {
                data.mask = strtol(p+1, &q, 0);
                if (!q || *q || data.mask > 32 || q == (p+1)) {
			if (debug >= 1)
                        	syslog(LOG_WARNING, "invalid netmask '%s' for hostname %s\n", p, local->name);
                        return;
                }
                if ((data.hostname = malloc(strlen(local->name) - strlen(local->name) + 1)) == NULL) {
			if (debug >= 1)
				syslog(LOG_WARNING, "Failed to allocate memory for storing hostname %s.", local->name);
                        return;
		}
                strlcpy(data.hostname, local->name, strlen(local->name) - strlen(p) + 1);
        } else {
		data.hostname = local->name;
		data.mask = 32;
	}

	data.rnh = &rnh;
	data.tablename = local->value;

	if (debug >= 2)
		syslog(LOG_WARNING, "Found hostname %s with netmask %d.", data.hostname, data.mask);

	//flush_table(data.tablename);

	while (running) {

		howmuch = host_dns(&data);	
		if (debug >= 2)
			syslog(LOG_WARNING, "Found %d entries for %s", howmuch, data.hostname);

		if (!firstrun) {
			firstrun++;
			if (debug >= 3)
				syslog(LOG_WARNING, "Not cleaning table %s host %s. ", data.tablename, data.hostname);
		} else {
			clean_table(&data);
			if (debug >= 3)
				syslog(LOG_WARNING, "cleaning table %s host %s. ", data.tablename, data.hostname);
		}
		nanosleep(&ts, NULL);
	}

	clean_table(&data);
	//flush_table(data.tablename);

	if (data.mask != 32)
		free(data.hostname);
}

static void
handle_signal(int sig)
{
        switch(sig) {
        case SIGHUP:
        case SIGTERM:
		running = 0;
                break;
        default:
		if (debug >= 3)
                	syslog(LOG_WARNING, "unhandled signal");
        }
}

void usage(void) {
	
	fprintf(stderr, "usage: filterdns pidfile interval filecfg debuglevel\n");
	exit(4);
}

int main(int argc, char *argv[]) {
	int exerr = 0;	
	int fd, error, i;
	char *file;
	int threadcount = 0;
	properties list, props;
	pthread_t *threads = NULL;
	FILE *pidfd;
	struct sigaction sa;
	
	if (argc < 4 || argc > 5)
		usage();
	
	interval = atoi(argv[2]);
	if (interval < 1) {
		fprintf(stderr, "Invalid interval %d\n", interval);
		exit(3);
	}
	
	if (argc == 5) {
        	debug = atoi(argv[4]);
        	if (debug < 1) {
                	fprintf(stderr, "Invalid debug level %d\n", debug);
                	exit(4);
        	}
	}

	file = argv[3];
	
	dev = open("/dev/pf", O_RDWR);
	if (dev < 0)
		errx(1, "Could not open device.");

	/* go into background */
	if (daemon(0, 0) == -1) {
		printf("error in daemon\n");
		exit(1);
	}
	
	/* write PID to file */
	pidfd = fopen(argv[1], "w");
	if (pidfd) {
		fprintf(pidfd, "%d\n", getpid());
		fclose(pidfd);
	} else
		syslog(LOG_WARNING, "could not open pid file");

	fd = open(file, O_RDONLY);
        if (fd == -1) {
                syslog(LOG_ERR, "unable to open configuration file");
                return (EX_OSERR);
        }

        props = properties_read(fd);
        if (props == NULL) {
                syslog(LOG_ERR, "error reading configuration file");
                return (EX_DATAERR);
        }

	/*
         * Catch SIGHUP in order to reread configuration file.
         */
        sa.sa_handler = handle_signal;
        sa.sa_flags = SA_SIGINFO|SA_RESTART;
        sigemptyset(&sa.sa_mask);
        error = sigaction(SIGHUP, &sa, NULL);
        if (error == -1)
                err(EX_OSERR, "unable to set signal handler");
        error = sigaction(SIGTERM, &sa, NULL);
        if (error == -1)
                err(EX_OSERR, "unable to set signal handler");

	list = props;
	while (list != NULL) {
		threadcount++;
		list = list->next;
	}

	threads = malloc(threadcount * sizeof(pthread_t));
	if (threads == NULL) {
		syslog(LOG_ERR, "error while allocating memory");
		exerr =  EX_OSERR;
		properties_free(props);
		exit(5);
	}

	memset(threads, 0, sizeof(threads) * threadcount);

	running = 1;

	list = props;
	i = 0;
	while (list != NULL) {
		error = pthread_create(&threads[i], NULL, check_hostname, list);
		if (error != 0) {
			if (debug >= 1)
				syslog(LOG_ERR, "Unable to create monitoring thread for host %s", list->name);
		}
		i = i + 1;
		list = list->next;
	}
	for (i = 0; i < threadcount; i++)
		pthread_join(threads[i], NULL);
	
	running = 0;

	//return 0;

	if (props != NULL)
		properties_free(props);
	if (threads != NULL)
		free(threads);
	return 1;
}

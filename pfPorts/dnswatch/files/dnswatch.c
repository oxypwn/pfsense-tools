/*
	$Id$
	part of pfSense (http://www.pfsense.org)
	originally part of m0n0wall (http://m0n0.ch/wall)
	Copyright (C) 2009 Scott Ullrich <sullrich@pfsense.org>
	Copyright (C) 2009 Ermal Luci <ermal@pfsense.org>
	Copyright (C) 2007 Manuel Kasper <mk@neon1.net>.
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
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <libutil.h>
#include <err.h>
#include <syslog.h>
#include <stdarg.h>
#include <err.h>
#include <sysexits.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <signal.h>

#include <pthread.h>

/*
	Resolves each host name in a given list at regular intervals, and runs
	a command whenever any of them resolves to a different IP address than
	before.
	
	Usage:
		dnswatch pidfile interval command hostfile
		
	interval is in seconds; for best results, set this to be slightly larger
	than the TTL of the DNS records being watched
*/

static char *command = NULL;
pthread_t *threads = NULL;
static int hosts = 0;
static int debug = 0;
static int interval = 10;

void usage(void) {
	fprintf(stderr, "usage: dnswatch pidfile interval command hostfile\n");
	exit(4);
}

void *check_hostname(void *arg)
{
	properties local = (properties) arg;
	struct hostent *he;
	struct in_addr *addr, ip;
	struct timespec ts;

	ts.tv_sec = interval;
        ts.tv_nsec = 0;

	if (!local->name)
		return 0;

	ip.s_addr = 0;
	for (;;) {
		he = gethostbyname2(local->name, AF_INET);
		if (he == NULL) {
			syslog(LOG_WARNING, "DNS lookup for host %s failed", local->name);
		} else {
			addr = (struct in_addr*)he->h_addr;
			if (ip.s_addr == 0) {
				ip = *addr;
			} else if (ip.s_addr != addr->s_addr) {
				ip = *addr;
				syslog(LOG_WARNING, "hostname %s ip changed to %s, reloading ipsec tunnel.",  local->name, inet_ntoa(*addr));
				system(command);
			}
		}
		nanosleep(&ts, NULL);
	}
}

static void
handle_signal(int sig)
{
        int i;

        switch(sig) {
        case SIGHUP:
        case SIGTERM:
                if (hosts) {
                        for (i = 0; i < hosts; i++) {
                                pthread_cancel(threads[i]);
                        }
                }
                break;
        default:
                if (debug >= 3)
                        syslog(LOG_WARNING, "unhandled signal");
        }
}

int main(int argc, char *argv[]) {
	char *file;
	properties list, props;
	int fd, i = 0, error = 0;
	FILE *pidfd = NULL;
	sig_t sig_error;

	if (argc > 5 || argc < 4)
		usage();

	interval = atoi(argv[2]);
	if (interval < 1) {
		fprintf(stderr, "Invalid interval %d\n", interval);
		exit(3);
	}
	
	command = argv[3];
	file = argv[4];

	closefrom(1);

	/* go into background */
	if (daemon(0, 0) == -1)
		exit(1);
	
	/* write PID to file */
	pidfd = fopen(argv[1], "w");
	if (pidfd) {
		fprintf(pidfd, "%d\n", getpid());
		fclose(pidfd);
	}
	
	// Attempt to open configuration file which lists hosts
	fd = open(file, O_RDONLY);
	if (fd == -1) {
		syslog(LOG_ERR, "unable to open configuration file '%s'", file);
		exit(1);
	}

	// Read hostnames in that are in the configuration file
	props = properties_read(fd);
	if (props == NULL) {
		syslog(LOG_ERR, "error reading configuration file");
		exit(1);
	}
	
	// Close open file handle for dnswatch configuration
	close(fd);

	/*
         * Catch SIGHUP in order to reread configuration file.
         */
        sig_error = signal(SIGHUP, handle_signal);
        if (sig_error == SIG_ERR)
                err(EX_OSERR, "unable to set signal handler");
        sig_error = signal(SIGTERM, handle_signal);
        if (sig_error == SIG_ERR)
                err(EX_OSERR, "unable to set signal handler");

	list = props;
	while (list != NULL) {
		list = list->next;
		hosts++;
	}

        threads = malloc(hosts * sizeof(pthread_t));
        if (threads == NULL) {
                syslog(LOG_ERR, "error while allocating memory");
                properties_free(props);
                exit(5);
        }

        memset(threads, 0, sizeof(threads) * hosts);

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
        for (i = 0; i < hosts; i++)
                pthread_join(threads[i], NULL);

        if (props != NULL)
                properties_free(props);
        if (threads != NULL)
                free(threads);

	return 0;
}

/* 
 * $Id$
 *
 * Copyright (c) 2003, Christianity.com
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     - Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     - Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     - Neither the name of Christianity.com nor the names of its
 *       contributors may be used to endorse or promote products derived from
 *       this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <err.h>
#include <syslog.h>
#include <stdarg.h>
#include <string.h>
#include <pthread.h>
#include <poll.h>
#include <signal.h>

#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/pfvar.h>

#include "service.h"
#include "vsvc.h"
#include "config.h"
#include "vsvc_rules.h"
#include "printers.h"
#include "pollers.h"

extern char *anchorname;

SLIST_HEAD(, vsvc_t) virtualservices;

void sigignore(int signal) {
	return;
}

void usage(void) {
	fprintf(stderr, 
	    "slbd copyright 2003 Christianity.com and all its subsidiaries\n"
	    "Usage:  slbd [ opts ... ]\n"
	    "             -c /path/to/capfile\n"
	    "             -r rule-refresh-time (in milliseconds; 10000 default)"
	    "\n");
}

int main(int argc, char **argv) {
	int i = 0, nt = 0, status, ch;
	int r_refresh = 15000;  /* default rule refresh time - 10 seconds */
	char *cfile = NULL;
	pthread_t *t;
	struct vsvc_t *v;

#ifndef DEBUG
	daemon(0,0);
#endif

	/* initialize timezone */
	tzset();

	openlog("slbd", (LOG_PERROR|LOG_PID), LOG_LOCAL1);

	while ((ch = getopt(argc, argv, "c:r:p:")) != -1) {
		switch(ch) {
		case 'c':
			cfile = optarg;
			break;
		case 'r':
			r_refresh = strtol(optarg, NULL, 10);
			if (r_refresh == LONG_MIN || r_refresh == LONG_MAX)
				err(1, "Bad refresh time");
			break;
		default:
			usage();
			exit(1);
		}
	}

	syslog(LOG_INFO, "Using r_refresh of %d milliseconds", r_refresh);
	vsvc_getconfig(cfile);


	signal(SIGPIPE, sigignore);
	signal(SIGHUP, sigignore);

	/*
	SLIST_FOREACH(v, &virtualservices, next) {
		printf("bleh %d\n", i++);
	}
	*/

#ifdef DEBUG
	warnx("Testing services");
#endif
	/* do one round through the tests */
	SLIST_FOREACH(v, &virtualservices, next) {
		for (i = 0; i < v->services_len; i++) {
			service_pollhttp(v->services[i]);
#ifdef DEBUG
			print_service(v->services[i]);
#endif
		}
		nt++;
	}

	/* we don't want to clear the ruleset until we're actually about to 
	   fill it in with something else. this allows us to kill and 
	   restart the slb daemon without killing all our incoming 
	   connections.
	 */
	vsvc_pfctlstart();
#ifdef DEBUG
	warnx("Starting ruleinit");
#endif
	vsvc_ruleinit();

	t = malloc(nt * sizeof(pthread_t));
	if (t == NULL) {
		syslog(LOG_ERR, "malloc failed: %s", strerror(errno));
		err(1, "malloc failed");
	}
	/* spawn poller threads */
#ifdef DEBUG
	warnx("spawning poller threads");
#endif
	SLIST_FOREACH(v, &virtualservices, next) {
#ifdef DEBUG
		warnx("spawning poller thread %d", v->id);
#endif
		if (pthread_create(&t[v->id], NULL,
		    (void *) &vsvc_threadpoll, (void *) v)) {
			syslog(LOG_ERR, "pthread_create failed: %s",
			    strerror(errno));
			err(1, "pthread_creation");
		}
#ifdef DEBUG
		warnx("spawned poller thread %d", v->id);
#endif
	}

	while (1) {
#ifdef DEBUG
		warnx("sleeping before rule committing");
#endif
		poll(NULL, 0, r_refresh); 
		vsvc_ruleinit();
	}

	return(status);
}


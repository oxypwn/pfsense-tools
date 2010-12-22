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

/*
	Resolves each host name in a given list at regular intervals, and runs
	a command whenever any of them resolves to a different IP address than
	before.
	
	Usage:
		dnswatch pidfile interval command hostfile
		
	interval is in seconds; for best results, set this to be slightly larger
	than the TTL of the DNS records being watched
*/

void usage(void) {
	fprintf(stderr, "usage: dnswatch pidfile interval command hostfile\n");
	exit(4);
}

int check_hostname(char *hostname, struct in_addr *ip) {
	struct hostent *he;
	struct in_addr *addr;

	he = gethostbyname2(hostname, AF_INET);
	if (he == NULL) {
		syslog(LOG_WARNING, "DNS lookup for %s failed", hostname);
		return 0;
	}
	
	addr = (struct in_addr*)he->h_addr;
	
	if (ip->s_addr != 0 && ip->s_addr != addr->s_addr) {
		*ip = *addr;
		return 1;
	}
	
	*ip = *addr;
	return 0;
}

int main(int argc, char *argv[]) {
	int interval;
	char *file;
	char *command;
	properties list, props;
	struct in_addr *ips;
	int fd;
	FILE *pidfd;

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

	int hosts = 1;
	list = props;
	while (list != NULL) {
		list = list->next;
		hosts++;
	}

	// Create a place to hold resolved ip addresses
	ips = calloc(hosts, sizeof(struct in_addr));
	if (ips == NULL) {
		fprintf(stderr, "calloc failed\n");
		exit(2);
	}

	// Loop forever checking to see if a hostname changes
	for (;;) {
		int i = 0;
		int changes = 0;
		list = props;
		while (list != NULL) {
			changes += check_hostname(list->name, &ips[i]);
			list = list->next;
			i++;
		}
		
		// If the hostname changed, run the specified command
		if (changes > 0)
			system(command);
		
		// Sleep until next run
		sleep(interval);
	}

	// Release memory before exiting
	properties_free(props);

	return 0;
}

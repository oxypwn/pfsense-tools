/* 
 * $Id$
 *
 * Copyright (c) 2003, Silas Partners
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
#include <sys/time.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/pfvar.h>
#include <netinet/in.h>
#include <sys/queue.h>
#include <arpa/inet.h>
#include <err.h>
#include <errno.h>
#include <syslog.h>
#include <stdarg.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#ifdef PFSENSE
#include <sys/stat.h>
#endif

#include "service.h"
#include "vsvc.h"
#include "printers.h"
#include "pollers.h"

static int	tcp_read_timeout = 5000; /* in milliseconds */
static int	poll_interval = 5000; /* in milliseconds */

#define MAXREQSIZE	300	
static char    *httprequest_f =	"%s %s HTTP/1.0\r\n"
				"User-Agent: Toaster-0.9"
				"\r\n\r\n";

int service_starttcp(struct service_t *s) {
	int fd = 0xDEADBEEF, result, status;
	int retry = 0;
	struct pollfd pfd;

retry:
	if ((fd = socket(AF_INET, SOCK_STREAM, 6)) == -1) {
		syslog(LOG_ERR, "service_starttcp: Could not create socket "
		    "for service %s:%d",
		    inet_ntoa(getservice_inaddr(s)), getservice_port(s));
#ifdef DEBUG
		warn("Could not create socket for service %s:%d",
		    inet_ntoa(getservice_inaddr(s)), getservice_port(s));
#endif
		status = -1;
		goto bail;
	}
	if (fcntl(fd, F_SETFL, O_NONBLOCK) == -1) {
		syslog(LOG_ERR, "service_starttcp: fcntl could not set fd "
		    "non-blocking");
#ifdef DEBUG
		warn("fcntl could not set fd non-blocking");
#endif
		status = -1;
		goto bail;
	}

	if (connect(fd, (struct sockaddr *) &s->addr, sizeof(struct sockaddr_in)) == -1) {
		switch(errno) {
			case EINPROGRESS:
				break;
			case EPERM:	/* We retry here as this is semi-common */
				if (retry++ <= 5) {
					/* Close socket */
					close(fd);
#ifdef DEBUG
					warn("connect(2) failed because of EPERM...retrying...");
#endif
					goto retry;
				}
			default:
				lock_service(s);
				setservice_down(s);
				syslog(LOG_ERR, "TCP poll failed to start to %s:%d during connect() (%s)",
		    		inet_ntoa(getservice_inaddr(s)), getservice_port(s), strerror(errno));
				unlock_service(s);
#ifdef DEBUG
				warn("connect(2) failed for the wrong reason");
#endif
				status = -1;
		}
	}

	memset(&pfd, 0x0, sizeof(pfd));
	pfd.fd = fd;
	pfd.events = (POLLIN|POLLOUT|POLLHUP|POLLNVAL);
	result = poll(&pfd, 1, tcp_read_timeout);

	switch (result) {
		case -1:
			syslog(LOG_ERR, "service_starttcp: poll(2) failed: %s",
			    strerror(errno));
			warn("poll(2) failed");
			status = -1;
			goto bail;
		case 0:
			switch(errno) {
				case EINPROGRESS:
					lock_service(s);
					setservice_down(s);
					if (s->prevstatus != s->status) {
						syslog(LOG_ERR, "TCP poll still in progress to %s:%d, marking service DOWN",
							inet_ntoa(getservice_inaddr(s)),
							getservice_port(s));
					}
					unlock_service(s);
					status = -2;
					goto bail;
				default:
					lock_service(s);
					setservice_down(s);
					/* 0 events => timeout */
					if (s->prevstatus != s->status) {
						syslog(LOG_ERR, "TCP poll failed to start to %s:%d during poll() (%s), marking service DOWN",
						inet_ntoa(getservice_inaddr(s)),
						getservice_port(s), strerror(errno));
					}
					unlock_service(s);
					status = -2;
					goto bail;
			}
		default:
			if (pfd.revents == POLLOUT) {
				/* we're connected if only POLLOUT is on */
				lock_service(s);
				setservice_up(s);
				unlock_service(s);
				status = fd;
				goto bail;
			}
			else {
				lock_service(s);
				setservice_down(s);
				syslog(LOG_ERR, "TCP poll failed to start to "
				    "%s:%d in default (%s)", inet_ntoa(getservice_inaddr(s)),
				    getservice_port(s), strerror(errno));
				unlock_service(s);
				status = -2;
				goto bail;
			}
			/* NOTREACHED */

	}

bail:
	if (status < 0) close(fd);
	return(status);
}

int service_tcpexpect(struct service_t *s, int fd, char *send, char *expect) {
	int result, status;
	char buf[BUFSIZ+1];
	struct pollfd pfd;

	result = write(fd, send, strlen(send));
	if (result == -1) {
		lock_service(s);
		setservice_down(s);
		if (s->prevstatus != s->status) {
			syslog(LOG_ERR, "TCP poll failed send for %s:%d, marking service DOWN", 
		    	    inet_ntoa(getservice_inaddr(s)), getservice_port(s));
		}
#ifdef DEBUG
		warn("write failed");
#endif
		unlock_service(s);

		status = -1;
		goto bail;
	}
	else if (result < strlen(send)) {
		result = write(fd, send+result, strlen(send)-result);
		if (result < strlen(send)-result) {
#ifdef DEBUG
			warn("double short-write");
#endif
			syslog(LOG_ERR, "double-short-write in "
			    "service_tcpexpect: %s", strerror(errno));
			status = -1;
			goto bail;
		}
	}
	else if (result != strlen(send)) {
#ifdef DEBUG
		warn("unknown error");
#endif
		syslog(LOG_ERR, "Unknown error in service_tcpexpect: %s",
		    strerror(errno));
		status = -1;
		goto bail;
	}

	pfd.fd = fd;
	pfd.events = (POLLIN);
	result = poll(&pfd, 1, tcp_read_timeout);

	switch (result) {
		case 0:
			lock_service(s);
			setservice_down(s);
			unlock_service(s);
			status = 0;
			goto bail;
		case -1:
#ifdef DEBUG
			warn("poll failed");
#endif
			status = -1;
			goto bail;
		default:
			result = read(fd, buf, BUFSIZ);
			if (result == -1) {
				lock_service(s);
				setservice_down(s);
				if (s->prevstatus != s->status) {
					syslog(LOG_ERR, "TCP poll failed expect for "
					    "%s:%d, marking service DOWN", inet_ntoa(getservice_inaddr(s)),
					    getservice_port(s));
				}
#ifdef DEBUG
				warn("read(2) failed with %d events", result);
#endif
				unlock_service(s);
				status = -1;
				goto bail;
			}
			else
				buf[result+1] = '\0';
#ifdef DEBUG
				warnx("Got buf: %s\n", buf);
#endif

			if (strstr(buf, expect) != NULL) {
#ifdef DEBUG
				warnx("Service up in tcpexpect.");
#endif
				lock_service(s);
				setservice_up(s);
				unlock_service(s);
			}
			else {
				lock_service(s);
				setservice_down(s);
				if (s->prevstatus != s->status) {
					syslog(LOG_ERR, "TCP poll failed expected "
					    "string check for %s:%d, marking service DOWN", 
					    inet_ntoa(getservice_inaddr(s)),
					    getservice_port(s));
				}
				unlock_service(s);
			}
	}
	status = 0;

bail:
	return(status);
}

int service_polltcp(struct service_t *s) {
	int fd = 0xDEADBEEF, status;

	lock_service(s);
	if ((getservice_status(s) & SVCSTATUS_ACTIVE) == 0) {
		syslog(LOG_ERR, "service_polltcp: reached unreachable code");
		return(-1);
	}
	unlock_service(s);
	
	fd = service_starttcp(s);
	switch (fd) {
		case -2:
			lock_service(s);
			setservice_down(s);
				if (s->prevstatus != s->status) {
					syslog(LOG_ERR, "TCP poll failed for %s:%d, marking service DOWN", 
						inet_ntoa(getservice_inaddr(s)),
						getservice_port(s));
				}
			unlock_service(s);
#ifdef DEBUG
			warnx("Could not open TCP connection");
#endif
			status = -2;
			goto bail;
		case -1:
#ifdef DEBUG
			warn("Something went wrong in service_starttcp().");
#endif
			syslog(LOG_ERR, "Something went awry in "
			    "service_starttcp()");
			status = -1;
			goto bail;
		default:
#ifdef DEBUG
			warnx("Service %s:%d has open port.",
			    inet_ntoa(getservice_inaddr(s)),
			    getservice_port(s));
#endif
			/* XXX do send/expect here if three's stuff to do XXX */
			if (strlen(s->poll_probe.data) > 0 ||
			    strlen(s->poll_response.data) > 0) {
#ifdef DEBUG
				warnx("Probing service %s:%d with string.",
				    inet_ntoa(getservice_inaddr(s)),
				    getservice_port(s));
#endif
				service_tcpexpect(s, fd, s->poll_probe.data,
				    s->poll_response.data);
			}
			else {
#ifdef DEBUG
				warnx("Content with open port, marking as up.");
#endif
				lock_service(s);
				setservice_up(s);
				if (s->prevstatus != s->status) {
					syslog(LOG_ERR, "TCP poll succeeded for %s:%d, marking service UP", 
						inet_ntoa(getservice_inaddr(s)),
						getservice_port(s));
				}
				
				unlock_service(s);
			}
			break;
	}

	status = 0;
bail:
	close(fd);
	return(0);
}


int service_pollhttp(struct service_t *s) {
	int fd, status;
	char request[MAXREQSIZE+1];

	if ((getservice_status(s) & SVCSTATUS_ACTIVE) == 0) 
		return(-1);
	
	fd = service_starttcp(s);
	switch (fd) {
		case -2:
#ifdef DEBUG
			warn("service_pollhttp could not open TCP connection");
#endif
			status = -1;
			goto bail;
		case -1:
#ifdef DEBUG
			warn("Bad TCP startup from service_starttcp()");
#endif
			status = -1;
			goto bail;
		default:
			/* we have an open TCP connection */
			break;
	}

	switch (getservice_polltype(s) &
	        (SVCPOLL_HTTPGET|SVCPOLL_HTTPHEAD|SVCPOLL_HTTPPOST)) {
		case SVCPOLL_HTTPPOST:
			errno = ENOSYS;
#ifdef DEBUG
			warn("HTTP POST not added yet");
#endif
			status = -1;
			goto bail;
		case SVCPOLL_HTTPHEAD:
			lock_service(s);
			snprintf(request, MAXREQSIZE, httprequest_f, "HEAD",
			    s->poll_probe.data);
			unlock_service(s);
			break;
		case SVCPOLL_HTTPGET:
			lock_service(s);
			snprintf(request, MAXREQSIZE, httprequest_f, "GET",
			    s->poll_probe.data);
			unlock_service(s);
			break;
		default:
			status = -1;
			goto bail;
			/* NOTREACHED */
	}
	
	service_tcpexpect(s, fd, request, s->poll_response.data);
	status = 0;

bail:
	close(fd);
	return(status);
}


int service_pollicmp(struct service_t *s) {
	int res, status;
	char cmd[128];
    
	if ((getservice_status(s) & SVCSTATUS_ACTIVE) == 0) {
		syslog(LOG_ERR, "service_pollicmp: reached unreachable code");
		return(-1);
	}
	
	/* XXX: billm - we're taking the cheap way out */
	snprintf(cmd, 127, "/usr/local/sbin/fping -B1.5 -t400 -r3 -q %s >/dev/null", 
	inet_ntoa(getservice_inaddr(s)));
	res = system(cmd);
	/* if the ping failed, try again */
	if(res != 0)  
		res = system(cmd);
 
	switch (res) {
		case 0:
			
			lock_service(s);
			setservice_up(s);
			if (s->prevstatus != s->status) {
				syslog(LOG_ERR, "ICMP poll succeeded for %s, marking service UP", 
					inet_ntoa(getservice_inaddr(s)));
			}
			unlock_service(s);
			break;
		default:
			lock_service(s);
			setservice_down(s);
			if (s->prevstatus != s->status) {
				syslog(LOG_ERR, "ICMP poll failed for %s, marking service DOWN", 
					inet_ntoa(getservice_inaddr(s)));
			}
			unlock_service(s);
			status = -2;
			goto bail;
	}

	status = 0;
bail:
	return(0);
}



struct timeval i2tv(int i) {
	struct timeval tv;

	tv.tv_usec = (((long) i ) % 1000) * 1000;
	tv.tv_sec = ((long) i - (long) i % 1000 );
	return tv;
}


void vsvc_threadpoll(void *p) {
	int i;
	polltype_t polltype;
	struct vsvc_t *v = p;
#ifdef PFSENSE
	int needs_filter_configure = 0;
	struct stat sb;
#endif

	while (1) {

#ifdef PFSENSE
		FILE *file;
		char filename[MAXPATHLEN+1];
#endif

		for (i = 0; i < v->services_len; i++) {
			v->services[i]->prevstatus = v->services[i]->status;
			polltype = getservice_polltype(v->services[i]);
			if (polltype & \
			   (SVCPOLL_HTTPGET|SVCPOLL_HTTPHEAD|SVCPOLL_HTTPPOST)){
				if (service_pollhttp(v->services[i])) {
#ifdef DEBUG
					warnx("Failed HTTP poll for vsvc %d"
					      ", svc %d", v->id, i);
					print_service(v->services[i]);
#endif
				}
			}
			else if (polltype & SVCPOLL_TCP) { 
				if (service_polltcp(v->services[i])) {
#ifdef DEBUG
					warnx("Failed TCP poll for vsvc %d"
					      ", svc %d", v->id, i);
					print_service(v->services[i]);
#endif
				}
				
			}
			else if (polltype & SVCPOLL_PING) { 
				if (service_pollicmp(v->services[i])) {
#ifdef DEBUG
					warnx("Failed ICMP poll for vsvc %d"
					      ", svc %d", v->id, i);
					print_service(v->services[i]);
#endif
				}
			}
			/* TODO: add non-TCP/HTTP poll */
#ifdef PFSENSE
			if (getservice_status(v->services[i]) != getservice_prevstatus(v->services[i])) 
				needs_filter_configure = 1;
#endif
		}

#ifdef PFSENSE
		/*  
		*   loop through and output the status of the pools
		*   so that the filter code can make the necessary
		*   adjustments
		*/

		snprintf(filename, MAXPATHLEN, "/tmp/%s.pool", v->poolname);
		file=fopen(filename,"w");
		/* loop through and make /tmp/$poolname.info */
		for (i = 0; i < v->services_len; i++) {
			//if ((getservice_status(v->services[i]) & SVCSTATUS_ACTIVE) == 0 ) {
			if (getservice_status(v->services[i]) != \
			  (SVCSTATUS_ACTIVE|SVCSTATUS_UP)) {
				/* service is down, do nothing */
			} else {
				 fprintf(file, "%s\n", inet_ntoa(getservice_inaddr(v->services[i])));
			}
		}
		fclose(file);

		if(needs_filter_configure == 1) {
			syslog(LOG_ERR, "Service %s changed status, reloading filter policy", v->poolname);
			snprintf(filename, MAXPATHLEN, "/tmp/filter_dirty");
			if (stat(filename, &sb)) {
				file=fopen(filename,"w");
				fclose(file);
			}
			needs_filter_configure = 0;
		}
#endif

		if (poll(NULL, 0, poll_interval)) 
#ifdef DEBUG
			warn("vsvc_threadpoll pause");
#else 
			do { } while (0);
#endif
	}
}

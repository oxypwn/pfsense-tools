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

/* XXX XXX NO LOCKING SHOULD GO ON IN THIS FILE */
#include <assert.h>
#include <errno.h>
#include <pthread.h>
#include <sys/queue.h>
#include <sys/socket.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <err.h>
#include <syslog.h>
#include <stdarg.h>

#include "service.h"

SLIST_HEAD(servicelist, service_t) services = SLIST_HEAD_INITIALIZER(services);

int init_service(struct service_t *s) {
	memset((void *) s, 0x0, sizeof(*s));
	
	s->addr.sin_family = AF_INET;
	if (pthread_mutex_init(&s->lock, NULL)) {
		syslog(LOG_CRIT, "Could not initialize service: %s",
		    strerror(errno));
		return(1);
	}
	SLIST_INSERT_HEAD(&services, s, next);
	return(0);
}

int lock_service(struct service_t *s) {
	if (pthread_mutex_lock(&s->lock)) {
		syslog(LOG_CRIT, "Could not lock mutex: %s", strerror(errno));
		return(1);
	}
	else return(0);
}

int unlock_service(struct service_t *s) {
	if (pthread_mutex_unlock(&s->lock)) {
		syslog(LOG_CRIT, "Could not unlock mutex: %s", strerror(errno));
		return(1);
	}
	else return(0);
}

int setservice_httpget(struct service_t *s, char *url, char *expect) {
	size_t len;

	len = strlcpy((char *) &s->poll_probe.data, url, MAXURLLEN);
	assert(len == strlen((char *) &s->poll_probe.data));

	if (len != strlen(url)) {
		syslog(LOG_ERR, "WARNING: Something went wrong with strlcpy, "
		    "maybe input URL is too long?");
	}

	len = strlcpy((char *) &s->poll_response.data, expect, MAXRESPLEN);
	assert(len == strlen((char *) &s->poll_response.data));

	/* HTTP GET and the other HTTP methods are mutually exclusive */
	setservice_addpolltype(s, SVCPOLL_HTTPGET);
	setservice_addpolltype(s, SVCPOLL_EXPECT);
	setservice_rmpolltype(s, SVCPOLL_HTTPPOST);
	setservice_rmpolltype(s, SVCPOLL_HTTPHEAD);
	if (getservice_polltype(s) & (SVCPOLL_HTTPPOST|SVCPOLL_HTTPHEAD)) {
		syslog(LOG_ERR, "Oddity from adding SVCPOLL_HTTPGET flag: %s",
		    strerror(errno));
		return(1);
	}
	return(0);
}

int setservice_httphead(struct service_t *s, char *url, char *expect) {
	if (setservice_httpget(s, url, expect)) {
		syslog(LOG_ERR, "Unable to setservice_httpget: %s", \
		    strerror(errno));
		return(1);
	}

	/* HTTP HEAD and the other HTTP methods are mutually exclusive */
	setservice_addpolltype(s, SVCPOLL_HTTPHEAD);
	setservice_rmpolltype(s, SVCPOLL_HTTPPOST);
	setservice_rmpolltype(s, SVCPOLL_HTTPGET);
	if (getservice_polltype(s) & (SVCPOLL_HTTPPOST|SVCPOLL_HTTPGET)) {
		syslog(LOG_ERR, "Unable to unset HTTPGET/POST and add "
		    "HTTPHEAD");
		return(1);
	}
	return(0);
}

int setservice_ping(struct service_t *s) {
	setservice_addpolltype(s, SVCPOLL_PING);
	return(0);
}

int setservice_tcppoll(struct service_t *s) {
	setservice_addpolltype(s, SVCPOLL_TCP);
	memset((void *) &s->poll_probe.data, 0x0, MAXURLLEN);
	memset((void *) &s->poll_response.data, 0x0, MAXRESPLEN);
	return(0);
}

int setservice_tcpexpect(struct service_t *s, char *send, char *expect) {
	size_t len;

	len = strlcpy((char *) &s->poll_probe.data, send, MAXURLLEN);
	assert(len == strlen((char *) &s->poll_probe.data));

	if (len != strlen(send)) {
		syslog(LOG_ERR, "WARNING: Something went wrong with strlcpy, "
		    "maybe input string is too long?");
	}

	len = strlcpy((char *) &s->poll_response.data, expect, MAXRESPLEN);
	assert(len == strlen((char *) &s->poll_response.data));

	setservice_rmpolltype(s, SVCPOLL_HTTPPOST);
	setservice_rmpolltype(s, SVCPOLL_HTTPGET);
	setservice_addpolltype(s, SVCPOLL_TCP);
	return(0);
}

int setservice_inaddr(struct service_t *s, char *a) {
	switch(inet_aton(a, &s->addr.sin_addr)) {
		case -1:
			syslog(LOG_ERR, "Unable to set service address to %s",
			    a);
			break;
		case 0:
			syslog(LOG_ERR, "Bad inet address: %s\n", a);
			break;
		default:
			return(0);
	}
	return(1);
}

int setservice_port(struct service_t *s, int p) {
	s->addr.sin_port = htons((unsigned short) p);
	return(0);
}

int getservice_port(struct service_t *s) {
	return((int) ntohs(s->addr.sin_port));
}

struct in_addr getservice_inaddr(struct service_t *s) {
	return(s->addr.sin_addr);
}


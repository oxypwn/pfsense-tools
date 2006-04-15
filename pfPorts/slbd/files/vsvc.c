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
#include <sys/queue.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/pfvar.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <errno.h>
#include <pthread.h>
#include <stdio.h>
#include <assert.h>
#include <err.h>
#include <string.h>
#include <syslog.h>
#include <stdarg.h>

#include "globals.h"
#include "service.h"
#include "vsvc.h"

int vsvc_init(struct vsvc_t *v) {
	int i = 0;
	memset(v, 0, sizeof(struct vsvc_t));
	v->addr.sin_family = AF_INET;
	if (pthread_mutex_init(&v->lock, NULL)) {
		syslog(LOG_CRIT, "vsvc_init: could not initialize mutex for "
		    "vsvc_t: %s", strerror(errno));
		err(1, "Could not initialize mutex for vsvc_t");
		i++;
	}
	return(i);
}

int vsvc_lock(struct vsvc_t *v) {
	if (pthread_mutex_lock(&v->lock)) {
		syslog(LOG_CRIT, "vsvc_lock: Could not lock vsvc_t mutex: %s",
		    strerror(errno));
		return(1);
	}
	else return(0);
}

int vsvc_unlock(struct vsvc_t *v) {
	if (pthread_mutex_unlock(&v->lock)) {
		syslog(LOG_CRIT, "vsvc_unlock: Could not unlock vsvc_t mutex: "
		    "%s", strerror(errno));
		return(1);
	}
	else return(0);
}

int vsvc_setinaddr(struct vsvc_t *v, char *a) {
	struct in_addr ia;
	if (inet_aton(a, &ia) != 1) {
		syslog(LOG_CRIT, "Could not inet_aton, aborting "
		    "vsvc_setinaddr: %s", strerror(errno));
		return(1);
	}
	else {
		v->addr.sin_addr = ia;
		return(0);
	}
}

int vsvc_setname(struct vsvc_t *v, char *n) {
	int len, newlen;

	len = strlen(n);
	if (len > MAXNAMELEN) {
	}
	newlen = strlcpy(v->name, n, MAXNAMELEN+1);
	if (newlen < len) 
		syslog(LOG_CRIT, "vsvc_t %d name too long - truncating", v->id);
	else if (newlen > len) {
		syslog(LOG_CRIT, "something is funk-teed: %d > %d",
		    newlen, len);
		return(1);
	}
	return(0);
}

int vsvc_setport(struct vsvc_t *v, int port) {
	in_port_t p;

	p = (in_port_t) port;
	if (port > 65535) {
		syslog(LOG_ERR, "vsvc_setport: invalid port: greater "
		    "than 65535");
		return(1);
	}
	else if (port < 1) {
		syslog(LOG_ERR, "vsvc_setport: invalid ports lower "
		    "than 1 make me suspicious");
		return(1);
	}
	else {
		v->addr.sin_port = htons((unsigned short) p);
		return(0);
	}
}	


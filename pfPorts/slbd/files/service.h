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

typedef unsigned long status_t;
typedef unsigned long polltype_t;


/* SLIST_HEAD(servicelist, service_t) head = SLIST_HEAD_INITIALIZER(head); */

/* our basic structure keeping track of a particular service */
struct service_t {
	SLIST_ENTRY(service_t) next;
	polltype_t	polltype;
#define SVCPOLL_PING		0x0001
#define SVCPOLL_TCP		0x0002
#define SVCPOLL_HTTPGET		0x0004
#define SVCPOLL_HTTPHEAD	0x0008
#define SVCPOLL_HTTPPOST	0x0010
#define SVCPOLL_EXPECT		0x0020
	pthread_mutex_t	lock;
	status_t	status;
#define SVCSTATUS_ACTIVE	0x0001
#define SVCSTATUS_UP		0x0002
	struct sockaddr_in	addr;
	struct tm last;  /* unused */
#define MAXURLLEN	255	/* maximum length of URI to GET, HEAD or POST */
	union {
		int	code;
		char	data[MAXURLLEN];
	} poll_probe;
#define MAXRESPLEN	255	/* maximum length of incoming response string */
	union {
		int	code;
		char	data[MAXRESPLEN];
	} poll_response;	/* the required response code/string */
	status_t	prevstatus;
};

/* definitions for service-marking macros */
/* all return the new status or polltype */
#define setservice_status(a,b)		(a->status = b)
#define setservice_active(a)		(a->status |= SVCSTATUS_ACTIVE)
#define setservice_inactive(a)		(a->status &= ~SVCSTATUS_ACTIVE)
#define setservice_up(a)		(a->status |= SVCSTATUS_UP)
#define setservice_down(a)		(a->status &= ~SVCSTATUS_UP)
#define setservice_polltype(a,b)	(a->polltype = b)
#define setservice_addpolltype(a,b)	(a->polltype |= b)
#define setservice_rmpolltype(a,b)	(a->polltype &= ~b)
#define getservice_polltype(a)		(a->polltype)
#define getservice_status(a)		(a->status)
#define getservice_prevstatus(a)	(a->prevstatus)

int init_service(struct service_t *);
int lock_service(struct service_t *);
int unlock_service(struct service_t *);
int setservice_httpget(struct service_t *, char *, char *); /* get/response */
int setservice_httphead(struct service_t *, char *, char *);
int setservice_httppost(struct service_t *, char *, char *); /* not done */
int setservice_ping(struct service_t *);
int setservice_tcppoll(struct service_t *);
int setservice_tcpexpect(struct service_t *, char *, char *);

int setservice_inaddr(struct service_t *, char *);
int setservice_port(struct service_t *, int);
int getservice_port(struct service_t *);
struct in_addr getservice_inaddr(struct service_t *);


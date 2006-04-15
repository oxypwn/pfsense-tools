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

/* needs service.h and pfvar.h */

struct vsvc_t {
	SLIST_ENTRY(vsvc_t)	next;
	u_int32_t		dirty;
	u_int32_t		id;
	u_int32_t		rule_nr;
	u_int32_t		services_len;
	status_t		status;
#define VSVCSTATUS_ACTIVE	0x0001
#define VSVCSTATUS_UP		0x0002
	struct pf_pool		pool;
	pthread_mutex_t		lock;
#define MAXNAMELEN 255
	char			name[MAXNAMELEN+1];
	char			anchor[PF_ANCHOR_NAME_SIZE];
#ifdef OpenBSD3_5
        char                    ruleset[PF_RULESET_NAME_SIZE];
#endif
	struct sockaddr_in	addr;
	struct sockaddr_in	sitedown;
	struct service_t      **services;  /* to service_t[services_len] */
	char			poolname[MAXNAMELEN+1];
	int			needs_filter_reload;
};

#define	vsvc_getstatus(a)	(a->status)
#define	vsvc_setstatus(a, b)	(a->status = b)
#define vsvc_getinaddr(a)	(a->addr.sin_addr)
#define vsvc_getname(a)		((char *) a->name)
#define vsvc_getport(a)		((int) ntohs(a->addr.sin_port))
#define vsvc_setactive(a)	(a->status |= VSVCSTATUS_ACTIVE)
#define vsvc_setinactive(a)	(a->status &= ~VSVCSTATUS_ACTIVE)
#define vsvc_markup(a)		(a->status |= VSVCSTATUS_UP)
#define vsvc_markdown(a)	(a->status &= ~VSVCSTATUS_UP)

int		vsvc_init(struct vsvc_t *);
int		vsvc_lock(struct vsvc_t *);
int		vsvc_unlock(struct vsvc_t *);
int		vsvc_setinaddr(struct vsvc_t *, char *);
int		vsvc_setname(struct vsvc_t *, char *);
int		vsvc_setport(struct vsvc_t *, int);

/* manipulate rules associated with a virtual service */
/* we put these in a different header */
/*
int		vsvc_addpooladdr(struct vsvc_t *, struct sockaddr_in *);
struct pf_pool	vsvc_getpool(struct vsvc_t *);
struct pf_rule	vsvc_getrule(struct vsvc_t *);
int		vsvc_updaterule(struct vsvc_t *);
*/

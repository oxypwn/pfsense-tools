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

/*
 * Portions Copyright (c) 2001 Daniel Hartmeier
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above
 *      copyright notice, this list of conditions and the following
 *      disclaimer in the documentation and/or other materials provided
 *      with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#include <net/pfvar.h>
#include <sys/queue.h>
#include <errno.h>
#include <err.h>
#include <syslog.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <string.h>

#include "globals.h"
#include "service.h"
#include "vsvc.h"
#include "printers.h"
#include "vsvc_rules.h"

int vsvc_pfctlstart(void) {
	int dev;
	struct pfioc_rule pr;

	if ((dev = open("/dev/pf", O_RDWR, 0)) == -1) {
		syslog(LOG_ERR, "Could not open /dev/pf, quitting: %s",
		    strerror(errno));
		err(1, "Could not open /dev/pf");
	}

	pthread_mutex_destroy(&io.lock);

	if (pthread_mutex_init(&io.lock, NULL)) {
		syslog(LOG_ERR, "Could not initialize IO mutex: %s. Quitting.",
		    strerror(errno));
		err(1, "Could not initialize IO mutex");
	}
	
	/* if (pthread_mutex_lock(&io.lock))
		err(1, "pthread_mutex_lock(&io.lock)"); */

	memset(&pr, 0x0, sizeof(pr));

	/* to replace pfctl_rules do:
	 *  - DIOCBEGINRULES
	 *  - DIOCADDRULE (pfctl_add_rule, pfctl.c:924)
	 *  - DIOCCOMMITRULES
	 */

	pr.rule.action = PF_RDR;

	io.dev = dev;
	io.flags = PFIO_UP;
	io.ticket = pr.ticket; /* this may or may not be a good idea. */

	return(0);
}

int vsvc_pfctlunlock(void) {
	int status = 0;
	if (pthread_mutex_unlock(&io.lock)) {
#ifdef DEBUG
		warn("vsvc_pfctlunlock()");
#endif
		status = 1;
		goto bail;
	}
	status = 0;
bail:
	return(status);
}

int vsvc_pfctllock(void) {
	int status = 0;
	if (pthread_mutex_lock(&io.lock)) {
#ifdef DEBUG
		warn("vsvc_pfctllock()");
#endif
		status = 1;
		goto bail;
	}
	status = 0;
bail:
	return(status);
}

int vsvc_ruleinit(void) {
	int status;
	struct vsvc_t *vf;
	struct pfioc_trans pt;
	struct pfioc_trans_e *pte;

	if (vsvc_pfctllock()) {
		status = 1;
		goto bail;
	}

	memset(&pt, 0x0, sizeof(pt));
	if ((pte = malloc(sizeof(struct pfioc_trans_e))) == NULL) {
		warnx("pte could not allocate space");
		status = 1;
		goto bail;
	}
	pte->rs_num = PF_RULESET_RDR;
	memcpy(&pte->anchor, anchorname, PF_ANCHOR_NAME_SIZE);
#ifdef DEBUG
	warnx("Loading rules into anchor %s",
	    pte->anchor);
#endif
	pt.size = 1;  /* XXX hardcoded? */
	pt.esize = sizeof(struct pfioc_trans_e);
	pt.array = pte;

	if (ioctl(io.dev, DIOCXBEGIN, &pt)) {
		syslog(LOG_ERR, "DIOCXBEGIN failed: %s", strerror(errno));
#ifdef DEBUG
		warn("DIOCXBEGIN failed");
#endif
		if (errno != EBADF)
			close(io.dev);
#ifdef DEBUG
		warnx("vsvc_ruleinit reopening pf handle"); 
#endif
		if (vsvc_pfctlstart()) {
			syslog(LOG_ERR, "vsvc_pfctlstart() failed; quitting");
			errx(1, "vsvc_pfctlstart() failed; exiting");
		}
		if (vsvc_pfctllock()) {
			syslog(LOG_ERR, "could not lock pfctl after recovery");
			errx(1, "could not lock pfctl after recovery");
		}
		status = 0;
	}
#ifdef DEBUG
	warnx("Ticket set to %d", pt.array->ticket);
#endif
	io.ticket = pt.array->ticket;

	SLIST_FOREACH(vf, &virtualservices, next) {
		/* add rule based on the up/down stuff in the vsvcs */
#ifdef DEBUG
		warnx("adding rule %d", vf->id);
#endif
		if (vsvc_ruleadd(vf)) {
			syslog(LOG_ERR, "vsvc_buildrule failed for %s",
			    vf->name);
#ifdef DEBUG
			warnx("vsvc_buildrule failed for %d", vf->id);
#endif
			status = 1;
			goto bail;
		}
	}

	if (ioctl(io.dev, DIOCXCOMMIT, &pt)) {
		syslog(LOG_ERR, "DIOCXCOMMIT failed for %s", vf->name);
#ifdef DEBUG
		warn("DIOCXCOMMIT");
#endif
		status = 1;
		goto bail;
	}
	status = 0;

bail:
	free(pte);
	vsvc_pfctlunlock();
	return(status);
}

int vsvc_ruleadd(struct vsvc_t *v) {
	int status = 0, i, n;
	struct pf_pooladdr *a;
	struct pf_rule r;
	struct pfioc_rule pr;
	struct pfioc_pooladdr pa;

	memset(&r, 0x0, sizeof(r));
	memset(&r, 0x0, sizeof(r));

	/* see parse.y:2297 for building base RDR */
	r.action = PF_RDR;
	r.af = AF_INET;
	r.proto = IPPROTO_TCP;
	r.dst.port_op = PF_OP_EQ;
	r.dst.port[0] = v->addr.sin_port;
	r.dst.port[1] = v->addr.sin_port;
	r.dst.addr.v.a.addr.v4 = v->addr.sin_addr;
	r.dst.addr.v.a.addr.v4 = v->addr.sin_addr;
	r.dst.addr.v.a.mask.v4.s_addr = htonl(INADDR_NONE);
	r.dst.addr.v.a.mask.v4.s_addr = htonl(INADDR_NONE);
	r.rpool.opts = PF_POOL_ROUNDROBIN | PF_POOL_STICKYADDR | PF_POOL_RANDOM;
	//memcpy(r.anchorname, anchorname, PF_ANCHOR_NAME_SIZE);

	TAILQ_INIT(&r.rpool.list);
	for (i = 0, n = 0; i < v->services_len; i++) {
		if (getservice_status(v->services[i]) != \
			(SVCSTATUS_ACTIVE|SVCSTATUS_UP))
			continue;

		a = calloc(1, sizeof(struct pf_pooladdr));
		if (a == NULL) {
			syslog(LOG_CRIT, "CRITICAL: calloc returned NULL: %s",
			     strerror(errno));
#ifdef DEBUG
			warn("calloc returned NULL");
#endif
			status = 1;
			goto bail;
		}
		r.rpool.proxy_port[0] = htons(v->services[i]->addr.sin_port);
		r.rpool.proxy_port[1] = htons(v->services[i]->addr.sin_port);
		a->addr.v.a.addr.v4 = v->services[i]->addr.sin_addr;
		a->addr.v.a.mask.v4.s_addr = htonl(INADDR_NONE);
		a->ifname[0] = 0;
		TAILQ_INSERT_TAIL(&r.rpool.list, a, entries);
		n++;
	}

	/* prepare to put in our address pool */
	memset(&pa, 0x0, sizeof(pa));

	if (ioctl(io.dev, DIOCBEGINADDRS, &pa)) {
		syslog(LOG_ERR, "DIOCBEGINADDRS failed: %s", strerror(errno));
#ifdef DEBUG
		warn("DIOCBEGINADDRS");
#endif
		status = 1;
		goto bail;
	}
	pa.af = AF_INET;
	memcpy(pa.anchor, anchorname, PF_ANCHOR_NAME_SIZE);

	/* sitedown */
	if (n == 0) {
		syslog(LOG_ERR, "Switching to sitedown for VIP %s:%d",
		    v->name, vsvc_getport(v));

#ifdef DEBUG
		warnx("sitedown for vsvc %d", v->id);
#endif
		a = calloc(1, sizeof(struct pf_pooladdr));
		if (a == NULL) {
			warn("calloc returned NULL");
			status = 1;
			goto bail;
		}
		a->addr.v.a.addr.v4 = v->sitedown.sin_addr;
		a->addr.v.a.mask.v4.s_addr = htonl(INADDR_NONE);
		/* set sitedown redir port */
		r.rpool.proxy_port[0] = htons(v->sitedown.sin_port);
		r.rpool.proxy_port[1] = htons(v->sitedown.sin_port);
		a->ifname[0] = 0;
		TAILQ_INSERT_TAIL(&r.rpool.list, a, entries);
	}

	/* add each address to the pool */
	TAILQ_FOREACH(a, &r.rpool.list, entries) {
		memcpy(&pa.addr, a, sizeof(struct pf_pooladdr));
		if (ioctl(io.dev, DIOCADDADDR, &pa)) {
			syslog(LOG_ERR, "DIOCADDADDR failed: %s", 
			    strerror(errno));
#ifdef DEBUG
			warn("DIOCADDADDR");
#endif
			status = 1;
			goto bail;
		}
	}
	v->rule_nr = r.nr = v->id;
	
	/* prepare the pfioc_rule for ioctl */
	memset(&pr, 0x0, sizeof(pr));
	memcpy(pr.anchor, anchorname, PF_ANCHOR_NAME_SIZE);
	pr.action = PF_RDR;
	pr.ticket = io.ticket;
	pr.pool_ticket = pa.ticket;
	pr.nr = v->rule_nr;
	memcpy(&pr.rule, &r, sizeof(pr.rule));
	/* XXX we have to work around the fact that PF can't handle
	    an anchorname inside the pr.rule in 3.5; fixed in -current prolly */
	//memset(&pr.rule.anchorname, 0x0, PF_ANCHOR_NAME_SIZE);

	if (ioctl(io.dev, DIOCADDRULE, &pr)) {
		syslog(LOG_ERR, "DIOCADDRULE failed: %s", strerror(errno));
#ifdef DEBUG
		warn("DIOCADDRULE");
#endif
		status = 1;
	}
	else {
		status = 0;
	}

	/* cleanup after our calloc's -- memory leak otherwise */

bail:
	while ((a = TAILQ_FIRST(&r.rpool.list)) != NULL) {
		TAILQ_REMOVE(&r.rpool.list, a, entries);
		free(a);
	}
	return(status);
}

int vsvc_ruleupdate(struct vsvc_t *v) {
	/* XXX BROKEN */
	return(0);
}

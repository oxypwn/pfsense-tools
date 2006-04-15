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
#include <sys/socket.h>
#include <sys/queue.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <time.h>
#include <stdio.h>

#include <net/if.h>
#include <net/pfvar.h>

#include "globals.h"
#include "service.h"
#include "vsvc.h"
#include "printers.h"

void print_service(struct service_t *s) {
	printf("===================================\n");
	printf("Real Address: %s\n", inet_ntoa(getservice_inaddr(s)));
	printf("Real Port: %d\n", getservice_port(s));

	printf("Polltype: ");
	if (s->polltype & SVCPOLL_PING) printf("SVCPOLL_PING|");
	if (s->polltype & SVCPOLL_TCP) printf("SVCPOLL_TCP|");
	if (s->polltype & SVCPOLL_HTTPGET) printf("SVCPOLL_HTTPGET|");
	if (s->polltype & SVCPOLL_HTTPHEAD) printf("SVCPOLL_HTTPHEAD|");
	if (s->polltype & SVCPOLL_HTTPPOST) printf("SVCPOLL_HTTPPOST|");
	if (s->polltype & SVCPOLL_EXPECT) printf("SVCPOLL_EXPECT");
	printf("\n");
	if (s->polltype & (SVCPOLL_TCP)) {
		printf("TCP Expect Information: ");
		printf("Send=%s,", s->poll_probe.data);
		printf("Expect=%s", s->poll_response.data);
		printf("\n");
	}
	if (s->polltype & (SVCPOLL_HTTPGET|SVCPOLL_HTTPHEAD|SVCPOLL_HTTPPOST)) {
		printf("HTTP Information: ");
		printf("URL=%s,", s->poll_probe.data);
		printf("Expect=%s", s->poll_response.data);
		printf("\n");
	}
	printf("Lock Status: %s\n", (pthread_mutex_trylock(&s->lock) ? "Locked" : "Unlocked" ));
	pthread_mutex_unlock(&s->lock);
	printf("Status: ");
	if (s->status & SVCSTATUS_UP) printf("Up/"); else printf("Down/");
	if (s->status & SVCSTATUS_ACTIVE) printf("Active"); else printf("Inactive");
	printf("\n");
	printf("---------------------\n");
}

void print_vsvc(struct vsvc_t *v) {
	int i;
	printf("================================================\n");
	printf("Virtual Service #%d Settings\n", v->id);
	printf("------------------------------------------------\n");
	printf("Id: %u\n", v->id);
	printf("Rule Number: %u\n", v->rule_nr);
	printf("Number of Real Services: %u\n", v->services_len);
	printf("Status: ");
	printf(((vsvc_getstatus(v) & VSVCSTATUS_ACTIVE)) ? "Active" : "Inactive");
	printf(",");
	printf(((vsvc_getstatus(v) & VSVCSTATUS_UP)) ? "Up" : "Down");
	printf("\n");
	printf("Virtual Address: %s\n", inet_ntoa(vsvc_getinaddr(v)));
	printf("Virtual Port: %d\n", vsvc_getport(v));
	printf("Lock Status: %s\n", (pthread_mutex_trylock(&v->lock) ? "Locked" : "Unlocked" ));
	pthread_mutex_unlock(&v->lock);
	printf("Sitedown Address: %s\n", inet_ntoa(v->sitedown.sin_addr));
	printf("Sitedown Port: %d\n", (int) v->sitedown.sin_port);
	
	printf("-------------------------------------\n");
	for (i = 0; i < v->services_len; i++) {
		printf("Real Service #%d\n", i);
		print_service(v->services[i]);
	}
}

/*
void print_pfioc_rule(struct pfioc_rule *p) { 
	printf(" */

/*
 * Copyright (c) 2004 Camiel Dobbelaar, <cd@sentia.nl>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/tree.h>

#include <net/if.h>
#include <net/pfvar.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/tcp_fsm.h>

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "filter.h"
#include "state.h"

static SPLAY_HEAD(statetree, state) stateroot;

static int statecompare(struct state *, struct state *);

static int numstates;

static int
statecompare(struct state *a, struct state *b)
{
	int diff;

	if (a->s_port > b->s_port)
		return (1);
	if (a->s_port < b->s_port)
		return (-1);

	diff = memcmp(&a->ip_src, &b->ip_src, sizeof a->ip_src);
	if (diff != 0)
		return (diff);

	diff = memcmp(&a->ip_dst, &b->ip_dst, sizeof a->ip_dst);
	if (diff != 0)
		return (diff);

	if (a->d_port > b->d_port)
		return (1);
	if (a->d_port < b->d_port)
		return (-1);

	return (0);
}

SPLAY_PROTOTYPE(statetree, state, node, statecompare)
SPLAY_GENERATE(statetree, state, node, statecompare)

void
state_init(void)
{
	SPLAY_INIT(&stateroot);
	numstates = 0;
}

struct state *
state_new(struct ip *ip, struct tcphdr *tcp)
{
	struct state *s;
        static u_int32_t id = 1;

	if (numstates >= MAXSTATES)
		return (NULL);

	s = calloc(1, sizeof(struct state));
	if (s == NULL)
		return (NULL);

        s->id = id++;
	memcpy(&s->ip_src, &ip->ip_src, sizeof s->ip_src);
	memcpy(&s->ip_src_real, &ip->ip_src, sizeof s->ip_src_real);
	memcpy(&s->ip_dst, &ip->ip_dst, sizeof s->ip_dst);
	s->s_port = tcp->th_sport;
	s->d_port = tcp->th_dport;
	s->tcps = 0;
	s->state_ts = time(NULL);
	s->rule_ts = 0;
	s->clientbuf = NULL;
	s->clientbuflen = 0;

	SPLAY_INSERT(statetree, &stateroot, s);
	numstates++;

	return (s);
}

struct state *
state_find(struct ip *ip, struct tcphdr *tcp, int *isclient)
{
	struct state *n, s;
	int i;
	
	/*
	 * Educated guess: the client has the higher numbered port.
	 */
	if (tcp->th_sport > tcp->th_dport)
		*isclient = 1;
	else
		*isclient = 0;

	memset(&s, 0, sizeof s);
	for (i = 0; i < 2; i++) {
		if (*isclient) {
			memcpy(&s.ip_src, &ip->ip_src, sizeof s.ip_src);
			memcpy(&s.ip_dst, &ip->ip_dst, sizeof s.ip_dst);
			s.s_port = tcp->th_sport;
			s.d_port = tcp->th_dport;
		} else {
			memcpy(&s.ip_src, &ip->ip_dst, sizeof s.ip_src);
			memcpy(&s.ip_dst, &ip->ip_src, sizeof s.ip_dst);
			s.s_port = tcp->th_dport;
			s.d_port = tcp->th_sport;
		}

		n = SPLAY_FIND(statetree, &stateroot, &s);
		if (n != NULL)
			return (n);

		*isclient = !(*isclient);
	}

	return (NULL);
}

void
state_remove(struct state *s)
{
	SPLAY_REMOVE(statetree, &stateroot, s);
	numstates--;

	if (s->rule_ts != 0)
		filter_remove(s->id);
	if (s->clientbuf != NULL)
		free(s->clientbuf);

	free(s);
}

int
state_purge(int all)
{
	struct state *n, *s;
	time_t now;
	
	time(&now);

	for (s = SPLAY_MIN(statetree, &stateroot); s; s = n) {
		n = SPLAY_NEXT(statetree, &stateroot, s);

		if (all)
			state_remove(s);

		else if (s->tcps == TCPS_SYN_SENT &&
		    (now - s->state_ts > SYN_TIMEOUT))
			state_remove(s);

		else if (s->tcps > TCPS_SYN_SENT &&
		    !filter_lookup(&s->ip_src, &s->ip_dst, s->s_port,
		    s->d_port, &s->ip_src_real))
			state_remove(s);

		else if (s->rule_ts && (now - s->rule_ts > RULE_TIMEOUT)) {
			filter_remove(s->id);
			s->rule_ts = 0;
		}
	}
	
	return (numstates);
}

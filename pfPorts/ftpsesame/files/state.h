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

#define MAXSTATES       1000
#define SYN_TIMEOUT     30
#define RULE_TIMEOUT    180

struct state {
	SPLAY_ENTRY(state) node;
	u_int32_t	id;
	struct in_addr	ip_src;
	struct in_addr	ip_src_real;
	struct in_addr	ip_dst;
	u_int16_t	s_port;
	u_int16_t	d_port;
	int		tcps;
	time_t		state_ts;
	time_t		rule_ts;
	char		*clientbuf;
	size_t		clientbuflen;
};

void		 state_init(void);
struct state	*state_new(struct ip *, struct tcphdr *);
struct state	*state_find(struct ip *, struct tcphdr *, int *);
void		 state_remove(struct state *);
int		 state_purge(int);

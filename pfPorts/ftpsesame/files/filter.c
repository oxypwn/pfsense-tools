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

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>

#include <net/if.h>
#include <net/pfvar.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include <err.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "filter.h"

static struct pfioc_pooladdr	pfp;
static struct pfioc_rule	pfr;
static struct pfioc_trans	pft;
static struct pfioc_trans_e	pfte;
static int dev;

void
filter_init(char *qname, char *tagname)
{
	struct pf_status status;

	dev = open("/dev/pf", O_RDWR);	
	if (dev == -1)
		err(1, "/dev/pf");
	if (ioctl(dev, DIOCGETSTATUS, &status) == -1)
		err(1, "DIOCGETSTATUS");
	if (!status.running)
		errx(1, "pf is disabled");

	/*
	 * Initialize the structs for filter_allow.
	 */

	memset(&pfp, 0, sizeof pfp);
	memset(&pfr, 0, sizeof pfr);
	memset(&pft, 0, sizeof pft);
	memset(&pfte, 0, sizeof pfte);

	pft.size = 1;
	pft.esize = sizeof pfte;
	pft.array = &pfte;
	pfte.rs_num = PF_RULESET_FILTER;

	/*
	 * pass [quick] log inet proto tcp \
	 *     from $src/32 to $dst/32 port = $d_port flags S/SAFR keep state
	 *     [tag tagname] [queue qname]
	 */
	pfr.rule.action = PF_PASS;
	if (tagname == NULL)
		pfr.rule.quick = 1;
	pfr.rule.log = 1;
	pfr.rule.af = AF_INET;		
	pfr.rule.proto = IPPROTO_TCP;
	pfr.rule.src.addr.type = PF_ADDR_ADDRMASK;
	memset(&pfr.rule.src.addr.v.a.mask.v4, 255, 4);
	pfr.rule.dst.addr.type = PF_ADDR_ADDRMASK;
	memset(&pfr.rule.dst.addr.v.a.mask.v4, 255, 4);
	pfr.rule.dst.port_op = PF_OP_EQ;
	pfr.rule.keep_state = 1;
	pfr.rule.flags = TH_SYN;
	pfr.rule.flagset = (TH_SYN|TH_ACK|TH_FIN|TH_RST);
	if (tagname != NULL)
		strlcpy(pfr.rule.tagname, tagname, sizeof pfr.rule.tagname);
	if (qname != NULL)
		strlcpy(pfr.rule.qname, qname, sizeof pfr.rule.qname);
}

int
filter_allow(u_int32_t id, struct in_addr *src, struct in_addr *src2,
    struct in_addr *dst, u_int16_t d_port)
{
	char an[PF_ANCHOR_NAME_SIZE];

	/* The structs are initialized in filter_init. */

	snprintf(an, PF_ANCHOR_NAME_SIZE, "%s/%d.%d", FTPSESAME_ANCHOR,
	    getpid(), id);
	strlcpy(pfp.anchor, an, PF_ANCHOR_NAME_SIZE);
	strlcpy(pfr.anchor, an, PF_ANCHOR_NAME_SIZE);
	strlcpy(pfte.anchor, an, PF_ANCHOR_NAME_SIZE);
	
	if (ioctl(dev, DIOCXBEGIN, &pft) == -1)
		return (0);
	pfr.ticket = pfte.ticket;

	if (ioctl(dev, DIOCBEGINADDRS, &pfp) == -1)
		return (0);
	pfr.pool_ticket = pfp.ticket;

	if (src != NULL && dst != NULL && d_port != 0) {
		memcpy(&pfr.rule.src.addr.v.a.addr.v4, src, 4);
		memcpy(&pfr.rule.dst.addr.v.a.addr.v4, dst, 4);
		pfr.rule.dst.port[0] = htons(d_port);
		if (ioctl(dev, DIOCADDRULE, &pfr) == -1)
			return (0);

		if (src2 != NULL) {
			memcpy(&pfr.rule.src.addr.v.a.addr.v4, src2, 4);
			if (ioctl(dev, DIOCADDRULE, &pfr) == -1)
				return (0);
		}
	}

	if (ioctl(dev, DIOCXCOMMIT, &pft) == -1)
		return (0);
	
	return (1);
}

int
filter_remove(u_int32_t id)
{
	return (filter_allow(id, NULL, NULL, NULL, 0));
}

int
filter_lookup(struct in_addr *src, struct in_addr *dst, u_int16_t s_port,
    u_int16_t d_port, struct in_addr *src_real)
{
	struct pfioc_natlook pnl;
	int r;

	memset(&pnl, 0, sizeof pnl);
	pnl.af = AF_INET;
	memcpy(&pnl.saddr.v4, src, sizeof pnl.saddr.v4);
	memcpy(&pnl.daddr.v4, dst, sizeof pnl.daddr.v4);
	pnl.proto = IPPROTO_TCP;
	pnl.sport = s_port;
	pnl.dport = d_port;
	pnl.direction = PF_IN;

	/*
	 * DIOCNATLOOK does not handle PF_INOUT, so we have to check
	 * both directions ourselves.
	 */
	r = ioctl(dev, DIOCNATLOOK, &pnl);
	if (r == -1 && errno == ENOENT) {
		pnl.direction = PF_OUT;
		r = ioctl(dev, DIOCNATLOOK, &pnl);
	}
	if (r == -1)
		return (0);

	/* Copy the real source address if there is NAT involved. */
	if (memcmp(&pnl.saddr.v4, &pnl.rsaddr.v4, sizeof pnl.saddr.v4) != 0)
		memcpy(src_real, &pnl.rsaddr.v4, sizeof src_real);

	return (1);
}

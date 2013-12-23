/*	$NetBSD: print-tcp.c,v 1.9 2007/07/26 18:15:12 plunky Exp $	*/

/*
 * Copyright (c) 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997
 *	The Regents of the University of California.  All rights reserved.
 *
 * Copyright (c) 1999-2004 The tcpdump.org project
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that: (1) source code distributions
 * retain the above copyright notice and this paragraph in its entirety, (2)
 * distributions including binary code include the above copyright notice and
 * this paragraph in its entirety in the documentation or other materials
 * provided with the distribution, and (3) all advertising materials mentioning
 * features or use of this software display the following acknowledgement:
 * ``This product includes software developed by the University of California,
 * Lawrence Berkeley Laboratory and its contributors.'' Neither the name of
 * the University nor the names of its contributors may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sbuf.h>
#include <netinet/in.h>
#include <netinet/tcp.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"

/* These tcp optinos do not have the size octet */
#define ZEROLENOPT(o) ((o) == TCPOPT_EOL || (o) == TCPOPT_NOP)

#define TCPOPT_WSCALE           3       /* window scale factor (rfc1323) */
#define TCPOPT_SACKOK           4       /* selective ack ok (rfc2018) */
#define TCPOPT_SACK             5       /* selective ack (rfc2018) */
#define TCPOPT_ECHO             6       /* echo (rfc1072) */
#define TCPOPT_ECHOREPLY        7       /* echo (rfc1072) */
#define TCPOPT_TIMESTAMP        8       /* timestamp (rfc1323) */
#define    TCPOLEN_TIMESTAMP            10
#define    TCPOLEN_TSTAMP_APPA          (TCPOLEN_TIMESTAMP+2) /* appendix A */
#define TCPOPT_CC               11      /* T/TCP CC options (rfc1644) */
#define TCPOPT_CCNEW            12      /* T/TCP CC options (rfc1644) */
#define TCPOPT_CCECHO           13      /* T/TCP CC options (rfc1644) */
#define TCPOPT_SIGNATURE        19      /* Keyed MD5 (rfc2385) */
#define    TCPOLEN_SIGNATURE            18
#define TCPOPT_AUTH             20      /* Enhanced AUTH option */
#define TCPOPT_UTO              28      /* tcp user timeout (rfc5482) */

struct tok tcp_option_values[] = {
        { TCPOPT_EOL, "eol" },
        { TCPOPT_NOP, "nop" },
        { TCPOPT_MAXSEG, "mss" },
        { TCPOPT_WSCALE, "wscale" },
        { TCPOPT_SACKOK, "sackOK" },
        { TCPOPT_SACK, "sack" },
        { TCPOPT_ECHO, "echo" },
        { TCPOPT_ECHOREPLY, "echoreply" },
        { TCPOPT_TIMESTAMP, "TS" },
        { TCPOPT_CC, "cc" },
        { TCPOPT_CCNEW, "ccnew" },
        { TCPOPT_CCECHO, "" },
        { TCPOPT_SIGNATURE, "md5" },
        { TCPOPT_AUTH, "enhanced auth" },
        { TCPOPT_UTO, "uto" },
        { 0, NULL }
};

void
tcp_print(struct sbuf *sbuf, register const u_char *bp, register u_int length,
	  register const u_char *bp2)
{
        register const struct tcphdr *tp;
        register const struct ip *ip;
        register u_char flags;
        register u_int hlen;
        register char ch;
        u_int16_t sport, dport, win, urp;
        u_int32_t seq, ack;
#ifdef INET6
        register const struct ip6_hdr *ip6;
#endif

        tp = (struct tcphdr *)bp;

        hlen = (tp->th_off & 0x0f) * 4;
        if (hlen < sizeof(*tp)) {
                sbuf_printf(sbuf, "errormsg='tcp %d [bad hdr length %u - too short < %lu]' ",
                             length - hlen, hlen, (unsigned long)sizeof(*tp));
                return;
        }

        ip = (struct ip *)bp2;
#ifdef INET6
        if (IP_V(ip) == 6)
                ip6 = (struct ip6_hdr *)bp2;
        else
                ip6 = NULL;
#endif /*INET6*/
        ch = '\0';
        sport = ntohs(EXTRACT_16BITS(&tp->th_sport));
        dport = ntohs(EXTRACT_16BITS(&tp->th_dport));

	sbuf_printf(sbuf, "srcport=%u dstport=%u ", sport, dport);

        seq = EXTRACT_32BITS(&tp->th_seq);
        ack = EXTRACT_32BITS(&tp->th_ack);
        win = EXTRACT_16BITS(&tp->th_win);
        urp = EXTRACT_16BITS(&tp->th_urp);

        flags = tp->th_flags;
        sbuf_printf(sbuf, "flags=%s%s%s", flags & TH_FIN ? "F" : "", flags & TH_SYN ? "S" : "", flags & TH_RST ? "R" : "");
        sbuf_printf(sbuf, "%s%s%s", flags & TH_PUSH ? "P" : "", flags & TH_ACK ? "A" : "", flags & TH_URG ? "U" : "");
        sbuf_printf(sbuf, "%s%s ", flags & TH_ECE ? "E" : "", flags & TH_CWR ? "C" : "");

        if (hlen > length) {
                sbuf_printf(sbuf, "errormsg='[bad hdr length %u - too long, > %u]' ",
                             hlen, length);
                return;
        }

        length -= hlen;
        if (length > 0 || flags & (TH_SYN | TH_FIN | TH_RST)) {
                if (length > 0)
                        sbuf_printf(sbuf, "seq=%u:%u ", seq, seq + length);
		else
			sbuf_printf(sbuf, "seq=%u ", seq);
        }

        if (flags & TH_ACK) {
                sbuf_printf(sbuf, "ack=%u ", ack);
        }

        sbuf_printf(sbuf, "win=%d ", win);

        if (flags & TH_URG)
                sbuf_printf(sbuf, "urg=%d ", urp);
        /*
         * Handle any options.
         */
        if (hlen > sizeof(*tp)) {
                register const u_char *cp;
                register u_int opt, datalen;
                register u_int len;

                hlen -= sizeof(*tp);
                cp = (const u_char *)tp + sizeof(*tp);
                sbuf_printf(sbuf, "options=[");
                while (hlen > 0) {
                        if (ch != '\0')
                                sbuf_printf(sbuf, "%c", ch);
                        opt = *cp++;
                        if (ZEROLENOPT(opt))
                                len = 1;
                        else {
                                len = *cp++;	/* total including type, len */
                                if (len < 2 || len > hlen)
                                        goto bad;
                                --hlen;		/* account for length byte */
                        }
                        --hlen;			/* account for type byte */
                        datalen = 0;

                        sbuf_printf(sbuf, "%s", code2str(tcp_option_values, "Unknown Option %u", opt));

                        /* Account for data printed */
                        cp += datalen;
                        hlen -= datalen;

                        /* Check specification against observed length */
                        ++datalen;			/* option octet */
                        if (!ZEROLENOPT(opt))
                                ++datalen;		/* size octet */
                        ch = ';';
                        if (opt == TCPOPT_EOL)
                                break;
                }
                sbuf_printf(sbuf, "] ");
        }

        /*
         * Print length field before crawling down the stack.
         */
        sbuf_printf(sbuf, "length=%u ", length);

        if (length <= 0)
                return;

        return;
 bad:
        sbuf_printf(sbuf, "[bad opt]");
        if (ch != '\0')
                sbuf_printf(sbuf, ">");
        return;
}

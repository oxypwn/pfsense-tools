/* $Id$ */

/*
 * Copyright (c) 2005 Henrik Gustafsson <henrik.gustafsson@fnord.se>
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

#ifndef _IOCTL_HELPERS_H_
#define _IOCTL_HELPERS_H_

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <net/if.h>

#include <net/pfvar.h>

int	radix_get_astats(int dev, struct pfr_astats **astats, const struct pfr_table *filter, int flags);
int	radix_get_tstats(int dev, struct pfr_tstats **tstats, const struct pfr_table *filter, int flags);
int	radix_get_tables(int dev, struct pfr_table **tables, const struct pfr_table *filter, int flags);
int	radix_del_addrs(int dev, const struct pfr_table *table, struct pfr_addr *addrs, int addr_count, int flags);
int	get_states(int dev, struct pf_state **states);

#endif /*_IOCTL_HELPERS_H_*/

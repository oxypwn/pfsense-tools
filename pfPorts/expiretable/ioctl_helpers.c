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

#include "ioctl_helpers.h"
#include <sys/ioctl.h>
#include <stdlib.h>
#include <string.h>

int
radix_ioctl(int dev, unsigned long request, struct pfioc_table *pt) {
	void *inbuf, *newinbuf;
	size_t len = 0;
	inbuf = newinbuf = NULL;

	for(;;) {
		pt->pfrio_size = len;
		if (len) {
			newinbuf = realloc(inbuf, len * pt->pfrio_esize);
			if (newinbuf == NULL) {
				if (inbuf != NULL) {
					free(inbuf);
					inbuf = newinbuf = NULL;
					return (-1);
				}
			}
			pt->pfrio_buffer = newinbuf;
		}
		if (ioctl(dev, request, pt) < 0) {
			if (inbuf != NULL) {
				free(inbuf);
				inbuf = newinbuf = NULL;
			}
			return (-1);
		}
		if (pt->pfrio_size + 1 < len)
			break;
		if (pt->pfrio_size == 0)
			return (0);
		if (len == 0)
			len = pt->pfrio_size;
		len *= 2;
	}

	return pt->pfrio_size;
}

int
radix_get_astats(int dev, struct pfr_astats **astats, const struct pfr_table *filter, int flags) {
	struct pfioc_table pt;

	memset(&pt, 0, sizeof(struct pfioc_table));
	pt.pfrio_esize = sizeof(struct pfr_astats);
	pt.pfrio_flags = flags;
	
	if (filter != NULL) {
		pt.pfrio_table = *filter;
		pt.pfrio_table.pfrt_flags = 0; /* No flags are allowed in this context */
	}

	if (radix_ioctl(dev, DIOCRGETASTATS, &pt) < 0)
		return (-1);

	*astats = (struct pfr_astats *)pt.pfrio_buffer;
	return pt.pfrio_size;
}

int
radix_del_addrs(int dev, const struct pfr_table *table, struct pfr_addr *addrs, int addr_count, int flags) {
	struct pfioc_table pt;

	memset(&pt, 0, sizeof(struct pfioc_table));
	pt.pfrio_size = addr_count;
	pt.pfrio_esize = sizeof(struct pfr_addr);
	pt.pfrio_flags = flags;
	
	pt.pfrio_table = *table;
	pt.pfrio_buffer = addrs;
	
	if (ioctl(dev, DIOCRDELADDRS, &pt) < 0) {
		return (-1);
	}
	else {
		return pt.pfrio_ndel;
	}
}

int
radix_get_tables(int dev, struct pfr_table **tables, const struct pfr_table *filter, int flags) {
	struct pfioc_table pt;

	memset(&pt, 0, sizeof(struct pfioc_table));
	pt.pfrio_esize = sizeof(struct pfr_table);
	pt.pfrio_flags = flags;
	if (filter != NULL)
		pt.pfrio_table = *filter;

	if (radix_ioctl(dev, DIOCRGETTABLES, &pt) < 0)
		return (-1);

	*tables = (struct pfr_table *)pt.pfrio_buffer;
	return pt.pfrio_size;
}

int
radix_get_tstats(int dev, struct pfr_tstats **tstats, const struct pfr_table *filter, int flags) {
	struct pfioc_table pt;

	memset(&pt, 0, sizeof(struct pfioc_table));
	pt.pfrio_esize = sizeof(struct pfr_tstats);
	pt.pfrio_flags = flags;
	if (filter != NULL)
		pt.pfrio_table = *filter;


	if (radix_ioctl(dev, DIOCRGETTSTATS, &pt) < 0)
		return (-1);

	*tstats = (struct pfr_tstats *)pt.pfrio_buffer;
	return pt.pfrio_size;
}


int
get_states(int dev, struct pf_state **states) { 
	struct pfioc_states ps;
	caddr_t inbuf, newinbuf;
	size_t len = 0;

	inbuf = newinbuf = NULL;
	memset(&ps, 0, sizeof(struct pfioc_states));
	*states = NULL;	
	for (;;) {
		ps.ps_len = len;
		if (len) {
			newinbuf = realloc(inbuf, len);
			if (newinbuf == NULL) {
				if (inbuf != NULL) {
					free(inbuf);
					inbuf = newinbuf = NULL;
					return (-1);
				}
			}
			ps.ps_buf = inbuf = newinbuf;
		}
		if (ioctl(dev, DIOCGETSTATES, &ps) < 0) {
			if (inbuf != NULL) {
				free(inbuf);
				inbuf = newinbuf = NULL;
			}
			return (-1);
		}
		if (ps.ps_len + sizeof(struct pfioc_states) < len)
			break; /* We have states! */
		if (ps.ps_len == 0)
			return (0); /* No states available */
		if (len == 0)
			len = ps.ps_len;
		len *= 2;
	}
		
	*states = ps.ps_states;
	return ps.ps_len / sizeof(struct pf_state);
}

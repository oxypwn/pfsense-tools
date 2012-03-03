/*
 * This file is in the public domain.
 *
 * $FreeBSD: ports/net/openntpd/files/adjfreq.c,v 1.1 2009/08/03 13:58:59 naddy Exp $
 */

#include <sys/types.h>
#include <sys/timex.h>

#include "ntpd.h"

int
adjfreq(const int64_t *freq, int64_t *oldfreq)
{
	struct timex t;

	if (oldfreq) {
		t.modes = 0;
		if (ntp_adjtime(&t) == -1)
			return -1;
		*oldfreq = (int64_t)t.freq * (1<<16) * 1000;
	}
	if (freq) {
		t.modes = MOD_FREQUENCY;
		t.freq = *freq / ((1<<16) * 1000);
		if (ntp_adjtime(&t) == -1)
			return -1;
	}
	return 0;
}

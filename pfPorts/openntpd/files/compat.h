/*
 * This file is in the public domain.
 *
 * $FreeBSD: ports/net/openntpd/files/compat.h,v 1.1 2009/08/03 13:58:59 naddy Exp $
 */

#ifndef SA_LEN
# define SA_LEN(x)	((x)->sa_len)
#endif

#ifndef EAI_NODATA
# define EAI_NODATA	EAI_NONAME
#endif

#ifndef __dead
# define __dead
#endif

#undef HAVE_SENSORS

/* adjfreq.c */
int			adjfreq(const int64_t *, int64_t *);

/* arc4random.c */
u_int32_t		arc4random_uniform(u_int32_t);

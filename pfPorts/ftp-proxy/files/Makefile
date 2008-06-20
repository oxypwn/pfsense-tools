#	$OpenBSD: Makefile,v 1.3 2006/11/26 11:31:13 deraadt Exp $

PROG=	ftp-proxy
SRCS=	ftp-proxy.c filter.c
MAN=

CFLAGS+= -I${.CURDIR}
CFLAGS+= -Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith \
         -Wno-uninitialized
DPADD+= ${LIBEVENT}

LIB_DEPENDS=    event-1.3d:${PORTSDIR}/devel/libevent
LDADD+= -L/usr/local/lib -levent 
LIBEVENT_LIB	= -L${LOCALBASE}/lib -levent 

DESTDIR=/usr/local/sbin/

.include <bsd.prog.mk>

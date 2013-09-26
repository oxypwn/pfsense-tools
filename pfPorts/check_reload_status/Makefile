# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	check_reload_status
PORTVERSION=	0.0.3
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty
NO_STAGE=	yes

MAINTAINER?=	eri@pfsense.org
COMMENT?=	run various pfSense scripts on event.

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}
CFLAGS+=	-I/usr/local/include -L/usr/local/lib 

LIB_DEPENDS=   event:${PORTSDIR}/devel/libevent

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -levent -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c
	${CC} ${CFLAGS} -o ${WRKSRC}/pfSctl ${FILESDIR}/pfSctl.c

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/
	${INSTALL_PROGRAM} ${WRKSRC}/pfSctl ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

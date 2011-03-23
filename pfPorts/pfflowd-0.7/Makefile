# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	pfflowd
PORTVERSION=	0.7
PORTREVISION?=	0
CATEGORIES?=	net
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@pfsense.org
COMMENT=        Convert pfsync states to NetFlow datagrams

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}
CFLAGS+=	-I/usr/local/include -L/usr/local/lib 

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} -g -static -o work/pfflowd files/pfflowd.o files/pidfile.o files/nf9.o -lpcap -lutil

do-install:
	${INSTALL_PROGRAM} work/${PORTNAME} ${PREFIX}/${WHERE}/

	
.include <bsd.port.mk>

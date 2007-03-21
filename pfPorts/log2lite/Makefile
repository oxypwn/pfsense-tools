# New ports collection makefile for:	log2lite
# Date created:		27 June 2005
# Whom:			Scott Ullrich (geekgod@geekgod.com)
#
# $FreeBSD: $

PORTNAME=	log2lite
PORTVERSION=	0.8
CATEGORIES=	sysutils
#DISTNAME=	${PORTNAME}-${PORTVERSION}
PORTREVISION?=  0
MASTER_SITES=   # empty
DISTFILES=      # none
EXTRACT_ONLY=   # empty

MAINTAINER=	geekgod@geekgod.com
COMMENT=	Logs to sqlite database

LIB_DEPENDS=	sqlite3:${PORTSDIR}/databases/sqlite3

MAN8=		log2lite.8

PLIST_FILES=    sbin/log2lite

.include <bsd.port.pre.mk>

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -static -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c -I/usr/local/include/ -L/usr/local/lib -lsqlite3 -lpthread

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/log2lite ${PREFIX}/sbin
	#${INSTALL_MAN} ${WRKSRC}/log2lite.8 ${PREFIX}/man/man8

clean:
	rm -rf ${WRKSRC}
.include <bsd.port.post.mk>

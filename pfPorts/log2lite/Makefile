# New ports collection makefile for:	log2lite
# Date created:		27 June 2005
# Whom:			Scott Ullrich (geekgod@geekgod.com)
#
# $FreeBSD: $

PORTNAME=	log2lite
PORTVERSION=	0.8
CATEGORIES=	sysutils
MASTER_SITES=   # empty
DISTFILES=      # none
EXTRACT_ONLY=   # empty

MAINTAINER=	geekgod@geekgod.com
COMMENT=	Logs to sqlite database

LIB_DEPENDS=	libsqlite3.so:${PORTSDIR}/databases/sqlite3

PLIST_FILES=    sbin/log2lite

.include <bsd.port.pre.mk>

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -static -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c -I/usr/local/include/ -L/usr/local/lib -lsqlite3 -lpthread

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/log2lite ${STAGEDIR}${PREFIX}/sbin

.include <bsd.port.post.mk>

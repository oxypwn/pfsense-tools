# New ports collection makefile for:	pftpx
# Date created:		27 June 2005
# Whom:			Scott Ullrich (geekgod@geekgod.com)
#
# $FreeBSD: $

PORTNAME=	pftpx
PORTVERSION=	0.8
PORTREVISION=	1
CATEGORIES=	net
MASTER_SITES=	http://www.sentia.org/downloads/
DISTNAME=	${PORTNAME}-${PORTVERSION}

BUILD_DEPENDS=	${LOCALBASE}/lib/libevent.a:${PORTSDIR}/devel/libevent
RUN_DEPENDS=	${LOCALBASE}/lib/libevent.a:${PORTSDIR}/devel/libevent

MAINTAINER=	geekgod@geekgod.com
COMMENT=	Much enhanced ftp proxy for pf that supports most ftp protocols

MAN8=		pftpx.8

MANCOMPRESSED=	no

.include <bsd.port.pre.mk>

.if ${OSVERSION} < 500000
IGNORE=		Only for 5.0 and above
.endif

.if ${OSVERSION} < 502116
MAKE_ARGS=	LOCALBASE="${PREFIX}" OSLEVEL=34
.if defined(WITH_ALTQ) && (${WITH_ALTQ} == "yes")
CFLAGS+=	-DHAVE_ALTQ=1
.endif
.elif ${OSVERSION} < 600025
MAKE_ARGS=	LOCALBASE="${PREFIX}" OSLEVEL=35
CFLAGS+=	-DHAVE_ALTQ=1 -DHAVE_RULE_ANCHOR=1
.else
MAKE_ARGS=	LOCALBASE="${PREFIX}" OSLEVEL=37
CFLAGS+=	-DHAVE_ALTQ=1
.endif

.if ${OSVERSION} < 502106
BUILD_DEPENDS=	${LOCALBASE}/include/pf/net/pfvar.h:${PORTSDIR}/security/pf
.if defined(WITH_ALTQ) && (${WITH_ALTQ} == "yes")
BUILD_DEPENDS+=${LOCALBASE}/include/pf/altq/altq.h:${PORTSDIR}/security/pf
.endif
RUN_DEPENDS=	${LOCALBASE}/modules/pf.ko:${PORTSDIR}/security/pf

CFLAGS+=	-I${LOCALBASE}/include/pf
.endif

PLIST_FILES=	sbin/pftpx

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/pftpx ${PREFIX}/sbin
	${INSTALL_MAN} ${WRKSRC}/pftpx.8 ${PREFIX}/man/man8

.include <bsd.port.post.mk>

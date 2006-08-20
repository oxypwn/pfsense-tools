# New ports collection makefile for:	miniupnpd
# Date created:		20 August 2006
# Whom:			Seth Mos (seth.mos@xs4all.nl)
#
# $FreeBSD: $

PORTNAME=	miniupnpd
PORTVERSION=	20060721
CATEGORIES=	upnp
MASTER_SITES=	http://miniupnp.free.fr/files/download.php?file=
DISTNAME=	${PORTNAME}${PORTVERSION}

MAINTAINER=	seth.mos@xs4all.nl
COMMENT=	UPnP daemon for firewall interface

LIB_DEPENDS=	event-1.2:${PORTSDIR}/devel/libevent

PLIST_FILES=    sbin/miniupnpd

.include <bsd.port.pre.mk>

.if ${OSVERSION} < 500000
IGNORE=		only for 5.0 and above
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

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/miniupnpd ${PREFIX}/sbin

.include <bsd.port.post.mk>

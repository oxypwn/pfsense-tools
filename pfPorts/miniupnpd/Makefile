# New ports collection makefile for:	miniupnpd
# Date created:		20 August 2006
# Whom:			Seth Mos (seth.mos@xs4all.nl)
#
# $FreeBSD: $

PORTNAME=		miniupnpd
PORTVERSION=	1.2.pf1
CATEGORIES=		net
MASTER_SITES=	http://miniupnp.free.fr/files/
DISTFILES=		miniupnpd-1.2.tar.gz

MAINTAINER=		seth.mos@xs4all.nl rswagoner@gmail.com
COMMENT=		UPnP daemon for firewall interface

WRKSRC=         ${WRKDIR}/miniupnpd-1.2

PLIST_FILES=    sbin/miniupnpd

.include <bsd.port.pre.mk>

.if ${OSVERSION} < 500000
IGNORE=		only for 5.0 and above
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/miniupnpd ${PREFIX}/sbin

.include <bsd.port.post.mk>

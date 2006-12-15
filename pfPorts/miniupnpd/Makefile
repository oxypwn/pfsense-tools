# New ports collection makefile for:	miniupnpd
# Date created:		20 August 2006
# Whom:			Seth Mos (seth.mos@xs4all.nl)
#
# $FreeBSD: $

PORTNAME=		miniupnpd
PORTVERSION=	20061214
CATEGORIES=		net
MASTER_SITES=	http://miniupnp.free.fr/files/
DISTFILES=		miniupnpd-20061214.tar.gz

MAINTAINER=		seth.mos@xs4all.nl ryan@wgnrs.dynu.com
COMMENT=		UPnP daemon for firewall interface

#WRKSRC=         ${WRKDIR}/${PORTNAME}

PLIST_FILES=    sbin/miniupnpd

.include <bsd.port.pre.mk>

.if ${OSVERSION} < 500000
IGNORE=		only for 5.0 and above
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/miniupnpd ${PREFIX}/sbin

.include <bsd.port.post.mk>

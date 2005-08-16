# New ports collection makefile for:	wol
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	wol
PORTVERSION=	0.7.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR=	ahh

MAINTAINER?=	jebc@c4solutions.net
COMMENT?=	Wake on Lan initiator

WHERE=          bin
PLIST_FILES=    ${WHERE}/${PORTNAME}

GNU_CONFIGURE=	yes

CONFIGURE_ARGS=	--disable-nls

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/src/wol ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

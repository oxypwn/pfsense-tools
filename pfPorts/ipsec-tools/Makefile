# New ports collection makefile for:	wol
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	ipsec-tools
PORTVERSION=	0.6.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR=	${PORTNAME}

MAINTAINER?=	jebc@c4solutions.net
COMMENT?=	Wake on Lan initiator

WHERE=          bin
PLIST_FILES=    ${WHERE}/${PORTNAME}

USE_BZIP2=	yes
GNU_CONFIGURE=	yes

# for gssapi
#RUN_DEPENDS+=	biconv:${PORTSDIR}/converters/iconv

CONFIGURE_ARGS+=--enable-adminport
CONFIGURE_ARGS+=--enable-rc5
CONFIGURE_ARGS+=--enable-idea
#CONFIGURE_ARGS+=--enable-gssapi
CONFIGURE_ARGS+=--enable-hybrid
CONFIGURE_ARGS+=--enable-frag 
CONFIGURE_ARGS+=--enable-stats
CONFIGURE_ARGS+=--enable-dpd
CONFIGURE_ARGS+=--enable-samode-unspec
#do-install:
#	${INSTALL_PROGRAM} ${WRKSRC}/src/wol ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

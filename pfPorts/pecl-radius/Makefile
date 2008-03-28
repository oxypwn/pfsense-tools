# Ports collection makefile for:	pecl-radius
# Date created:				09 March 2005
# Whom:					Antonio Carlos Venancio Junior (<antonio@inf.ufsc.br>)
#
# $FreeBSD: ports/net/pecl-radius/Makefile,v 1.3 2007/07/06 08:12:37 miwi Exp $
#

PORTNAME=	radius
PORTVERSION=	1.2.5
CATEGORIES=	net security pear
MASTER_SITES=	http://pecl.php.net/get/
PKGNAMEPREFIX=	pecl-
EXTRACT_SUFX=	.tgz
DIST_SUBDIR=	PECL

MAINTAINER=	miwi@FreeBSD.org
COMMENT=	Radius client library for PHP

USE_PHP=	yes
USE_PHPEXT=	yes

CONFIGURE_ARGS=	--enable-radius

.if !defined(NOPORTDOCS)
post-install:
	${MKDIR} ${EXAMPLESDIR}
	${INSTALL_DATA} ${WRKSRC}/examples/* ${EXAMPLESDIR}
.endif

.include <bsd.port.mk>

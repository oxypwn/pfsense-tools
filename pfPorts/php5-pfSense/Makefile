# Ports collection makefile for:	pecl-radius
# Date created:				09 March 2005
# Whom:					Antonio Carlos Venancio Junior (<antonio@inf.ufsc.br>)
#
# $FreeBSD: ports/net/pecl-radius/Makefile,v 1.3 2007/07/06 08:12:37 miwi Exp $
#

PORTNAME=	pfSense
PORTVERSION=            0.1
CATEGORIES=             net
MASTER_SITES=           #
DISTFILES=              #
PORTVERSION=
CATEGORIES=
MASTER_SITES=
PKGNAMEPREFIX=	pfSense-

MAINTAINER=	eri@pfsense.org
COMMENT=	Library for getting useful info

USE_PHP=	yes
USE_PHPEXT=	yes

CONFIGURE_ARGS=	--enable-pfSense

extract:
	mkdir -p ${WRKSRC}
	cp files/* ${WRKSRC}

.include <bsd.port.mk>

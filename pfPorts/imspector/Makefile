# New ports collection makefile for:	imspector
# Date created:		02 December 2006
# Whom:			Ryan Wagoner (rswagoner@gmail.com)
#
# $FreeBSD: $

PORTNAME=		imspector
PORTVERSION=	0.3
CATEGORIES=		net
MASTER_SITES=	http://www.imspector.org/downloads/
DISTFILES=		imspector-0.3.tar.gz

HAS_CONFIGURE=	yes
CONFIGURE_ARGS=	--prefix=/usr/local --enable-pf --with-mysql=/usr/local

LIB_DEPENDS=	mysqlclient.15:${PORTSDIR}/databases/mysql51-client

MAINTAINER=		rswagoner@gmail.com
COMMENT=		Instant Messenger transparent proxy with logging capabilities

.include <bsd.port.mk>

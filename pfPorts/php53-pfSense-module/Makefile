# Ports collection makefile for:	pecl-radius
# Date created:				09 March 2005
# Whom:					Antonio Carlos Venancio Junior (<antonio@inf.ufsc.br>)
#
# $FreeBSD: ports/net/pecl-radius/Makefile,v 1.3 2007/07/06 08:12:37 miwi Exp $
#

PORTNAME=	pfSense
PORTVERSION=	0.1
CATEGORIES=	net
MASTER_SITES=	#
DISTFILES=	#
PKGNAMEPREFIX=	php53-
PKGNAMESUFFIX=	-module

MAINTAINER=	eri@pfsense.org
COMMENT=	Library for getting useful info

USE_PHP=	yes
USE_PHPEXT=	yes

# BUILD_DEPENDS+= ${PREFIX}/sbin/named:${PORTSDIR}/dns/bind98
BUILD_DEPENDS+= dhcpd:${PORTSDIR}/net/isc-dhcp42-server

CFLAGS+=	-I/usr/local/include -L/usr/local/lib -I. -DDHCP_INTEGRATION -DIPFW_FUNCTIONS
LDFLAGS+=	-lomapi -ldhcpctl -ldns -lisc 

CONFIGURE_ARGS=	--enable-pfSense

extract:
	if [ ! -d ${PREFIX}/include/isc ]; then \
		echo "Please reinstall isc-dhcp42-server port from pfPorts"; \
		exit 1; \
	fi
	mkdir -p ${WRKSRC}
	cp -r files/* ${WRKSRC}

post-install:
	cp ${WRKSRC}/modules/pfSense.so /usr/local/lib/php/${PHP_EXT_DIR}/

.include <bsd.port.mk>

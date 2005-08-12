# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	php4
PORTVERSION=	4.4.0
PORTREVISION?=	0
CATEGORIES?=	lang devel www
MASTER_SITES=	${MASTER_SITE_PHP:S,$,:release,} \
		http://downloads.php.net/ilia/:rc \
		http://downloads.php.net/jani/:rc
MASTER_SITE_SUBDIR=	distributions/:release
DISTNAME=	php-${PORTVERSION:S/.r/RC/}
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}:release

MAINTAINER?=	jebc@c4solutions.net
COMMENT?=	PHP Scripting Language for pfSense

CONFLICTS=      php4-4* php4-cgi-4* mod_php4-4*
#LATEST_LINK=	${PKGNAMEPREFIX}${PORTNAME}${PKGNAMESUFFIX}

WHERE=          bin
PLIST_FILES=    ${WHERE}/${PORTNAME}

USE_BZIP2=	yes
GNU_CONFIGURE=	yes

WITH_OPENSSL?=	yes
WITH_CURL?=	yes

CONFIGURE_ARGS=	--without-mysql \
		--without-pear \
		--enable-discard-path 

.if defined(WITH_CURL)
LIB_DEPENDS=   curl:${PORTSDIR}/ftp/curl
CONFIGURE_ARGS+=--with-curl
.endif

.if defined(WITH_OPENSSL)
CONFIGURE_ARGS+=--with-openssl
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/sapi/cgi/php ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

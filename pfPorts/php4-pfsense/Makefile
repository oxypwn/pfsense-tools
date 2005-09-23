# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PKGNAMESUFFIX=	-cgi
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

MAINTAINER?=	ale@FreeBSD.org
COMMENT?=	PHP Scripting Language (Apache Module and CLI)

LATEST_LINK=	${PKGNAMEPREFIX}${PORTNAME}${PKGNAMESUFFIX}

LIB_DEPENDS=   curl:${PORTSDIR}/ftp/curl

USE_BZIP2=	yes
GNU_CONFIGURE=	yes
USE_BISON=	yes
USE_REINPLACE=	yes

CONFIGURE_ARGS+=--without-mysql \
		--without-pear \
		--with-openssl \
		--with-curl \
		--enable-force-cgi-redirect \
		--enable-discard-path 

.if !defined(PKGNAMEPREFIX) && !defined(PKGNAMESUFFIX)
PHP_SAPI=	full
WITH_APACHE=	yes
.else
.if !defined(PKGNAMEPREFIX)
PHP_SAPI=	${PKGNAMESUFFIX:S/-//}
.else
PHP_SAPI=	${PKGNAMEPREFIX:S/_//}
WITH_APACHE=	yes
.endif
.endif

EXT_DIR=	20020429
WITH_OPENSSL=	yes

CONFLICTS?=	php4-cli-4* mod_php4-4* php4-cgi-4*
CONFLICTS+=	php5-5* php5-cli-5* mod_php5-5* php5-cgi-5*

.if ${PHP_SAPI} == "cgi"
SAPI_FILE=	bin/php
.endif

.include <bsd.port.pre.mk>


PLIST_SUB+=	SAPI_FILE=${SAPI_FILE}

_PORTSDIR!=	${REALPATH} ${PORTSDIR}
PHP_PORT=	${.CURDIR:S|^${_PORTSDIR}||:S|^/||}

post-patch:
	@${TOUCH} ${WRKSRC}/ext/php_config.h
	@${REINPLACE_CMD} "s|^\(extension_dir\)|; \1|" ${WRKSRC}/php.ini-*

post-build:
	@${ECHO_CMD} "PHP_VER=4" > ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_VERSION=${PORTVERSION}" >> ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_EXT_DIR=${EXT_DIR}" >> ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_PORT=\$${PORTSDIR}/${PHP_PORT}" >> ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_SAPI=${PHP_SAPI}" >> ${WRKDIR}/php.conf
.if defined(WITH_OPENSSL)
	@${ECHO_CMD} "PHP_EXT_INC=openssl" >> ${WRKDIR}/php.conf
.endif

post-install:
	@${INSTALL_DATA} ${WRKSRC}/php.ini-dist ${PREFIX}/etc
	@${INSTALL_DATA} ${WRKSRC}/php.ini-recommended ${PREFIX}/etc
	@${INSTALL_DATA} ${WRKDIR}/php.conf ${PREFIX}/etc
	@${TOUCH} ${PREFIX}/include/php/ext/php_config.h
.if defined(WITH_APACHE)
	@${CAT} ${PKGMESSAGE}
.endif

.include <bsd.port.post.mk>

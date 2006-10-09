# New ports collection makefile for:	php5
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php5/Makefile,v 1.96 2006/05/07 14:47:28 ale Exp $
#

PORTNAME=	php5
PORTVERSION=	5.2.0RC5
#PORTREVISION?=	RC3
CATEGORIES?=	lang devel www
MASTER_SITES=	http://downloads.php.net/%SUBDIR%/
MASTER_SITE_SUBDIR=	ilia
DISTNAME=	php-${PORTVERSION:S/.r/RC/}
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}:release

MAINTAINER?=	ale@FreeBSD.org
COMMENT?=	PHP Scripting Language (Apache Module and CLI)

LATEST_LINK=	${PKGNAMEPREFIX}${PORTNAME}${PKGNAMESUFFIX}

#USE_BZIP2=	yes
.if !defined(PKGNAMESUFFIX)
USE_AUTOTOOLS=	autoconf:259
USE_GETOPT_LONG=yes
LDFLAGS+=	-L${OPENSSLLIB} -lcrypto -lssl
USE_OPENSSL=	yes

CONFIGURE_ARGS=	--with-config-file-scan-dir=${PREFIX}/lib/php \
		--with-regex=php \
		--with-zend-vm=GOTO \
		--with-openssl=${OPENSSLBASE} \
		--with-openssl-dir=${OPENSSLBASE} \
		--with-curl=shared,${LOCALBASE} \
		--with-gettext=shared,${LOCALBASE} \
		--with-zlib=shared \
		--with-zlib-dir=/usr \
		--with-pcre-regex \
		--with-bz2=shared,/usr \
		--without-pear \
		--without-sqlite \
		--without-mysql \
		--disable-all \
		--disable-cli \
		--enable-bcmath=shared \
		--enable-zend-multibyte=shared \
		--enable-reflection=shared \
		--enable-spl=yes \
		--enable-memory-limit=yes \
		--enable-versioning=shared \
		--enable-cgi=yes \
		--enable-fastcgi=yes \
		--enable-force-cgi-redirect=yes \
		--enable-discard-path=yes \
		--enable-libxml=shared \
		--with-libxml-dir=${LOCALBASE} \
		--enable-xml=shared \
		--enable-xmlreader=shared \
		--enable-xmlwriter=shared \
		--enable-mbstring=shared \
		--enable-pcntl=shared \
		--enable-sysvmsg=shared \
		--enable-sysvsem=shared \
		--enable-sysvshm=shared \
		--enable-session=shared \
		--enable-shmop=shared \
		--enable-json=shared \
		--enable-posix=shared \
		--enable-simplexml=shared \
		--enable-tokenizer=shared \
		--enable-ctype=shared \
		--program-prefix=""

USE_GNOME=	libxml2

CONFLICTS=	php4-4*

MAN1=		php-config.1 phpize.1

.include <bsd.port.pre.mk>

PHP_SAPI=	cgi
PLIST_SUB+=	CGI=""

CONFIGURE_ENV=	CFLAGS="${CFLAGS} ${PTHREAD_CFLAGS}" \
		CPPFLAGS="${CPPFLAGS} -I/usr/include -I${LOCALBASE}/include" \
		LDFLAGS="-L/usr/lib -L${LOCALBASE}/lib" \
		LIBS="-L${LOCALBASE}/lib ${PTHREAD_LIBS}"

#CONFIGURE_ENV+=	ac_cv_pthreads_lib="-L/usr/lib -L${LOCALBASE}/lib ${PTHREAD_LIBS} -lpthread" \
#		ac_cv_pthreads_cflags="-I/usr/include ${PTHREAD_CFLAGS}" \
#		pthreads_working="yes"

MAKE_ENV+=	LDFLAGS="${LDFLAGS}"

post-patch:
	@${TOUCH} ${WRKSRC}/ext/php_config.h
	@${REINPLACE_CMD} "s|^\(extension_dir\)|; \1|" ${WRKSRC}/php.ini-*

pre-configure:
	@${CAT} ${WRKSRC}/acinclude.m4 ${WRKSRC}/build/libtool.m4 > ${WRKSRC}/aclocal.m4

post-build:
	@${ECHO_CMD} "PHP_VER=5" > ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_VERSION=${PORTVERSION}" >> ${WRKDIR}/php.conf
	@${ECHO_CMD} "PHP_SAPI=${PHP_SAPI}" >> ${WRKDIR}/php.conf

post-install:
# TODO: This is a hack. It installs the PHP binary to /usr/local/bin
#       cause for some reason it will be build by the PHP distribution
#       but not installed.
	${INSTALL_PROGRAM} ${WRKSRC}/sapi/cgi/php ${PREFIX}/bin
	@${INSTALL_DATA} ${WRKSRC}/php.ini-dist ${PREFIX}/etc
	@${INSTALL_DATA} ${WRKSRC}/php.ini-recommended ${PREFIX}/etc
	@${INSTALL_DATA} ${WRKDIR}/php.conf ${PREFIX}/etc
	@${TOUCH} ${PREFIX}/include/php/ext/php_config.h
# XXX Temporary hack
.if !defined(WITHOUT_CGI) && defined(WITHOUT_CLI)
	@${LN} -sf ${PREFIX}/bin/php-cgi ${PREFIX}/bin/php
.endif

.else
.include "${MASTERDIR}/Makefile.ext"
.endif
.include <bsd.port.post.mk>

# New ports collection makefile for:	libmrss
# Date created:		2006-10-09
# Whom:			Daniel S. Haischt	<me@daniel.stefan.haischt.name>
#
# $Id$
#

PORTNAME=	libmrss
PORTVERSION=	0.13
CATEGORIES=	textproc devel
MASTER_SITES=	http://www2.autistici.org/bakunin/libmrss/

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	mRss is a C library for parsing, writing and creating RSS files or streams.

LIB_DEPENDS=	nxml:${PORTSDIR}/textproc/libnxml

GNU_CONFIGURE=	yes
CONFIGURE_ENV+=	CFLAGS="${CFLAGS} -I/${LOCALBASE}/include" LDFLAGS="${LDFLAGS} -L${LOCALBASE}/lib"

USE_LDCONFIG=	yes

WANT_GNOME=	yes

OPTIONS=	PHPLIB "Compile and install PHP wrapper" Off

.include <bsd.port.pre.mk>

.if defined(WITH_PHPLIB)
USE_PHP=	yes
USE_PHPIZE=	yes
USE_PHPEXT=	yes
PHP_MODNAME=	mrss
BUILD_DEPENDS=	phpize:${PORTSDIR}/lang/php5
PLIST_FILES=	lib/php/extensions/no-debug-non-zts-20060613/mrss.so
.endif

post-install:
.if defined(WITH_PHPLIB)
	cd ${WRKSRC}/phpmrss && \
	${WRKSRC}/phpmrss/phpmrss_install.sh
.endif

.include <bsd.port.post.mk>

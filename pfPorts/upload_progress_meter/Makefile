# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	upload_progress_meter
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	jebc@c4solutions.net
COMMENT?=	reinits ata channel 0

WHERE=		lib/php/extensions/no-debug-non-zts-20020429
PLIST_FILES=    ${WHERE}/${PORTNAME}.so

GNU_CONFIGURE=  yes

PHP_AUTOCONF!=ls /usr/local/bin/autoconf* | head -1 | sed 's:/.*/::'
PHP_AUTOHEADER!=ls /usr/local/bin/autoheader* | head -1 | sed 's:/.*/::'

do-extract:
	mkdir -p ${WRKSRC}
	cp ${FILESDIR}/config.m4 ${WRKSRC}/
	cp ${FILESDIR}/upload_progress_meter.c ${WRKSRC}/
	cd ${WRKSRC} && \
		PHP_AUTOCONF=${PHP_AUTOCONF} \
		PHP_AUTOHEADER=${PHP_AUTOHEADER} \
		phpize

do-install:
	mkdir -p ${PREFIX}/${WHERE}/
	${INSTALL_PROGRAM} ${WRKSRC}/modules/upload_progress_meter.so ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

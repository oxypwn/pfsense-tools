# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	syslogd
PORTVERSION=	222550
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
PKGNAMESUFFIX=	-clog-zmq
DISTNAME=	${PORTNAME}-r${PORTVERSION}

MAINTAINER=	thompsa@FreeBSD.org
COMMENT=	FreeBSD syslogd with clog and zmq additions

LIB_DEPENDS=	czmq:${PORTSDIR}/devel/czmq

DISTDIR=	${FILESDIR}
# overwrite base
PREFIX=		/usr
PLIST_FILES=	sbin/syslogd

# apply in order
EXTRA_PATCHES+=	${PATCHDIR}/clog-support.diff
EXTRA_PATCHES+=	${PATCHDIR}/zmq-support.diff

do-fetch:

post-patch:
	@${SED} -i '' -e 's|%%PREFIX%%|${PREFIX}|g' \
		-e 's|%%LOCALBASE%%|${LOCALBASE}|g' ${WRKSRC}/Makefile

.include <bsd.port.mk>

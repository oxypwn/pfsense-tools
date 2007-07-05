# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	ftpsesame
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	ftp
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@gmail.com
COMMENT?=	reinits ata channel 0

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

BUILD_DEPENDS+=     libpcap>=0.9.4:${PORTSDIR}/net/libpcap

LDADD+= -lpcap -lalias

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	(cd files && make)

do-install:
	${INSTALL_PROGRAM} files/${PORTNAME} ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

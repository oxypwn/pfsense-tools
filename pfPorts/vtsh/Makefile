# New ports collection makefile for:	vtsh
# Date created:				Fri Oct 28 10:56:26 CDT 2005
# Whom:					Colin Smith <ethethlay@gmail.com>
#
# $Id$
#

PORTNAME=	vtsh
PORTVERSION=	0.0
PORTREVISION?=	0
CATEGORIES?=	shells
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	ethethlay@gmail.com
COMMENT?=	vtsh command shell

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

clean:
	echo

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

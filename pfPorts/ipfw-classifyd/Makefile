PORTNAME=	ipfw-classifyd
PORTVERSION=	0.0.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	ermal@pfsense.com
COMMENT?=	ipfw-classifyd

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-build:
	cd files && make

do-install:
	cd files && make install

.include <bsd.port.mk>

PORTNAME=	athstats
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	geekgod@geekgod.com
COMMENT?=	athstats

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

clean:
	rm files/athstats

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && make

do-install:
	cd files && make install

.include <bsd.port.mk>

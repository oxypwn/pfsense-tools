PORTNAME=	gzsig
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	geekgod@geekgod.com
COMMENT?=	reinits ata channel 0

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && make

do-install:
	cp files/gzsig /usr/local/sbin/
	chmod a+rx /usr/local/sbin/gzsig

do-clean:
	cd files && make clean
	rm -rf work

.include <bsd.port.mk>

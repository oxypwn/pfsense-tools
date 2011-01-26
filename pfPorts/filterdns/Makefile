PORTNAME=	filterdns
PORTVERSION=	0.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	eri@pfsense.org
COMMENT?=	filterdns

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-clean:
	cd files && make clean
	rm -r work
do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && make

do-install:
	${INSTALL_PROGRAM} files/${PORTNAME} ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

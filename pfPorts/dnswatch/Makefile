PORTNAME=	dnswatch
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	geekgod@geekgod.com
COMMENT?=	dnswatch

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c

do-install:
	cd files && make install
#${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

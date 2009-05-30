PORTNAME=	ftp-proxy
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	geekgod@geekgod.com
COMMENT?=	ftp-proxy

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && make
#${CC} ${CFLAGS} -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c

do-install:
	${INSTALL_PROGRAM} ${FILESDIR}/ftp-proxy ${PREFIX}/sbin
	${INSTALL_MAN} ${FILESDIR}/ftp-proxy.8 ${PREFIX}/man/man8

.include <bsd.port.mk>

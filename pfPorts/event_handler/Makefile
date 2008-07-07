PORTNAME=	event_handler
PORTVERSION=	0.0.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	ermal@pfsense.com
COMMENT?=	event_handler

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

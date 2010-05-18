PORTNAME=	wrapalixresetbutton
PORTVERSION=	0.0.3
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@pfsense.org
COMMENT?=	run various pfSense scripts on event.

WHERE=		sbin
PLIST_FILES=    ${WHERE}/wrapresetbtn
PLIST_FILES+=    ${WHERE}/alixresetbtn

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -lpthread -o ${WRKSRC}/wrapresetbtn ${FILESDIR}/wrapresetbtn.c
	${CC} ${CFLAGS} -lpthread -o ${WRKSRC}/alixresetbtn ${FILESDIR}/alixresetbtn.c

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/wrapresetbtn ${PREFIX}/${WHERE}/
	${INSTALL_PROGRAM} ${WRKSRC}/alixresetbtn ${PREFIX}/${WHERE}/

.include <bsd.port.mk>

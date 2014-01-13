PORTNAME=	blinkled
PORTVERSION=	0.1
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	jimp@pfsense.org
COMMENT?=	blinkled

WHERE=		bin
PLIST_FILES=	${WHERE}/${PORTNAME}

do-clean:
	make -C ${FILESDIR} clean
	rm -rf ${WRKDIR}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	make -C ${FILESDIR}

do-install:
	${INSTALL_PROGRAM} ${FILESDIR}/${PORTNAME} ${STAGEDIR}${PREFIX}/${WHERE}/

.include <bsd.port.mk>

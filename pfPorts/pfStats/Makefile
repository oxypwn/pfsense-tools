PORTNAME=	pfStats
PORTVERSION=	0.1
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	eri@pfsense.org
COMMENT?=	pfStats

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}
CFLAGS+=	-I/usr/local/include -L/usr/local/lib -lrrd_th -Wall -Werror

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	${CC} ${CFLAGS} -lrrd_th -lutil -lpthread -o ${WRKSRC}/${PORTNAME} ${FILESDIR}/${PORTNAME}.c

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${STAGEDIR}${PREFIX}/${WHERE}/

.include <bsd.port.mk>

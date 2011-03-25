
PORTNAME=	pfflowd
PORTVERSION=	0.8
PORTREVISION?=	0
CATEGORIES?=	net
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@pfsense.org
COMMENT=        Convert pfsync states to NetFlow datagrams

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}
CFLAGS+=	-I/usr/local/include -L/usr/local/lib 

do-extract:
	mkdir -p ${WRKSRC}
	${CP} files/* ${WRKSRC}

#do-build:
#	${CC} -g -static -o ${WRKSRC}/${PORTNAME} files/pfflowd.o files/pidfile.o files/nf9.o -lpcap -lutil

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/

	
.include <bsd.port.mk>

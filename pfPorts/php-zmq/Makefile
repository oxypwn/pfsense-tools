
PORTNAME=	php-zmq
PORTVERSION=	0.0.1
PORTREVISION?=	0
CATEGORIES?=	lang
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@gmail.com
COMMENT?=	run various pfSense scripts on event.

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && phpize && ./configure && make

do-install:
	cd files && make install

.include <bsd.port.mk>

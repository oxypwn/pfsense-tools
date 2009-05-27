PORTNAME=	ipsec-tools-devel
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	sullrich@gmail.com
COMMENT?=	IPSEC tools devel branch + NAT-T

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

clean:
	rm -f files/src/racoon

do-extract:
	mkdir -p ${WRKSRC}

do-build:
	cd files && ./configure --enable-natt --enable-adminport --enable-hybrid --enable-dpd --enable-stats --enable-frag && cd src && make

do-install:
	install files/src/racoon/racoon /usr/local/sbin/
	install files/src/setkey/setkey /usr/local/sbin/
.include <bsd.port.mk>

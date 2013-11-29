PORTNAME=	openiked
PORTVERSION=	2013.11.29
PORTREVISION=	1
CATEGORIES=	net

MAINTAINER=	eri@FreeBSD.org
COMMENT=	IKEv2 implementation daemon

#LIB_DEPENDS+=	libevent-1.4*:${PORTSDIR}/devel/libevent

GNU_CONFIGURE=  yes
CONFIGURE_ARGS+=	--with-bsd-auth --with-sock-dir=/var/run/ --with-libevent-dir=/usr/local
USE_AUTOTOOLS=	automake:env autoconf:env libtool:env
USES=		pathfix
USE_LDCONFIG=	yes

#MAKE_JOBS_UNSAFE=yes

USE_GITHUB=	yes
GH_ACCOUNT=	reyk

GH_TAGNAME=	f011623
GH_COMMIT=	f011623

NO_STAGE=	yes

pre-configure:
	@cd ${WRKSRC} && ./bootstrap

.include <bsd.port.mk>

# Created by: Archie Cobbs
# $FreeBSD: head/net/mpd5/Makefile 319824 2013-06-04 06:34:05Z bapt $

PORTNAME=	mpd
DISTVERSION=	5.6
CATEGORIES=	net
MASTER_SITES=	SF/${PORTNAME}/Mpd5/Mpd-${PORTVERSION}
DIST_SUBDIR=	mpd5
NO_STAGE=	yes

MAINTAINER=	mav@FreeBSD.org
COMMENT=	Multi-link PPP daemon based on netgraph(4)

LATEST_LINK=	mpd5

OPTIONS_DEFINE=	NG_IPACCT
NG_IPACCT_DESC=	Use ng_ipacct kernel module from port

HAS_CONFIGURE=	YES
CONFIGURE_WRKSRC=	"${WRKSRC}/src"

USE_OPENSSL=	yes

.include <bsd.port.options.mk>

CONFIGURE_ARGS+= --enable-ipv6

.if ${PORT_OPTIONS:MNG_IPACCT}
BUILD_DEPENDS+=	${LOCALBASE}/include/netgraph/ng_ipacct.h:${PORTSDIR}/net-mgmt/ng_ipacct
.if exists(${KMODDIR}/ng_ipacct.ko)
RUN_DEPENDS+=	${KMODDIR}/ng_ipacct.ko:${PORTSDIR}/net-mgmt/ng_ipacct
.else
RUN_DEPENDS+=	/boot/modules/ng_ipacct.ko:${PORTSDIR}/net-mgmt/ng_ipacct
.endif
.endif

MAN8=		mpd5.8
MANCOMPRESSED=	maybe
USE_RC_SUBR=	mpd5
HTMLNUM!=	jot 70 1
CONFSUF=	conf secret script
DOCSDIR=	${PREFIX}/share/doc/mpd5
PORTDOCS=	${HTMLNUM:S/^/mpd/:S/$/.html/} mpd.html mpd.ps README	\
		mpd_toc.html
PLIST_DIRS=	etc/mpd5
PLIST_FILES=	${CONFSUF:S/^/etc\/mpd5\/mpd./:S/$/.sample/} sbin/mpd5

.include <bsd.port.mk>

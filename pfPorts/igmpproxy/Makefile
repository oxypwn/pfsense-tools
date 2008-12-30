PORTNAME=	igmpproxy
PORTVERSION=	0.1
DISTNAME=	igmpproxy-src-${PORTVERSION}-beta2
CATEGORIES=	net
MASTER_SITES=	${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR= 	igmpproxy

MAINTAINER=	Ermal Luci <eri@pfsense.org>

USE_GMAKE =		Yes

WRKSRC=		${WRKDIR}/igmpproxy/src

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/igmpproxy ${PREFIX}/sbin
	${INSTALL_MAN} ${WRKSRC}/../doc/igmpproxy.8 ${PREFIX}/man/man8
	${INSTALL_MAN} ${WRKSRC}/../doc/igmpproxy.conf.5 ${PREFIX}/man/man5
	${MKDIR} ${PREFIX}/share/examples/igmpproxy
	${INSTALL_DATA} ${WRKSRC}/igmpproxy.conf \
	    ${PREFIX}/share/examples/igmpproxy

.include <bsd.port.mk>

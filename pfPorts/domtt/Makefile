# ex:ts=8
# New ports collection makefile for:	domTT
# Date created:				October 28, 2007
# Whom:					Daniel S. Haischt <me@daniel.stefan.haischt.name>
#
# $Id$
#

PORTNAME=		domtt
PORTVERSION=		0.7.3
PORTREVISION=		1
CATEGORIES=		textproc www
MASTER_SITES=		http://www.mojavelinux.com/cooker/download/index.php?file=domtooltip/
DISTNAME=		${PORTNAME}-${PORTVERSION}
WRKSRC=			${WRKDIR}/domTT

NO_BUILD=	yes

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	domTT JavaScript Framework

DOMTT_DIR=	${PREFIX}/www/javascript/domTT

.include <bsd.port.pre.mk>

do-install:
# tafeltree
	@${MKDIR} ${DOMTT_DIR}
	(cd ${WRKDIR}/domTT && cp *.js ${DOMTT_DIR})
	(cd ${WRKDIR}/domTT/examples && cp *.js ${DOMTT_DIR})

# Documentation
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	(cd ${WRKDIR}/domTT && cp LICENSE README TODO ${DOCSDIR})
	(cd ${WRKDIR}/domTT/web && cp -R * ${DOCSDIR})
.endif

.include <bsd.port.post.mk>

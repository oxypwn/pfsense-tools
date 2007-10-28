# ex:ts=8
# New ports collection makefile for:	TafelTree
# Date created:				October 28, 2007
# Whom:					Daniel S. Haischt <me@daniel.stefan.haischt.name>
#
# $Id$
#

PORTNAME=		tafelTree
PORTVERSION=		1.9.1
PORTREVISION=		1
CATEGORIES=		textproc www
MASTER_SITES=		${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR=	tafeltree
DISTNAME=		${PORTNAME}_${PORTVERSION:S/./_/g}
WRKSRC=			${WRKDIR}/${PORTNAME}

USE_ZIP=	yes
NO_BUILD=	yes

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	windows JavaScript Framework

TAFELTREE_DIR=	${PREFIX}/www/javascript/tafeltree

.include <bsd.port.pre.mk>

do-install:
# tafeltree
	@${MKDIR} ${TAFELTREE_DIR}
	@${MKDIR} ${TAFELTREE_DIR}/css
	@${MKDIR} ${TAFELTREE_DIR}/imgs
	(cd ${WRKDIR}/${PORTNAME} && cp Tree*.js ${TAFELTREE_DIR})
	(cd ${WRKDIR}/${PORTNAME}/css && cp *.css ${TAFELTREE_DIR}/css)
	(cd ${WRKDIR}/${PORTNAME}/imgs && cp *.gif ${TAFELTREE_DIR}/imgs)

# Documentation
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	(cd ${WRKDIR}/${PORTNAME} && cp CHANGELOG.txt ${DOCSDIR})
	(cd ${WRKDIR}/${PORTNAME}/doc && cp -R * ${DOCSDIR})
.endif

.include <bsd.port.post.mk>

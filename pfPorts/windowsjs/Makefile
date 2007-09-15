# ex:ts=8
# New ports collection makefile for:	windows-js
# Date created:				Setptember 15, 2007
# Whom:					Daniel S. Haischt <me@daniel.stefan.haischt.name>
#
# $Id$
#

PORTNAME=	windows_js
PORTVERSION=	1.3
PORTREVISION=	1
CATEGORIES=	textproc www
MASTER_SITES=	http://prototype-window.xilinus.com/download/
DISTNAME=	${PORTNAME}_${PORTVERSION}

USE_ZIP=	yes
NO_BUILD=	yes

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	windows JavaScript Framework

WINDOWSJS_DIR=	${PREFIX}/www/javascript/windows-js

.include <bsd.port.pre.mk>

do-install:
# windows-js
	@${MKDIR} ${WINDOWSJS_DIR}
	@${MKDIR} ${WINDOWSJS_DIR}/javascript
	@${MKDIR} ${WINDOWSJS_DIR}/themes
	(cd ${WRKDIR}/${DISTNAME}/javascripts && cp *.js ${WINDOWSJS_DIR}/javascript)
	(cd ${WRKDIR}/${DISTNAME}/themes && cp -R * ${WINDOWSJS_DIR}/themes)

# Documentation
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	(cd ${WRKDIR}/${DISTNAME}/documentation && cp -R * ${DOCSDIR})
.endif

.include <bsd.port.post.mk>

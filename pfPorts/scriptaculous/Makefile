# ex:ts=8
# New ports collection makefile for:	script.aculo.us
# Date created:				Setptember 01, 2007
# Whom:					Daniel S. Haischt <me@daniel.stefan.haischt.name>
#
# $Id$
#

PORTNAME=	scriptaculous-js
PORTVERSION=	1.7.1
PORTREVISION=	1
CATEGORIES=	textproc www
MASTER_SITES=	http://script.aculo.us/dist/
DISTNAME=	${PORTNAME}-${PORTVERSION}_beta3

NO_BUILD=	yes

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	script.aculo.us JavaScript Framework

SCRIPTACULOUS_DIR=	${PREFIX}/www/javascript/scriptaculous

.include <bsd.port.pre.mk>

do-install:
# Scriptaculous
	@${MKDIR} ${SCRIPTACULOUS_DIR}
	(cd ${WRKDIR}/${DISTNAME}/src && cp *.js ${SCRIPTACULOUS_DIR})

# Prototype
	@${INSTALL_DATA} "${WRKDIR}/${DISTNAME}/lib/prototype.js" "${SCRIPTACULOUS_DIR}"

# Documentation
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
.	for f in CHANGELOG MIT-LICENSE README
		@${INSTALL_DATA} "${WRKDIR}/${DISTNAME}/${f}" "${DOCSDIR}"
.	endfor
.endif

.include <bsd.port.post.mk>

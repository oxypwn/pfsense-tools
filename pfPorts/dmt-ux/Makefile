# New ports collection makefile for:	dmt-ux
# Date created:				27. August 2006
# Whom:	      				Daniel S. Haischt <me@daniel.stefan.haischt.name>
#
# $I $
#

PORTNAME=	dmt-ux
PORTVERSION=	0.104
CATEGORIES=	comms
MASTER_SITES=	http://www.spida.net/%SUBDIR%/
MASTER_SITE_SUBDIR=	/projects/${PORTNAME}/
DISTFILES=	${PORTNAME}-${PORTVERSION}.tar.gz
WORKSRC=	${WRKDIR}/dmt-ux-${PORTVERSION}

MAINTAINER=	me@daniel.stefan.haischt.name
COMMENT=	The DSL Modem Tool is a useful utility for Diagnosis and Tuning of DSL Modems.

LIB_DEPENDS=	gd.4:${PORTSDIR}/graphics/gd \
		freetype.9:${PORTSDIR}/print/freetype2

USE_GMAKE=	yes
USE_GETOPT_LONG=yes
MAKE_ENV=	_LDFLAGS="${LDFLAGS} -L${LOCALBASE}/lib" GMAKE=${GMAKE}
SCRIPTS_ENV=	PKG_PREFIX=${PREFIX} NONEXISTENT=${NONEXISTENT} PASSWD=/etc/passwd
SUB_FILES=	pkg-message
PKGMESSAGE=	${WRKDIR}/pkg-message

PORTDOCS=	License.GPL License.Bitstream README

#MAN8=		dmt-ux.8
MANCOMPRESSED=	yes
XPM=		downstream-arrowhead \
		downstream-arrowsection \
		modem-local \
		upstream-arrowhead \
		upstream-arrowsection \
		world
FONTS=		VeraBd Vera

.include <bsd.port.pre.mk>

do-install:
	${MKDIR} ${PREFIX}/share/${PORTNAME}
	${INSTALL_PROGRAM} ${WRKSRC}/dmt-ux ${PREFIX}/bin/
	${INSTALL_SCRIPT} ${FILESDIR}/dmt-ux.sh ${PREFIX}/etc/rc.d/
.for f in ${MAN8}
	${INSTALL_MAN} ${WRKSRC}/${f}.gz ${MAN8PREFIX}/man/man8/
.endfor
.for f in ${XPM}
	${INSTALL_DATA} ${WRKSRC}/${f}.xpm ${PREFIX}/share/${PORTNAME}
.endfor
.for f in ${FONTS}
	${INSTALL_DATA} ${WRKSRC}/${f}.ttf ${PREFIX}/share/${PORTNAME}
.endfor
.ifndef (NOPORTDOCS)
	${MKDIR} ${DOCSDIR}
.for f in ${PORTDOCS}
	${INSTALL_DATA} ${WRKSRC}/${f} ${DOCSDIR}
.endfor
.endif

post-install:
	@${SETENV} ${SCRIPTS_ENV} ${SH} ${PKGINSTALL} ${PKGNAME} POST-INSTALL
	@${CAT} ${PKGMESSAGE}

.include <bsd.port.post.mk>

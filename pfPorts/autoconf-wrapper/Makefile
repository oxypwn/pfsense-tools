# New ports collection makefile for:	autoconf-wrapper
# Date created:				4th April 2007
# Whom:					des
#
# $FreeBSD: ports/devel/autoconf-wrapper/Makefile,v 1.4 2010/12/04 07:31:01 ade Exp $
#

PORTNAME?=	autoconf-wrapper
PORTVERSION=	20101119
CATEGORIES=	devel
MASTER_SITES=	# none
DISTFILES=	# none
NO_STAGE=	yes

MAINTAINER=	autotools@FreeBSD.org
COMMENT?=	Wrapper script for GNU autoconf

WRKSRC=		${WRKDIR}
NO_BUILD=	YES

TOOL?=		AUTOCONF
WRAPPED_TOOLS?=	autoconf autoheader autom4te autoreconf autoscan \
		autoupdates ifnames
.include <bsd.port.pre.mk>

TOOLS_CASE!=	${ECHO_CMD} ${WRAPPED_TOOLS} | ${TR} ' ' '|'
PLIST_FILES=	bin/${PORTNAME}
.for tool in ${WRAPPED_TOOLS}
PLIST_FILES+=	bin/${tool}
.endfor

do-configure:
	@${SED} \
	    -e 's,%%PREFIX%%,${PREFIX},g' \
	    -e 's,%%TOOL%%,${TOOL},g' \
	    -e 's,%%TOOLS_CASE%%,${TOOLS_CASE},g' \
	    <${FILESDIR}/autotools-wrapper.sh >${WRKDIR}/${PORTNAME}.sh

do-install:
	@${INSTALL_SCRIPT} ${WRKDIR}/${PORTNAME}.sh ${PREFIX}/bin/${PORTNAME}
.for tool in ${WRAPPED_TOOLS}
	@${LN} -sf ${PORTNAME} ${PREFIX}/bin/${tool}
.endfor

.include <bsd.port.post.mk>

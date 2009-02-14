# New ports collection makefile for:   	imspector
# Date created:        			17 March 2008
# Whom:            			Ilja Dejs <ilja.dejs@gmail.com>
#
# $FreeBSD: ports/net-im/imspector/Makefile,v 1.3 2009/01/06 17:59:14 pav Exp $
#

PORTNAME=	imspector
PORTVERSION=	0.8
CATEGORIES=	net-im
MASTER_SITES=	http://www.imspector.org/downloads/

MAINTAINER=	lawrence@aslak.net
COMMENT=	IM transparent proxy with monitoring, blocking, and content-filtering supports

CFLAGS+=	-fPIC

BUILD_DEPENDS=  iconv:${PORTSDIR}/converters/iconv

USE_GMAKE=	yes
USE_MYSQL=      yes
USE_SQLITE=     yes

CONFIG_FILES=	imspector.conf badwords.txt acl.txt

USE_RC_SUBR=	${PORTNAME}

MAKE_ENV+=	ETCDIR=${ETCDIR}

post-patch:
	@${REINPLACE_CMD} -e 's,%%PREFIX%%,${PREFIX},g' \
		${WRKSRC}/imspector.conf \
		${WRKSRC}/main.cpp
post-install:
.for f in ${CONFIG_FILES}
	@if [ ! -f ${ETCDIR}/${f} ]; then \
		${CP} -p ${ETCDIR}/${f}.sample ${ETCDIR}/${f} ; \
	fi
.endfor

.include <bsd.port.mk>

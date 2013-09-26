# New ports collection makefile for:   	imspector
# Date created:        			17 March 2008
# Whom:            			Ilja Dejs <ilja.dejs@gmail.com>
#
# $FreeBSD: ports/net-im/imspector/Makefile,v 1.6 2011/06/14 19:10:49 jlaffaye Exp $
#

PORTNAME=	imspector
PORTVERSION=	20111108
CATEGORIES=	net-im
MASTER_SITES=	http://www.imspector.org/downloads/snapshots/
NO_STAGE=	yes

MAINTAINER=	m.tsatsenko@gmail.com
COMMENT=	IM transparent proxy with monitoring, blocking and content-filtering

LIB_DEPENDS=    mysqlclient.16:${PORTSDIR}/databases/mysql51-client
LIB_DEPENDS+=	sqlite3.8:${PORTSDIR}/databases/sqlite3

LICENSE=	GPLv2

CFLAGS+=	-fPIC -I ${LOCALBASE}/include -DHAVE_SSL
USE_GMAKE=	YES
USE_ICONV=	YES
USE_OPENSSL=	YES

CONFLICTS=      imspector-0.*

LATEST_LINK=	imspector-devel

CONFIG_FILES=	imspector.conf badwords.txt acl.txt

USE_RC_SUBR=	${PORTNAME}

MAKE_ENV+=	ETCDIR=${ETCDIR}

post-extract:
	${MV}	${WRKDIR}/${PORTNAME} ${WRKSRC}
post-patch:
	@${REINPLACE_CMD} -e 's,%%PREFIX%%,${PREFIX},g' \
		${WRKSRC}/imspector.conf \
		${WRKSRC}/main.cpp
	@${REINPLACE_CMD} -e 's,#ADD_PLUGINS,ADD_PLUGINS,' \
		${WRKSRC}/Makefile

post-install:
.for f in ${CONFIG_FILES}
	@if [ ! -f ${ETCDIR}/${f} ]; then \
		${CP} -p ${ETCDIR}/${f}.sample ${ETCDIR}/${f} ; \
	fi
.endfor

.include <bsd.port.mk>

# New ports collection makefile for:    mini_httpd
# Date created:         24 July 2002
# Whom:                 se
#
# $FreeBSD: ports/www/mini_httpd/Makefile,v 1.4 2004/03/22 22:29:49 se Exp $
#

PORTNAME=	mini_httpd
PORTVERSION=	1.19
CATEGORIES=	www
MASTER_SITES=	http://www.acme.com/software/mini_httpd/
DISTNAME=	${PORTNAME}-${PORTVERSION}

MAINTAINER=	jebc@c4solutions.net
COMMENT=	Small HTTP server with support for GET, HEAD, POST, CGI, SSL, IPv6

WHERE=		sbin
PLIST_FILES=    ${WHERE}/${PORTNAME}

.ifndef NO_SSL
USE_OPENSSL=	YES
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/${PORTNAME} ${PREFIX}/${WHERE}/
	#${INSTALL_PROGRAM} ${WRKSRC}/htpasswd ${PREFIX}/sbin/

.include <bsd.port.mk>

# New ports collection makefile for:	sshtools
# Date created:				01 Aug 2006
# Whom:					me@daniel.stefan.haischt.name
#
# $Id$

PORTNAME=		sshtools
PORTVERSION=		0.2.2
CATEGORIES=		security
MASTER_SITES=		${MASTER_SITE_SOURCEFORGE}
MASTER_SITE_SUBDIR=	${PORTNAME}
DISTNAME=		SSHTerm-${PORTVERSION}-applet-signed
WRKSRC=			${WRKDIR}/sshterm-applet

MAINTAINER=		me@daniel.stefan.haischt.name
COMMENT=		SSHTools is a suite of Java SSH applications providing a Java based SSH application.

USE_ZIP=		yes
#USE_JAVA=		yes
NO_BUILD=		yes

.include <bsd.port.pre.mk>

#.if ${JAVA_PORT_VERSION} == "1.1"
#RUN_DEPENDS+=		${JAVALIBDIR}/jfc-1.1.1/swing.jar:${PORTSDIR}/java/jfc
#.endif

.if !defined(NOPORTDOCS)
PORTDOCS=		instructions.htm SSHTools-small-logo2.gif LICENSE
.endif

PLIST_FILES=		/usr/local/www/java/SSHTermApplet-signed.jar \
			/usr/local/www/java/SSHTermApplet-jdkbug-workaround-signed.jar
#.if ${JAVA_PORT_VERSION} == "1.3.1"
#PLIST_FILES+=		%%JAVAJARDIR%%/SSHTermApplet-jdk1.3.1-dependencies-signed.jar
#.endif

do-install:
	@${MKDIR}	${PREFIX}/www/java
	${INSTALL_DATA} ${INSTALL_WRKSRC}/SSHTermApplet-signed.jar /usr/local/www/java/
	${INSTALL_DATA} ${INSTALL_WRKSRC}/SSHTermApplet-jdkbug-workaround-signed.jar /usr/local/www/java/
#.if ${JAVA_PORT_VERSION} == "1.3.1"
#	${INSTALL_DATA} ${INSTALL_WRKSRC}/SSHTermApplet-jdk1.3.1-dependencies-signed.jar ${JAVAJARDIR}/
#.endif
.if !defined(NOPORTDOCS)
	@${MKDIR}	${PREFIX}/share/doc/${PORTNAME}	
.for DOC in ${PORTDOCS}
	@${INSTALL_DATA} ${WRKSRC}/${DOC} ${PREFIX}/share/doc/${PORTNAME}
.endfor
.endif

.include <bsd.port.post.mk>

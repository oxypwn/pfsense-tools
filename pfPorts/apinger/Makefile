# Created by: Michael L. Hostbaek (mich@freebsdcluster.org)
# $FreeBSD: head/net/apinger/Makefile 313460 2013-03-05 17:07:43Z miwi $

PORTNAME=	apinger
PORTVERSION=	0.6.1
PORTREVISION=	2
CATEGORIES=	net ipv6
MASTER_SITES=	http://freebsdcluster.org/~mich/software/ \
		http://www.bnet.pl/~jajcus/apinger/

MAINTAINER=	mich@FreeBSD.org
COMMENT=	An IP device monitoring tool

GNU_CONFIGURE=	yes

OPTIONS_DEFINE=	IPV6
OPTIONS_DEFAULT=	IPV6

.include <bsd.port.options.mk>

CONFIGURE_ARGS+= --enable-ipv6

#post-extract:
#	@${SED} -e "s,%%PREFIX%%,${PREFIX},g" ${FILESDIR}/apinger.sh \
#		> ${WRKSRC}/apinger.sh

post-install:
	${INSTALL_DATA} ${WRKSRC}/src/apinger.conf ${PREFIX}/etc/apinger.conf.sample
.if !defined(BATCH)
	@${ECHO_MSG} ""
	@${ECHO_MSG} "###############################################################################"
	@${ECHO_MSG} "# Please edit ${PREFIX}/etc/apinger.conf to your needs.                      #"
	@${ECHO_MSG} "# A sample shell script has been installed in ${PREFIX}/etc/rc.d/            #"
	@${ECHO_MSG} "# rename it to automatically start apinger at boot.                           #"
	@${ECHO_MSG} "###############################################################################"
.endif

.if ${PORT_OPTIONS:MDOCS}
	@${MKDIR} ${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/README ${DOCSDIR}/README
	${INSTALL_DATA} ${WRKSRC}/NEWS ${DOCSDIR}/NEWS
	${INSTALL_DATA} ${WRKSRC}/AUTHORS ${DOCSDIR}/AUTHORS
.endif

.include <bsd.port.mk>

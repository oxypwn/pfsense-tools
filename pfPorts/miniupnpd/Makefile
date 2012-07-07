# New ports collection makefile for:	miniupnpd
# Date created:		22 March 2007
# Whom:			Daniel O'Connor <darius@dons.net.au>
#
# $FreeBSD: ports/net/miniupnpd/Makefile,v 1.15 2010/10/12 14:29:11 jpaetzel Exp $
#

PORTNAME=	miniupnpd
PORTVERSION=	1.6.20120406
CATEGORIES=	net
MASTER_SITES=	http://miniupnp.tuxfamily.org/files/ \
		http://miniupnp.free.fr/files/

MAINTAINER=	seth.mos@dds.nl
COMMENT=	A UPnP IGD implementation which uses pf/ipf

SUB_FILES=	miniupnpd.conf.sample
SUB_LIST=	UUID=${UUID}

UUID!=		uuidgen
FWNAME?=	pf
PLIST_FILES=	etc/miniupnpd.conf.sample sbin/miniupnpd

MAN8=		miniupnpd.8

USE_RC_SUBR=	miniupnpd.sh

OPTIONS=	PF_ENABLE_FILTER_RULES		"Enable pf generation of filter rules" on \

.include <bsd.port.options.mk>
.if defined(WITH_PF_ENABLE_FILTER_RULES)
EXTRA_PATCHES=  ${PATCHDIR}/pf_enable_filter_rules.patch
.endif

do-install:
	@${INSTALL_PROGRAM} ${WRKSRC}/miniupnpd ${PREFIX}/sbin/miniupnpd
	@${INSTALL_DATA} ${WRKDIR}/miniupnpd.conf.sample ${PREFIX}/etc/miniupnpd.conf.sample
	@${INSTALL_MAN} ${WRKSRC}/miniupnpd.1 ${PREFIX}/man/man8/miniupnpd.8
	@${CAT} ${PKGMESSAGE}

.include <bsd.port.mk>

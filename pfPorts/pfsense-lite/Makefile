# New ports collection makefile for:	php4
# Date created:				Tue Feb 18 11:17:13 CET 2003
# Whom:					Alex Dupre <sysadmin@alexdupre.com>
#
# $FreeBSD: ports/lang/php4/Makefile,v 1.88 2005/07/13 19:56:27 ale Exp $
#

PORTNAME=	pfsense-lite
PORTVERSION=	0.0.2
PORTREVISION?=	0
CATEGORIES?=	sysutils
MASTER_SITES=	# empty
DISTFILES=	# none
EXTRACT_ONLY=	# empty

MAINTAINER?=	jebc@c4solutions.net
COMMENT?=	reinits ata channel 0

RUN_DEPENDS+=   autoconf213:${PORTSDIR}/devel/autoconf213
RUN_DEPENDS+=   dhcpd:${PORTSDIR}/net/isc-dhcp3-server
RUN_DEPENDS+=   dnsmasq:${PORTSDIR}/dns/dnsmasq
RUN_DEPENDS+=   mpd:${PORTSDIR}/net/mpd
RUN_DEPENDS+=   olsrd:${PORTSDIR}/net/olsrd
RUN_DEPENDS+=   pftop:${PORTSDIR}/sysutils/pftop

RUN_DEPENDS+=   atareinit:${PORTSDIR}/pfPorts/atareinit
RUN_DEPENDS+=   beep:${PORTSDIR}/pfPorts/beep
RUN_DEPENDS+=   check_reload_status:${PORTSDIR}/pfPorts/check_reload_status
RUN_DEPENDS+=   choparp:${PORTSDIR}/pfPorts/choparp
RUN_DEPENDS+=   expiretable:${PORTSDIR}/pfPorts/expiretable
RUN_DEPENDS+=   ifstats:${PORTSDIR}/pfPorts/ifstats
RUN_DEPENDS+=   kbdcheck:${PORTSDIR}/pfPorts/kbdcheck
RUN_DEPENDS+=   mini_httpd:${PORTSDIR}/pfPorts/mini_httpd-pfsense
RUN_DEPENDS+=   minicron:${PORTSDIR}/pfPorts/minicron
RUN_DEPENDS+=   pftpx:${PORTSDIR}/pfPorts/pftpx
RUN_DEPENDS+=   php4-pfsense:${PORTSDIR}/pfPorts/php4-pfsense
#RUN_DEPENDS+=   sasyncd:${PORTSDIR}/pfPorts/sasyncd
RUN_DEPENDS+=   slbd:${PORTSDIR}/pfPorts/slbd
RUN_DEPENDS+=   sshlockout_pf:${PORTSDIR}/pfPorts/sshlockout_pf
#RUN_DEPENDS+=   stats:${PORTSDIR}/pfPorts/stats
RUN_DEPENDS+=   verifysig:${PORTSDIR}/pfPorts/verifysig
RUN_DEPENDS+=   wol:${PORTSDIR}/pfPorts/wol
RUN_DEPENDS+=   upload_progress_meter:${PORTSDIR}/pfPorts/upload_progress_meter

NO_BUILD=	yes

.include <bsd.port.mk>

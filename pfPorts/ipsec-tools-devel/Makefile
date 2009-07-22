
PORTNAME=	ipsec-tools
PORTVERSION=	0.8
CATEGORIES=	security
MASTER_SITES=	http://iserv.nl/files/pfsense/
DISTFILES=		ipsec-tools-0.8.tar.bz2
MAINTAINER=	vanhu@netasq.com
COMMENT=	KAME racoon IKE daemon, ipsec-tools version

CONFLICTS=	racoon-[0-9]*

USE_RC_SUBR=	racoon.sh
USE_OPENSSL=	yes
USE_BZIP2=	yes

USE_AUTOTOOLS=	libtool:15
GNU_CONFIGURE=	yes
USE_LDCONFIG=	yes
CONFIGURE_TARGET=	--build=${MACHINE_ARCH}-portbld-freebsd${OSREL}
CONFIGURE_ARGS=	--enable-shared --sysconfdir=${PREFIX}/etc/racoon \
		--localstatedir=${STATEDIR:S/\/racoon//} \
		--with-pkgversion=freebsd-${PORTVERSION} \
		--enable-adminport

STATEDIR=	/var/db/racoon
SUB_LIST+=	STATEDIR=${STATEDIR}
PLIST_SUB+=	STATEDIR=${STATEDIR}

WRKSRC=		work/ipsec-tools-0.8-alpha20090525+natt

WITH_NATT=yo

OPTIONS=	DEBUG		"enable Debug support" off \
		IPV6		"enable IPV6 support" off \
		ADMINPORT	"enable Admin port" on \
		STATS		"enable Statistics logging function" off \
		DPD		"enable Dead Peer Detection" on \
		NATT		"enable NAT-Traversal (kernel-patch required)" on \
		NATTF		"require NAT-Traversal (fail without kernel-patch)" off \
		FRAG		"enable IKE fragmentation payload support" on \
		HYBRID		"enable Hybrid Mode-cfg and Xauth support" on \
		PAM		"enable PAM authentication" off \
		GSSAPI		"enable GSS-API authentication" off \
		RADIUS		"enable Radius authentication" off \
		LDAP		"enable LDAP authentication" on \
		SAUNSPEC	"enable Unspecified SA mode" on \
		RC5		"enable RC5 encryption (patented)" off \
		IDEA		"enable IDEA encryption (patented)" off

MAN3=		ipsec_set_policy.3 ipsec_strerror.3
MAN5=		racoon.conf.5
MAN8=		racoon.8 racoonctl.8 setkey.8 plainrsa-gen.8

PORTDOCS=	*

.include <bsd.port.pre.mk>

.ifdef(WITH_DEBUG)
CONFIGURE_ARGS+=	--enable-debug
.else
CONFIGURE_ARGS+=	--disable-debug
.endif

.ifdef(WITH_IPV6)
CONFIGURE_ARGS+=	--enable-ipv6
.else
CONFIGURE_ARGS+=	--disable-ipv6
.endif

.ifdef(WITH_ADMINPORT)
CONFIGURE_ARGS+=	--enable-adminport
.else
CONFIGURE_ARGS+=	--disable-adminport
.endif

CONFIGURE_ARGS+=	--disable-stats

.ifdef(WITH_DPD)
CONFIGURE_ARGS+=	--enable-dpd
.else
CONFIGURE_ARGS+=	--disable-dpd
.endif

.ifdef(WITH_NATT)
.	ifdef(WITH_NATTF)
CONFIGURE_ARGS+=	--enable-natt=yes
.	else
CONFIGURE_ARGS+=	--enable-natt=kernel
.	endif
.else
CONFIGURE_ARGS+=	--disable-natt
.endif

.ifdef(WITH_FRAG)
CONFIGURE_ARGS+=	--enable-frag
.else
CONFIGURE_ARGS+=	--disable-frag
.endif

.ifdef(WITH_HYBRID)
CONFIGURE_ARGS+=	--enable-hybrid
.else
CONFIGURE_ARGS+=	--disable-hybrid
.endif

.ifdef(WITH_PAM)
CONFIGURE_ARGS+=	--with-libpam
.else
CONFIGURE_ARGS+=	--without-libpam
.endif

.ifdef(WITH_GSSAPI)
USE_ICONV=	yes
CFLAGS+=	-I${LOCALBASE}/include
LDFLAGS+=	-L${LOCALBASE}/lib
CONFIGURE_ARGS+=	--enable-gssapi
.else
CONFIGURE_ARGS+=	--disable-gssapi
.endif

.ifdef(WITH_RADIUS)
CONFIGURE_ARGS+=	--with-libradius
.else
CONFIGURE_ARGS+=	--without-libradius
.endif

.ifdef(WITH_LDAP)
USE_OPENLDAP=   YES
CONFIGURE_ARGS+=	--with-libldap=${LOCALBASE}
.else
CONFIGURE_ARGS+=	--without-libldap
.endif

.ifdef(WITH_SAUNSPEC)
CONFIGURE_ARGS+=	--enable-samode-unspec
.else
CONFIGURE_ARGS+=	--disable-samode-unspec
.endif

.ifdef(WITH_RC5)
CONFIGURE_ARGS+=	--enable-rc5
.else
CONFIGURE_ARGS+=	--disable-rc5
.endif

.ifdef(WITH_IDEA)
CONFIGURE_ARGS+=	--enable-idea
.else
CONFIGURE_ARGS+=	--disable-idea
.endif

.ifdef(WITH_NATT)
pre-configure:
	@${ECHO_MSG} "===> -------------------------------------------------------------------------"
	@${ECHO_MSG} "===> ATTENTION: You need a kernel patch to enable NAT-Traversal functionality!"
	@${ECHO_MSG} "===> You can download the patch here:"
	@${ECHO_MSG} "===>     http://ipsec-tools.sf.net/freebsd6-natt.diff"
	@${ECHO_MSG} "===> You might possibly have to do some steps manually if it fails to apply."
	@${ECHO_MSG} "===> -------------------------------------------------------------------------"
	@sleep 3
.endif

post-install:
	@if [ -z `/sbin/sysctl -a | ${GREP} -q ipsec && ${ECHO_CMD} ipsec` ]; then \
	    ${ECHO_MSG} "WARNING: IPsec feature is disabled on this host"; \
	    ${ECHO_MSG} "         You must build the kernel if you want to run racoon on the host"; \
	fi ;
	@${MKDIR} ${EXAMPLESDIR}
	@${RM} -f ${WRKSRC}/src/racoon/samples/*.in
	@${CP} -r ${WRKSRC}/src/racoon/samples/* ${EXAMPLESDIR}
.if !defined(NOPORTDOCS)
	@${MKDIR} ${DOCSDIR}
	@${INSTALL_DATA} ${WRKSRC}/src/racoon/doc/* ${DOCSDIR}
.endif

.include <bsd.port.post.mk>

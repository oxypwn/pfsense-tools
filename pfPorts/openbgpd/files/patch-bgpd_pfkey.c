--- bgpd/pfkey.c.orig	2013-02-22 10:19:56.000000000 +0000
+++ bgpd/pfkey.c	2013-02-22 10:20:40.000000000 +0000
@@ -1,4 +1,4 @@
-/*	$OpenBSD: pfkey.c,v 1.37 2009/04/21 15:25:52 henning Exp $ */
+/*	$OpenBSD: pfkey.c,v 1.40 2009/12/14 17:38:18 claudio Exp $ */
 
 /*
  * Copyright (c) 2003, 2004 Henning Brauer <henning@openbsd.org>
@@ -21,7 +21,7 @@
 #include <sys/socket.h>
 #include <sys/uio.h>
 #include <net/pfkeyv2.h>
-#include <netinet/ip_ipsp.h>
+//#include <netinet/ip_ipsp.h>
 #include <ctype.h>
 #include <errno.h>
 #include <limits.h>
@@ -65,15 +65,15 @@
 {
 	struct sadb_msg		smsg;
 	struct sadb_sa		sa;
-	struct sadb_address	sa_src, sa_dst, sa_peer, sa_smask, sa_dmask;
+	struct sadb_address	sa_src, sa_dst;
 	struct sadb_key		sa_akey, sa_ekey;
 	struct sadb_spirange	sa_spirange;
-	struct sadb_protocol	sa_flowtype, sa_protocol;
 	struct iovec		iov[IOV_CNT];
 	ssize_t			n;
 	int			len = 0;
 	int			iov_cnt;
-	struct sockaddr_storage	ssrc, sdst, speer, smask, dmask;
+	struct sockaddr_storage	ssrc, sdst, smask, dmask;
+	struct sockaddr		*saptr;
 
 	if (!pid)
 		pid = getpid();
@@ -81,22 +81,17 @@
 	/* we need clean sockaddr... no ports set */
 	bzero(&ssrc, sizeof(ssrc));
 	bzero(&smask, sizeof(smask));
-	switch (src->af) {
-	case AF_INET:
-		((struct sockaddr_in *)&ssrc)->sin_addr = src->v4;
-		ssrc.ss_len = sizeof(struct sockaddr_in);
-		ssrc.ss_family = AF_INET;
+	if ((saptr = addr2sa(src, 0)))
+		memcpy(&ssrc, saptr, sizeof(ssrc));
+	switch (src->aid) {
+	case AID_INET:
 		memset(&((struct sockaddr_in *)&smask)->sin_addr, 0xff, 32/8);
 		break;
-	case AF_INET6:
-		memcpy(&((struct sockaddr_in6 *)&ssrc)->sin6_addr,
-		    &src->v6, sizeof(struct in6_addr));
-		ssrc.ss_len = sizeof(struct sockaddr_in6);
-		ssrc.ss_family = AF_INET6;
+	case AID_INET6:
 		memset(&((struct sockaddr_in6 *)&smask)->sin6_addr, 0xff,
 		    128/8);
 		break;
-	case 0:
+	case AID_UNSPEC:
 		ssrc.ss_len = sizeof(struct sockaddr);
 		break;
 	default:
@@ -107,22 +102,17 @@
 
 	bzero(&sdst, sizeof(sdst));
 	bzero(&dmask, sizeof(dmask));
-	switch (dst->af) {
-	case AF_INET:
-		((struct sockaddr_in *)&sdst)->sin_addr = dst->v4;
-		sdst.ss_len = sizeof(struct sockaddr_in);
-		sdst.ss_family = AF_INET;
+	if ((saptr = addr2sa(dst, 0)))
+		memcpy(&sdst, saptr, sizeof(sdst));
+	switch (dst->aid) {
+	case AID_INET:
 		memset(&((struct sockaddr_in *)&dmask)->sin_addr, 0xff, 32/8);
 		break;
-	case AF_INET6:
-		memcpy(&((struct sockaddr_in6 *)&sdst)->sin6_addr,
-		    &dst->v6, sizeof(struct in6_addr));
-		sdst.ss_len = sizeof(struct sockaddr_in6);
-		sdst.ss_family = AF_INET6;
+	case AID_INET6:
 		memset(&((struct sockaddr_in6 *)&dmask)->sin6_addr, 0xff,
 		    128/8);
 		break;
-	case 0:
+	case AID_UNSPEC:
 		sdst.ss_len = sizeof(struct sockaddr);
 		break;
 	default:
@@ -158,6 +148,7 @@
 		sa.sadb_sa_spi = spi;
 		sa.sadb_sa_state = SADB_SASTATE_MATURE;
 		break;
+#if 0
 	case SADB_X_ADDFLOW:
 	case SADB_X_DELFLOW:
 		bzero(&sa_flowtype, sizeof(sa_flowtype));
@@ -172,6 +163,7 @@
 		sa_protocol.sadb_protocol_direction = 0;
 		sa_protocol.sadb_protocol_proto = 6;
 		break;
+#endif
 	}
 
 	bzero(&sa_src, sizeof(sa_src));
@@ -201,6 +193,7 @@
 		sa_ekey.sadb_key_bits = 8 * elen;
 
 		break;
+#if 0
 	case SADB_X_ADDFLOW:
 	case SADB_X_DELFLOW:
 		/* sa_peer always points to the remote machine */
@@ -220,8 +213,8 @@
 		sa_dst.sadb_address_exttype = SADB_X_EXT_DST_FLOW;
 
 		bzero(&smask, sizeof(smask));
-		switch (src->af) {
-		case AF_INET:
+		switch (src->aid) {
+		case AID_INET:
 			smask.ss_len = sizeof(struct sockaddr_in);
 			smask.ss_family = AF_INET;
 			memset(&((struct sockaddr_in *)&smask)->sin_addr,
@@ -233,7 +226,7 @@
 				    htons(0xffff);
 			}
 			break;
-		case AF_INET6:
+		case AID_INET6:
 			smask.ss_len = sizeof(struct sockaddr_in6);
 			smask.ss_family = AF_INET6;
 			memset(&((struct sockaddr_in6 *)&smask)->sin6_addr,
@@ -247,8 +240,8 @@
 			break;
 		}
 		bzero(&dmask, sizeof(dmask));
-		switch (dst->af) {
-		case AF_INET:
+		switch (dst->aid) {
+		case AID_INET:
 			dmask.ss_len = sizeof(struct sockaddr_in);
 			dmask.ss_family = AF_INET;
 			memset(&((struct sockaddr_in *)&dmask)->sin_addr,
@@ -260,7 +253,7 @@
 				    htons(0xffff);
 			}
 			break;
-		case AF_INET6:
+		case AID_INET6:
 			dmask.ss_len = sizeof(struct sockaddr_in6);
 			dmask.ss_family = AF_INET6;
 			memset(&((struct sockaddr_in6 *)&dmask)->sin6_addr,
@@ -284,6 +277,7 @@
 		sa_dmask.sadb_address_len =
 		    (sizeof(sa_dmask) + ROUNDUP(dmask.ss_len)) / 8;
 		break;
+#endif
 	}
 
 	iov_cnt = 0;
@@ -310,6 +304,7 @@
 		smsg.sadb_msg_len += sa_spirange.sadb_spirange_len;
 		iov_cnt++;
 		break;
+#if 0
 	case SADB_X_ADDFLOW:
 		/* sa_peer always points to the remote machine */
 		iov[iov_cnt].iov_base = &sa_peer;
@@ -351,6 +346,7 @@
 		smsg.sadb_msg_len += sa_dmask.sadb_address_len;
 		iov_cnt++;
 		break;
+#endif
 	}
 
 	/* dest addr */
@@ -411,6 +407,33 @@
 }
 
 int
+pfkey_read(int sd, struct sadb_msg *h)
+{
+	struct sadb_msg hdr;
+
+	if (recv(sd, &hdr, sizeof(hdr), MSG_PEEK) != sizeof(hdr)) {
+		log_warn("pfkey peek");
+		return (-1);
+	}
+
+	/* XXX: Only one message can be outstanding. */
+	if (hdr.sadb_msg_seq == sadb_msg_seq &&
+	    hdr.sadb_msg_pid == pid) {
+		if (h)
+			bcopy(&hdr, h, sizeof(hdr));
+		return (0);
+	}
+
+	/* not ours, discard */
+	if (read(sd, &hdr, sizeof(hdr)) == -1) {
+		log_warn("pfkey read");
+		return (-1);
+	}
+
+	return (1);
+}
+
+int
 pfkey_reply(int sd, u_int32_t *spip)
 {
 	struct sadb_msg hdr, *msg;
@@ -418,23 +441,13 @@
 	struct sadb_sa *sa;
 	u_int8_t *data;
 	ssize_t len;
+	int rv;
 
-	for (;;) {
-		if (recv(sd, &hdr, sizeof(hdr), MSG_PEEK) != sizeof(hdr)) {
-			log_warn("pfkey peek");
+	do {
+		rv = pfkey_read(sd, &hdr);
+		if (rv == -1)
 			return (-1);
-		}
-
-		if (hdr.sadb_msg_seq == sadb_msg_seq &&
-		    hdr.sadb_msg_pid == pid)
-			break;
-
-		/* not ours, discard */
-		if (read(sd, &hdr, sizeof(hdr)) == -1) {
-			log_warn("pfkey read");
-			return (-1);
-		}
-	}
+	} while (rv);
 
 	if (hdr.sadb_msg_errno != 0) {
 		errno = hdr.sadb_msg_errno;
@@ -550,6 +563,7 @@
 int
 pfkey_ipsec_establish(struct peer *p)
 {
+#if 0
 	uint8_t satype = SADB_SATYPE_ESP;
 
 	switch (p->auth.method) {
@@ -621,6 +635,9 @@
 
 	p->auth.established = 1;
 	return (0);
+#else
+	return (-1);
+#endif
 }
 
 int
@@ -660,6 +677,7 @@
 		break;
 	}
 
+#if 0
 	if (pfkey_flow(fd, satype, SADB_X_DELFLOW, IPSP_DIRECTION_OUT,
 	    &p->auth.local_addr, &p->conf.remote_addr, 0, BGP_PORT) < 0)
 		return (-1);
@@ -681,6 +699,7 @@
 	if (pfkey_flow(fd, satype, SADB_X_DELFLOW, IPSP_DIRECTION_IN,
 	    &p->conf.remote_addr, &p->auth.local_addr, BGP_PORT, 0) < 0)
 		return (-1);
+#endif
 	if (pfkey_reply(fd, NULL) < 0)
 		return (-1);
 
@@ -730,11 +749,9 @@
 		if (errno == EPROTONOSUPPORT) {
 			log_warnx("PF_KEY not available, disabling ipsec");
 			sysdep->no_pfkey = 1;
-			return (0);
-		} else {
-			log_warn("PF_KEY socket");
 			return (-1);
-		}
+		} else
+			fatal("pfkey setup failed");
 	}
-	return (0);
+	return (fd);
 }

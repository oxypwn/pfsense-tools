--- src/racoon/isakmp.c.orig	2009-06-09 00:06:21.000000000 -0400
+++ src/racoon/isakmp.c	2009-06-09 00:07:38.000000000 -0400
@@ -3249,12 +3249,22 @@
 		 * check in/outbound SAs.
 		 * Select only SAs where src == local and dst == remote (outgoing)
 		 * or src == remote and dst == local (incoming).
+		 * XXX we sometime have src/dst ports set to 0 and want to match
+		 * iph1->local/remote with ports set to 500. This is a bug, see trac:2
 		 */
+#ifdef ENABLE_NATT
+		if ((CMPSADDR(iph1->local, src) || CMPSADDR(iph1->remote, dst)) &&
+			(CMPSADDR(iph1->local, dst) || CMPSADDR(iph1->remote, src))) {
+			msg = next;
+			continue;
+		}
+#else
 		if ((CMPSADDR(iph1->local, src) || CMPSADDR(iph1->remote, dst)) &&
 			(CMPSADDR(iph1->local, dst) || CMPSADDR(iph1->remote, src))) {
 			msg = next;
 			continue;
 		}
+#endif
 
 		proto_id = pfkey2ipsecdoi_proto(msg->sadb_msg_satype);
 		iph2 = getph2bysaidx(src, dst, proto_id, sa->sadb_sa_spi);

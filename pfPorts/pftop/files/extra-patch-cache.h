--- cache.h.orig	2007-11-07 00:34:18.000000000 -0600
+++ cache.h	2013-06-23 06:20:40.000000000 -0500
@@ -31,14 +31,24 @@
 struct sc_ent {
         RB_ENTRY(sc_ent)    tlink;
 	TAILQ_ENTRY(sc_ent) qlink;
+#ifdef HAVE_PFSYNC_STATE
+#if __FreeBSD_version > 1000000
+	u_int32_t	id;
+#else
+	u_int32_t	    id[2];
+#endif
+#else
 	struct pf_addr      addr[2];
+#endif
 	double		    peak;
 	double		    rate;
 	time_t		    t;
 	u_int32_t	    bytes;
+#ifndef HAVE_PFSYNC_STATE
         u_int16_t           port[2];
         u_int8_t            af;
         u_int8_t            proto;
+#endif
 };
 
 int cache_init(int);

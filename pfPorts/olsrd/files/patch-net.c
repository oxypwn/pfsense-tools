--- src/bsd/net.c.orig	2012-03-22 09:32:14.000000000 +0200
+++ src/bsd/net.c	2012-03-22 09:32:47.000000000 +0200
@@ -96,7 +96,7 @@
 #include <net80211/ieee80211_ioctl.h>
 #endif
 
-#if defined __FreeBSD__ || __FreeBSD_kernel__
+#if defined __FreeBSD__ || defined __FreeBSD_kernel__
 #include <net/if_var.h>
 #include <net/ethernet.h>
 #include <netinet/in_var.h>

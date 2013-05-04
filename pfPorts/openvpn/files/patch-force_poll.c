--- src/openvpn/event.c.orig	2013-05-04 23:30:57.000000000 +0000
+++ src/openvpn/event.c	2013-05-04 23:00:04.000000000 +0000
@@ -43,7 +43,7 @@
  * when both are available.
  */
 #if defined(TARGET_DARWIN)
-#define SELECT_PREFERRED_OVER_POLL
+//#define SELECT_PREFERRED_OVER_POLL
 #endif
 
 /*

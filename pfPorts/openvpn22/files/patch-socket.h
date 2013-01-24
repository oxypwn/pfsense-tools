--- socket.h.orig	2011-05-18 14:50:28.000000000 -0400
+++ socket.h	2011-05-18 14:50:39.000000000 -0400
@@ -242,7 +242,7 @@
 
 #if PASSTOS_CAPABILITY
   /* used to get/set TOS. */
-  uint8_t ptos;
+  uint32_t ptos;
   bool ptos_defined;
 #endif
 

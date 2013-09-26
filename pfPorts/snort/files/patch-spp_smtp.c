--- src/dynamic-preprocessors/smtp/spp_smtp.c.orig	2013-02-19 16:14:24.000000000 -0500
+++ src/dynamic-preprocessors/smtp/spp_smtp.c	2013-09-15 18:11:24.000000000 -0400
@@ -600,7 +600,7 @@
         return 0;
     }
 
-    sfPolicyUserDataIterate (smtp_config, CheckFilePolicyConfig);
+    sfPolicyUserDataIterate (smtp_swap_config, CheckFilePolicyConfig);
 
     if (smtp_mime_mempool != NULL)
     {

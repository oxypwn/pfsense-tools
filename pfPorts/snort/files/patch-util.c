--- src/util.c.orig	2013-01-26 17:13:02.000000000 +0100
+++ src/util.c	2013-01-26 17:13:57.000000000 +0100
@@ -516,7 +516,7 @@
     if (snort_conf == NULL)
         return;
 
-    if (ScLogQuiet() && !ScDaemonMode() && !ScLogSyslog())
+    if (ScLogQuiet())
         return;
 
     va_start(ap, format);
@@ -553,7 +553,7 @@
     if (snort_conf == NULL)
         return;
 
-    if (ScLogQuiet() && !ScDaemonMode() && !ScLogSyslog())
+    if (ScLogQuiet())
         return;
 
     va_start(ap, format);

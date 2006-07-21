--- scanner_clamd.c.orig	Mon Dec 12 15:05:01 2005
+++ scanner_clamd.c	Wed Jul 19 23:25:49 2006
@@ -53,6 +53,13 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 
+#ifdef __FreeBSD__
+#include <strfunc.h>
+#ifndef STRFUNC_H
+#error "Please install the strfunc library located in the ports collection at /usr/ports/devel/libstrfunc"
+#endif
+#endif
+
 #include "p3scan.h"
 #include "getlinep3.h"
 

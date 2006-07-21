--- scanner_sample.c.org	Wed Jul 19 21:36:01 2006
+++ scanner_sample.c	Wed Jul 19 21:43:18 2006
@@ -35,10 +35,9 @@
  */
 
 #include <stdio.h>
-#include <malloc.h>
 #include <sys/un.h>
 #include <sys/socket.h>
-
+#include <stdlib.h>
 
 /* we need p3scan.h */
 #include "p3scan.h"

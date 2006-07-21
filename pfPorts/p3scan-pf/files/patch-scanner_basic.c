--- scanner_basic.c.org	Wed Jul 19 21:34:06 2006
+++ scanner_basic.c	Wed Jul 19 21:42:53 2006
@@ -39,8 +39,9 @@
 #include <sys/wait.h>
 #include <sys/stat.h>
 #include <errno.h>
-#include <malloc.h>
 #include <pcre.h>
+#include <stdlib.h>
+#include <netinet/in.h>
 
 #include "p3scan.h"
 

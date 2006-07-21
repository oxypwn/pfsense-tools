--- scanner_bash.c.org	Wed Jul 19 21:33:59 2006
+++ scanner_bash.c	Wed Jul 19 21:42:08 2006
@@ -39,8 +39,9 @@
 #include <sys/wait.h>
 #include <sys/stat.h>
 #include <errno.h>
-#include <malloc.h>
 #include <pcre.h>
+#include <stdlib.h>
+#include <netinet/in.h>
 
 #include "p3scan.h"
 #include "parsefile.h"

--- getlinep3.c.org	Wed Jul 19 22:23:18 2006
+++ getlinep3.c	Wed Jul 19 22:23:31 2006
@@ -37,11 +37,11 @@
 #include <stdio.h>
 #include <unistd.h>
 #include <string.h>
-#include <malloc.h>
 #include <stdarg.h>
 #include <fcntl.h>
 #include <sys/time.h>
 #include <errno.h>
+#include <stdlib.h>
 
 #include "getlinep3.h"
 

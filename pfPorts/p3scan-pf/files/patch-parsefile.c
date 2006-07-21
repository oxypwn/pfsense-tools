--- parsefile.c.org	Wed Jul 19 21:24:50 2006
+++ parsefile.c	Wed Jul 19 21:26:54 2006
@@ -69,9 +69,10 @@
 #include <stdio.h>
 #include <stdlib.h>
 #include <fcntl.h>
-#include <malloc.h>
+#include <stdlib.h>
 #include <string.h>
 #include <sys/stat.h>
+#include <netinet/in.h>
 #include "parsefile.h"
 #include "getlinep3.h"
 #include "p3scan.h"

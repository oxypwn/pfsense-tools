--- scanner_avpd.c.org	Wed Jul 19 21:33:33 2006
+++ scanner_avpd.c	Wed Jul 19 22:04:19 2006
@@ -43,12 +43,12 @@
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
-#include <malloc.h>
 #include <sys/un.h>
 #include <sys/socket.h>
 #include <stdarg.h>
 #include <dirent.h>
 #include <ctype.h>
+#include <netinet/in.h>
 
 #include "p3scan.h"
 
@@ -88,7 +88,7 @@
    if (avp_fd!=-1 && connected==-1){
       do_log(LOG_DEBUG, "Trying to connect to socket");
       if (connect(avp_fd, (struct sockaddr *)(&avp_socket),
-      sizeof(avp_socket.sun_family) + strlen(NodeCtl)) >= 0){
+      SUN_LEN(&avp_socket)) >= 0){
          connected=1;
          do_log(LOG_DEBUG, "avp_socket_connect connected to kavdaemon");
          return 0;

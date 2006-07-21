--- scanner_avpd_new.c.org	Wed Jul 19 21:33:40 2006
+++ scanner_avpd_new.c	Wed Jul 19 22:18:00 2006
@@ -44,7 +44,6 @@
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
-#include <malloc.h>
 #include <sys/un.h>
 #include <sys/socket.h>
 #include <stdarg.h>
@@ -52,6 +51,7 @@
 #include <ctype.h>
 #include <sys/select.h>
 #include <fcntl.h>
+#include <netinet/in.h>
 
 #include "p3scan.h"
 
@@ -101,7 +101,7 @@
    }
    if (avp_fd!=-1 && connected==-1){
       do_log(LOG_DEBUG, "Trying to connect to socket");
-      if (connect(avp_fd, (struct sockaddr *)(&avp_socket),sizeof(avp_socket.sun_family) + strlen(NodeCtl)) >= 0){
+      if (connect(avp_fd, (struct sockaddr *)(&avp_socket),SUN_LEN(&avp_socket)) >= 0){
          int ret;
          if (kav_version==5) {
             fd_set fds;

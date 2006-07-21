--- scanner_trophie.c.org	Wed Jul 19 21:36:39 2006
+++ scanner_trophie.c	Wed Jul 19 22:20:31 2006
@@ -41,11 +41,11 @@
 #include <sys/wait.h>
 #include <sys/stat.h>
 #include <errno.h>
-#include <malloc.h>
 #include <sys/un.h>
 #include <sys/socket.h>
 #include <stdarg.h>
 #include <ctype.h>
+#include <netinet/in.h>
 
 #include "p3scan.h"
 
@@ -75,7 +75,7 @@
     if (trophie_fd!=-1 && connected==-1){
       do_log(LOG_DEBUG, "Trying to connect to socket");
       if (connect(trophie_fd, (struct sockaddr *)(&trophie_socket),
-         sizeof(trophie_socket.sun_family) + strlen(config->virusscanner)) >= 0){
+         SUN_LEN(&trophie_socket)) >= 0){
          connected=1;
          do_log(LOG_DEBUG, "trophie_socket_connect connected");
          return 0;

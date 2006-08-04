--- p3scan.c.orig	Mon Dec 12 15:00:00 2005
+++ p3scan.c	Fri Aug  4 17:32:07 2006
@@ -41,36 +41,40 @@
 TODO: Wanted: white-list support
 TODO: Wanted: no iptables support
 */
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <arpa/inet.h>
-#include <netinet/in.h>
-#include <netinet/ip.h>
-#include <sys/socket.h>
 #include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/wait.h>
+#include <sys/time.h>
+#include <sys/param.h>
+#include <sys/signal.h>
 #include <sys/stat.h>
+#include <sys/statvfs.h>
+#include <sys/ioctl.h>
+#include <net/if.h>
+#include <net/pfvar.h>
+#include <netinet/in.h>
+#include <netinet/in_systm.h>
+#include <netinet/ip.h>
+#include <arpa/inet.h>
 #include <fcntl.h>
 #include <unistd.h>
 #include <stdarg.h>
-#include <sys/signal.h>
-#include <sys/wait.h>
 #include <pwd.h>
 #include <time.h>
-#include <sys/time.h>
 #include <syslog.h>
-#include <sys/param.h>
 #include <ctype.h>
-#include <linux/netfilter_ipv4.h>
-#include <malloc.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
 #include <getopt.h>
 #include <netdb.h>
 #include <libgen.h>
 #include <errno.h>
 #include <dirent.h>
-#include <sys/statvfs.h>
 #include <assert.h>
 #include <sys/select.h>
+#include <sys/ucred.h>
+#include <sys/mount.h>
 
 #include "p3scan.h"
 #include "getline_ssl.h"
@@ -116,6 +120,20 @@
 static int str_tag[8];
 static char smtpstr[LEN];
 
+u_int32_t read_address(const char *s)
+{
+    int a, b, c, d;
+    sscanf(s, "%i.%i.%i.%i", &a, &b, &c, &d);
+    return htonl(a << 24 | b << 16 | c << 8 | d);
+}
+
+void print_address(u_int32_t a)
+{
+    a = ntohl(a);
+    printf("%i.%i.%i.%i", a >> 24 & 255, a >> 16 & 255,
+           a >> 8 & 255, a & 255);
+}
+
 void do_sigterm_proxy2(int signr){
 
    if(config->debug) fprintf(stderr, "do_sigterm_proxy2, signal %i\n", signr);
@@ -699,9 +717,19 @@
 #define COPYMSG "/var/spool/p3scan/copymsg "
    FILE * scanner;
    static char  line[4096*16];
-   struct statvfs fs;
    int htmlfd=0;
 
+   struct statfs fs;
+   if ((ret=statfs(config->virusdir,&fs))!=0) {
+     do_log(LOG_EMERG, "Unable to get available space!");
+     return SCANNER_RET_CRIT; // Should never reach here, but keep it clean. :)
+   }
+   kbfree=fs.f_bavail*fs.f_bsize/1024;
+   if ( config->freespace != 0 && kbfree < config->freespace ){
+     do_log(LOG_CRIT, "Not enough space! Available space: %d", kbfree);
+     return SCANNER_RET_CRIT;
+   }
+
    ret=checktimeout(p);
    if (ret < 0) return SCANNER_RET_CRIT;
    /* See if we want to manipulate the virus notification message before it might be sent */
@@ -1556,6 +1584,8 @@
    struct timeval timeout;
    int scanfd=-1;
    int error;
+   int dev;
+   struct pfioc_natlook nl;
    int maybe_a_space; // signals a space in the keyword for setting USERNAME var
    int clientret, serverret;
    unsigned long len, smtpsze;
@@ -1640,10 +1670,38 @@
       }
    } else {
       if (htonl(INADDR_ANY) == config->targetaddr.sin_addr.s_addr) {
-         if (getsockopt(p->client_fd, SOL_IP, SO_ORIGINAL_DST, &p->server_addr, &p->socksize)){
-            do_log(LOG_CRIT, "ERR: No IP-Conntrack-data (getsockopt failed)");
-            return 1;
+         //if (getsockopt(p->client_fd, SOL_IP, SO_ORIGINAL_DST, &p->server_addr, &p->socksize)){
+         //   do_log(LOG_CRIT, "ERR: No IP-Conntrack-data (getsockopt failed)");
+
+         // Start kernel request
+         dev = open("/dev/pf", O_RDWR);
+         if (dev == -1) {
+           do_log(LOG_NOTICE, "open dev pf failed");
+         } else {
+           memset(&nl, 0, sizeof(struct pfioc_natlook));
+           nl.saddr.v4.s_addr      = p->client_addr.sin_addr.s_addr;
+           nl.sport                = p->client_addr.sin_port;
+           nl.daddr.v4.s_addr      = config->addr.sin_addr.s_addr;
+           nl.dport                = config->addr.sin_port;
+           nl.af                   = AF_INET;
+           nl.proto                = IPPROTO_TCP;
+           nl.direction            = PF_OUT;
+
+           if (ioctl(dev, DIOCNATLOOK, &nl)) ;
+                
+           p->server_addr.sin_addr.s_addr = nl.rdaddr.v4.s_addr;
+           p->server_addr.sin_port = nl.rdport;
+           // printf("internal host "); print_address(nl.rdaddr.v4.s_addr);
+           // printf(":%u\n", ntohs(nl.rdport));
+         }
+
+         close(dev);
+         /*
+         if (getsockname(p->client_fd, (struct sockaddr*)&p->server_addr, &p->socksize)){
+           do_log(LOG_CRIT, "No IP-Conntrack-data (getsockname failed)"); 
+           return 1;
          }
+         */
          /* try to avoid loop */
          if (((ntohl(p->server_addr.sin_addr.s_addr) == INADDR_LOOPBACK)
          && p->server_addr.sin_port == config->addr.sin_port )
@@ -2882,7 +2940,7 @@
    char * responsemsg;
    int virusdirlen=0;
    char chownit[100];
-#define CHOWNCMD "/bin/chown"
+#define CHOWNCMD "/usr/sbin/chown"
    int len=0;
    int ret=0;
    FILE * chowncmd;
@@ -2920,7 +2978,10 @@
       fclose(fp);
    }else do_log(LOG_CRIT, "ERR: Can't write PID to %s", PID_FILE);
    len=strlen(CHOWNCMD)+1+strlen(config->runasuser)+1+strlen(config->runasuser)+1+strlen(config->pidfile)+1;
+   //snprintf(chownit, len, "%s %s:%s %s", CHOWNCMD, config->runasuser, config->runasuser, config->pidfile);
+   do_log(LOG_DEBUG, "%s %s:%s %s=%i",CHOWNCMD, config->runasuser, config->runasuser, config->pidfile, len);
    snprintf(chownit, len, "%s %s:%s %s", CHOWNCMD, config->runasuser, config->runasuser, config->pidfile);
+
    if ((chowncmd=popen(chownit, "r"))==NULL){
       do_log(LOG_ALERT, "ERR: Can't '%s' !!!", chowncmd);
       return SCANNER_RET_ERR;

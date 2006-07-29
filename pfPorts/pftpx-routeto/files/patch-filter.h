--- filter.h	Mon Mar 21 21:39:28 2005
+++ /root/filter.h	Sat Jul 29 00:05:04 2006
@@ -17,7 +17,7 @@
 #define	PFTPX_ANCHOR	"pftpx"
 
 int add_filter(u_int32_t, u_int8_t, struct sockaddr *, struct sockaddr *,
-    u_int16_t);
+    u_int16_t, char *, struct sockaddr *);
 int add_nat(u_int32_t, struct sockaddr *, struct sockaddr *, u_int16_t,
     struct sockaddr *, u_int16_t, u_int16_t);
 int add_rdr(u_int32_t, struct sockaddr *, struct sockaddr *, u_int16_t,

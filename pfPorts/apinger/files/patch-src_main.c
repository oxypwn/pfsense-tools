--- src/main.c.old	2008-07-10 22:36:21.000000000 +0200
+++ src/main.c	2008-07-10 22:36:53.000000000 +0200
@@ -96,7 +96,7 @@
 
 int icmp_sock;
 int icmp6_sock;
-int ident;
+uint16_t ident;
 
 struct timeval next_probe={0,0};
 
@@ -286,6 +286,8 @@
 #ifdef FORKED_RECEIVER
 	signal(SIGCHLD,sigchld_handler);
 #endif
+	logit("Starting Alarm Pinger, apinger(%i)", ident);
+
 	main_loop();
 	if (icmp_sock>=0) close(icmp_sock);
 	if (icmp6_sock>=0) close(icmp6_sock);

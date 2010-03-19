--- src/modem.c.orig	2010-03-19 20:22:04.000000000 +0000
+++ src/modem.c	2010-03-19 20:22:56.000000000 +0000
@@ -514,7 +514,7 @@
     struct ngm_connect	cn;
     char       		path[NG_PATHSIZ];
     int			hotchar = PPP_FLAG;
-#if NGM_TTY_COOKIE < 1226109660
+#if 0
     struct nodeinfo	ngtty;
     int			ldisc = NETGRAPHDISC;
 #else
@@ -534,7 +534,7 @@
     	return(-1);
     }
 
-#if NGM_TTY_COOKIE < 1226109660
+#if 0
     /* Install ng_tty line discipline */
     if (ioctl(m->fd, TIOCSETD, &ldisc) < 0) {
 

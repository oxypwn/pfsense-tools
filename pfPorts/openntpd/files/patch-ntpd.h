$FreeBSD: ports/net/openntpd/files/patch-ntpd.h,v 1.2 2009/11/24 14:55:52 naddy Exp $
--- ntpd.h.orig	2009-11-23 20:37:40.000000000 +0100
+++ ntpd.h	2009-11-23 20:38:12.000000000 +0100
@@ -29,11 +29,12 @@
 #include <pwd.h>
 #include <stdarg.h>
 
+#include "compat.h"
 #include "ntp.h"
 #include <imsg.h>
 
 #define	NTPD_USER	"_ntp"
-#define	CONFFILE	"/etc/ntpd.conf"
+#define	CONFFILE	"%%PREFIX%%/etc/ntpd.conf"
 #define DRIFTFILE	"/var/db/ntpd.drift"
 
 #define	INTERVAL_QUERY_NORMAL		30	/* sync to peers every n secs */

--- server/drivers/hd44780-drivers.h.orig	Sun Jun  3 17:22:58 2007
+++ server/drivers/hd44780-drivers.h	Sun Jun  3 17:24:23 2007
@@ -16,6 +16,7 @@
 # include "hd44780-ext8bit.h"
 # include "hd44780-serialLpt.h"
 # include "hd44780-winamp.h"
+# include "hd44780-ipc2u.h"
 #endif
 #include "hd44780-serial.h"
 #include "hd44780-lis2.h"
@@ -39,6 +40,7 @@
 	{ "8bit",          hd_init_ext8bit,   "\tnone\n" },
 	{ "serialLpt",     hd_init_serialLpt, "\tnone\n" },
 	{ "winamp",        hd_init_winamp,    "\tnone\n" },
+	{ "ipc2u",         hd_init_ipc2u,     "\tnone\n" },
 #endif
 	/* Serial connectiontypes */
 	{ "picanlcd",      hd_init_serial,    "\tnone\n" },

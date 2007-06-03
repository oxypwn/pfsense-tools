--- server/drivers/hd44780-ipc2u.h.orig	Sun Jun  3 16:23:06 2007
+++ server/drivers/hd44780-ipc2u.h	Sun Jun  3 17:19:00 2007
@@ -0,0 +1,9 @@
+#ifndef HD_IPC2U_H
+#define HD_IPC2U_H
+
+#include "lcd.h"					  /* for Driver */
+
+// initialise this particular driver
+int hd_init_ipc2u(Driver *drvthis);
+
+#endif

--- src/util.c	2010-12-09 12:00:46.000000000 -0800
+++ src/util.c	2011-01-31 16:06:06.000000000 -0800
@@ -199,6 +199,12 @@
     LogMessage("           Using ZLIB version: %s\n", zlib_ver);
 #endif
     LogMessage("\n");
+	LogMessage("     ___   Built Date for Snort on Pfsense is Feb. 10, 2011.\n");
+	LogMessage(" ___/ f \\  Orion IPS Patches Copyright (C) 2009-2010 Robert Zelaya.\n");
+	LogMessage("/ p \\___/Sense\n");
+	LogMessage("\\___/   \\\n");
+	LogMessage("    \\___/  Using Snort.org dynamic plugins and SnortSam 2.69.\n");
+	LogMessage("\n");
 
     return 0;
 }

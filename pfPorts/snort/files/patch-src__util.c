diff -ruN snort-2.9.0.5/src/util.c snort-2.9.0.5_bkup/src/util.c
--- ./src/util.c    2011-03-24 07:36:19.000000000 -0700
+++ ./src/util.c       2011-06-20 00:24:22.000000000 -0700
@@ -199,6 +199,12 @@
     LogMessage("           Using ZLIB version: %s\n", zlib_ver);
 #endif
     LogMessage("\n");
+       LogMessage("     ___   Built Date for Snort on Pfsense 2.0 x86 is June 20 2011.\n");
+       LogMessage(" ___/ f \\  2009-2011 Robert Zelaya.\n");
+       LogMessage("/ p \\___/Sense\n");
+       LogMessage("\\___/   \\\n");
+       LogMessage("    \\___/  Using Snort.org dynamic plugins and SnortSam IPS code.\n");
+       LogMessage("\n");

     return 0;
 }


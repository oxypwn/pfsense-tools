--- src/stat_cache.c.orig	2009-05-26 14:00:57.000000000 -0400
+++ src/stat_cache.c	2009-05-26 14:01:50.000000000 -0400
@@ -489,6 +489,12 @@
 
 
 	if (S_ISREG(st.st_mode)) {
+		/* fix broken stat/open for symlinks to reg files with appended slash on freebsd,osx */
+		if (name->ptr[name->used-2] == '/') {
+			errno = ENOTDIR;
+			return HANDLER_ERROR;
+		}
+
 		/* try to open the file to check if we can read it */
 		if (-1 == (fd = open(name->ptr, O_RDONLY))) {
 			return HANDLER_ERROR;

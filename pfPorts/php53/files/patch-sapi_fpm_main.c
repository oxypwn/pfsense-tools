--- sapi/fpm/fpm/fpm_main.c.orig	2013-12-10 20:04:57.000000000 +0100
+++ sapi/fpm/fpm/fpm_main.c	2013-12-15 20:20:37.000000000 +0100
@@ -1871,6 +1872,9 @@
 				return FPM_EXIT_SOFTWARE;
 			}
 
+			if (sapi_cgibin_getenv("NO_HEADERS", sizeof("NO_HEADERS") - 1 TSRMLS_CC))
+				SG(request_info).no_headers = 1;
+
 			/* check if request_method has been sent.
 			 * if not, it's certainly not an HTTP over fcgi request */
 			if (!SG(request_info).request_method) {
@@ -1926,6 +1930,26 @@
 
 			fpm_request_executing();
 
+			if (file_handle.handle.fp && (file_handle.handle.fp != stdin)) {
+                                /* #!php support */
+                                c = fgetc(file_handle.handle.fp);
+                                if (c == '#') {
+                                        while (c != '\n' && c != '\r' && c != EOF) {
+                                                c = fgetc(file_handle.handle.fp);       /* skip to end of line */
+                                        }
+                                        /* handle situations where line is terminated by \r\n */
+                                        if (c == '\r') {
+                                                if (fgetc(file_handle.handle.fp) != '\n') {
+                                                        long pos = ftell(file_handle.handle.fp);
+                                                        fseek(file_handle.handle.fp, pos - 1, SEEK_SET);
+                                                }
+                                        }
+                                        CG(start_lineno) = 2;
+                                } else {
+                                        rewind(file_handle.handle.fp);
+                                }
+                        }
+
 			php_execute_script(&file_handle TSRMLS_CC);
 
 fastcgi_request_done:

--- sapi/fpm/fpm/fpm_main.c.orig	2013-12-15 18:46:07.000000000 +0100
+++ sapi/fpm/fpm/fpm_main.c	2013-12-15 18:46:15.000000000 +0100
@@ -1065,6 +1065,9 @@
 		script_path_translated = env_path_translated;
 	}
 
+	if (sapi_cgibin_getenv("NO_HEADERS", sizeof("NO_HEADERS") - 1 TSRMLS_CC))
+		SG(request_info).no_headers = 1;
+
 	/* initialize the defaults */
 	SG(request_info).path_translated = NULL;
 	SG(request_info).request_method = NULL;

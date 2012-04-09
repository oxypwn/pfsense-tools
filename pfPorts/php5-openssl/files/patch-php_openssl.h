--- php_openssl.h.orig	2010-07-01 17:24:24.000000000 -0400
+++ php_openssl.h	2010-07-01 17:24:40.000000000 -0400
@@ -74,6 +74,13 @@
 PHP_FUNCTION(openssl_csr_sign);
 PHP_FUNCTION(openssl_csr_get_subject);
 PHP_FUNCTION(openssl_csr_get_public_key);
+
+PHP_FUNCTION(openssl_crl_new);
+PHP_FUNCTION(openssl_crl_revoke_cert_by_serial);
+PHP_FUNCTION(openssl_crl_revoke_cert);
+PHP_FUNCTION(openssl_crl_export);
+PHP_FUNCTION(openssl_crl_export_file);
+
 #else
 
 #define phpext_openssl_ptr NULL

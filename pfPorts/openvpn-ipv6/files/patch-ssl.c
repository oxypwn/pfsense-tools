--- ssl.c
+++ ssl.c
@@ -1874,13 +1874,15 @@ init_ssl (const struct options *options)
     }
   else
 #endif
+    {
 #ifdef ENABLE_X509ALTUSERNAME
-  x509_username_field = (char *) options->x509_username_field;
+      x509_username_field = (char *) options->x509_username_field;
 #else
-  x509_username_field = X509_USERNAME_FIELD_DEFAULT;
+      x509_username_field = X509_USERNAME_FIELD_DEFAULT;
 #endif
-  SSL_CTX_set_verify (ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT,
-			verify_callback);
+      SSL_CTX_set_verify (ctx, SSL_VERIFY_PEER | SSL_VERIFY_FAIL_IF_NO_PEER_CERT,
+                          verify_callback);
+    }
 
   /* Connection information callback */
   SSL_CTX_set_info_callback (ctx, info_callback);


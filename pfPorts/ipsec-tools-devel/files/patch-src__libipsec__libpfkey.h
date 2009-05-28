--- src/libipsec/libpfkey.h.orig        2009-05-28 12:34:31.000000000 -0400
+++ src/libipsec/libpfkey.h     2009-05-28 12:34:52.000000000 -0400
@@ -161,10 +161,8 @@

 /* XXX should be somewhere else !!!
  */
-#ifdef SADB_X_NAT_T_NEW_MAPPING
 #define PFKEY_ADDR_X_PORT(ext) (ntohs(((struct sadb_x_nat_t_port *)ext)->sadb_x_nat_t_port_port))
 #define PFKEY_ADDR_X_NATTYPE(ext) ( ext != NULL && ((struct sadb_x_nat_t_type *)ext)->sadb_x_nat_t_type_type )
-#endif


 int pfkey_open __P((void));


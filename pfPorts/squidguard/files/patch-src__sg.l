diff -r da91afd19d38 src/sg.l
--- src/sg.l	Wed Sep 04 17:46:45 2013 -0300
+++ src/sg.l	Wed Sep 04 17:52:22 2013 -0300
@@ -105,6 +105,8 @@
 ^acl         return ACL;
 ^dbhome                return DBHOME;
 ^logdir                return LOGDIR;
+^stripntdomain return STRIPNTDOMAIN;
+^striprealm    return STRIPREALM;
 ^ldapcachetime return LDAPCACHETIME;
 ^ldapprotover  return LDAPPROTOVER;
 ^ldapbinddn    { BEGIN LDAPDN_STATE; return LDAPBINDDN; }

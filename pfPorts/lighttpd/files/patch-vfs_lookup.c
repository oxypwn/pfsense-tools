--- vfs_lookup.c        Thu Oct  5 16:25:22 2000
+++ vfs_lookup.c.new    Thu Oct  5 16:24:44 2000
@@ -504,6 +504,14 @@
        }
 
        /*
+        * Check for bogus trailing slashes.
+        */
+       if (trailing_slash && dp->v_type != VDIR) {
+               error = ENOTDIR;
+               goto bad2;
+       }
+
+       /*
         * Check for symbolic link
         */
        if ((dp->v_type == VLNK) &&
@@ -515,14 +523,6 @@
                        goto bad2;
                }
                return (0);
-       }
-
-       /*
-        * Check for bogus trailing slashes.
-        */
-       if (trailing_slash && dp->v_type != VDIR) {
-               error = ENOTDIR;
-               goto bad2;
        }
 
 nextname:


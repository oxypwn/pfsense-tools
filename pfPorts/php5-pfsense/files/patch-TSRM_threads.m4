--- TSRM/threads.m4.orig	Wed Apr 27 13:22:18 2005
+++ TSRM/threads.m4	Tue Sep  5 00:17:21 2006
@@ -164,7 +164,7 @@
 dnl
 AC_DEFUN([PTHREADS_ASSIGN_VARS],[
 if test -n "$ac_cv_pthreads_lib"; then
-  LIBS="$LIBS -l$ac_cv_pthreads_lib"
+  LIBS="$LIBS $ac_cv_pthreads_lib"
 fi
 
 if test -n "$ac_cv_pthreads_cflags"; then

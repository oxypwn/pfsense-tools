--- sys/amd64/amd64/mp_machdep.c.orig   2009-05-01 00:59:55.000000000 +0400
+++ sys/amd64/amd64/mp_machdep.c        2009-05-01 01:00:20.000000000 +0400
@@ -309,6 +309,8 @@ cpu_topo(void)
 {
        int cg_flags;

+       topo_probe();
+
        /*
         * Determine whether any threading flags are
         * necessry.
$ diff -urp sys/i386/i386/mp_machdep.c.orig sys/i386/i386/mp_machdep.c
--- sys/i386/i386/mp_machdep.c.orig     2009-05-01 01:01:53.000000000 +0400
+++ sys/i386/i386/mp_machdep.c  2009-05-01 01:01:41.000000000 +0400
@@ -362,6 +362,8 @@ cpu_topo(void)
 {
        int cg_flags;

+       topo_probe();
+
        /*
         * Determine whether any threading flags are
         * necessry.
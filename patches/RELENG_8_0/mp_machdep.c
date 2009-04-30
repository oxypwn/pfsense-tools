--- sys/amd64/amd64/mp_machdep.c	(revision 191699)
+++ sys/amd64/amd64/mp_machdep.c	(working copy)
@@ -214,6 +214,8 @@
 		else if (type == CPUID_TYPE_CORE)
 			cpu_cores = cnt;
 	}
+	if (cpu_cores == 0)
+		cpu_cores = 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
 	cpu_cores /= cpu_logical;
--- sys/i386/i386/mp_machdep.c	(revision 191699)
+++ sys/i386/i386/mp_machdep.c	(working copy)
@@ -267,6 +267,8 @@
 		else if (type == CPUID_TYPE_CORE)
 			cpu_cores = cnt;
 	}
+	if (cpu_cores == 0)
+		cpu_cores = 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
 	cpu_cores /= cpu_logical;

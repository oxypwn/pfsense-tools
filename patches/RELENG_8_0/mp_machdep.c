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
@@ -352,7 +354,7 @@
 	else if (cpu_high)
 		topo_probe_0x4();
 	if (cpu_cores == 0)
-		cpu_cores = mp_ncpus;
+		cpu_cores = mp_ncpus > 0 ? mp_ncpus : 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
 }
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
@@ -299,7 +301,7 @@
 	else if (cpu_high)
 		topo_probe_0x4();
 	if (cpu_cores == 0)
-		cpu_cores = mp_ncpus;
+		cpu_cores = mp_ncpus > 0 ? mp_ncpus : 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
 }
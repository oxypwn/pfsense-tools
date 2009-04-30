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
@@ -345,16 +347,21 @@
 static void
 topo_probe(void)
 {
+	static int cpu_topo_probed = 0;
 
+	if (cpu_topo_probed)
+		return;
+
 	logical_cpus = logical_cpus_mask = 0;
 	if (cpu_high >= 0xb)
 		topo_probe_0xb();
 	else if (cpu_high)
 		topo_probe_0x4();
 	if (cpu_cores == 0)
-		cpu_cores = mp_ncpus;
+		cpu_cores = mp_ncpus > 0 ? mp_ncpus : 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
+	cpu_topo_probed = 1;
 }
 
 struct cpu_group *
@@ -366,6 +373,7 @@
 	 * Determine whether any threading flags are
 	 * necessry.
 	 */
+	topo_probe();
 	if (cpu_logical > 1 && hyperthreading_cpus)
 		cg_flags = CG_FLAG_HTT;
 	else if (cpu_logical > 1)
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
@@ -292,16 +294,21 @@
 static void
 topo_probe(void)
 {
+	static int cpu_topo_probed = 0;
 
+	if (cpu_topo_probed)
+		return;
+
 	logical_cpus = logical_cpus_mask = 0;
 	if (cpu_high >= 0xb)
 		topo_probe_0xb();
 	else if (cpu_high)
 		topo_probe_0x4();
 	if (cpu_cores == 0)
-		cpu_cores = mp_ncpus;
+		cpu_cores = mp_ncpus > 0 ? mp_ncpus : 1;
 	if (cpu_logical == 0)
 		cpu_logical = 1;
+	cpu_topo_probed = 1;
 }
 
 struct cpu_group *
@@ -313,6 +320,7 @@
 	 * Determine whether any threading flags are
 	 * necessry.
 	 */
+	topo_probe();
 	if (cpu_logical > 1 && hyperthreading_cpus)
 		cg_flags = CG_FLAG_HTT;
 	else if (cpu_logical > 1)

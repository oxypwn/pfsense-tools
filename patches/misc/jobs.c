--- jobs.c	Thu Mar 16 02:29:57 2006
+++ jobs.c.sku	Thu Mar 16 02:33:10 2006
@@ -50,6 +50,7 @@
 #include <sys/resource.h>
 #include <paths.h>
 #include <sys/ioctl.h>
+#include <sys/stat.h>
 
 #include "shell.h"
 #if JOBS
@@ -147,7 +148,9 @@
 			initialpgrp = tcgetpgrp(ttyfd);
 			if (initialpgrp < 0) {
 out:				out2str("sh: can't access tty; job control turned off\n");
+				system("touch /tmp/ttybug");
 				mflag = 0;
+				exit(-1);
 				return;
 			}
 			if (initialpgrp == -1)
@@ -170,6 +173,8 @@
 		setsignal(SIGTSTP);
 		setsignal(SIGTTOU);
 		setsignal(SIGTTIN);
+		system("touch /tmp/ttybug");
+		exit(-1);
 	}
 	jobctl = on;
 }
@@ -200,8 +205,9 @@
 	int status;
 
 	jp = getjob(argv[1]);
-	if (jp->jobctl == 0)
+	if (jp->jobctl == 0) {
 		error("job not created under job control");
+	}
 	out1str(jp->ps[0].cmd);
 	out1c('\n');
 	flushout(&output);
@@ -742,6 +748,7 @@
 		TRACE(("Fork failed, errno=%d\n", errno));
 		INTON;
 		error("Cannot fork: %s", strerror(errno));
+		system("touch /tmp/ttybug");
 		exit(-1);
 	}
 	if (pid == 0) {
@@ -765,8 +772,8 @@
 			if (setpgid(0, pgrp) == 0 && mode == FORK_FG) {
 				/*** this causes superfluous TIOCSPGRPS ***/
 				if (tcsetpgrp(ttyfd, pgrp) < 0) {
-					system("touch /tmp/ttybug");;
 					error("tcsetpgrp failed, errno=%d", errno);
+					system("touch /tmp/ttybug");
 					exit(-1);
 				}
 			}
@@ -873,6 +880,7 @@
 	if (jp->jobctl) {
 		if (tcsetpgrp(ttyfd, mypgrp) < 0) {
 			error("tcsetpgrp failed, errno=%d\n", errno);
+			system("touch /tmp/ttybug");
 			exit(-1);
 		}
 	}
@@ -1247,3 +1255,19 @@
 	}
 	cmdnextc = q;
 }
+
+/* Check if file exists */
+int fexist(char * filename)
+{
+  struct stat buf;
+
+  if (( stat (filename, &buf)) < 0)
+    return (0);
+
+  if (! S_ISREG(buf.st_mode)) {
+    return (0);
+  }
+
+  return(1);
+} 
+

--- jobs.c	Thu Jan 12 05:24:46 2006
+++ jobs.c.sku	Mon Mar 13 06:58:09 2006
@@ -148,7 +148,9 @@
 			if (initialpgrp < 0) {
 out:				out2str("sh: can't access tty; job control turned off\n");
 				mflag = 0;
-				return;
+				out2str("We are sorry.  We need to logout now, please type 0 at the prompt");
+				system("touch /tmp/ttybug");
+				exit(-1);
 			}
 			if (initialpgrp == -1)
 				initialpgrp = getpgrp();

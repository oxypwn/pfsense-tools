--- src/snortsam.c	2009-11-26 18:04:12.000000000 -0800
+++ src/snortsam.c	2011-01-31 15:11:21.000000000 -0800
@@ -2809,7 +2809,7 @@
 */
 	safecopy(buf,SNORTSAM_REV+11);
 	buf[strlen(SNORTSAM_REV+11)-2]=0;
-	printf("\nSnortSam, v %s.\nCopyright (c) 2001-2009 Frank Knobbe <frank@knobbe.us>. All rights reserved.\n\n",buf);
+	printf("\nSnortSam, v %s.\nCopyright (c) 2001-2009 Frank Knobbe <frank@knobbe.us>. All rights reserved.\nBuild Date for SnortSam on Pfsense is Feb. 10, 2011, Robert Zelaya\n\n",buf);
 	
 	TwoFish_srand=FALSE;			/* Since we need to rand() before any TwoFish call, */
 									/* there is no need for TwoFish to initialze rand as well. */

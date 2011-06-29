diff -ruN snortsam/src/snortsam.c snortsam_bkup/src/snortsam.c
--- ./src/snortsam.c	2011-02-20 10:26:17.000000000 -0800
+++ ./src/snortsam.c	2011-06-20 01:36:08.000000000 -0700
@@ -2810,7 +2810,7 @@
 */
 	safecopy(buf,SNORTSAM_REV+11);
 	buf[strlen(SNORTSAM_REV+11)-2]=0;
-	printf("\nSnortSam, v %s.\nCopyright (c) 2001-2009 Frank Knobbe <frank@knobbe.us>. All rights reserved.\n\n",buf);
+	printf("\nSnortSam, v %s.\nCopyright (c) 2001-2009 Frank Knobbe <frank@knobbe.us>. All rights reserved.\n\nBuild Date for SnortSam on Pfsense 2.0 x86 is June 19, 2011, Robert Zelaya.\n\n",buf);
 	
 	TwoFish_srand=FALSE;			/* Since we need to rand() before any TwoFish call, */
 									/* there is no need for TwoFish to initialze rand as well. */

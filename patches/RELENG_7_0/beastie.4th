Index: beastie.4th
===================================================================
RCS file: /home/ncvs/src/sys/boot/forth/beastie.4th,v
retrieving revision 1.12
diff -u -r1.12 beastie.4th
--- beastie.4th	31 Mar 2006 21:36:17 -0000	1.12
+++ beastie.4th	9 Nov 2008 23:20:21 -0000
@@ -93,32 +93,33 @@
 	     at-xy ."        `--{__________)"
 ;
 
-: fbsdbw-logo ( x y -- )
-	2dup at-xy ."      ______" 1+
-	2dup at-xy ."     |  ____| __ ___  ___ " 1+
-	2dup at-xy ."     | |__ | '__/ _ \/ _ \" 1+
-	2dup at-xy ."     |  __|| | |  __/  __/" 1+
-	2dup at-xy ."     | |   | | |    |    |" 1+
-	2dup at-xy ."     |_|   |_|  \___|\___|" 1+
-	2dup at-xy ."      ____   _____ _____" 1+
-	2dup at-xy ."     |  _ \ / ____|  __ \" 1+
-	2dup at-xy ."     | |_) | (___ | |  | |" 1+
-	2dup at-xy ."     |  _ < \___ \| |  | |" 1+
-	2dup at-xy ."     | |_) |____) | |__| |" 1+
-	2dup at-xy ."     |     |      |      |" 1+
-	     at-xy ."     |____/|_____/|_____/"
+: pfsense-logo ( x y -- )
+	2dup at-xy . "                         " 1+
+	2dup at-xy . "          ______         " 1+
+	2dup at-xy . "         /      \        " 1+
+	2dup at-xy . "   _____/    f   \       " 1+
+	2dup at-xy . "  /     \        /       " 1+
+	2dup at-xy . " /   p   \______/  Sense " 1+
+	2dup at-xy . " \       /      \        " 1+
+	2dup at-xy . "  \_____/        \       " 1+
+	2dup at-xy . "        \        /       " 1+
+	2dup at-xy . "         \______/        " 1+
+	2dup at-xy . "                         " 1+
+	2dup at-xy . "                         " 1+
+	2dup at-xy . "                         " 1+
+	     at-xy . "                         " 
 ;
 
 : print-logo ( x y -- )
 	s" loader_logo" getenv
 	dup -1 = if
 		drop
-		fbsdbw-logo
+		pfsense-logo
 		exit
 	then
 	2dup s" fbsdbw" compare-insensitive 0= if
 		2drop
-		fbsdbw-logo
+		pfsense-logo
 		exit
 	then
 	2dup s" beastiebw" compare-insensitive 0= if
@@ -137,7 +138,7 @@
 		exit
 	then
 	2drop
-	fbsdbw-logo
+	pfsense-logo
 ;
 
 : acpienabled? ( -- flag )

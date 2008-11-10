Index: beastie.4th
===================================================================
RCS file: /home/ncvs/src/sys/boot/forth/beastie.4th,v
retrieving revision 1.12
diff -u -r1.12 beastie.4th
--- beastie.4th	31 Mar 2006 21:36:17 -0000	1.12
+++ beastie.4th	10 Nov 2008 00:07:47 -0000
@@ -94,19 +94,20 @@
 ;
 
 : fbsdbw-logo ( x y -- )
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
+	2dup at-xy ."                              " 1+
+	2dup at-xy ."                             " 1+
+	2dup at-xy ."                             " 1+
+	2dup at-xy ."                 ______         " 1+
+	2dup at-xy ."                /      \        " 1+
+	2dup at-xy ."          _____/    f   \       " 1+
+	2dup at-xy ."         /     \        /       " 1+
+	2dup at-xy ."        /   p   \______/  Sense " 1+
+	2dup at-xy ."        \       /      \        " 1+
+	2dup at-xy ."         \_____/        \       " 1+
+	2dup at-xy ."               \        /       " 1+
+	2dup at-xy ."                \______/        " 1+
+	2dup at-xy ."                             " 1+
+	     at-xy ."                             "
 ;
 
 : print-logo ( x y -- )

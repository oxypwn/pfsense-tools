Index: beastie.4th
===================================================================
RCS file: /home/ncvs/src/sys/boot/forth/beastie.4th,v
retrieving revision 1.12
diff -u -r1.12 beastie.4th
--- beastie.4th	31 Mar 2006 21:36:17 -0000	1.12
+++ beastie.4th	10 Nov 2008 00:31:19 -0000
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
@@ -178,11 +179,11 @@
 	clear
 	46 4 print-logo
 	42 20 2 2 box
-	13 6 at-xy ." Welcome to FreeBSD!"
-	printmenuitem ."  Boot FreeBSD [default]" bootkey !
+	13 6 at-xy ." Welcome to pfSense!"
+	printmenuitem ."  Boot pfSense [default]" bootkey !
 	s" arch-i386" environment? if
 		drop
-		printmenuitem ."  Boot FreeBSD with ACPI " bootacpikey !
+		printmenuitem ."  Boot pfSense with ACPI " bootacpikey !
 		acpienabled? if
 			." disabled"
 		else
@@ -191,9 +192,9 @@
 	else
 		-2 bootacpikey !
 	then
-	printmenuitem ."  Boot FreeBSD in Safe Mode" bootsafekey !
-	printmenuitem ."  Boot FreeBSD in single user mode" bootsinglekey !
-	printmenuitem ."  Boot FreeBSD with verbose logging" bootverbosekey !
+	printmenuitem ."  Boot pfSense in Safe Mode" bootsafekey !
+	printmenuitem ."  Boot pfSense in single user mode" bootsinglekey !
+	printmenuitem ."  Boot pfSense with verbose logging" bootverbosekey !
 	printmenuitem ."  Escape to loader prompt" escapekey !
 	printmenuitem ."  Reboot" rebootkey !
 	menuX @ 20 at-xy

--- ../ifstated-20050505.orig/parse.y   Thu May  5 11:51:24 2005
+++ parse.y     Thu May  5 12:06:07 2005
@@ -1,4 +1,5 @@
 /*	$OpenBSD: parse.y,v 1.9 2005/02/07 12:41:53 mcbride Exp $	*/
+/*	$OpenBSD: parse.y,v 1.14 2006/05/26 01:06:12 deraadt Exp $	*/
 
 /*
  * Copyright (c) 2004 Ryan McBride <mcbride@openbsd.org>
@@ -24,6 +25,7 @@
 #include <sys/types.h>
 #include <sys/time.h>
 #include <sys/socket.h>
+#include <sys/limits.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <net/if.h>
@@ -35,7 +37,8 @@
 #include <stdio.h>
 #include <string.h>
 #include <syslog.h>
-#include <event.h>
+#include <sys/event.h>
+#include <limits.h>
 
 #include "ifstated.h"
 
@@ -251,7 +254,7 @@
 				curaction = curstate->init;
 			else
 				curaction = conf->always.init;
-		} optnl '{' optnl action_l '}' {
+		} action_block {
 			if (curstate != NULL)
 				curaction = curstate->always;
 			else
@@ -452,9 +455,7 @@
 	while ((c = getc(f)) == '\\') {
 		next = getc(f);
 		if (next != '\n') {
-			if (isspace(next))
-				yyerror("whitespace after \\");
-			ungetc(next, f);
+			c = next;
 			break;
 		}
 		yylval.lineno = lineno;
@@ -674,6 +675,7 @@
 
 	if (errors) {
 		clear_config(conf);
+		errors = 0;
 		return (NULL);
 	}
 
@@ -699,6 +701,11 @@
 				break;
 			}
 		}
+		if (state == NULL) {
+			fprintf(stderr, "error: state '%s' not declared\n",
+			    action->act.statename);
+			errors++;
+		}
 		break;
 	}
 	case IFSD_ACTION_CONDITION:
@@ -882,3 +889,4 @@
 	external->refcount++;
 	return (external);
 }
+

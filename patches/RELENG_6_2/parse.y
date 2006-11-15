--- parse.y.orig	Fri May 27 04:25:39 2005
+++ parse.y	Fri May 27 04:30:17 2005
@@ -3799,7 +3799,7 @@
 		yyerror("keep state on block rules doesn't make sense");
 		problems++;
 	}
-	if ((r->tagname[0] || r->match_tagname[0]) && !r->keep_state &&
+	if (r->tagname[0] && !r->keep_state &&
 	    r->action == PF_PASS) {
 		yyerror("tags cannot be used without keep state");
 		problems++;

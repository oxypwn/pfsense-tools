--- src_old/racoon/grabmyaddr.c	2011-07-11 14:51:13.000000000 +0000
+++ src/racoon/grabmyaddr.c	2011-07-11 14:53:53.000000000 +0000
@@ -767,9 +767,9 @@
 #endif
 		break;
 	default:
-		plog(LLV_WARNING, LOCATION, NULL,
-		     "unrecognized route message with rtm_type: %d",
-		     rtm->rtm_type);
+		//plog(LLV_WARNING, LOCATION, NULL,
+		//     "unrecognized route message with rtm_type: %d",
+		//     rtm->rtm_type);
 		break;
 	}
 }

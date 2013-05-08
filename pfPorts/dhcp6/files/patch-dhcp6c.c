diff --git a/dhcp6c.c b/dhcp6c.c
index 1caaaa5..3291e52 100644
--- dhcp6c.c
+++ dhcp6c.c
@@ -1828,15 +1828,6 @@ client6_recvreply(ifp, dh6, len, optinfo)
 	}
 
 	/*
-	 * Call the configuration script, if specified, to handle various
-	 * configuration parameters.
-	 */
-	if (ifp->scriptpath != NULL && strlen(ifp->scriptpath) != 0) {
-		dprintf(LOG_DEBUG, FNAME, "executes %s", ifp->scriptpath);
-		client6_script(ifp->scriptpath, state, optinfo);
-	}
-
-	/*
 	 * Set refresh timer for configuration information specified in
 	 * information-request.  If the timer value is specified by the server
 	 * in an information refresh time option, use it; use the protocol
@@ -1888,6 +1879,15 @@ client6_recvreply(ifp, dh6, len, optinfo)
 		    &optinfo->serverID, ev->authparam);
 	}
 
+	/*
+	 * Call the configuration script, if specified, to handle various
+	 * configuration parameters.
+	 */
+	if (ifp->scriptpath != NULL && strlen(ifp->scriptpath) != 0) {
+		dprintf(LOG_DEBUG, FNAME, "executes %s", ifp->scriptpath);
+		client6_script(ifp->scriptpath, state, optinfo);
+	}
+
 	dhcp6_remove_event(ev);
 
 	if (state == DHCP6S_RELEASE) {

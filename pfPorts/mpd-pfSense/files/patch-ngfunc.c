--- src/ngfunc.c.orig	2008-04-16 13:29:08.000000000 -0400
+++ src/ngfunc.c	2008-04-16 13:29:16.000000000 -0400
@@ -249,6 +249,7 @@
       struct ng_mesg	reply;
   }			u;
   char		path[NG_PATHLEN + 1];
+#if 0
   char		*eptr;
   int		ifnum;
 
@@ -258,9 +259,10 @@
   ifnum = (int)strtoul(ifname + strlen(NG_IFACE_IFACE_NAME), &eptr, 10);
   if (ifnum < 0 || *eptr != '\0')
     return(-1);
+#endif
 
   /* See if interface exists */
-  snprintf(path, sizeof(path), "%s%d:", NG_IFACE_IFACE_NAME, ifnum);
+  snprintf(path, sizeof(path), "%s:", ifname);
   if (NgSendMsg(b->csock, path, NGM_GENERIC_COOKIE, NGM_NODEINFO, NULL, 0) < 0)
     return(0);
   if (NgRecvMsg(b->csock, &u.reply, sizeof(u), NULL) < 0) {
@@ -270,7 +272,7 @@
 
   /* It exists */
   if (buf != NULL)
-    snprintf(buf, max, "%s%d", NG_IFACE_IFACE_NAME, ifnum);
+    snprintf(buf, max, "%s", ifname);
   return(1);
 }
 
@@ -294,30 +296,10 @@
   struct nodeinfo	*const ni = (struct nodeinfo *)(void *)u.reply.data;
   struct ngm_rmhook	rm;
   struct ngm_mkpeer	mp;
+  struct ngm_name	nm;
+  char path[NG_PATHLEN + 1];
   int			rtn = 0;
 
-  /* If ifname is not null, create interfaces until it gets created */
-  if (ifname != NULL) {
-    int count;
-
-    for (count = 0; count < MAX_IFACE_CREATE; count++) {
-      switch (NgFuncIfaceExists(b, ifname, buf, max)) {
-      case 1:				/* ok now it exists */
-	return(0);
-      case 0:				/* nope, create another one */
-	NgFuncCreateIface(b, NULL, NULL, 0);
-	break;
-      case -1:				/* something weird happened */
-	return(-1);
-      default:
-	assert(0);
-      }
-    }
-    Log(LG_ERR, ("[%s] created %d interfaces, that's too many!",
-      b->name, count));
-    return(-1);
-  }
-
   /* Create iface node (as a temporary peer of the socket node) */
   snprintf(mp.type, sizeof(mp.type), "%s", NG_IFACE_NODE_TYPE);
   snprintf(mp.ourhook, sizeof(mp.ourhook), "%s", TEMPHOOK);
@@ -328,7 +310,6 @@
       b->name, NG_IFACE_NODE_TYPE, ".", mp.ourhook, strerror(errno)));
     return(-1);
   }
-
   /* Get the new node's name */
   if (NgSendMsg(b->csock, TEMPHOOK,
       NGM_GENERIC_COOKIE, NGM_NODEINFO, NULL, 0) < 0) {
@@ -342,6 +323,28 @@
     rtn = -1;
     goto done;
   }
+
+if (ifname != NULL) {
+  /* Set the new node's name */
+  bzero(path, sizeof(path));
+  snprintf(path, sizeof(path), "%s:", ni->name);
+snprintf(nm.name, sizeof(nm.name), "%s", ifname);
+  if (NgSendMsg(b->csock, path,
+      NGM_IFACE_COOKIE, NGM_IFACE_SET_IFNAME, nm.name, sizeof(nm.name)) < 0) {
+    Log(LG_ERR, ("[%s] %s: %s", b->name, "NGM_NODEINFO", strerror(errno)));
+    rtn = -1;
+    goto done;
+  }
+
+  /* Set the new node's name */
+  if (NgSendMsg(b->csock, path,
+      NGM_GENERIC_COOKIE, NGM_NAME, &nm, sizeof(nm)) < 0) {
+    Log(LG_ERR, ("[%s] %s: %s", b->name, "NGM_NODEINFO", strerror(errno)));
+    rtn = -1;
+    goto done;
+  }
+  snprintf(buf, max, "%s", ifname);
+} else 
   snprintf(buf, max, "%s", ni->name);
 
 done:
@@ -355,7 +358,7 @@
   }
 
   /* Done */
-  return(rtn);
+  return (rtn);
 }
 
 /*

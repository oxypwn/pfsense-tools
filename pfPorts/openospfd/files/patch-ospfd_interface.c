--- ospfd/interface.c.orig	2010-03-18 20:06:01.000000000 +0000
+++ ospfd/interface.c	2010-03-18 20:05:00.000000000 +0000
@@ -687,6 +687,7 @@
 	struct in_addr			addr;
 	unsigned int			ifindex;
 	int				count;
+	char				name[IF_NAMESIZE];
 };
 
 LIST_HEAD(,if_group_count) ifglist = LIST_HEAD_INITIALIZER(ifglist);
@@ -700,15 +701,21 @@
 	switch (iface->type) {
 	case IF_TYPE_POINTOPOINT:
 	case IF_TYPE_BROADCAST:
-		LIST_FOREACH(ifg, &ifglist, entry)
+		LIST_FOREACH(ifg, &ifglist, entry) {
 			if (iface->ifindex == ifg->ifindex &&
 			    addr->s_addr == ifg->addr.s_addr)
 				break;
+			if (!strcmp(iface->name, ifg->name)) {
+				ifg->count--;
+				break;
+			}
+		}
 		if (ifg == NULL) {
 			if ((ifg = calloc(1, sizeof(*ifg))) == NULL)
 				fatal("if_join_group");
 			ifg->addr.s_addr = addr->s_addr;
 			ifg->ifindex = iface->ifindex;
+			strlcpy(ifg->name, iface->name, sizeof(ifg->name));
 			LIST_INSERT_HEAD(&ifglist, ifg, entry);
 		}
 

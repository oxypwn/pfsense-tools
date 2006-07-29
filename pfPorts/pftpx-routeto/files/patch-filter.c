--- filter.c	Mon Mar 21 21:39:28 2005
+++ /root/filter.c	Sat Jul 29 00:05:04 2006
@@ -55,7 +55,8 @@
 
 int
 add_filter(u_int32_t id, u_int8_t dir, struct sockaddr *src,
-    struct sockaddr *dst, u_int16_t d_port)
+    struct sockaddr *dst, u_int16_t d_port, char *routeto_if,
+    struct sockaddr *routeto)
 {
 	if (!src || !dst || !d_port) {
 		errno = EINVAL;
@@ -66,6 +67,23 @@
 		return (-1);
 
 	pfr.rule.direction = dir;
+
+	if (routeto_if && routeto) {
+		pfr.rule.rt = PF_ROUTETO;
+		if (routeto->sa_family == AF_INET) {
+			memcpy(&pfp.addr.addr.v.a.addr.v4,
+			    &satosin(routeto)->sin_addr.s_addr, 4);
+			memset(&pfp.addr.addr.v.a.mask.addr8, 255, 4);
+		} else {
+			memcpy(&pfp.addr.addr.v.a.addr.v6,
+			    &satosin6(routeto)->sin6_addr.s6_addr, 16);
+			memset(&pfp.addr.addr.v.a.mask.addr8, 255, 16);
+		}
+		strlcpy(pfp.addr.ifname, routeto_if, sizeof(pfp.addr.ifname));
+		if (ioctl(dev, DIOCADDADDR, &pfp) == -1)
+			return (-1);
+	}
+
 	if (ioctl(dev, DIOCADDRULE, &pfr) == -1)
 		return (-1);
 

--- src/openvpn/tun.c.orig	2013-05-05 10:28:13.000000000 +0000
+++ src/openvpn/tun.c	2013-05-05 10:28:21.000000000 +0000
@@ -2264,15 +2264,6 @@
 
 #elif defined(TARGET_FREEBSD)
 
-static inline int
-freebsd_modify_read_write_return (int len)
-{
-  if (len > 0)
-    return len > sizeof (u_int32_t) ? len - sizeof (u_int32_t) : 0;
-  else
-    return len;
-}
-
 void
 open_tun (const char *dev, const char *dev_type, const char *dev_node, struct tuntap *tt)
 {
@@ -2285,10 +2276,12 @@
       if (ioctl (tt->fd, TUNSIFMODE, &i) < 0) {
 	msg (M_WARN | M_ERRNO, "ioctl(TUNSIFMODE): %s", strerror(errno));
       }
+#if 0
       i = 1;
       if (ioctl (tt->fd, TUNSIFHEAD, &i) < 0) {
 	msg (M_WARN | M_ERRNO, "ioctl(TUNSIFHEAD): %s", strerror(errno));
       }
+#endif
     }
 }
 
@@ -2331,46 +2324,12 @@
 int
 write_tun (struct tuntap* tt, uint8_t *buf, int len)
 {
-  if (tt->type == DEV_TYPE_TUN)
-    {
-      u_int32_t type;
-      struct iovec iv[2];
-      struct ip *iph;
-
-      iph = (struct ip *) buf;
-
-      if (tt->ipv6 && iph->ip_v == 6)
-        type = htonl (AF_INET6);
-      else 
-        type = htonl (AF_INET);
-
-      iv[0].iov_base = (char *)&type;
-      iv[0].iov_len = sizeof (type);
-      iv[1].iov_base = buf;
-      iv[1].iov_len = len;
-
-      return freebsd_modify_read_write_return (writev (tt->fd, iv, 2));
-    }
-  else
     return write (tt->fd, buf, len);
 }
 
 int
 read_tun (struct tuntap* tt, uint8_t *buf, int len)
 {
-  if (tt->type == DEV_TYPE_TUN)
-    {
-      u_int32_t type;
-      struct iovec iv[2];
-
-      iv[0].iov_base = (char *)&type;
-      iv[0].iov_len = sizeof (type);
-      iv[1].iov_base = buf;
-      iv[1].iov_len = len;
-
-      return freebsd_modify_read_write_return (readv (tt->fd, iv, 2));
-    }
-  else
     return read (tt->fd, buf, len);
 }
 

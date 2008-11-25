--- src/network_freebsd_sendfile.c	2008-11-24 19:04:59.000000000 -0500
+++ src/network_freebsd_sendfile.c	2008-11-24 19:05:37.000000000 -0500
@@ -177,6 +177,7 @@
 			}
 
 			if (r == 0 && (errno != EAGAIN && errno != EINTR)) {
+			} else if (r == 0) {
 				int oerrno = errno;
 				/* We got an event to write but we wrote nothing
 				 *

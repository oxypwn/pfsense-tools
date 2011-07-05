--- src/racoon/sockmisc.c.old	2011-07-05 17:01:31.000000000 +0000
+++ src/racoon/sockmisc.c	2011-07-05 16:56:05.000000000 +0000
@@ -105,8 +105,6 @@
 		return CMPSADDR_MISMATCH;
 
 	switch (addr1->sa_family) {
-	case AF_UNSPEC:
-		break;
 	case AF_INET:
 		sa1 = (caddr_t)&((struct sockaddr_in *)addr1)->sin_addr;
 		sa2 = (caddr_t)&((struct sockaddr_in *)addr2)->sin_addr;

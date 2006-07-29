--- pftpx.c	Sat Jul 29 00:56:05 2006
+++ pftpx.c	Sat Jul 29 05:06:44 2006
@@ -161,9 +161,9 @@
 
 char ntop_buf[NTOP_BUFS][INET6_ADDRSTRLEN];
 
-struct sockaddr_storage fixed_server_ss, fixed_proxy_ss;
+struct sockaddr_storage fixed_server_ss, fixed_proxy_ss, routeto_ss;
 char *fixed_server, *fixed_server_port, *fixed_proxy, *listen_ip, *listen_port,
-    *qname;
+    *routeto, *routeto_if, *qname;
 int caught_sig, daemonize, id_count, ipv6_mode, loglevel, max_sessions,
     rfc_mode, session_count, timeout;
 extern char *__progname;
@@ -430,13 +430,13 @@
 			goto fail;
 
 		/* pass in from $client to $server port $port */
-		if (add_filter(s->id, PF_IN, client_sa, server_sa,
-		    s->port) == -1)
+		if (add_filter(s->id, PF_IN, client_sa, server_sa, s->port,
+		    NULL, NULL) == -1)
 			goto fail;
 
 		/* pass out from $proxy to $server port $port */
 		if (add_filter(s->id, PF_OUT, proxy_sa, server_sa,
-		    s->port) == -1)
+		    s->port, routeto_if, sstosa(&routeto_ss)) == -1)
 			goto fail;
 	}
 
@@ -472,13 +472,13 @@
 		}
 
 		/* pass in from $server to $client port $port */
-		if (add_filter(s->id, PF_IN, server_sa, client_sa, s->port) ==
-		    -1)
+		if (add_filter(s->id, PF_IN, server_sa, client_sa, s->port,
+		     routeto_if, sstosa(&routeto_ss)) == -1)
 			goto fail;
 
 		/* pass out from $orig_server to $client port $port */
-		if (add_filter(s->id, PF_OUT, orig_sa, client_sa, s->port) ==
-		    -1)
+		if (add_filter(s->id, PF_OUT, orig_sa, client_sa, s->port,
+		    NULL, NULL) == -1)
 			goto fail;
 	}
 
@@ -846,12 +846,14 @@
 	timeout		= 24 * 3600;
 	qname		= NULL;
 	rfc_mode	= 0;
+	routeto		= NULL;
+	routeto_if	= NULL;
 
 	/* Other initialization. */
 	session_count = 0;
 	id_count = 1;
 
-	while ((ch = getopt(argc, argv, "6D:b:c:df:g:m:p:q:rt:")) != -1) {
+	while ((ch = getopt(argc, argv, "6D:2:b:c:df:g:m:n:p:q:rt")) != -1) {
 		switch (ch) {
 		case '6':
 			ipv6_mode = 1;
@@ -897,6 +899,12 @@
 			if (timeout < 0)
 				errx(1, "bad timeout");
 			break;
+                case '2':
+                        routeto = optarg;
+                        break;
+                case 'n':
+                        routeto_if = optarg;
+                        break;
 		default:
 			usage();
 		}
@@ -928,6 +936,22 @@
 		    sock_ntop(sstosa(&fixed_proxy_ss)));
 		freeaddrinfo(res);
 	}
+
+	if (routeto) {
+		memset(&hints, 0, sizeof hints);
+		hints.ai_flags = AI_NUMERICHOST;
+		hints.ai_family = ipv6_mode ? AF_INET6 : AF_INET;
+		hints.ai_socktype = SOCK_STREAM;
+		error = getaddrinfo(routeto, NULL, &hints, &res);
+		if (error)
+			errx(1, "getaddrinfo route-to address failed: %s",
+			    gai_strerror(error));
+		memcpy(&routeto_ss, res->ai_addr, res->ai_addrlen);
+		logmsg(LOG_INFO, "using route-to (%s %s)", routeto_if,
+		    sock_ntop(sstosa(&routeto_ss)));
+		freeaddrinfo(res);
+	}
+
 
 	if (fixed_server) {
 		memset(&hints, 0, sizeof hints);

--- mini_httpd.c.orig	Wed Dec  3 18:27:22 2003
+++ mini_httpd.c	Mon May  2 20:12:57 2005
@@ -73,8 +73,10 @@
 extern char* crypt( const char* key, const char* setting );
 
 
-#if defined(AF_INET6) && defined(IN6_IS_ADDR_V4MAPPED)
-#define USE_IPV6
+#ifndef NO_IPV6
+# if defined(AF_INET6) && defined(IN6_IS_ADDR_V4MAPPED)
+#  define USE_IPV6
+# endif
 #endif
 
 #ifndef STDIN_FILENO
@@ -141,10 +143,10 @@
 #define AUTH_FILE ".htpasswd"
 #endif /* AUTH_FILE */
 #ifndef READ_TIMEOUT
-#define READ_TIMEOUT 60
+#define READ_TIMEOUT 600000000
 #endif /* READ_TIMEOUT */
 #ifndef WRITE_TIMEOUT
-#define WRITE_TIMEOUT 300
+#define WRITE_TIMEOUT 30000000
 #endif /* WRITE_TIMEOUT */
 #ifndef DEFAULT_CHARSET
 #define DEFAULT_CHARSET "iso-8859-1"
@@ -171,9 +173,12 @@
 static char* argv0;
 static int debug;
 static unsigned short port;
+static int maxproc;
+static int currproc;
 static char* dir;
 static char* data_dir;
 static int do_chroot;
+static int captivemode;
 static int vhost;
 static char* user;
 static char* cgi_pattern;
@@ -209,6 +214,7 @@
 static size_t request_size, request_len, request_idx;
 static int method;
 static char* path;
+static char* captive_reqpath;
 static char* file;
 static char* pathinfo;
 struct stat sb;
@@ -228,6 +234,8 @@
 static char* useragent;
 
 static char* remoteuser;
+static char* authuser;
+static char* authpw;
 
 
 /* Forwards. */
@@ -236,7 +244,7 @@
 static void value_required( char* name, char* value );
 static void no_value_required( char* name, char* value );
 static int initialize_listen_socket( usockaddr* usaP );
-static void handle_request( void );
+static void handle_request( int http_error );
 static void de_dotdot( char* file );
 static int get_pathinfo( void );
 static void do_file( void );
@@ -322,9 +330,13 @@
     argv0 = argv[0];
     debug = 0;
     port = 0;
+	maxproc = 16 ;
+	currproc = 0 ;
     dir = (char*) 0;
     data_dir = (char*) 0;
     do_chroot = 0;
+    captivemode = 0;
+    captive_reqpath = NULL;
     vhost = 0;
     cgi_pattern = (char*) 0;
     url_pattern = (char*) 0;
@@ -377,6 +389,11 @@
 	    ++argn;
 	    port = (unsigned short) atoi( argv[argn] );
 	    }
+	else if ( strcmp( argv[argn], "-maxproc" ) == 0 && argn + 1 < argc )
+	    {
+	    ++argn;
+	    maxproc = (unsigned short) atoi( argv[argn] );
+	    }
 	else if ( strcmp( argv[argn], "-d" ) == 0 && argn + 1 < argc )
 	    {
 	    ++argn;
@@ -431,6 +448,8 @@
 	    ++argn;
 	    max_age = atoi( argv[argn] );
 	    }
+	else if ( strcmp( argv[argn], "-a" ) == 0 )
+	    captivemode = 1;
 	else
 	    usage();
 	++argn;
@@ -709,6 +728,13 @@
 	    perror( "data_dir chdir" );
 	    exit( 1 );
 	    }
+	    else
+	    {
+		/* Get new current directory. */
+	        (void) getcwd( cwd, sizeof(cwd) - 1 );
+	        if ( cwd[strlen( cwd ) - 1] != '/' )
+		    (void) strcat( cwd, "/" );
+	    }
 	}
 
     /* If we're root, become someone else. */
@@ -722,6 +748,7 @@
 	    exit( 1 );
 	    }
 	/* Check for unnecessary security exposure. */
+	/*
 	if ( ! do_chroot )
 	    {
 	    syslog( LOG_WARNING,
@@ -729,6 +756,7 @@
 	    (void) fprintf( stderr,
 		"%s: started as root without requesting chroot(), warning only\n", argv0 );
 	    }
+	*/
 	}
 
     /* Catch various signals. */
@@ -751,6 +779,7 @@
 
     init_mime();
 
+	/*
     if ( hostname == (char*) 0 )
 	syslog(
 	    LOG_NOTICE, "%.80s starting on port %d", SERVER_SOFTWARE,
@@ -759,6 +788,7 @@
 	syslog(
 	    LOG_NOTICE, "%.80s starting on %.80s, port %d", SERVER_SOFTWARE,
 	    hostname, (int) port );
+	*/
 
     /* Main loop. */
     for (;;)
@@ -795,7 +825,7 @@
 	    }
 	if ( select( maxfd + 1, &lfdset, (fd_set*) 0, (fd_set*) 0, (struct timeval*) 0 ) < 0 )
 	    {
-	    if ( errno == EINTR || errno == EAGAIN )
+	    if ( errno == EINTR || errno == EAGAIN || errno == ECONNABORTED )
 		continue;	/* try again */
 	    syslog( LOG_CRIT, "select - %m" );
 	    perror( "select" );
@@ -816,7 +846,7 @@
 	    }
 	if ( conn_fd < 0 )
 	    {
-	    if ( errno == EINTR || errno == EAGAIN )
+	    if ( errno == EINTR || errno == EAGAIN || errno == ECONNABORTED )
 		continue;	/* try again */
 #ifdef EPROTO
 	    if ( errno == EPROTO )
@@ -827,8 +857,16 @@
 	    exit( 1 );
 	    }
 
+	/* If we've reach max child procs, then send back server busy error */
+	if (currproc >= maxproc) {
+		handle_request(503) ;
+		close(conn_fd) ;
+		continue ;
+	}
+
 	/* Fork a sub-process to handle the connection. */
 	r = fork();
+
 	if ( r < 0 )
 	    {
 	    syslog( LOG_CRIT, "fork - %m" );
@@ -843,9 +881,10 @@
 		(void) close( listen4_fd );
 	    if ( listen6_fd != -1 )
 		(void) close( listen6_fd );
-	    handle_request();
+	    handle_request(0);
 	    exit( 0 );
 	    }
+	currproc++;
 	(void) close( conn_fd );
 	}
     }
@@ -855,9 +894,9 @@
 usage( void )
     {
 #ifdef USE_SSL
-    (void) fprintf( stderr, "usage:  %s [-C configfile] [-D] [-S] [-E certfile] [-Y cipher] [-p port] [-d dir] [-dd data_dir] [-c cgipat] [-u user] [-h hostname] [-r] [-v] [-l logfile] [-i pidfile] [-T charset] [-P P3P] [-M maxage]\n", argv0 );
+    (void) fprintf( stderr, "usage:  %s [-C configfile] [-D] [-S] [-E certfile] [-Y cipher] [-p port] [-d dir] [-dd data_dir] [-c cgipat] [-u user] [-h hostname] [-r] [-v] [-l logfile] [-i pidfile] [-T charset] [-P P3P] [-M maxage] [-maxproc max_concurrent_procs]\n", argv0 );
 #else /* USE_SSL */
-    (void) fprintf( stderr, "usage:  %s [-C configfile] [-D] [-p port] [-d dir] [-dd data_dir] [-c cgipat] [-u user] [-h hostname] [-r] [-v] [-l logfile] [-i pidfile] [-T charset] [-P P3P] [-M maxage]\n", argv0 );
+    (void) fprintf( stderr, "usage:  %s [-C configfile] [-D] [-p port] [-d dir] [-dd data_dir] [-c cgipat] [-u user] [-h hostname] [-r] [-v] [-l logfile] [-i pidfile] [-T charset] [-P P3P] [-M maxage] [-maxproc max_concurrent_procs]\n", argv0 );
 #endif /* USE_SSL */
     exit( 1 );
     }
@@ -1121,15 +1160,16 @@
 ** not needed.
 */
 static void
-handle_request( void )
+handle_request( int http_error )
     {
     char* method_str;
     char* line;
     char* cp;
+    int has_indexfile;
     int r, file_len, i;
     const char* index_names[] = {
-	"index.html", "index.htm", "index.xhtml", "index.xht", "Default.htm",
-	"index.cgi" };
+	"index.php", "index.html", "index.htm", "index.xhtml", "index.xht",
+	"Default.htm", "index.cgi" };
 
     /* Set up the timeout for reading. */
 #ifdef HAVE_SIGSET
@@ -1141,6 +1181,8 @@
 
     /* Initialize the request variables. */
     remoteuser = (char*) 0;
+    authuser = (char*) 0;
+    authpw = (char*) 0;
     method = METHOD_UNKNOWN;
     path = (char*) 0;
     file = (char*) 0;
@@ -1166,9 +1208,11 @@
     ** solution is writev() (as used in thttpd), or send the headers with
     ** send(MSG_MORE) (only available in Linux so far).
     */
+	/*
     r = 1;
     (void) setsockopt(
 	conn_fd, IPPROTO_TCP, TCP_NOPUSH, (void*) &r, sizeof(r) );
+	*/
 #endif /* TCP_NOPUSH */
 
 #ifdef USE_SSL
@@ -1215,11 +1259,13 @@
 	send_error( 400, "Bad Request", "", "Can't parse request." );
     *protocol++ = '\0';
     protocol += strspn( protocol, " \t\012\015" );
+    if (!captivemode) {
     query = strchr( path, '?' );
     if ( query == (char*) 0 )
 	query = "";
     else
 	*query++ = '\0';
+	}
 
     /* Parse the rest of the request headers. */
     while ( ( line = get_request_line() ) != (char*) 0 )
@@ -1287,6 +1333,38 @@
     else
 	send_error( 501, "Not Implemented", "", "That method is not implemented." );
 
+	if(http_error == 503) {
+		add_headers(
+		503, "Server temporarily overloaded", "", "", "text/html; charset=%s", (off_t) -1, (time_t) -1 );
+
+		send_error_body( 503, "Server temporarily overloaded", "The server cannot process the request due to a high load" );
+
+		send_response();
+
+		#ifdef USE_SSL
+			SSL_free( ssl );
+		#endif /* USE_SSL */
+		alarm(0) ;
+		return ;
+	}	
+
+	if (captivemode) {
+		/* only accept GET in captive portal mode */
+		captive_reqpath = path;		
+		path = "/index.php";
+		file = "index.php";
+		
+    	/* Set up the timeout for writing. */
+#ifdef HAVE_SIGSET
+		(void) sigset( SIGALRM, handle_write_timeout );
+#else /* HAVE_SIGSET */
+		(void) signal( SIGALRM, handle_write_timeout );
+#endif /* HAVE_SIGSET */
+		(void) alarm( WRITE_TIMEOUT );
+		
+		do_cgi();
+	} else {
+
     strdecode( path, path );
     if ( path[0] != '/' )
 	send_error( 400, "Bad Request", "", "Bad filename." );
@@ -1344,23 +1422,28 @@
 	    }
 
 	/* Check for an index file. */
+	has_indexfile = 0;
 	for ( i = 0; i < sizeof(index_names) / sizeof(char*); ++i )
 	    {
-	    (void) snprintf( idx, sizeof(idx), "%s%s", file, index_names[i] );
-	    if ( stat( idx, &sb ) >= 0 )
+	    (void) snprintf( idx, sizeof(idx), "/%s%s", file, index_names[i] );
+	    if ( stat( idx+1, &sb ) >= 0 )
 		{
-		file = idx;
+		/* re-construct the path */
+		path = idx;
+		/* and the file */
+		file = &(path[1]);
+		de_dotdot( file );
 		do_file();
-		goto got_one;
+		has_indexfile = 1;
+		break;
 		}
 	    }
 
 	/* Nope, no index file, so it's an actual directory request. */
+	if ( has_indexfile == 0 )
 	do_dir();
-
-	got_one: ;
 	}
-
+	}
 #ifdef USE_SSL
     SSL_free( ssl );
 #endif /* USE_SSL */
@@ -1544,6 +1627,7 @@
     char buf[10000];
     size_t buflen;
     char* contents;
+    char contents_type[64];
     size_t contents_size, contents_len;
 #ifdef HAVE_SCANDIR
     int n, i;
@@ -1624,7 +1708,8 @@
 	SERVER_URL, SERVER_SOFTWARE );
     add_to_buf( &contents, &contents_size, &contents_len, buf, buflen );
 
-    add_headers( 200, "Ok", "", "", "text/html; charset=%s", contents_len, sb.st_mtime );
+    (void) snprintf( contents_type, sizeof(contents_type), "text/html; charset=%s", charset );
+    add_headers( 200, "Ok", "", "", contents_type, contents_len, sb.st_mtime );
     if ( method != METHOD_HEAD )
 	add_to_response( contents, contents_len );
     send_response();
@@ -2116,7 +2201,9 @@
     static char* envp[50];
     int envn;
     char* cp;
+    char scriptpath[MAXPATHLEN];
     char buf[256];
+    char rp[MAXPATHLEN];
 
     envn = 0;
     envp[envn++] = build_env( "PATH=%s", CGI_PATH );
@@ -2134,11 +2221,19 @@
     envp[envn++] = build_env( "SERVER_PORT=%s", buf );
     envp[envn++] = build_env(
 	"REQUEST_METHOD=%s", get_method_str( method ) );
-    envp[envn++] = build_env( "SCRIPT_NAME=%s", path );
+    if ( vhost )
+	envp[envn++] = build_env( "SCRIPT_NAME=%s", file + strlen( req_hostname ) );
+    else
+        envp[envn++] = build_env( "SCRIPT_NAME=/%s", file );
+    (void) snprintf( buf, sizeof(buf), "%s%s", cwd, file );
+    envp[envn++] = build_env( "SCRIPT_FILENAME=%s", buf );
     if ( pathinfo != (char*) 0 )
 	{
 	envp[envn++] = build_env( "PATH_INFO=/%s", pathinfo );
-	(void) snprintf( buf, sizeof(buf), "%s%s", cwd, pathinfo );
+	/* save the path of the cgi file */
+	(void) strncpy( scriptpath, buf, sizeof(scriptpath) );
+	/* and reattach the path_info stuff */
+	(void) snprintf( buf, sizeof(buf), "%s/%s", scriptpath, pathinfo );
 	envp[envn++] = build_env( "PATH_TRANSLATED=%s", buf );
 	}
     if ( query[0] != '\0' )
@@ -2162,11 +2257,23 @@
 	}
     if ( remoteuser != (char*) 0 )
 	envp[envn++] = build_env( "REMOTE_USER=%s", remoteuser );
+    if ( authuser != (char*) 0 )
+        {
+        envp[envn++] = build_env( "AUTH_USER=%s", authuser );
+        envp[envn++] = build_env( "AUTH_PW=%s", authpw );
+#ifdef PHP_ENV	
+        envp[envn++] = build_env( "PHP_AUTH_USER=%s", authuser );
+        envp[envn++] = build_env( "PHP_AUTH_PW=%s", authpw );
+#endif /* PHP_ENV */
+        }
     if ( authorization != (char*) 0 )
 	envp[envn++] = build_env( "AUTH_TYPE=%s", "Basic" );
     if ( getenv( "TZ" ) != (char*) 0 )
 	envp[envn++] = build_env( "TZ=%s", getenv( "TZ" ) );
 
+	if (captive_reqpath != NULL)
+		envp[envn++] = build_env("CAPTIVE_REQPATH=%s", captive_reqpath);
+
     envp[envn] = (char*) 0;
     return envp;
     }
@@ -2213,40 +2320,50 @@
     FILE* fp;
     char* cryp;
 
-    /* Construct auth filename. */
-    if ( dirname[strlen(dirname) - 1] == '/' )
-	(void) snprintf( authpath, sizeof(authpath), "%s%s", dirname, AUTH_FILE );
-    else
-	(void) snprintf( authpath, sizeof(authpath), "%s/%s", dirname, AUTH_FILE );
-
-    /* Does this directory have an auth file? */
-    if ( stat( authpath, &sb ) < 0 )
-	/* Nope, let the request go through. */
-	return;
-
     /* Does this request contain authorization info? */
-    if ( authorization == (char*) 0 )
-	/* Nope, return a 401 Unauthorized. */
-	send_authenticate( dirname );
-
+    if ( authorization != (char*) 0 )
+        {
     /* Basic authorization info? */
-    if ( strncmp( authorization, "Basic ", 6 ) != 0 )
-	send_authenticate( dirname );
-
+        if ( strncmp( authorization, "Basic ", 6 ) == 0 )
+	    {
     /* Decode it. */
     l = b64_decode(
 	&(authorization[6]), (unsigned char*) authinfo, sizeof(authinfo) - 1 );
     authinfo[l] = '\0';
     /* Split into user and password. */
     authpass = strchr( authinfo, ':' );
-    if ( authpass == (char*) 0 )
-	/* No colon?  Bogus auth info. */
-	send_authenticate( dirname );
+	    if ( authpass != (char*) 0 )
+	        {
     *authpass++ = '\0';
     /* If there are more fields, cut them off. */
     colon = strchr( authpass, ':' );
     if ( colon != (char*) 0 )
 	*colon = '\0';
+		/* save to authuser and authpw variables */
+		authuser = authinfo;
+		authpw = authpass;
+		}
+	    }
+	}
+   
+    /* Construct auth filename. */
+    if ( dirname[strlen(dirname) - 1] == '/' )
+	(void) snprintf( authpath, sizeof(authpath), "%s%s", dirname, AUTH_FILE );
+    else
+	(void) snprintf( authpath, sizeof(authpath), "%s/%s", dirname, AUTH_FILE );
+
+    /* Does this directory have an auth file? */
+    if ( stat( authpath, &sb ) < 0 )
+	/* Nope, let the request go through. */
+	return;
+
+    /* Is it an empty auth file? */
+    if ( sb.st_size == 0 )   
+	send_error( 403, "Forbidden", "", "File is protected." );
+
+    /* Do we have an authuser? */
+    if ( authuser == (char*) 0 )
+        send_authenticate( dirname );
 
     /* Open the password file. */
     fp = fopen( authpath, "r" );
@@ -2272,15 +2389,18 @@
 	    continue;
 	*cryp++ = '\0';
 	/* Is this the right user? */
-	if ( strcmp( line, authinfo ) == 0 )
+	if ( strcmp( line, authuser ) == 0 )
 	    {
 	    /* Yes. */
 	    (void) fclose( fp );
 	    /* So is the password right? */
-	    if ( strcmp( crypt( authpass, cryp ), cryp ) == 0 )
+	    if ( strcmp( crypt( authpw, cryp ), cryp ) == 0 )
 		{
 		/* Ok! */
-		remoteuser = line;
+		remoteuser = authuser;
+		/* clear AUTH_USER and AUTH_PW because we made the authentication ourself */
+		authuser = (char*) 0;
+		authpw = (char*) 0;
 		return;
 		}
 	    else
@@ -2336,13 +2456,13 @@
 static void
 send_error( int s, char* title, char* extra_header, char* text )
     {
+    char contents_type[64];
+    (void) snprintf( contents_type, sizeof(contents_type), "text/html; charset=%s", charset );
     add_headers(
-	s, title, extra_header, "", "text/html; charset=%s", (off_t) -1, (time_t) -1 );
+	s, title, extra_header, "", contents_type, (off_t) -1, (time_t) -1 );
 
     send_error_body( s, title, text );
 
-    send_error_tail();
-
     send_response();
 
 #ifdef USE_SSL
@@ -2378,14 +2498,15 @@
     /* Send built-in error page. */
     buflen = snprintf(
 	buf, sizeof(buf), "\
-<HTML>\n\
-<HEAD><TITLE>%d %s</TITLE></HEAD>\n\
-<BODY BGCOLOR=\"#cc9999\" TEXT=\"#000000\" LINK=\"#2020ff\" VLINK=\"#4040cc\">\n\
-<H4>%d %s</H4>\n",
+<html>\n\
+<head><title>%d %s</title></head>\n\
+<body>\n\
+<h3>%d %s</h3>\n",
 	s, title, s, title );
     add_to_response( buf, buflen );
     buflen = snprintf( buf, sizeof(buf), "%s\n", text );
     add_to_response( buf, buflen );
+    send_error_tail();
     }
 
 
@@ -2416,7 +2537,7 @@
     {
     char buf[500];
     int buflen;
-
+/*
     if ( match( "**MSIE**", useragent ) )
 	{
 	int n;
@@ -2430,13 +2551,10 @@
 	buflen = snprintf( buf, sizeof(buf), "-->\n" );
 	add_to_response( buf, buflen );
 	}
-
+*/
     buflen = snprintf( buf, sizeof(buf), "\
-<HR>\n\
-<ADDRESS><A HREF=\"%s\">%s</A></ADDRESS>\n\
-</BODY>\n\
-</HTML>\n",
-	SERVER_URL, SERVER_SOFTWARE );
+</body>\n\
+</html>\n");
     add_to_response( buf, buflen );
     }
 
@@ -2457,8 +2575,10 @@
     start_response();
     buflen = snprintf( buf, sizeof(buf), "%s %d %s\015\012", protocol, status, title );
     add_to_response( buf, buflen );
+/*
     buflen = snprintf( buf, sizeof(buf), "Server: %s\015\012", SERVER_SOFTWARE );
     add_to_response( buf, buflen );
+*/
     now = time( (time_t*) 0 );
     (void) strftime( timebuf, sizeof(timebuf), rfc1123_fmt, gmtime( &now ) );
     buflen = snprintf( buf, sizeof(buf), "Date: %s\015\012", timebuf );
@@ -2725,9 +2845,10 @@
     /* If we're vhosting, prepend the hostname to the url.  This is
     ** a little weird, perhaps writing separate log files for
     ** each vhost would make more sense.
+    ** Bah. I just put the vhost name in square brackets --bhoc
     */
     if ( vhost )
-	(void) snprintf( url, sizeof(url), "/%s%s", req_hostname, path );
+	(void) snprintf( url, sizeof(url), "[%s]%s", req_hostname, path );
     else
 	(void) snprintf( url, sizeof(url), "%s", path );
     /* Format the bytes. */
@@ -3034,8 +3155,10 @@
     {
     /* Don't need to set up the handler again, since it's a one-shot. */
 
+	/*
     syslog( LOG_NOTICE, "exiting due to signal %d", sig );
     (void) fprintf( stderr, "%s: exiting due to signal %d\n", argv0, sig );
+	*/
     closelog();
     exit( 1 );
     }
@@ -3096,6 +3219,7 @@
 		}
 	    break;
 	    }
+	currproc-- ;
 	}
 
     /* Restore previous errno. */
@@ -3128,7 +3252,9 @@
 static void
 handle_read_timeout( int sig )
     {
+	/*
     syslog( LOG_INFO, "%.80s connection timed out reading", ntoa( &client_addr ) );
+	*/
     send_error(
 	408, "Request Timeout", "",
 	"No request appeared within a reasonable time period." );

diff -r da91afd19d38 src/sgDiv.c
--- src/sgDiv.c	Wed Sep 04 17:46:45 2013 -0300
+++ src/sgDiv.c	Wed Sep 04 17:57:52 2013 -0300
@@ -223,11 +223,35 @@
       break;
     case 1: /* ident */
       if(strcmp(p,"-")){
-	strcpy(s->ident,p);
-	for(p=s->ident; *p != '\0'; p++) /* convert ident to lowercase chars */
-	  *p = tolower(*p);
-      } else
-	s->ident[0] = '\0';
+        char *stripntdomain = NULL, *striprealm = NULL;
+        HTUnEscape(p);
+        stripntdomain = sgSettingGetValue("stripntdomain");
+        if(stripntdomain == NULL)
+          stripntdomain = DEFAULT_STRIPNTDOMAIN;
+        striprealm = sgSettingGetValue("striprealm");
+        if(striprealm == NULL)
+	  striprealm = DEFAULT_STRIPREALM;
+        if (strcmp(stripntdomain,"false")) {
+           char *u = strrchr(p, '\\');
+           if (!u)
+              u = strrchr(p, '/');
+           if (!u)
+              u = strrchr(p, '+');
+           if (u && u[1])
+              p = u + 1;
+        }
+        if (strcmp(striprealm,"false")) {
+           char *u = strchr(p, '@');
+           if (u != NULL) {
+              *u = '\0';
+           }
+        }
+        strcpy(s->ident,p);
+        for (p=s->ident; *p != '\0'; p++) /* convert ident to lowercase chars */
+           *p = tolower(*p);
+      } else {
+        s->ident[0] = '\0';
+      } 
       break;
     case 2: /* method */
       strcpy(s->method,p);
@@ -734,7 +758,7 @@
       p++;
       break;
     case 'u': /* Requested URL */
-      strcat(buf, req->orig);
+      strcat(buf, req->orig, 2048);
       p++;
       break;
     default:

--- msnprotocolplugin.cpp	2008/09/04 13:48:13	1.18
+++ msnprotocolplugin.cpp	2009/01/02 12:54:37	1.19
@@ -46,6 +46,7 @@
 
 #pragma pack()
 
+void setlocalid(std::string id);
 void setremoteid(std::string id);
 bool processmessage(bool outgoing, std::string id, int headerlength, char *msg,
 	std::vector<struct imevent> &imevents, std::string clientaddress);
@@ -116,7 +117,7 @@
 	{
 		/* The local user is logging in. */
 		if (command == "ANS" && argc > 1) 
-			localid = args[1];
+			setlocalid(args[1]);
 	}
 	else
 	{
@@ -124,7 +125,7 @@
 		if (command == "USR")
 		{
 			if (args[1] == "OK" && argc > 2)
-				localid = args[2];
+				setlocalid(args[2]);
 		}
 		/* A remote user joined the chat. */
 		if (command == "JOI" && argc > 0)
@@ -226,13 +227,28 @@
 	
 	return 0;
 }
+
+/* Sets the localid.  ID may have a UUID, if its a 2009 client. */
+void setlocalid(std::string id)
+{
+	localid = id;
+
+	size_t n = localid.find_last_of(";");
 	
+	if (n != std::string::npos)
+		localid = localid.substr(0, n);
+}
+
 /* Sets the remoteid, depending on wether or not this is the first remote id
  * spotted. */
 void setremoteid(std::string id)
 {
 	/* Sometimes we can be called with the same ID, ignore those. */
 	if (id == remoteid) return;
+	
+	/* MSN 2009 beta appears to "CALL" itself, thus resulting in a JOI to the
+	 * local user. Ignore those too. */
+	if (id == localid) return;
 
 	if (!gotremoteid)
 	{


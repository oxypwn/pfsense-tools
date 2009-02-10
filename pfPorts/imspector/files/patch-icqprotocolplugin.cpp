--- icqprotocolplugin.cpp	2008-10-02 10:28:28.000000000 -0500
+++ icqprotocolplugin.cpp.orig	2009-02-08 21:45:34.000000000 -0600
@@ -673,7 +673,7 @@
 					size_t inbytesleft = mylength - 4;
 					size_t outbytesleft = BUFFER_SIZE - 1; /* Trailing \0 */
 					size_t result = iconv(iconv_utf16be_utf8,
-						&inbuf, &inbytesleft, &outbuf, &outbytesleft);
+						(const char**)&inbuf, &inbytesleft, &outbuf, &outbytesleft);
 
 					if (result == (size_t) -1)
 					{

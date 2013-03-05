--- rate_abusers.c.orig	2013-03-05 18:36:19.000000000 +0000
+++ rate_abusers.c	2013-03-05 18:48:47.000000000 +0000
@@ -195,8 +195,6 @@
 	struct ip *iph;
 	u_int32_t sip;
 	u_int32_t dip;
-	u_int32_t host;
-	long long in = 0, out = 0;
 
 	if(caplen < sizeof(struct ip)) return;
 
@@ -206,14 +204,12 @@
 	sip = iph->ip_src.s_addr;
 	dip = iph->ip_dst.s_addr;
 
- 	if(is_ours(ipci, sip)) out = len;
-	if(is_ours(ipci, dip)) in = len;
+	if (!len)
+		return;
+	if ((is_ours(ipci, sip) && is_ours(ipci, dip)) && (!opt_local)) return;
 
-	if(!(in || out)) return;
-	if(in && out && (!opt_local)) return;
-
-	if(in)  add_entry(ntohl(dip), in, 0);
-	if(out) add_entry(ntohl(sip), 0, out);
+	add_entry(ntohl(sip), (long long)len, 0);
+	add_entry(ntohl(dip), 0, (long long)len);
 }
 
 void r_abusers_setup(int argc, char ** argv,

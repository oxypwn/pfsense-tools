--- src_old/bund.c	2010/02/21 20:09:39	1.198
+++ src/bund.c	2011/06/29 16:09:40	1.199
@@ -331,8 +331,10 @@
     b->pppConfig.links[l->bundleIndex].mru = lcp->peer_mru;
     b->pppConfig.links[l->bundleIndex].enableACFComp = lcp->peer_acfcomp;
     b->pppConfig.links[l->bundleIndex].enableProtoComp = lcp->peer_protocomp;
-    b->pppConfig.links[l->bundleIndex].bandwidth = (l->bandwidth / 8 + 5) / 10;
-    b->pppConfig.links[l->bundleIndex].latency = (l->latency + 500) / 1000;
+    b->pppConfig.links[l->bundleIndex].bandwidth =
+	MIN((l->bandwidth / 8 + 5) / 10, NG_PPP_MAX_BANDWIDTH);
+    b->pppConfig.links[l->bundleIndex].latency =
+	MIN((l->latency + 500) / 1000, NG_PPP_MAX_LATENCY);
 
     /* What to do when the first link comes up */
     if (b->n_up == 1) {

Index: sys/contrib/pf/net/pf.c
===================================================================
RCS file: /home/eri/development/dummynet/localrepo/src/src/sys/contrib/pf/net/pf.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 pf.c
--- sys/contrib/pf/net/pf.c	10 Jul 2008 18:39:39 -0000	1.1.1.1
+++ sys/contrib/pf/net/pf.c	23 Jul 2008 20:11:34 -0000
@@ -4290,7 +4290,7 @@
 	struct pf_ruleset	*ruleset = NULL;
 	struct pf_src_node	*nsn = NULL;
 	struct pf_addr		*saddr = pd->src, *daddr = pd->dst;
-#if 0
+#if 1
 	struct pf_grehdr         gr;
 #endif
 	sa_family_t		 af = pd->af;
@@ -4526,14 +4526,18 @@
 			else
 				PF_ACPY(&s->gwy.addr, &s->lan.addr, af);
 		}
-#if 0
+#if 1
 		if (pd->proto == IPPROTO_GRE &&
                 	pf_pull_hdr(m, off, &gr, sizeof(gr),
                         NULL, NULL, pd->af)  != NULL &&
                         /* Check GRE header bits. */
                         ((ntohl(*((u_int32_t *) &gr)) & PPTP_INIT_MASK)
-                        == PPTP_INIT_VALUE))
-                        s->gwy.port = gr.gh_call_id;
+                        == PPTP_INIT_VALUE)) {
+			if (direction == PF_IN) 
+                        	s->gwy.port = gr.gh_call_id;
+			else 
+				s->lan.port = gr.gh_call_id;
+		}
 #endif
 
 		s->src.state = PFOTHERS_SINGLE;
@@ -5827,7 +5831,7 @@
 	struct pf_grehdr         gr;
         u_int16_t                callid = 0;
 
-#if 0
+#if 1
         if (pd->proto == IPPROTO_GRE &&
                 pf_pull_hdr(m, off, &gr, sizeof(gr), NULL, NULL, pd->af)  != NULL &&
                 /* Check GRE header bits. */
@@ -5845,7 +5849,7 @@
 	} else {
 		PF_ACPY(&key.lan.addr, pd->src, key.af);
 		PF_ACPY(&key.ext.addr, pd->dst, key.af);
-		key.lan.port = 0;
+		key.lan.port = callid;
 		key.ext.port = 0;
 	}
 
@@ -6946,7 +6950,7 @@
 			action = pf_test_tcp(&r, &s, dir, kif,
 			    m, off, h, &pd, &a, &ruleset, &ipintrq);
 #endif
-#if 0
+#if 1
 		/* XXX: This are here until a pluggable framework for NAT is finished */
        		if (s != NULL && s->nat_rule.ptr != NULL &&
 			s->nat_rule.ptr->action != PF_BINAT) {
Index: sys/contrib/pf/net/pf_pptp.c
===================================================================
RCS file: /home/eri/development/dummynet/localrepo/src/src/sys/contrib/pf/net/pf_pptp.c,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 pf_pptp.c
--- sys/contrib/pf/net/pf_pptp.c	10 Jul 2008 18:39:39 -0000	1.1.1.1
+++ sys/contrib/pf/net/pf_pptp.c	24 Jul 2008 21:32:08 -0000
@@ -179,10 +179,10 @@
 	case PPTP_WanErrorNotify: /* XXX: Is this needed?! */
 	case PPTP_SetLinkInfo:
 		if (dir == PF_IN) {
-			pcall_id = hptr.cid1;
+			pcall_id = hptr.cid2;
                 	hptr.cid1 = state->lan.pad;
                 	th->th_sum = pf_cksum_fixup(th->th_sum,
-                        	pcall_id, hptr.cid1, 0);
+                        	pcall_id, hptr.cid2, 0);
 		} else
 			return;
 		break;
@@ -257,7 +257,7 @@
                 s->direction = state->direction; 
                 s->af = state->af;
                 PF_ACPY(&s->gwy.addr, &state->ext.addr, pd->af);
-                s->gwy.port = hptr.cid1;
+                s->lan.port = hptr.cid1;
                 PF_ACPY(&s->lan.addr, &state->ext.addr, pd->af);
                 PF_ACPY(&s->ext.addr, &state->lan.addr, pd->af);
                 s->src.state = PFOTHERS_NO_TRAFFIC;

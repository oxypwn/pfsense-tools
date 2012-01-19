diff -ur ../pftop-0.7.old/bpf_image.c ./bpf_image.c
--- ../pftop-0.7.old/bpf_image.c	2012-01-19 14:59:38.000000000 +0000
+++ ./bpf_image.c	2012-01-19 15:00:20.000000000 +0000
@@ -28,6 +28,7 @@
 #include <stdio.h>
 #include <string.h>
 
+#include "config.h"
 #include "pcap-int.h"
 
 #ifdef HAVE_OS_PROTO_H
diff -ur ../pftop-0.7.old/cache.c ./cache.c
--- ../pftop-0.7.old/cache.c	2012-01-19 14:59:38.000000000 +0000
+++ ./cache.c	2012-01-19 14:59:42.000000000 +0000
@@ -105,6 +105,9 @@
 add_state(pf_state_t *st)
 {
 	struct sc_ent *ent;
+#ifdef HAVE_PFSYNC_STATE
+	pf_state_host_t *sk, *nk;
+#endif
 	assert(st != NULL);
 
 	if (cache_max == 0)
@@ -118,10 +121,24 @@
 
 	cache_size--;
 
+#ifdef HAVE_PFSYNC_STATE
+	if (st->direction == PF_OUT) {
+		sk = &st->key[PF_SK_STACK];
+		nk = &st->key[PF_SK_WIRE];
+	} else {
+		sk = &st->key[PF_SK_WIRE];
+		nk = &st->key[PF_SK_STACK];
+	}
+	ent->addr[0] = sk->addr[1];
+	ent->port[0] = sk->port[1];
+	ent->addr[1] = nk->addr[1];
+	ent->port[1] = nk->port[1];
+#else
 	ent->addr[0] = st->lan.addr;
 	ent->port[0] = st->lan.port;
 	ent->addr[1] = st->ext.addr;
 	ent->port[1] = st->ext.port;
+#endif
 	ent->af = st->af;
 	ent->proto = st->proto;
 #ifdef HAVE_INOUT_COUNT
@@ -147,10 +164,26 @@
 	if (cache_max == 0)
 		return (NULL);
 
+#ifdef HAVE_PFSYNC_STATE
+	pf_state_host_t *sk, *nk;
+
+	if (st->direction == PF_OUT) {
+		sk = &st->key[PF_SK_STACK];
+		nk = &st->key[PF_SK_WIRE];
+	} else {
+		sk = &st->key[PF_SK_WIRE];
+		nk = &st->key[PF_SK_STACK];
+	}
+	ent.addr[0] = sk->addr[1];
+	ent.port[0] = sk->port[1];
+	ent.addr[1] = nk->addr[1];
+	ent.port[1] = nk->port[1];
+#else
 	ent.addr[0] = st->lan.addr;
 	ent.port[0] = st->lan.port;
 	ent.addr[1] = st->ext.addr;
 	ent.port[1] = st->ext.port;
+#endif
 	ent.af = st->af;
 	ent.proto = st->proto;
 
diff -ur ../pftop-0.7.old/config.h ./config.h
--- ../pftop-0.7.old/config.h	2012-01-19 14:59:38.000000000 +0000
+++ ./config.h	2012-01-19 15:00:00.000000000 +0000
@@ -74,9 +74,13 @@
 #define HAVE_PFSYNC_STATE
 #endif
 
+/* XXX: Kludge for pcap */
+#define HAVE_SNPRINTF
+#define	HAVE_VSNPRINTF
+
 #ifdef HAVE_PFSYNC_STATE
 typedef struct pfsync_state pf_state_t;
-typedef struct pfsync_state_host pf_state_host_t;
+typedef struct pfsync_state_key pf_state_host_t;
 typedef struct pfsync_state_peer pf_state_peer_t;
 #define COUNTER(c) ((((u_int64_t) c[0])<<32) + c[1])
 #define pfs_ifname ifname
diff -ur ../pftop-0.7.old/pftop.c ./pftop.c
--- ../pftop-0.7.old/pftop.c	2012-01-19 14:59:38.000000000 +0000
+++ ./pftop.c	2012-01-19 14:59:42.000000000 +0000
@@ -552,6 +552,17 @@
 	if (af < s2->af)
 		return -sortdir;
 	
+#ifdef HAVE_PFSYNC_STATE
+	a = &s1->key[PF_SK_WIRE];
+	b = &s1->key[PF_SK_WIRE];
+
+	ret = PF_AEQ(&a->addr[dir], &b->addr[dir], af);
+	if (ret)
+		return ret * sortdir;
+
+	if (ntohs(a->port[dir]) > ntohs(b->port[dir]))
+		return sortdir;
+#else
 	if (s1->direction == dir) {
 		a = &s1->lan;
 	} else {
@@ -570,6 +581,7 @@
 
 	if (ntohs(a->port) > ntohs(b->port))
 		return sortdir;
+#endif
 	return -sortdir;
 }
 
@@ -595,7 +607,7 @@
 		   const pf_state_t *s2, int dir)
 {
 	const pf_state_host_t *a, *b;
-	int af;
+	int af, ret;
 
 	af = s1->af;
 
@@ -604,6 +616,17 @@
 	if (af < s2->af)
 		return -sortdir;
 	
+#ifdef HAVE_PFSYNC_STATE
+	a = &s1->key[PF_SK_WIRE];
+	b = &s1->key[PF_SK_WIRE];
+
+	ret = compare_addr(af, &a->addr[dir], &b->addr[dir]);
+	if (ret)
+		return ret * sortdir;
+
+	if (ntohs(a->port[dir]) > ntohs(b->port[dir]))
+		return sortdir;
+#else
 	if (s1->direction == dir) {
 		a = &s1->lan;
 	} else {
@@ -623,6 +646,7 @@
 
 	if (compare_addr(af, &a->addr, &b->addr) > 0)
 		return sortdir;
+#endif
 	return -sortdir;
 }
 
@@ -867,9 +891,17 @@
 }
 
 void
-print_fld_host(field_def *fld, pf_state_host_t * h, int af)
+print_fld_host(field_def *fld, pf_state_host_t * h, int af
+#ifdef HAVE_PFSYNC_STATE
+, int index
+#endif
+)
 {
+#ifdef HAVE_PFSYNC_STATE
+	u_int16_t p = ntohs(h->port[index]);
+#else
 	u_int16_t p = ntohs(h->port);
+#endif
 
 	if (fld == NULL)
 		return;
@@ -880,7 +912,11 @@
 	}
 
 	tb_start();
+#ifdef HAVE_PFSYNC_STATE
+	tb_print_addr(&h->addr[index], NULL, af);
+#else
 	tb_print_addr(&h->addr, NULL, af);
+#endif
 
 	if (af == AF_INET)
 		tbprintf(":%u", p);
@@ -944,6 +980,9 @@
 {
 	pf_state_peer_t *src, *dst;
 	struct protoent *p;
+#ifdef HAVE_PFSYNC_STATE
+	pf_state_host_t *sk, *nk;
+#endif
 
 	if (s->direction == PF_OUT) {
 		src = &s->src;
@@ -960,6 +999,23 @@
 	else
 		print_fld_uint(FLD_PROTO, s->proto);
 
+#ifdef HAVE_PFSYNC_STATE
+	if (s->direction == PF_OUT) {
+		sk = &s->key[PF_SK_STACK];
+		nk = &s->key[PF_SK_WIRE];
+	} else {
+		sk = &s->key[PF_SK_WIRE];
+		nk = &s->key[PF_SK_STACK];
+	}
+
+	print_fld_host(FLD_SRC, nk, s->af, 1);
+	print_fld_host(FLD_DEST, nk, s->af, 0);
+
+	if (PF_ANEQ(&nk->addr[1], &sk->addr[1], s->af) ||
+	    (nk->port[1] != sk->port[1])) {
+		print_fld_host(FLD_GW, sk, s->af, 1);
+	}
+#else
 	if (s->direction == PF_OUT) {
 		print_fld_host(FLD_SRC, &s->lan, s->af);
 		print_fld_host(FLD_DEST, &s->ext, s->af);
@@ -972,6 +1028,7 @@
 	    (s->lan.port != s->gwy.port)) {
 		print_fld_host(FLD_GW, &s->gwy, s->af);
 	}
+#endif
 
 	if (s->direction == PF_OUT)
 		print_fld_str(FLD_DIR, "Out");
@@ -1475,8 +1532,12 @@
 	print_fld_str(FLD_LABEL, pr->label);
 #endif
 #ifdef HAVE_RULE_STATES
+#ifdef HAVE_PFSYNC_STATE
+	print_fld_size(FLD_STATS, pr->states_cur);
+#else
 	print_fld_size(FLD_STATS, pr->states);
 #endif
+#endif
 
 #ifdef HAVE_INOUT_COUNT_RULES
 	print_fld_size(FLD_PKTS, pr->packets[0] + pr->packets[1]);
@@ -1570,10 +1631,10 @@
 #ifdef HAVE_RULE_UGID
 	if (pr->uid.op)
 		tb_print_ugid(pr->uid.op, pr->uid.uid[0], pr->uid.uid[1],
-		        "user", UID_MAX);
+		        "user", UINT_MAX);
 	if (pr->gid.op)
 		tb_print_ugid(pr->gid.op, pr->gid.gid[0], pr->gid.gid[1],
-		        "group", GID_MAX);
+		        "group", UINT_MAX);
 #endif
 
 	if (pr->flags || pr->flagset) {
@@ -1765,7 +1826,12 @@
 				  strerror(errno));
 			return (-1);
 		}
+#ifdef PFALTQ_FLAG_IF_REMOVED
+		if (pa.altq.qid > 0 &&
+		    !(pa.altq.local_flags & PFALTQ_FLAG_IF_REMOVED)) {
+#else
 		if (pa.altq.qid > 0) {
+#endif
 			pq.nr = nr;
 			pq.ticket = pa.ticket;
 			pq.buf = &qstats;
diff -ur ../pftop-0.7.old/sf-gencode.c ./sf-gencode.c
--- ../pftop-0.7.old/sf-gencode.c	2012-01-19 14:59:38.000000000 +0000
+++ ./sf-gencode.c	2012-01-19 14:59:42.000000000 +0000
@@ -44,12 +44,12 @@
 
 #define INET6
 
+#include "config.h"
+
 #include <pcap-int.h>
 #include <pcap-namedb.h>
 #include "sf-gencode.h"
 
-#include "config.h"
-
 #define JMP(c) ((c)|BPF_JMP|BPF_K)
 
 /* Locals */
@@ -478,9 +478,15 @@
 gen_hostop(bpf_u_int32 addr, bpf_u_int32 mask, int dir)
 {
 	struct block *b0, *b1, *b2;
+#ifdef HAVE_PFSYNC_STATE
+	const static int lan_off = offsetof(pf_state_t, key[PF_SK_STACK].addr[1].v4);
+	const static int gwy_off = offsetof(pf_state_t, key[PF_SK_WIRE].addr[0].v4);
+	const static int ext_off = offsetof(pf_state_t, key[PF_SK_WIRE].addr[1].v4);
+#else
 	const static int lan_off = offsetof(pf_state_t, lan.addr.v4);
 	const static int gwy_off = offsetof(pf_state_t, gwy.addr.v4);
 	const static int ext_off = offsetof(pf_state_t, ext.addr.v4);
+#endif
 
 	addr = ntohl(addr);
 	mask = ntohl(mask);
@@ -566,9 +572,15 @@
 	struct block *b0, *b1, *b2;
 	u_int32_t *a, *m;
 
+#ifdef HAVE_PFSYNC_STATE
+	const static int lan_off = offsetof(pf_state_t, key[PF_SK_STACK].addr[1].v6);
+	const static int gwy_off = offsetof(pf_state_t, key[PF_SK_WIRE].addr[0].v6);
+	const static int ext_off = offsetof(pf_state_t, key[PF_SK_WIRE].addr[1].v6);
+#else
 	const static int lan_off = offsetof(pf_state_t, lan.addr.v6);
 	const static int gwy_off = offsetof(pf_state_t, gwy.addr.v6);
 	const static int ext_off = offsetof(pf_state_t, ext.addr.v6);
+#endif
 	a = (u_int32_t *)addr;
 	m = (u_int32_t *)mask;
 
@@ -752,9 +764,15 @@
 gen_portop(int port, int proto, int dir)
 {
 	struct block *b0, *b1, *b2;
+#ifdef HAVE_PFSYNC_STATE
+	const static int lan_off = offsetof(pf_state_t, key[PF_SK_STACK].port[1]);
+	const static int gwy_off = offsetof(pf_state_t, key[PF_SK_WIRE].port[0]);
+	const static int ext_off = offsetof(pf_state_t, key[PF_SK_WIRE].port[1]);
+#else
 	const static int lan_off = offsetof(pf_state_t, lan.port);
 	const static int gwy_off = offsetof(pf_state_t, gwy.port);
 	const static int ext_off = offsetof(pf_state_t, ext.port);
+#endif
 
 	port = ntohs(port);
 
diff -ur ../pftop-0.7.old/sf-gencode.h ./sf-gencode.h
--- ../pftop-0.7.old/sf-gencode.h	2012-01-19 14:59:38.000000000 +0000
+++ ./sf-gencode.h	2012-01-19 14:59:42.000000000 +0000
@@ -28,6 +28,7 @@
 #ifndef _SF_GENCODE_H_
 #define _SF_GENCODE_H_
 
+#include "config.h"
 #include "pcap-int.h"
 
 /* Address qualifiers. */

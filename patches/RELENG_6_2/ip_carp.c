Index: ip_carp.c
===================================================================
RCS file: /home/ncvs/src/sys/netinet/ip_carp.c,v
retrieving revision 1.27.2.9
diff -u -r1.27.2.9 ip_carp.c
--- ip_carp.c	10 Oct 2006 18:39:38 -0000	1.27.2.9
+++ ip_carp.c	6 Jun 2007 21:56:46 -0000
@@ -1,4 +1,4 @@
-/* 	$FreeBSD: src/sys/netinet/ip_carp.c,v 1.27.2.9 2006/10/10 18:39:38 bz Exp $ */
+/* 	$FreeBSD: src/sys/netinet/ip_carp.c,v 1.27.2.11 2007/06/06 16:20:50 glebius Exp $ */
 
 /*
  * Copyright (c) 2002 Michael Shalayeff. All rights reserved.
@@ -191,7 +191,7 @@
 static void	carp_input_c(struct mbuf *, struct carp_header *, sa_family_t);
 static int 	carp_clone_create(struct if_clone *, int);
 static void 	carp_clone_destroy(struct ifnet *);
-static void	carpdetach(struct carp_softc *);
+static void	carpdetach(struct carp_softc *, int);
 static int	carp_prepare_ad(struct mbuf *, struct carp_softc *,
 		    struct carp_header *);
 static void	carp_send_ad_all(void);
@@ -406,9 +406,7 @@
 
 	if (sc->sc_carpdev)
 		CARP_SCLOCK(sc);
-	carpdetach(sc);	
-	if (sc->sc_carpdev)
-		CARP_SCUNLOCK(sc);
+	carpdetach(sc, 1);	/* Returns unlocked. */
 
 	mtx_lock(&carp_mtx);
 	LIST_REMOVE(sc, sc_next);
@@ -420,7 +418,7 @@
 }
 
 static void
-carpdetach(struct carp_softc *sc)
+carpdetach(struct carp_softc *sc, int unlock)
 {
 	struct carp_if *cif;
 
@@ -450,9 +448,10 @@
 			sc->sc_carpdev->if_carp = NULL;
 			CARP_LOCK_DESTROY(cif);
 			FREE(cif, M_IFADDR);
-		}
+		} else if (unlock)
+			CARP_UNLOCK(cif);
+		sc->sc_carpdev = NULL;
 	}
-        sc->sc_carpdev = NULL;
 }
 
 /* Detach an interface from the carp. */
@@ -471,7 +470,7 @@
 	CARP_LOCK(cif);
 	for (sc = TAILQ_FIRST(&cif->vhif_vrs); sc; sc = nextsc) {
 		nextsc = TAILQ_NEXT(sc, sc_list);
-		carpdetach(sc);
+		carpdetach(sc, 0);
 	}
 }
 
@@ -658,7 +657,7 @@
 	SC2IFP(sc)->if_ipackets++;
 	SC2IFP(sc)->if_ibytes += m->m_pkthdr.len;
 
-	if (SC2IFP(sc)->if_bpf) {
+	if (bpf_peers_present(SC2IFP(sc)->if_bpf)) {
 		struct ip *ip = mtod(m, struct ip *);
 		uint32_t af1 = af;
 

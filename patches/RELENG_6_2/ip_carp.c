--- src/sys/netinet/ip_carp.c.orig      Thu Feb  1 18:53:55 2007
+++ src/sys/netinet/ip_carp.c   Tue Feb  6 18:41:24 2007
@@ -191,7 +191,7 @@
 static void    carp_input_c(struct mbuf *, struct carp_header *, sa_family_t);
 static int     carp_clone_create(struct if_clone *, int);
 static void    carp_clone_destroy(struct ifnet *);
-static void    carpdetach(struct carp_softc *);
+static void    carpdetach(struct carp_softc *, int);
 static int     carp_prepare_ad(struct mbuf *, struct carp_softc *,
                    struct carp_header *);
 static void    carp_send_ad_all(void);
@@ -406,9 +406,7 @@

        if (sc->sc_carpdev)
                CARP_SCLOCK(sc);
-       carpdetach(sc);
-       if (sc->sc_carpdev)
-               CARP_SCUNLOCK(sc);
+       carpdetach(sc, 1);      /* Returns unlocked. */

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
-               }
+               } else if (unlock)
+                       CARP_UNLOCK(cif);
+               sc->sc_carpdev = NULL;
        }
-        sc->sc_carpdev = NULL;
 }

 /* Detach an interface from the carp. */
@@ -471,7 +470,7 @@
        CARP_LOCK(cif);
        for (sc = TAILQ_FIRST(&cif->vhif_vrs); sc; sc = nextsc) {
                nextsc = TAILQ_NEXT(sc, sc_list);
-               carpdetach(sc);
+               carpdetach(sc, 0);
        }
 }


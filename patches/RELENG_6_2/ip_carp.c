Index: ip_carp.c
===================================================================
RCS file: /home/ncvs/src/sys/netinet/ip_carp.c,v
retrieving revision 1.27.2.9
diff -u -r1.27.2.9 ip_carp.c
--- ip_carp.c	10 Oct 2006 18:39:38 -0000	1.27.2.9
+++ ip_carp.c	1 Feb 2008 18:19:10 -0000
@@ -1882,8 +1882,12 @@
 				cif = (struct carp_if *)sc->sc_carpdev->if_carp;
 				TAILQ_FOREACH(vr, &cif->vhif_vrs, sc_list)
 					if (vr != sc &&
-					    vr->sc_vhid == carpr.carpr_vhid)
-						return EEXIST;
+					    vr->sc_vhid == carpr.carpr_vhid) {
+						error = EEXIST;
+						break;
+					}
+					if (error == EEXIST) 
+						break;
 			}
 			sc->sc_vhid = carpr.carpr_vhid;
 			IFP2ENADDR(sc->sc_ifp)[0] = 0;

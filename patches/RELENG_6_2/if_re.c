Index: if_re.c
===================================================================
RCS file: /home/ncvs/src/sys/dev/re/if_re.c,v
retrieving revision 1.46.2.20
diff -u -r1.46.2.20 if_re.c
--- if_re.c	21 Sep 2006 11:08:28 -0000	1.46.2.20
+++ if_re.c	17 Aug 2007 23:37:25 -0000
@@ -168,6 +168,8 @@
 static struct rl_type re_devs[] = {
 	{ DLINK_VENDORID, DLINK_DEVICEID_528T, RL_HWREV_8169S,
 		"D-Link DGE-528(T) Gigabit Ethernet Adapter" },
+	{ DLINK_VENDORID, DLINK_DEVICEID_528T, RL_HWREV_8169_8110SB,
+		"D-Link DGE-528(T) Rev.B1 Gigabit Ethernet Adapter" },
 	{ RT_VENDORID, RT_DEVICEID_8139, RL_HWREV_8139CPLUS,
 		"RealTek 8139C+ 10/100BaseTX" },
 	{ RT_VENDORID, RT_DEVICEID_8101E, RL_HWREV_8101E,
@@ -184,6 +186,8 @@
 		"RealTek 8169SB/8110SB Single-chip Gigabit Ethernet" },
 	{ RT_VENDORID, RT_DEVICEID_8169SC, RL_HWREV_8169_8110SC,
 		"RealTek 8169SC/8110SC Single-chip Gigabit Ethernet" },
+	{ RT_VENDORID, RT_DEVICEID_8169, RL_HWREV_8169_8110SC,
+		"RealTek 8169SC/8110SC Single-chip Gigabit Ethernet" },
 	{ RT_VENDORID, RT_DEVICEID_8169, RL_HWREV_8110S,
 		"RealTek 8110S Single-chip Gigabit Ethernet" },
 	{ COREGA_VENDORID, COREGA_DEVICEID_CGLAPCIGT, RL_HWREV_8169S,
@@ -1216,7 +1220,9 @@
 	 * Allocate the parent bus DMA tag appropriate for PCI.
 	 */
 #define RL_NSEG_NEW 32
-	error = bus_dma_tag_create(NULL,	/* parent */
+// DAAN Daan daan !!
+//	error = bus_dma_tag_create(bus_get_dma_tag(dev), 1, 0,
+	error = bus_dma_tag_create(NULL, 1, 0,
 			1, 0,			/* alignment, boundary */
 			BUS_SPACE_MAXADDR_32BIT,/* lowaddr */
 			BUS_SPACE_MAXADDR,	/* highaddr */

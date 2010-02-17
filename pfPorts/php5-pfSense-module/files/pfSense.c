#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_pfSense.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if_types.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <net/pfvar.h>
#include <sys/ioctl.h>
#include <sys/sysctl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/ethernet.h>

#include <vm/vm_param.h>

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

static function_entry pfSense_functions[] = {
    PHP_FE(pfSense_get_interface_info, NULL)
    PHP_FE(pfSense_get_interface_addresses, NULL)
    PHP_FE(pfSense_get_interface_stats, NULL)
    PHP_FE(pfSense_get_pf_stats, NULL)
    PHP_FE(pfSense_get_os_hw_data, NULL)
    PHP_FE(pfSense_get_os_kern_data, NULL)
    {NULL, NULL, NULL}
};

zend_module_entry pfSense_module_entry = {
#if ZEND_MODULE_API_NO >= 20010901
    STANDARD_MODULE_HEADER,
#endif
    PHP_PFSENSE_WORLD_EXTNAME,
    pfSense_functions,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
#if ZEND_MODULE_API_NO >= 20010901
    PHP_PFSENSE_WORLD_VERSION,
#endif
    STANDARD_MODULE_PROPERTIES
};

#ifdef COMPILE_DL_PFSENSE
ZEND_GET_MODULE(pfSense)
#endif

enum {	PFRB_TABLES = 1, PFRB_TSTATS, PFRB_ADDRS, PFRB_ASTATS,
	PFRB_IFACES, PFRB_TRANS, PFRB_MAX };
struct pfr_buffer {
	int	 pfrb_type;	/* type of content, see enum above */
	int	 pfrb_size;	/* number of objects in buffer */
	int	 pfrb_msize;	/* maximum number of objects in buffer */
	void	*pfrb_caddr;	/* malloc'ated memory area */
};
#define PFRB_FOREACH(var, buf)				\
	for ((var) = pfr_buf_next((buf), NULL);		\
	    (var) != NULL;				\
	    (var) = pfr_buf_next((buf), (var)))

/* interface management code */

static int
pfi_get_ifaces(int dev, const char *filter, struct pfi_kif *buf, int *size)
{
	struct pfioc_iface io;

	if (size == NULL || *size < 0 || (*size && buf == NULL)) {
		errno = EINVAL;
		return (-1);
	}
	bzero(&io, sizeof io);
	if (filter != NULL)
		if (strlcpy(io.pfiio_name, filter, sizeof(io.pfiio_name)) >=
		    sizeof(io.pfiio_name)) {
			errno = EINVAL;
			return (-1);
		}
	io.pfiio_buffer = buf;
	io.pfiio_esize = sizeof(*buf);
	io.pfiio_size = *size;
	if (ioctl(dev, DIOCIGETIFACES, &io))
		return (-1);
	*size = io.pfiio_size;
	return (0);
}

/* buffer management code */

size_t buf_esize[PFRB_MAX] = { 0,
	sizeof(struct pfr_table), sizeof(struct pfr_tstats),
	sizeof(struct pfr_addr), sizeof(struct pfr_astats),
	sizeof(struct pfi_kif), sizeof(struct pfioc_trans_e)
};

/*
 * return next element of the buffer (or first one if prev is NULL)
 * see PFRB_FOREACH macro
 */
static void *
pfr_buf_next(struct pfr_buffer *b, const void *prev)
{
	size_t bs;

	if (b == NULL || b->pfrb_type <= 0 || b->pfrb_type >= PFRB_MAX)
		return (NULL);
	if (b->pfrb_size == 0)
		return (NULL);
	if (prev == NULL)
		return (b->pfrb_caddr);
	bs = buf_esize[b->pfrb_type];
	if ((((caddr_t)prev)-((caddr_t)b->pfrb_caddr)) / bs >= b->pfrb_size-1)
		return (NULL);
	return (((caddr_t)prev) + bs);
}

/*
 * minsize:
 *    0: make the buffer somewhat bigger
 *    n: make room for "n" entries in the buffer
 */
static int
pfr_buf_grow(struct pfr_buffer *b, int minsize)
{
	caddr_t p;
	size_t bs;

	if (b == NULL || b->pfrb_type <= 0 || b->pfrb_type >= PFRB_MAX) {
		errno = EINVAL;
		return (-1);
	}
	if (minsize != 0 && minsize <= b->pfrb_msize)
		return (0);
	bs = buf_esize[b->pfrb_type];
	if (!b->pfrb_msize) {
		if (minsize < 64)
			minsize = 64;
		b->pfrb_caddr = calloc(bs, minsize);
		if (b->pfrb_caddr == NULL)
			return (-1);
		b->pfrb_msize = minsize;
	} else {
		if (minsize == 0)
			minsize = b->pfrb_msize * 2;
		if (minsize < 0 || minsize >= SIZE_T_MAX / bs) {
			/* msize overflow */
			errno = ENOMEM;
			return (-1);
		}
		p = realloc(b->pfrb_caddr, minsize * bs);
		if (p == NULL)
			return (-1);
		bzero(p + b->pfrb_msize * bs, (minsize - b->pfrb_msize) * bs);
		b->pfrb_caddr = p;
		b->pfrb_msize = minsize;
	}
	return (0);
}

/*
 * reset buffer and free memory.
 */
static void
pfr_buf_clear(struct pfr_buffer *b)
{
	if (b == NULL)
		return;
	if (b->pfrb_caddr != NULL)
		free(b->pfrb_caddr);
	b->pfrb_caddr = NULL;
	b->pfrb_size = b->pfrb_msize = 0;
}

PHP_FUNCTION(pfSense_get_interface_addresses)
{
	struct ifaddrs *ifdata, *mb;
        struct if_data *md;
	struct sockaddr_in *tmp;
        struct sockaddr_dl *tmpdl;
	struct ifreq ifr;
        char outputbuf[128];
        char *ifname;
        int ifname_len, s, addresscnt = 0;
	zval *caps;
	zval *encaps;

        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &ifname, &ifname_len) == FAILURE) {
                RETURN NULL;
        }

        array_init(return_value);

	getifaddrs(&ifdata);
        if (ifdata == NULL) {
                //printf("No data found\n");
                RETURN NULL;
        }

        for(mb = ifdata; mb != NULL; mb = mb->ifa_next) {
		if (mb == NULL)
                        continue;
		if (ifname_len != strlen(mb->ifa_name))
                        continue;
                if (strncmp(ifname, mb->ifa_name, ifname_len) != 0)
                        continue;
	if (mb->ifa_flags & IFF_UP)
		add_assoc_string(return_value, "status", "up", 1);
	else
		add_assoc_string(return_value, "status", "down", 1);
	if (mb->ifa_flags & IFF_LINK0)
		add_assoc_long(return_value, "link0", 1);
	if (mb->ifa_flags & IFF_LINK1)
		add_assoc_long(return_value, "link1", 1);
	if (mb->ifa_flags & IFF_LINK2)
		add_assoc_long(return_value, "link2", 1);
	if (mb->ifa_flags & IFF_MULTICAST)
		add_assoc_long(return_value, "multicast", 1);
	if (mb->ifa_flags & IFF_LOOPBACK)
                add_assoc_long(return_value, "loopback", 1);
	if (mb->ifa_flags & IFF_POINTOPOINT)
                add_assoc_long(return_value, "pointtopoint", 1);
	if (mb->ifa_flags & IFF_PROMISC)
                add_assoc_long(return_value, "promisc", 1);
	if (mb->ifa_flags & IFF_PPROMISC)
                add_assoc_long(return_value, "permanentpromisc", 1);
	if (mb->ifa_flags & IFF_OACTIVE)
                add_assoc_long(return_value, "oactive", 1);
	if (mb->ifa_flags & IFF_ALLMULTI)
                add_assoc_long(return_value, "allmulti", 1);
	if (mb->ifa_flags & IFF_SIMPLEX)
                add_assoc_long(return_value, "simplex", 1);
	if (mb->ifa_data != NULL) {
		md = mb->ifa_data;
		if (md->ifi_link_state == LINK_STATE_UP)
                	add_assoc_long(return_value, "linkstateup", 1);
		//add_assoc_long(return_value, "hwassistflag", md->ifi_hwassist);
		add_assoc_long(return_value, "mtu", md->ifi_mtu);
		switch (md->ifi_type) {
		case IFT_IEEE80211:
			add_assoc_string(return_value, "iftype", "wireless", 1);
			break;
		case IFT_ETHER:
		case IFT_FASTETHER:
		case IFT_FASTETHERFX:
		case IFT_GIGABITETHERNET:
			add_assoc_string(return_value, "iftype", "ether", 1);
			break;
		case IFT_L2VLAN:
			add_assoc_string(return_value, "iftype", "vlan", 1);
			break;
		case IFT_BRIDGE:
			add_assoc_string(return_value, "iftype", "bridge", 1);
			break;
		case IFT_TUNNEL:
		case IFT_GIF:
		case IFT_FAITH:
		case IFT_ENC:
		case IFT_PFLOG: 
		case IFT_PFSYNC:
			add_assoc_string(return_value, "iftype", "virtual", 1);
			break;
		case IFT_CARP:
			add_assoc_string(return_value, "iftype", "carp", 1);
			break;
		default:
			add_assoc_string(return_value, "iftype", "other", 1);
		}
	}
	ALLOC_INIT_ZVAL(caps);
	ALLOC_INIT_ZVAL(encaps);
	array_init(caps);
	array_init(encaps);
	s = socket(AF_LOCAL, SOCK_DGRAM, 0);
	if (s >= 0) {
		strncpy(ifr.ifr_name, ifname, sizeof(ifr.ifr_name));
		if (ioctl(s, SIOCGIFCAP, (caddr_t)&ifr) == 0) {
			if (ifr.ifr_reqcap & IFCAP_POLLING)
				add_assoc_long(caps, "polling", 1);
			if (ifr.ifr_reqcap & IFCAP_RXCSUM)
				add_assoc_long(caps, "rxcsum", 1);
			if (ifr.ifr_reqcap & IFCAP_TXCSUM)
				add_assoc_long(caps, "txcsum", 1);
			if (ifr.ifr_reqcap & IFCAP_VLAN_MTU)
				add_assoc_long(caps, "vlanmtu", 1);
			if (ifr.ifr_reqcap & IFCAP_JUMBO_MTU)
				add_assoc_long(caps, "jumbomtu", 1);
			if (ifr.ifr_reqcap & IFCAP_VLAN_HWTAGGING)
				add_assoc_long(caps, "vlanhwtag", 1);
			if (ifr.ifr_reqcap & IFCAP_VLAN_HWCSUM)
                		add_assoc_long(caps, "vlanhwcsum", 1);
			if (ifr.ifr_reqcap & IFCAP_TSO4)
                		add_assoc_long(caps, "tso4", 1);
			if (ifr.ifr_reqcap & IFCAP_TSO6)
                		add_assoc_long(caps, "tso6", 1);
			if (ifr.ifr_reqcap & IFCAP_LRO)
                		add_assoc_long(caps, "lro", 1);
			if (ifr.ifr_reqcap & IFCAP_WOL_UCAST)
                		add_assoc_long(caps, "wolucast", 1);
			if (ifr.ifr_reqcap & IFCAP_WOL_MCAST)
                		add_assoc_long(caps, "wolmcast", 1);
			if (ifr.ifr_reqcap & IFCAP_WOL_MAGIC)
                		add_assoc_long(caps, "wolmagic", 1);
			if (ifr.ifr_reqcap & IFCAP_TOE4)
                		add_assoc_long(caps, "toe4", 1);
			if (ifr.ifr_reqcap & IFCAP_TOE6)
                		add_assoc_long(caps, "toe6", 1);
			if (ifr.ifr_reqcap & IFCAP_VLAN_HWFILTER)
                		add_assoc_long(caps, "vlanhwfilter", 1);
#if 0
			if (ifr.ifr_reqcap & IFCAP_POLLING_NOCOUNT)
                		add_assoc_long(caps, "pollingnocount", 1);
#endif

			if (ifr.ifr_curcap & IFCAP_POLLING)
                                add_assoc_long(encaps, "polling", 1);
                        if (ifr.ifr_curcap & IFCAP_RXCSUM)
                                add_assoc_long(encaps, "rxcsum", 1);
                        if (ifr.ifr_curcap & IFCAP_TXCSUM)
                                add_assoc_long(encaps, "txcsum", 1);
                        if (ifr.ifr_curcap & IFCAP_VLAN_MTU)
                                add_assoc_long(encaps, "vlanmtu", 1);
                        if (ifr.ifr_curcap & IFCAP_JUMBO_MTU)
                                add_assoc_long(encaps, "jumbomtu", 1);
                        if (ifr.ifr_curcap & IFCAP_VLAN_HWTAGGING)
                                add_assoc_long(encaps, "vlanhwtag", 1);
                        if (ifr.ifr_curcap & IFCAP_VLAN_HWCSUM)
                                add_assoc_long(encaps, "vlanhwcsum", 1);
                        if (ifr.ifr_curcap & IFCAP_TSO4)
                                add_assoc_long(encaps, "tso4", 1);
                        if (ifr.ifr_curcap & IFCAP_TSO6)
                                add_assoc_long(encaps, "tso6", 1);
                        if (ifr.ifr_curcap & IFCAP_LRO)
                                add_assoc_long(encaps, "lro", 1);
                        if (ifr.ifr_curcap & IFCAP_WOL_UCAST)
                                add_assoc_long(encaps, "wolucast", 1);
                        if (ifr.ifr_curcap & IFCAP_WOL_MCAST)
                                add_assoc_long(encaps, "wolmcast", 1);
                        if (ifr.ifr_curcap & IFCAP_WOL_MAGIC)
                                add_assoc_long(encaps, "wolmagic", 1);
                        if (ifr.ifr_curcap & IFCAP_TOE4)
                                add_assoc_long(encaps, "toe4", 1);
                        if (ifr.ifr_curcap & IFCAP_TOE6)
                                add_assoc_long(encaps, "toe6", 1);
                        if (ifr.ifr_curcap & IFCAP_VLAN_HWFILTER)
                                add_assoc_long(encaps, "vlanhwfilter", 1);
#if 0
                        if (ifr.ifr_reqcap & IFCAP_POLLING_NOCOUNT)
                                add_assoc_long(caps, "pollingnocount", 1);
#endif
		}
	}
	add_assoc_zval(return_value, "caps", caps);
	add_assoc_zval(return_value, "encaps", encaps);
	//zval_ptr_dtor(&caps);
	//zval_ptr_dtor(&encaps);
		if (mb->ifa_addr == NULL)
			continue;
		switch (mb->ifa_addr->sa_family) {
		case AF_INET:
			if (addresscnt > 0)
				break;
                        bzero(outputbuf, sizeof outputbuf);
                        tmp = (struct sockaddr_in *)mb->ifa_addr;
                        inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
			add_assoc_string(return_value, "ipaddr", outputbuf, 1);
			addresscnt++;
                        tmp = (struct sockaddr_in *)mb->ifa_netmask;
			unsigned char mask;
			const unsigned char *byte = (unsigned char *)&tmp->sin_addr.s_addr;
			int i = 0, n = sizeof(tmp->sin_addr.s_addr);
			while (n--) {
				mask = ((unsigned char)-1 >> 1) + 1;
				do {
					if (mask & byte[n])
						i++;
					mask >>= 1;
				} while (mask);
			}
			add_assoc_long(return_value, "subnetbits", i);

                        bzero(outputbuf, sizeof outputbuf);
                        inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                        add_assoc_string(return_value, "subnet", outputbuf, 1);

                        if (mb->ifa_flags & IFF_BROADCAST) {
                                bzero(outputbuf, sizeof outputbuf);
                                tmp = (struct sockaddr_in *)mb->ifa_broadaddr;
                                inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                                add_assoc_string(return_value, "broadcast", outputbuf, 1);
                        }

			if (mb->ifa_flags & IFF_POINTOPOINT) {
				bzero(outputbuf, sizeof outputbuf);
                                tmp = (struct sockaddr_in *)mb->ifa_dstaddr;
                                inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                                add_assoc_string(return_value, "tunnel", outputbuf, 1);
			}

		break;
		case AF_LINK:
                        tmpdl = (struct sockaddr_dl *)mb->ifa_addr;
                        bzero(outputbuf, sizeof outputbuf);
                        ether_ntoa_r((struct ether_addr *)LLADDR(tmpdl), outputbuf);
                        add_assoc_string(return_value, "macaddr", outputbuf, 1);
                        md = (struct if_data *)mb->ifa_data;

		break;
               }
        }
	freeifaddrs(ifdata);
}

PHP_FUNCTION(pfSense_get_interface_info)
{
	struct ifaddrs *ifdata, *mb;
	struct if_data *tmpd;
        struct sockaddr_in *tmp;
        struct sockaddr_dl *tmpdl;
        char outputbuf[128];
        char *ifname;
        int ifname_len;
	struct pfr_buffer b;
	struct pfi_kif *p;
        int i = 0, error = 0;
	int dev;
	char *pf_status;

        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &ifname, &ifname_len) == FAILURE) {
                RETURN_NULL();
        }

	if ((dev = open("/dev/pf", O_RDWR)) < 0)
		RETURN NULL;

        array_init(return_value);

        getifaddrs(&ifdata);
        if (ifdata == NULL) {
                //printf("No data found\n");
		RETURN NULL;
        }

        for(mb = ifdata; mb != NULL; mb = mb->ifa_next) {
                if (mb == NULL)
                        continue;
                if (strncmp(ifname, mb->ifa_name, ifname_len) != 0)
                        continue;
                //printf("%s", mb->ifa_name);
                if (mb->ifa_flags & IFF_UP)
                        add_assoc_string(return_value, "status", "up", 1);
                else
                        add_assoc_string(return_value, "status", "down", 1);
                if (mb->ifa_flags & IFF_LINK0)
                        add_assoc_string(return_value, "link0", "down", 1);
                else
                        add_assoc_string(return_value, "link0", "up", 1);

#if 0
                if (mb->ifa_flags & IFF_BROADCAST)
                        printf(" BROADCAST");
                if (mb->ifa_flags & IFF_LOOPBACK)
                        printf(" LOOPBACK");
                if (mb->ifa_flags & IFF_PPROMISC)
                        printf(" PROMISC");
                if (mb->ifa_flags & IFF_STATICARP)
                        printf(" STATICARP");
                if (mb->ifa_flags & IFF_MULTICAST)
                        printf(" MULTICAST");
                if (mb->ifa_flags & IFF_DRV_RUNNING)
                        printf(" RUNNING");
                if (mb->ifa_flags & IFF_DRV_OACTIVE)
                        printf(" FULLQUEUE");
                printf(" ");
#endif
                switch (mb->ifa_addr->sa_family) {
                case AF_INET:
                        bzero(&outputbuf, sizeof outputbuf);
                        tmp = (struct sockaddr_in *)mb->ifa_addr;
                        inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                        add_assoc_string(return_value, "ipaddr", outputbuf, 1);

                        bzero(&outputbuf, sizeof outputbuf);
                        tmp = (struct sockaddr_in *)mb->ifa_netmask;
                        inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                        add_assoc_string(return_value, "subnet", outputbuf, 1);

                        if (mb->ifa_flags & IFF_BROADCAST) {
                                bzero(&outputbuf, sizeof outputbuf);
                                tmp = (struct sockaddr_in *)mb->ifa_broadaddr;
                                inet_ntop(AF_INET, (void *)&tmp->sin_addr, outputbuf, 128);
                                add_assoc_string(return_value, "broadcast", outputbuf, 1);
                        }

                        break;
#if 0
                case AF_INET6:
                        printf("AF_INET6 ");
                        break;
#endif
                case AF_LINK:

                        tmpdl = (struct sockaddr_dl *)mb->ifa_addr;
			bzero(&outputbuf, sizeof outputbuf);
			ether_ntoa_r((struct ether_addr *)LLADDR(tmpdl), outputbuf);
			add_assoc_string(return_value, "macaddr", outputbuf, 1);
                        tmpd = (struct if_data *)mb->ifa_data;
#if 0
                        if (tmpd->ifi_link_state == 2)
                                printf(" Link UP");
                        else
                                printf(" Link DOWN");
                        printf(" %u", tmpd->ifi_ipackets);
#endif
			add_assoc_long(return_value, "inerrs", tmpd->ifi_ierrors);
			add_assoc_long(return_value, "outerrs", tmpd->ifi_oerrors);
			add_assoc_long(return_value, "collisions", tmpd->ifi_collisions);
			add_assoc_long(return_value, "inmcasts", tmpd->ifi_imcasts);
			add_assoc_long(return_value, "outmcasts", tmpd->ifi_omcasts);
			add_assoc_long(return_value, "unsuppproto", tmpd->ifi_noproto);
			add_assoc_long(return_value, "mtu", tmpd->ifi_mtu);

                        break;
                }
        }
        freeifaddrs(ifdata);

	bzero(&b, sizeof(b));
	b.pfrb_type = PFRB_IFACES;
	for (;;) {
		pfr_buf_grow(&b, b.pfrb_size);
		b.pfrb_size = b.pfrb_msize;
		if (pfi_get_ifaces(dev, ifname, b.pfrb_caddr, &b.pfrb_size)) {
			error = 1;
			break;
		}
		if (b.pfrb_size <= b.pfrb_msize)
			break;
		i++;
	}
	if (error == 0) {
                add_assoc_string(return_value, "interface", p->pfik_name, 1);

#define PAF_INET 0
#define PPF_IN 0
#define PPF_OUT 1
                add_assoc_long(return_value, "inpktspass", (unsigned long long)p->pfik_packets[PAF_INET][PPF_IN][PF_PASS]);
                add_assoc_long(return_value, "outpktspass", (unsigned long long)p->pfik_packets[PAF_INET][PPF_OUT][PF_PASS]);
                add_assoc_long(return_value, "inbytespass", (unsigned long long)p->pfik_bytes[PAF_INET][PPF_IN][PF_PASS]);
                add_assoc_long(return_value, "outbytespass", (unsigned long long)p->pfik_bytes[PAF_INET][PPF_OUT][PF_PASS]);

                add_assoc_long(return_value, "inpktsblock", (unsigned long long)p->pfik_packets[PAF_INET][PPF_IN][PF_DROP]);
                add_assoc_long(return_value, "outpktsblock", (unsigned long long)p->pfik_packets[PAF_INET][PPF_OUT][PF_DROP]);
                add_assoc_long(return_value, "inbytesblock", (unsigned long long)p->pfik_bytes[PAF_INET][PPF_IN][PF_DROP]);
                add_assoc_long(return_value, "outbytesblock", (unsigned long long)p->pfik_bytes[PAF_INET][PPF_OUT][PF_DROP]);

                add_assoc_long(return_value, "inbytes", (unsigned long long)(p->pfik_bytes[PAF_INET][PPF_IN][PF_DROP] + p->pfik_bytes[PAF_INET][PPF_IN][PF_PASS]));
                add_assoc_long(return_value, "outbytes", (unsigned long long)(p->pfik_bytes[PAF_INET][PPF_OUT][PF_DROP] + p->pfik_bytes[PAF_INET][PPF_OUT][PF_PASS]));
                add_assoc_long(return_value, "inpkts", (unsigned long long)(p->pfik_packets[PAF_INET][PPF_IN][PF_DROP] + p->pfik_packets[PAF_INET][PPF_IN][PF_PASS]));
                add_assoc_long(return_value, "outpkts", (unsigned long long)(p->pfik_packets[PAF_INET][PPF_OUT][PF_DROP] + p->pfik_packets[PAF_INET][PPF_OUT][PF_PASS]));
#undef PPF_IN
#undef PPF_OUT
#undef PAF_INET
        }
	pfr_buf_clear(&b);
	close(dev);
}

PHP_FUNCTION(pfSense_get_interface_stats)
{
	struct ifaddrs *ifdata, *mb;
        struct if_data *tmpd;
        struct sockaddr_dl *tmpdl;
        char outputbuf[128];
        char *ifname;
        int ifname_len;

        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &ifname, &ifname_len) == FAILURE) {
                RETURN_NULL();
        }

        array_init(return_value);

        getifaddrs(&ifdata);
        if (ifdata == NULL) {
                //printf("No data found\n");
                RETURN NULL;
        }

        for(mb = ifdata; mb != NULL; mb = mb->ifa_next) {
                if (mb == NULL)
                        continue;
                if (strncmp(ifname, mb->ifa_name, ifname_len) != 0)
                        continue;
                //printf("%s", mb->ifa_name);
                if (mb->ifa_flags & IFF_UP)
                        add_assoc_string(return_value, "status", "up", 1);
                else
                        add_assoc_string(return_value, "status", "down", 1);
                if (mb->ifa_flags & IFF_LINK0)
                        add_assoc_string(return_value, "link0", "down", 1);
                else
                        add_assoc_string(return_value, "link0", "up", 1);
		switch (mb->ifa_addr->sa_family) {
                case AF_LINK:
                        tmpdl = (struct sockaddr_dl *)mb->ifa_addr;
                        bzero(&outputbuf, sizeof outputbuf);
                        ether_ntoa_r((struct ether_addr *)LLADDR(tmpdl), outputbuf);
                        add_assoc_string(return_value, "macaddr", outputbuf, 1);
                        tmpd = (struct if_data *)mb->ifa_data;

                        add_assoc_long(return_value, "inpkts", tmpd->ifi_ipackets);
                        add_assoc_long(return_value, "inbytes", tmpd->ifi_ibytes);
                        add_assoc_long(return_value, "outpkts", tmpd->ifi_opackets);
                        add_assoc_long(return_value, "outbytes", tmpd->ifi_obytes);
                        add_assoc_long(return_value, "inerrs", tmpd->ifi_ierrors);
                        add_assoc_long(return_value, "outerrs", tmpd->ifi_oerrors);
                        add_assoc_long(return_value, "collisions", tmpd->ifi_collisions);
                        add_assoc_long(return_value, "inmcasts", tmpd->ifi_imcasts);
                        add_assoc_long(return_value, "outmcasts", tmpd->ifi_omcasts);
                        add_assoc_long(return_value, "unsuppproto", tmpd->ifi_noproto);
                        add_assoc_long(return_value, "mtu", tmpd->ifi_mtu);

                        break;
                }
		break;
        }
        freeifaddrs(ifdata);

}

PHP_FUNCTION(pfSense_get_pf_stats) {
	struct pf_status status;
	time_t runtime;
	unsigned sec, min, hrs, day = runtime;
	char statline[80];
	char buf[PF_MD5_DIGEST_LENGTH * 2 + 1];
	static const char hex[] = "0123456789abcdef";
	int i;
	int dev;

	array_init(return_value);

	if ((dev = open("/dev/pf", O_RDWR)) < 0) {
		add_assoc_string(return_value, "error", strerror(errno), 1);
	} else {


	bzero(&status, sizeof(status));
        if (ioctl(dev, DIOCGETSTATUS, &status)) {
		add_assoc_string(return_value, "error", strerror(errno), 1);
	} else {
                add_assoc_long(return_value, "rulesmatch", (unsigned long long)status.counters[PFRES_MATCH]);
                add_assoc_long(return_value, "pullhdrfail", (unsigned long long)status.counters[PFRES_BADOFF]);
                add_assoc_long(return_value, "fragments", (unsigned long long)status.counters[PFRES_FRAG]);
                add_assoc_long(return_value, "shortpacket", (unsigned long long)status.counters[PFRES_SHORT]);
                add_assoc_long(return_value, "normalizedrop", (unsigned long long)status.counters[PFRES_NORM]);
                add_assoc_long(return_value, "nomemory", (unsigned long long)status.counters[PFRES_MEMORY]);
                add_assoc_long(return_value, "badtimestamp", (unsigned long long)status.counters[PFRES_TS]);
                add_assoc_long(return_value, "congestion", (unsigned long long)status.counters[PFRES_CONGEST]);
                add_assoc_long(return_value, "ipoptions", (unsigned long long)status.counters[PFRES_IPOPTIONS]);
                add_assoc_long(return_value, "protocksumbad", (unsigned long long)status.counters[PFRES_PROTCKSUM]);
                add_assoc_long(return_value, "statesbad", (unsigned long long)status.counters[PFRES_BADSTATE]);
                add_assoc_long(return_value, "stateinsertions", (unsigned long long)status.counters[PFRES_STATEINS]);
                add_assoc_long(return_value, "maxstatesdrop", (unsigned long long)status.counters[PFRES_MAXSTATES]);
                add_assoc_long(return_value, "srclimitdrop", (unsigned long long)status.counters[PFRES_SRCLIMIT]);
                add_assoc_long(return_value, "synproxydrop", (unsigned long long)status.counters[PFRES_SYNPROXY]);

                add_assoc_long(return_value, "maxstatesreached", (unsigned long long)status.lcounters[LCNT_STATES]);
                add_assoc_long(return_value, "maxsrcstatesreached", (unsigned long long)status.lcounters[LCNT_SRCSTATES]);
                add_assoc_long(return_value, "maxsrcnodesreached", (unsigned long long)status.lcounters[LCNT_SRCNODES]);
                add_assoc_long(return_value, "maxsrcconnreached", (unsigned long long)status.lcounters[LCNT_SRCCONN]);
                add_assoc_long(return_value, "maxsrcconnratereached", (unsigned long long)status.lcounters[LCNT_SRCCONNRATE]);
                add_assoc_long(return_value, "overloadtable", (unsigned long long)status.lcounters[LCNT_OVERLOAD_TABLE]);
                add_assoc_long(return_value, "overloadflush", (unsigned long long)status.lcounters[LCNT_OVERLOAD_FLUSH]);

                add_assoc_long(return_value, "statesearch", (unsigned long long)status.fcounters[FCNT_STATE_SEARCH]);
                add_assoc_long(return_value, "stateinsert", (unsigned long long)status.fcounters[FCNT_STATE_INSERT]);
                add_assoc_long(return_value, "stateremovals", (unsigned long long)status.fcounters[FCNT_STATE_REMOVALS]);

                add_assoc_long(return_value, "srcnodessearch", (unsigned long long)status.scounters[SCNT_SRC_NODE_SEARCH]);
                add_assoc_long(return_value, "srcnodesinsert", (unsigned long long)status.scounters[SCNT_SRC_NODE_INSERT]);
                add_assoc_long(return_value, "srcnodesremovals", (unsigned long long)status.scounters[SCNT_SRC_NODE_REMOVALS]);

                add_assoc_long(return_value, "stateid", (unsigned long long)status.stateid);

                add_assoc_long(return_value, "running", status.running);
                add_assoc_long(return_value, "states", status.states);
                add_assoc_long(return_value, "srcnodes", status.src_nodes);

                add_assoc_long(return_value, "hostid", ntohl(status.hostid));
		for (i = 0; i < PF_MD5_DIGEST_LENGTH; i++) {
			buf[i + i] = hex[status.pf_chksum[i] >> 4];
			buf[i + i + 1] = hex[status.pf_chksum[i] & 0x0f];
		}
		buf[i + i] = '\0';
		add_assoc_string(return_value, "pfchecksum", buf, 1);
		printf("Checksum: 0x%s\n\n", buf);

		switch(status.debug) {
		case PF_DEBUG_NONE:
			add_assoc_string(return_value, "debuglevel", "none", 1);
			break;
		case PF_DEBUG_URGENT:
			add_assoc_string(return_value, "debuglevel", "urgent", 1);
			break;
		case PF_DEBUG_MISC:
			add_assoc_string(return_value, "debuglevel", "misc", 1);
			break;
		case PF_DEBUG_NOISY:
			add_assoc_string(return_value, "debuglevel", "noisy", 1);
			break;
		default:
			add_assoc_string(return_value, "debuglevel", "unknown", 1);
			break;
		}

		runtime = time(NULL) - status.since;
		if (status.since) {
			sec = day % 60;
			day /= 60;
			min = day % 60;
			day /= 60;
			hrs = day % 24;
			day /= 24;
			snprintf(statline, sizeof(statline),
		    		"Running: for %u days %.2u:%.2u:%.2u",
		    		day, hrs, min, sec);
			add_assoc_string(return_value, "uptime", statline, 1);
		}
	}
	close(dev);
	}
}

PHP_FUNCTION(pfSense_get_os_hw_data) {
	int i, mib[4], idata;
	size_t len;	
	char *data;

	array_init(return_value);

	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
		data = malloc(len);
		if (data != NULL) {
			if (!sysctl(mib, 2, data, &len, NULL, 0)) {
				add_assoc_string(return_value, "hwmachine", data, 1);
				free(data);
			}
		}
	}

	mib[0] = CTL_HW;
        mib[1] = HW_MODEL;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "hwmodel", data, 1);
                                free(data);
                        }
		}
        }

	mib[0] = CTL_HW;
        mib[1] = HW_MACHINE_ARCH;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "hwarch", data, 1);
                                free(data);
                        }
                }
        }

	mib[0] = CTL_HW;
        mib[1] = HW_NCPU;
	len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
		add_assoc_long(return_value, "ncpus", idata);

	mib[0] = CTL_HW;
        mib[1] = HW_PHYSMEM;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "physmem", idata);

	mib[0] = CTL_HW;
        mib[1] = HW_USERMEM;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "usermem", idata);

	mib[0] = CTL_HW;
        mib[1] = HW_REALMEM;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "realmem", idata);
}

PHP_FUNCTION(pfSense_get_os_kern_data) {
        int i, mib[4], idata;
        size_t len;
        char *data;
	struct timeval bootime;

	array_init(return_value);

        mib[0] = CTL_KERN;
        mib[1] = KERN_HOSTUUID;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "hostuuid", data, 1);
                                free(data);
                        }
                }
        }

        mib[0] = CTL_KERN;
        mib[1] = KERN_HOSTNAME;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "hostname", data, 1);
                                free(data);
                        }
                }
        }

        mib[0] = CTL_KERN;
        mib[1] = KERN_OSRELEASE;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "osrelease", data, 1);
                                free(data);
                        }
                }
        }

	mib[0] = CTL_KERN;
        mib[1] = KERN_VERSION;
        if (!sysctl(mib, 2, NULL, &len, NULL, 0)) {
                data = malloc(len);
                if (data != NULL) {
                        if (!sysctl(mib, 2, data, &len, NULL, 0)) {
                                add_assoc_string(return_value, "oskernel_version", data, 1);
                                free(data);
                        }
                }
        }

        mib[0] = CTL_KERN;
        mib[1] = KERN_BOOTTIME;
        len = sizeof(bootime);
        if (!sysctl(mib, 2, &bootime, &len, NULL, 0))
                add_assoc_string(return_value, "boottime", ctime(&bootime.tv_sec), 1);

        mib[0] = CTL_KERN;
        mib[1] = KERN_HOSTID;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "hostid", idata);

        mib[0] = CTL_KERN;
        mib[1] = KERN_OSRELDATE;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "osreleasedate", idata);

	mib[0] = CTL_KERN;
        mib[1] = KERN_OSREV;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "osrevision", idata);

	mib[0] = CTL_KERN;
        mib[1] = KERN_SECURELVL;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "ossecurelevel", idata);

	mib[0] = CTL_KERN;
        mib[1] = KERN_OSRELDATE;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "osreleasedate", idata);

	mib[0] = CTL_KERN;
        mib[1] = KERN_OSRELDATE;
        len = sizeof(idata);
        if (!sysctl(mib, 2, &idata, &len, NULL, 0))
                add_assoc_long(return_value, "osreleasedate", idata);
}

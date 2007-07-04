/*
 * Copyright (c) 2004 Camiel Dobbelaar, <cd@sentia.nl>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

#include <net/if.h>
#include <net/pfvar.h>
#include <net/ppp_defs.h>
#include <netinet/if_ether.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/tcp_fsm.h>
#include <arpa/inet.h>

#include <ctype.h>
#include <err.h>
#include <errno.h>
#include <pcap.h>
#include <pwd.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#include <time.h>
#include <unistd.h>

#include "filter.h"
#include "state.h"

#define NOPRIV_USER	"proxy"
#define CHROOT_DIR	"/var/empty"

#define PCAP_TO_MS	500
#define PURGE_INTERVAL	60
#define SNAPLEN		500

#define IPSTR_LEN	16
#define	IP_HDRLEN	(sizeof(struct ip))
#define TH_MASK		(TH_FIN|TH_SYN|TH_RST|TH_ACK)

int	 clienttalk(struct state *, char *);
void	 servertalk(struct state *, char *);
int	 parse_port(char *, int);
struct state *tcp_state(struct ip *, struct tcphdr *, int *);
void	 process_pkt(u_char *, struct pcap_pkthdr *, u_char *);
char	*copy_argv(char * const *);
int	 drop_privs(void);
void	 logmsg(int, const char *, ...);
void	 sig_alarm(int);
void	 sig_close(int);
void	 usage(void);

enum { PARSE_PORT, PARSE_PASV, PARSE_EPSV, PARSE_EPRT };
enum { ACTIVE, PASSIVE };

u_int32_t ps_proc;
int daemonize, linktype, loglevel;
unsigned int linklen;
volatile sig_atomic_t gotsig_alarm, gotsig_close;
extern char *__progname;

int
clienttalk(struct state *s, char *cbuf)
{
	size_t buflen;

	/* Cbuf length is ultimately bound by the snaplen. */

	logmsg(LOG_DEBUG, "#%d client: %s", s->id, cbuf);

	buflen = strlen(cbuf) + 1;
	if (buflen > s->clientbuflen) {
		if (s->clientbuf != NULL)
			free(s->clientbuf);
		/* What reduces the number of mallocs? */
		buflen += 42;
		s->clientbuf = malloc(buflen);
		if (s->clientbuf == NULL) {
			logmsg(LOG_ERR, "clienttalk malloc");
			s->clientbuflen = 0;
			return (0);
		}
		s->clientbuflen = buflen;
	}

	strlcpy(s->clientbuf, cbuf, s->clientbuflen);

	return (1);
}

void
servertalk(struct state *s, char *sbuf)
{
	struct in_addr *src, *dst, *realsrc;
	char *cbuf, ipstr[IPSTR_LEN];
	int mode, port;

	cbuf = s->clientbuf;

	logmsg(LOG_DEBUG, "#%d server: %s", s->id, sbuf);

	/* Passive mode (PASV). */
	if (strcasecmp("PASV", cbuf) == 0 &&
	    strncasecmp("227 ", sbuf, strlen("227 ")) == 0) {
		logmsg(LOG_INFO, "#%d passive: %s", s->id, sbuf);
		mode = PASSIVE;
		src = &s->ip_src;
		dst = &s->ip_dst;
		port = parse_port(sbuf, PARSE_PASV);
	}
	/* Active mode (PORT). */
	else if (strncasecmp("PORT ", cbuf, strlen("PORT ")) == 0 &&
	    strncasecmp("200 ", sbuf, strlen("200 ")) == 0) {
		logmsg(LOG_INFO, "#%d active: %s", s->id, cbuf);
		mode = ACTIVE;
		src = &s->ip_dst;
		dst = &s->ip_src;
		port = parse_port(cbuf, PARSE_PORT);
	}
	/* Extended passive mode (EPSV). */
	else if (strcasecmp("EPSV", cbuf) == 0 &&
	    strncasecmp("229 ", sbuf, strlen("229 ")) == 0) {
		logmsg(LOG_INFO, "#%d ext. passive: %s", s->id, sbuf);
		mode = PASSIVE;
		src = &s->ip_src;
		dst = &s->ip_dst;
		port = parse_port(sbuf, PARSE_EPSV);
	}
	/* Extended active mode (EPRT). */
	else if (strncasecmp("EPRT ", cbuf, strlen("EPRT ")) == 0 &&
	    strncasecmp("200 ", sbuf, strlen("200 ")) == 0) {
		logmsg(LOG_INFO, "#%d ext. active: %s", s->id, cbuf);
		mode = ACTIVE;
		src = &s->ip_dst;
		dst = &s->ip_src;
		port = parse_port(cbuf, PARSE_EPRT);
	}	
	/* No match. */
	else
		return;

	if (port == -1) {
		logmsg(LOG_WARNING, "#%d parse_port failed: client '%s', " \
		    "server '%s'", s->id, cbuf, sbuf);
		return;
	}

	if (port < 1024) {
		logmsg(LOG_WARNING, "#%d denying low port %d request", s->id,
		    port);
		return;
	}

	strlcpy(ipstr, inet_ntoa(*dst), sizeof ipstr);
	logmsg(LOG_INFO, "#%d allowing %s to %s port %d", s->id,
	    inet_ntoa(*src), ipstr, port);

	realsrc = NULL;
	if (mode == PASSIVE &&
	    memcmp(&s->ip_src, &s->ip_src_real, sizeof s->ip_src) != 0) {
		realsrc = &s->ip_src_real;
		logmsg(LOG_INFO, "#%d passive/nat: also allowing %s to " \
		    "%s port %d", s->id, inet_ntoa(*realsrc), ipstr, port);
	}

	if (filter_allow(s->id, src, realsrc, dst, port))
		s->rule_ts = time(NULL);
	else
		logmsg(LOG_ERR, "#%d filter_allow failed: %s", s->id,
		    strerror(errno));
}

int
parse_port(char *buf, int mode)
{
	unsigned int	i, port, v[6];
	char		c1, c2, *p;

	/* Find the last space or left-parenthesis. */
	for (p = buf + strlen(buf); p > buf; p--)
		if (*p == ' ' || *p == '(')
			break;
	if (p == buf)
		return (-1);

	/* The %c format specifier is used to detect trailing characters. */
	switch (mode) {
	case PARSE_PORT:
		i = sscanf(p, " %u,%u,%u,%u,%u,%u%c", &v[0], &v[1], &v[2],
		    &v[3], &v[4], &v[5], &c1);
		if (i != 6 || v[0] > 255 || v[1] > 255 || v[2] > 255 ||
		    v[3] > 255 || v[4] > 255 || v[5] > 255)
			return (-1);
		port = (v[4] << 8) | v[5];
		break;
	case PARSE_PASV:
		i = sscanf(p, "(%u,%u,%u,%u,%u,%u)%c%c", &v[0], &v[1], &v[2],
		    &v[3], &v[4], &v[5], &c1, &c2);
		if (i != 6) {
			/* Microsoft FTP server prints a trailing dot. */
			if (i != 7 || c1 != '.')
				return (-1);
		}
		if (v[0] > 255 || v[1] > 255 || v[2] > 255 ||
		    v[3] > 255 || v[4] > 255 || v[5] > 255)
			return (-1);
		port = (v[4] << 8) | v[5];
		break;
	case PARSE_EPSV:
		i = sscanf(p, "(|||%u|)%c", &port, &c1);
		if (i != 1 || port > 65535)
			return (-1);
		break;
	case PARSE_EPRT:
		/* Our EPRT support is limited to IPv4. */
		i = sscanf(p, " |1|%u.%u.%u.%u|%u|%c", &v[0], &v[1], &v[2],
		    &v[3], &port, &c1);
		if (i != 5 || v[0] > 255 || v[1] > 255 || v[2] > 255 ||
		    v[3] > 255 || port > 65535)
			return (-1);
		break;
	default:
		return (-1);
	}

	return (port);
}

struct state *
tcp_state(struct ip *ip, struct tcphdr *tcp, int *isclient)
{
	struct state *s;

	s = state_find(ip, tcp, isclient);

	if (s == NULL) {
		if ((tcp->th_flags & TH_MASK) == TH_SYN) {
			char ipstr[IPSTR_LEN];

			s = state_new(ip, tcp);
			if (s == NULL) {
				logmsg(LOG_ERR, "cannot add session");
				return (NULL);
			}
			strlcpy(ipstr, inet_ntoa(ip->ip_src), sizeof ipstr);
			logmsg(LOG_INFO, "#%d session init: client %s:%d, " \
			    "server %s:%d", s->id, ipstr, ntohs(tcp->th_sport),
			    inet_ntoa(ip->ip_dst), ntohs(tcp->th_dport));

			s->tcps = TCPS_SYN_SENT;
		}
		/* SYN has no payload. */
		return (NULL);
	}
			
	if (tcp->th_flags & (TH_FIN|TH_RST)) {
		logmsg(LOG_INFO, "#%d session finish", s->id);
		state_remove(s);
		return (NULL);
	}

	switch (s->tcps) {
	case TCPS_SYN_SENT:
		/* Expect a SYN/ACK from the server. */
		if (*isclient || (tcp->th_flags & TH_MASK) != (TH_SYN|TH_ACK))
			break;
		/*
		 * Now is a good time to check that pf allowed this connection.
		 * (pf does not filter for us, as we are on bpf)
		 */
		if (filter_lookup(&s->ip_src, &s->ip_dst, s->s_port, s->d_port,
		    &s->ip_src_real))
			s->tcps = TCPS_SYN_RECEIVED;
		else
			logmsg(LOG_WARNING, "#%d session not in statetable",
			    s->id);
		/* SYN/ACK has no payload. */
		break;
	case TCPS_SYN_RECEIVED:
		/* Expect an ACK from the client to complete the handshake. */
		if (*isclient && (tcp->th_flags & TH_MASK) == TH_ACK) {
			s->tcps = TCPS_ESTABLISHED;
			return (s);
		}
		break;
	case TCPS_ESTABLISHED:
		if ((tcp->th_flags & TH_MASK) == TH_ACK)
			return (s);
		break;
	default:
		logmsg(LOG_ERR, "#%d unknown tcp state: %d", s->id, s->tcps);
	}

	return (NULL);
}

void
process_pkt(u_char *notused, struct pcap_pkthdr *h, u_char *p)
{
	struct ip *ip;
	struct tcphdr *tcp;
	struct state *s;
	int isclient;
	unsigned int i, ip_len, tcp_datalen, tcp_off;
	char *tcp_data;

	ps_proc++;

	if (h->caplen != h->len) {
		logmsg(LOG_WARNING, "drop: short capture");
		return;
	}

	/*
	 * We don't want to grok all linktypes to be able to check if the
	 * packet is of type IP, so we just assume it is.  The user must
	 * supply a seriously bad expression on the commandline anyway for
	 * non-IP packets to get here.  In that case, the checks below should
	 * suffice, but they'll get a bit more logging.
	 */

	if (h->len < linklen + IP_HDRLEN) {
		logmsg(LOG_WARNING, "drop: short ip");
		return;
	}

	ip = (struct ip *)(p + linklen);

	if (ip->ip_v != 4) {
		logmsg(LOG_WARNING, "drop: not ipv4");
		return;
	}
	if ((ip->ip_hl << 2) != IP_HDRLEN) {
		logmsg(LOG_WARNING, "drop: ip options");
		return;
	}

	ip_len = ntohs(ip->ip_len);

	if (h->len < linklen + ip_len) {
		logmsg(LOG_WARNING, "drop: long ip");
		return;
	}
	if ((ntohs(ip->ip_off) & (IP_MF | IP_OFFMASK)) != 0) {
		logmsg(LOG_WARNING, "drop: fragmented");
		return;
	}
	if (ip->ip_ttl < 2) {
		logmsg(LOG_WARNING, "drop: ttl too low");
		return;
	}
	if (ip->ip_p != IPPROTO_TCP) {
		logmsg(LOG_WARNING, "drop: not tcp");
		return;
	}
	if (ip_len < IP_HDRLEN + sizeof(struct tcphdr)) {
		logmsg(LOG_WARNING, "drop: tcp short");
		return;
	}

	tcp = (struct tcphdr *)(p + linklen + IP_HDRLEN);

	/* Run our little state machine. */
	s = tcp_state(ip, tcp, &isclient);
	if (s == NULL)
		return;

	tcp_off = tcp->th_off << 2;
	if (ip_len < IP_HDRLEN + tcp_off) {
		logmsg(LOG_WARNING, "drop: tcp_off off");
		return;
	}
	tcp_datalen = ip_len - (IP_HDRLEN + tcp_off);
	if (tcp_datalen == 0)
		return;
	tcp_data = ((char *)tcp) + tcp_off;

	/*
	 * We are going to be strict here and only look at properly
	 * terminated lines.  The lines we are looking for are small
	 * enough to always fit in one IP packet.  If not, tough luck.
	 *
	 * If there are multiple lines in one packet, we only look at
	 * the first one.
	 */

	for (i = 0; i < tcp_datalen; i++)
		if (tcp_data[i] == '\r' || tcp_data[i] == '\n') {
			tcp_data[i] = '\0';
			break;
		}
	if (i == tcp_datalen) {
		if (s->clientbuf != NULL)
			s->clientbuf[0] = '\0';
		return;
	}

	if (isclient) {
		if (!clienttalk(s, tcp_data))
			state_remove(s);
		return;
	}

	if (s->clientbuf == NULL || s->clientbuf[0] == '\0')
		return;

	servertalk(s, tcp_data);
	s->clientbuf[0] = '\0';
}

int
main(int argc, char **argv)
{
	struct bpf_insn blockall[] = { BPF_STMT(BPF_RET+BPF_K, 0) };
	struct bpf_program bprog, wfilter;
	struct pcap_stat pstat;
	char errbuf[PCAP_ERRBUF_SIZE];
	char *filter, *interface, *qname, *tagname;
	pcap_t *hpcap;
	int ch, immediate;

	/* Defaults. */
	daemonize = 1;
	loglevel = LOG_NOTICE;
	interface = NULL;
	tagname = NULL;
	qname = NULL;
	filter = "tcp and port 21";

	while ((ch = getopt(argc, argv, "D:di:q:t:")) != -1) {
		switch (ch) {
		case 'D':
			loglevel = atoi(optarg);
			if (loglevel < LOG_EMERG || loglevel > LOG_DEBUG)
				usage();
			break;
		case 'd':
			daemonize = 0;
			break;
		case 'i':
			interface = optarg;
			break;
		case 't':
			if (strlen(optarg) >= PF_TAG_NAME_SIZE)
				errx(1, "tag too long");
			tagname = optarg;
			break;
		case 'q':
			if (strlen(optarg) >= PF_QNAME_SIZE)
				errx(1, "queue too long");
			qname = optarg;
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;

	if (argc) {
		filter = copy_argv(argv);
		if (filter == NULL)
			err(1, "copy_argv");
	}

	/* Check for root to save the user from cryptic failure messages. */
	if (getuid() != 0)
		errx(1, "needs to start as root");

	filter_init(qname, tagname);

	if (interface == NULL) {
		interface = pcap_lookupdev(errbuf);
		if (interface == NULL)
			errx(1, "%s", errbuf);
	}
	hpcap = pcap_open_live(interface, SNAPLEN, 0, PCAP_TO_MS, errbuf);
	if (hpcap == NULL)
		errx(1, "%s", errbuf);

	linktype = pcap_datalink(hpcap);
	switch (linktype) {
	case DLT_EN10MB:
		linklen = sizeof(struct ether_header);
		break;
	case DLT_PPP:
		linklen = PPP_HDRLEN;
	case DLT_LOOP:
		linklen = 4;
		break;
	default:
		errx(1, "%s: unsupported interface type", interface);
	}

	if (pcap_compile(hpcap, &bprog, filter, 1, 0) < 0 ||
	    pcap_setfilter(hpcap, &bprog) < 0)
		errx(1, "filter '%s': %s", filter, pcap_geterr(hpcap));

	immediate = 1;
	if (ioctl(pcap_fileno(hpcap), BIOCIMMEDIATE, &immediate) < 0)
		err(1, "BIOCIMMEDIATE");
	wfilter.bf_len = 1;
	wfilter.bf_insns = blockall;
	if (ioctl(pcap_fileno(hpcap), BIOCSETWF, &wfilter) < 0)
		err(1, "BIOCSETWF");
	if (ioctl(pcap_fileno(hpcap), BIOCLOCK) < 0)
		err(1, "BIOCLOCK");

	if (daemonize) {
		if (daemon(0, 0) == -1)
			err(1, "daemon");
		openlog(__progname, LOG_PID | LOG_NDELAY, LOG_DAEMON);
	}

	/* Use logmsg for output from here on. */
	
	if (!drop_privs()) {
		logmsg(LOG_ERR, "drop_privs: %s", strerror(errno));
		exit(1);
	}

	gotsig_alarm = gotsig_close = 0;
	signal(SIGALRM, sig_alarm);
	signal(SIGINT, sig_close);
	signal(SIGQUIT, sig_close);
	signal(SIGTERM, sig_close);
	alarm(PURGE_INTERVAL);

	state_init();
	ps_proc = 0;

	for (;;) {
		/* Step up... Step up... Step in the Arena. */
		pcap_dispatch(hpcap, 0, (pcap_handler)process_pkt, NULL);

		if (gotsig_close)
			break;

		if (gotsig_alarm) {
			logmsg(LOG_DEBUG, "sessions after purging: %d",
				state_purge(0));
			gotsig_alarm = 0;
			alarm(PURGE_INTERVAL);
		}
	}
	
	state_purge(1);

	pcap_close(hpcap);

	if (daemonize)
		closelog();

	return (0);
}

char *
copy_argv(char * const *argv)
{
	size_t len = 0, n;
	char *buf;

	if (argv == NULL)
		return (NULL);

	for (n = 0; argv[n]; n++)
		len += strlen(argv[n]) + 1;
	if (len == 0)
		return (NULL);

	buf = malloc(len);
	if (buf == NULL)
		return (NULL);

	strlcpy(buf, argv[0], len);
	for (n = 1; argv[n]; n++) {
		strlcat(buf, " ", len);
		strlcat(buf, argv[n], len);
	}
	return (buf);
}

int
drop_privs(void)
{
	struct passwd *pw;
	gid_t gidset[1];

	pw = getpwnam(NOPRIV_USER);
	if (pw == NULL)
		return (0);

	tzset();

	if (chroot(CHROOT_DIR) != 0)
		return (0);
	chdir("/");

	gidset[0] = pw->pw_gid;
	if (setgroups(1, gidset) == -1 || setegid(pw->pw_gid) == -1 ||
	    setgid(pw->pw_gid) == -1 || seteuid(pw->pw_uid) == -1 ||
	    setuid(pw->pw_uid) == -1)
		return (0);
	
	return (1);
}

void
logmsg(int pri, const char *message, ...)
{
	va_list ap;
	va_start(ap, message);

	if (pri > loglevel)
		return;
		
	if (!daemonize) {
		vfprintf(stderr, message, ap);
		fprintf(stderr, "\n");
	} else
		vsyslog(pri, message, ap);
	va_end(ap);
}

void
sig_alarm(int sig)
{
	gotsig_alarm = 1;
}

void
sig_close(int sig)
{
	gotsig_close = 1;
}

void
usage(void)
{
	fprintf(stderr, "usage: %s [-d] [-D level] [-i interface] " \
	    "[-q queue] [-t tag] [expression]\n", __progname);
	exit(1);
}

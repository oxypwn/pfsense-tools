/*-
 * Copyright (c) 2008 Michael Telahun Makonnen <mtm@FreeBSD.Org>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * $Id$
 */

#include <sys/types.h>
#include <sys/socket.h>

#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>

#include <assert.h>
#include <err.h>
#include <fcntl.h>
#include <libgen.h>
#include <libutil.h>
#include <limits.h>
#include <pthread.h>
#include <signal.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sysexits.h>
#include <syslog.h>
#include <unistd.h>

#include "hashtable.h"
#include "pathnames.h"
#include "protocols.h"

#define IC_DPORT	7777
#define IC_HASHSZ	4096
#define IC_PKTMAXMATCH	5
#define IC_PKTSZ	1500
#define IC_QMAXSZ	256

/*
 * Internal representation of a packet.
 */
struct ic_pkt {
	STAILQ_ENTRY(ic_pkt) fp_link;
	struct sockaddr_in   fp_saddr;	/* divert(4) address/port of packet */
	socklen_t	     fp_salen;	/* size in bytes of fp_addr */
	u_char	 *fp_pkt;		/* raw packet from divert(4) */
	size_t	 fp_pktlen;		/* size in bytes of packet */
};

STAILQ_HEAD(pkt_head, ic_pkt);

/*
 * Structure on which incomming/outgoing packets are queued.
 */
struct ic_queue {
	pthread_cond_t	fq_condvar;	/* signaled when pkts are available */
	pthread_mutex_t fq_mtx;		/* syncronization mutex */
	struct pkt_head fq_pkthead;	/* queue head */
	int fq_maxsz;			/* max size (in packets) of queue */
	int fq_size;			/* current size */
};

/*
 * Contains information about a particular ip flow.
 */
struct ip_flow {
	char	 *if_data;	/* concatenated payload (max QMAXSZ pkts) */
	uint32_t if_datalen;	/* length in bytes of if_data */
	uint16_t if_pktcount;	/* number of packets concatenated */
	uint16_t if_fwrule;	/* ipfw(4) rule associated with flow */
};

/*
 * Structure used as key for maintaining hash table of IP flows.
 */
struct ip_flow_key {
	struct in_addr ik_src;		/* src IP address */
	struct in_addr ik_dst;		/* dst IP address */
	uint16_t  ik_sport;		/* src port */
	uint16_t  ik_dport;		/* dst port */
};

/*
 * IP packet header.
 */
struct allhdr {
	struct ip ah_ip;
	union {
		struct tcphdr tcp;
		struct udphdr udp;
	} ah_nexthdr;
#define ah_tcp		ah_nexthdr.tcp
#define ah_udp		ah_nexthdr.udp
};

/*
 * Global incomming and outgoing queues.
 */
static struct ic_queue inQ;
static struct ic_queue outQ;

/* divert(4) socket */
static int dvtS;

/* config file path */
static const char *conf = IC_CONFIG_PATH;

/* Directory containing protocol files with matching RE patterns */
static const char *protoDir = IC_PROTO_PATH;

/* List of protocols available to the system */
struct ic_protocols *fp;

/*
 * Forward function declarations.
 */
void		*classify_pthread(void *);
void		*read_pthread(void *);
void		*write_pthread(void *);
static int	equalkeys(void *, void *);
static unsigned int hashfromkey(void *);
static void	test_re(void);
static void	handle_signal(int);
static int	read_config(const char *, struct ic_protocols *);
static void	usage(const char *);

int
main(int argc, char **argv)
{
	struct sockaddr_in addr;
	struct sigaction sa;
	pthread_t  classifytd, readtd, writetd;
	const char *errstr;
	long long  num;
	uint16_t   port, qmaxsz;
	int	   ch, error, tflag;

	tflag = 0;
	port = IC_DPORT;
	qmaxsz = IC_QMAXSZ;
	while ((ch = getopt(argc, argv, "htc:P:p:q:")) != -1) {
		switch(ch) {
		case 'c':
			conf = strdup(optarg);
			if (conf == NULL)
				err(EX_TEMPFAIL, "config file path");
			break;
		case 'P':
			protoDir = strdup(optarg);
			if (protoDir == NULL)
				err(EX_TEMPFAIL, "protocols directory path");
			break;
		case 'p':
			num = strtonum((const char *)optarg, 1, 65535, &errstr);
			if (num == 0 && errstr != NULL) {
				errx(EX_USAGE, "invalid divert port: %s", errstr);
			}
			port = (uint16_t)num;
			break;
		case 'q':
			num = strtonum((const char *)optarg, 0, 65535, &errstr);
			if (num == 0 && errstr != NULL) {
				errx(EX_USAGE, "invalid queue length: %s", errstr);
			}
			qmaxsz = (uint16_t)num;
			break;
		case 't':
			tflag = 1;
			break;
		case 'h':
		default:
			usage((const char *)*argv);
			exit(EX_USAGE);
		}
	}
	argc -= optind;
	argv += optind;

	/* The user just wants to test an RE pattern against a data file. */
	if (tflag) {
		test_re();
		return (0);
	}

	if (daemon(0, 1) != 0)
		err(EX_OSERR, "unable to daemonize");

	/*
	 * Initialize incomming and outgoing queues.
	 */
	STAILQ_INIT(&inQ.fq_pkthead);
	inQ.fq_maxsz = qmaxsz;
	error = pthread_mutex_init(&inQ.fq_mtx, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to initialize input queue mutex");
	error = pthread_cond_init(&inQ.fq_condvar, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to initialize input queue condvar");
	STAILQ_INIT(&outQ.fq_pkthead);
	outQ.fq_maxsz = qmaxsz;
	error = pthread_mutex_init(&outQ.fq_mtx, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to initialize output queue mutex");
	error = pthread_cond_init(&outQ.fq_condvar, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to initialize output queue condvar");

	/*
	 * Create and bind the divert(4) socket.
	 */
	memset((void *)&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = INADDR_ANY;
	dvtS = socket(PF_INET, SOCK_RAW, IPPROTO_DIVERT);
	if (dvtS == -1)
		err(EX_OSERR, "unable to create divert socket");
	error = bind(dvtS, (struct sockaddr *)&addr, sizeof(addr));
	if (error != 0)
		err(EX_OSERR, "unable to bind divert socket");

	/*
	 * Initialize list of available protocols.
	 */
	fp = init_protocols(protoDir);
	if (fp == NULL) {
		syslog(LOG_ERR, "unable to initialize list of protocols: %m");
		exit(EX_SOFTWARE);
	}

	/*
	 * Match protocol to ipfw(4) rule from configuration file.
	 */
	error = read_config(conf, fp);
	if (error != 0){
		syslog(LOG_ERR, "unable to open configuration file");
		exit(error);
	}

	/*
	 * Catch SIGHUP in order to reread configuration file.
	 */
	sa.sa_handler = handle_signal;
	sa.sa_flags = SA_SIGINFO|SA_RESTART;
	sigemptyset(&sa.sa_mask);
	error = sigaction(SIGHUP, &sa, NULL);
	if (error == -1)
		err(EX_OSERR, "unable to set signal handler");
	error = sigaction(SIGTERM, &sa, NULL);
	if (error == -1)
		err(EX_OSERR, "unable to set signal handler");

	/*
	 * Create the various threads.
	 */
	error = pthread_create(&readtd, NULL, read_pthread, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to create reader thread");
	error = pthread_create(&classifytd, NULL, classify_pthread, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to create classifier thread");
	error = pthread_create(&writetd, NULL, write_pthread, NULL);
	if (error != 0)
		err(EX_OSERR, "unable to create writer thread");

	/*
	 * Wait for our threads to exit.
	 */
	pthread_join(readtd, NULL);
	pthread_join(classifytd, NULL);
	pthread_join(writetd, NULL);

	/*
	 * Cleanup
	 */
	close(dvtS);
	
	return (0);
}

void *
read_pthread(void *arg __unused)
{
	struct ic_pkt	   *pkt;
	struct ip *ipp;
	int	  len;

	while (1) {
		pkt = (struct ic_pkt *)malloc(sizeof(struct ic_pkt));
		if (pkt == NULL) {
			syslog(LOG_ERR, "malloc of pkt structure failed: %m");
			exit(EX_TEMPFAIL);
		}
		pkt->fp_pkt = (char *)malloc(IC_PKTSZ);
		if (pkt->fp_pkt == NULL) {
			syslog(LOG_ERR, "malloc of buffer for pkt failed: %m");
			exit(EX_TEMPFAIL);
		}

getinput:
		memset(&pkt->fp_saddr, '\0', sizeof(struct sockaddr_in));
		pkt->fp_salen = sizeof(struct sockaddr_in);
		len = recvfrom(dvtS, (void *)pkt->fp_pkt, IC_PKTSZ, 0,
		    (struct sockaddr *)&pkt->fp_saddr, &pkt->fp_salen);
		if (len == -1) {
			syslog(LOG_ERR, "receive from divert socket failed: %m");
			exit(EX_OSERR);
		}
		ipp = (struct ip *)pkt->fp_pkt;

		/* Drop packets that are not TCP or UDP */
		if (ipp->ip_p != IPPROTO_TCP && ipp->ip_p != IPPROTO_UDP) {
			syslog(LOG_WARNING, "packet dropped: not TCP or UDP");
			goto getinput;

		/* Drop the packet if the queue is already full */
		} else if (inQ.fq_size >= inQ.fq_maxsz) {
			syslog(LOG_WARNING, "packet dropped: input queue full");
			goto getinput;
		}

		/*
		 * Enqueue incomming packet.
		 */
		pkt->fp_pktlen = len;
		pthread_mutex_lock(&inQ.fq_mtx);
		STAILQ_INSERT_HEAD(&inQ.fq_pkthead, pkt, fp_link);
		inQ.fq_size++;
		pthread_mutex_unlock(&inQ.fq_mtx);
		pthread_cond_signal(&inQ.fq_condvar);
	}

	/* NOTREACHED */
	return (NULL);
}

#define SET_KEY(k, hdr, sp, dp)						\
	do {								\
		(k) = (struct ip_flow_key *)malloc(sizeof(struct ip_flow_key));	\
		if ((k) != NULL) {					\
			if ((sp) > (dp)) {				\
				(k)->ik_src = (hdr)->ah_ip.ip_src;		\
				(k)->ik_dst = (hdr)->ah_ip.ip_dst;		\
				(k)->ik_sport = (sp);			\
				(k)->ik_dport = (dp);			\
			} else {					\
				(k)->ik_src = (hdr)->ah_ip.ip_dst;		\
				(k)->ik_dst = (hdr)->ah_ip.ip_src;		\
				(k)->ik_sport = (dp);			\
				(k)->ik_dport = (sp);			\
			}						\
		}							\
	} while (0)

/*
 * XXX - Yeah, I know. This is messy, but I want the classifier and pattern
 *	 tester (-t switch) to use the same code, but I didn't want to put
 *	 it in a separate function of its own for performance reasons.
 */
#define CLASSIFY(fp, pkt, proto, flow, key, pmatch, trycount, error, regerr) 	\
	do {									\
		(trycount) = 0;							\
		SLIST_FOREACH((proto), &(fp)->fp_p, p_next) {			\
			if ((proto)->p_fwrule == 0)				\
				continue;					\
			else if ((trycount) == (fp)->fp_inuse)			\
				break;						\
			(pmatch).rm_so = 0;					\
			(pmatch).rm_eo = (flow)->if_datalen;			\
			(error) = regexec(&(proto)->p_preg, (flow)->if_data,	\
				1, &(pmatch), REG_STARTEND);			\
                        if ((error) == 0) {                                     \
                                (flow)->if_fwrule = (proto)->p_fwrule;          \
                                (pkt)->fp_saddr.sin_port = (flow)->if_fwrule;   \
				break;						\
			} else if ((error) != REG_NOMATCH) {			\
				regerror((error), &(proto)->p_preg, (regerr), sizeof((regerr))); \
				syslog(LOG_WARNING, "error matching %s:%d -> %s:%d against %s: %s", \
					inet_ntoa((key)->ik_src), ntohs((key)->ik_sport), \
					inet_ntoa((key)->ik_dst), ntohs((key)->ik_dport), \
					(proto)->p_name, (regerr));		\
			}							\
			(trycount)++;						\
		}								\
	} while (0)

void *
classify_pthread(void *arg __unused)
{
	char		 errbuf[LINE_MAX];
	struct allhdr	 *hdr;
	struct ip_flow_key *key;
	struct ip_flow	 *flow;
	struct tcphdr	 *tcp;
	struct udphdr	 *udp;
	struct ic_pkt	 *pkt;
	struct hashtable *sh, *th, *uh;
	struct protocol	 *proto;
	regmatch_t	 pmatch;
	u_char		 *data, *payload;
	uint16_t	 trycount;
	int		 datalen, error;

	/*
	 * There are 3 tables: udp, tcp, and tcp syn.
	 * The tcp syn table tracks connections for which a
	 * SYN packet has been sent but no reply has been returned
	 * yet. Once the SYN ACK reply is detected it is moved to
	 * the regular tcp connection tracking table.
	 */
	sh = create_hashtable(IC_HASHSZ, hashfromkey, equalkeys);
	if (sh == NULL) {
		syslog(LOG_ERR, "unable to create TCP (SYN) tracking table");
		exit(EX_SOFTWARE);
	}
	th = create_hashtable(IC_HASHSZ, hashfromkey, equalkeys);
	if (th == NULL) {
		syslog(LOG_ERR, "unable to create TCP tracking table");
		exit(EX_SOFTWARE);
	}
	uh = create_hashtable(IC_HASHSZ, hashfromkey, equalkeys);
	if (uh == NULL) {
		syslog(LOG_ERR, "unable to create UDP tracking table");
		exit(EX_SOFTWARE);
	}

	flow = NULL;
	key = NULL;
	while(1) {
		pthread_mutex_lock(&inQ.fq_mtx);
		pkt = STAILQ_LAST(&inQ.fq_pkthead, ic_pkt, fp_link);
		while (pkt == NULL) {
			error = pthread_cond_wait(&inQ.fq_condvar, &inQ.fq_mtx);
			if (error != 0) {
				strerror_r(error, errbuf, sizeof(errbuf));
				syslog(EX_OSERR,
				    "unable to wait on input queue: %s",
				    errbuf);
				exit(EX_OSERR);
			}
			pkt = STAILQ_LAST(&inQ.fq_pkthead, ic_pkt, fp_link);
		}
		STAILQ_REMOVE(&inQ.fq_pkthead, pkt, ic_pkt, fp_link);
		inQ.fq_size--;
		pthread_mutex_unlock(&inQ.fq_mtx);

		/*
		 * Check if new and insert into appropriate table.
		 */
		hdr = (struct allhdr *)pkt->fp_pkt;
		if (hdr->ah_ip.ip_p == IPPROTO_TCP) {
			tcp = &hdr->ah_tcp;
			payload = (u_char *)((u_char *)tcp + (tcp->th_off * 4));
			datalen = ntohs(hdr->ah_ip.ip_len) -
			    (int)((caddr_t)payload - (caddr_t)&hdr->ah_ip);
			assert(datalen >= 0);

			SET_KEY(key, hdr, tcp->th_sport, tcp->th_dport);
			if (key == NULL) {
				syslog(LOG_WARNING, "packet dropped: %m");
				free(pkt->fp_pkt);
				free(pkt);
				continue;
			}

			/*
			 * Handle session initiation.
			 */
			if ((tcp->th_flags & TH_FLAGS) ==  TH_SYN) {
				/*
				 * Assume any pre-existing records are stale.
				 */
				flow = hashtable_search(sh, (void *)key);
				if (flow != NULL) {
					flow = hashtable_remove(sh, (void *)key);
					free(flow->if_data);
					free(flow);
					flow = NULL;
				}

				flow = (struct ip_flow *)
				    malloc(sizeof(struct ip_flow));
				if (flow == NULL) {
					syslog(LOG_WARNING, "packet dropped: %m");
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}
				flow->if_data = NULL;
				flow->if_datalen = 0;
				/* Don't count TCP handshake packets */
				flow->if_pktcount = 0;
				flow->if_fwrule = 0;
				if (hashtable_insert(sh, (void *)key,
				    (void *)flow) == 0) {
					syslog(LOG_NOTICE,
					    "packet dropped: unable to insert into table");
					free(flow);
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}
				goto enqueue;
			/*
			 * Handle session tear-down.
			 * XXX - Not sure what other flags are not allowed with FIN.
			 */
			} else if (((tcp->th_flags & TH_FIN) != 0) &&
			    (tcp->th_flags & (TH_RST|TH_SYN)) == 0) {
				/* XXX - Should we look in SYN table also? */
				flow = hashtable_search(th, (void *)key);
				if (flow != NULL) {
					flow = hashtable_remove(th, (void *)key);
					if (flow->if_data != NULL)
						free(flow->if_data);
					free(flow);
					flow = NULL;
				}
				free(key);
				goto enqueue;
			}

			/*
			 * Skip anything that's not an ACK or PSH/ACK
			 */
			if ((tcp->th_flags & TH_FLAGS) !=  TH_ACK &&
			    (tcp->th_flags & TH_FLAGS) !=  (TH_PUSH|TH_ACK))
				goto enqueue;

			/*
			 * Look in the regular table first since most
			 * packets will belong to an already established
			 * session.
			 */
			flow = hashtable_search(th, (void *)key);
			if (flow != NULL) {
				if (datalen > 0 && flow->if_pktcount < IC_PKTMAXMATCH) {
					data = (char *)realloc((void *)flow->if_data,
					    flow->if_datalen + datalen);
					if (data == NULL) {
						syslog(LOG_WARNING, "packet dropped: %m");
						free(key);
						free(pkt->fp_pkt);
						free(pkt);
						continue;
					}
					memcpy((void *)(data + flow->if_datalen),
					    (void *)payload, datalen);
					flow->if_data = data;
					flow->if_datalen += datalen;
					flow->if_pktcount++;

				/*
				 * If we haven't been able to classify this flow after
				 * collecting IC_PKTMAXMATCH packets, just pass it through.
				 */
				} else if (flow->if_pktcount >= IC_PKTMAXMATCH &&
				    flow->if_fwrule == 0)
					goto enqueue;
				goto classify;
			}

			flow = hashtable_search(sh, (void *)key);
			if (flow != NULL) {
				if (datalen > 0) {
					data = (char *)malloc(datalen);
					if (data == NULL) {
						syslog(LOG_WARNING, "packet dropped: %m");
						free(key);
						free(pkt->fp_pkt);
						free(pkt);
						continue;
					}
					memcpy((void *)data, (void *)payload,
					    datalen);
				} else
					data = NULL;

				flow->if_data = data;
				flow->if_datalen = datalen;

				/*
				 * If we're still in the SYN table then this is probably
				 * the last ACK of the handshake. Don't count it against
				 * the packet count for this flow if there is no data.
				 */
				flow->if_pktcount = (flow->if_data == NULL) ? 0 : 1;

				/*
				 * Remove it from the SYN table and insert into the
				 * regular tcp flow tracking table.
				 */
				hashtable_remove(sh, (void *)key);
				if (hashtable_insert(th, (void *)key, (void *)flow) == 0) {
					syslog(LOG_WARNING,
					    "packet dropped: unable to insert into table");
					if (data != NULL)
						free(data);
					free(flow);
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}
				goto classify;
			}

			/*
			 * None of the Above (tm). Just pass it through.
			 */
			goto enqueue;

		} else if (hdr->ah_ip.ip_p == IPPROTO_UDP) {
			udp = &hdr->ah_udp;
			payload = (u_char *)((u_char *)udp + ntohs(udp->uh_ulen));
			datalen = ntohs(hdr->ah_ip.ip_len) -
			    (int)((caddr_t)payload - (caddr_t)&hdr->ah_ip);
			assert(datalen >= 0);

			SET_KEY(key, hdr, udp->uh_sport, udp->uh_dport);
			if (key == NULL) {
				syslog(LOG_WARNING, "packet dropped: %m");
				free(pkt->fp_pkt);
				free(pkt);
				continue;
			}

			/*
			 * If this is a new connection insert payload.
			 * Otherwise, if we haven't reached the packet limit
			 * append it to the pre-existing data.
			 */
			flow = hashtable_search(uh, key);
			if (flow == NULL) {
				flow = (struct ip_flow *)malloc(sizeof(struct ip_flow));
				if (flow == NULL) {
					syslog(LOG_WARNING, "packet dropped: %m");
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}

				if (datalen > 0) {
					data = (char *)malloc(datalen);
					if (data == NULL) {
						syslog(LOG_WARNING, "packet dropped: %m");
						free(flow);
						free(key);
						free(pkt->fp_pkt);
						free(pkt);
						continue;
					}
					memcpy((void *)data, (void *)payload,
					    datalen);
				} else
					data = NULL;

				flow->if_data = data;
				flow->if_datalen = datalen;
				flow->if_pktcount = 1;
				flow->if_fwrule = 0;
				if (hashtable_insert(uh, (void *)key, (void *)flow) == 0) {
					syslog(LOG_WARNING,
					    "packet dropped: unable to insert into table");
					if (data != NULL)
						free(data);
					free(flow);
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}
			} else if ((flow->if_pktcount < IC_PKTMAXMATCH) &&
			    datalen > 0) {
				data = (char *)realloc((void *)flow->if_data,
				    flow->if_datalen + datalen);
				if (data == NULL) {
					syslog(LOG_WARNING, "packet dropped: %m");
					free(key);
					free(pkt->fp_pkt);
					free(pkt);
					continue;
				}
				memcpy((void *)(data + flow->if_datalen),
				    (void *)payload, datalen);
				flow->if_data = data;
				flow->if_datalen += datalen;
				flow->if_pktcount++;
			/*
			 * If we haven't been able to classify this flow after
			 * collecting IC_PKTMAXMATCH packets, just pass it through.
			 */
			} else if (flow->if_pktcount >= IC_PKTMAXMATCH &&
			    flow->if_fwrule == 0)
				goto enqueue;
		} else
			/* Not an TCP or UDP packet. */
			goto enqueue;

classify:
		assert(flow != NULL);

		/*
		 * Inform divert(4) what rule to send it to by
		 * modifying the port number of the associated sockaddr_in
		 * structure. Note: we subtract one from the ipfw(4) rule
		 * number because processing in ipfw(4) will start with
		 * the next rule *after* the supplied rule number.
		 */
		if (flow->if_fwrule != 0) {
			pkt->fp_saddr.sin_port = flow->if_fwrule;
			goto enqueue;
		}

		/*
		 * Do not try to match protocol patterns if there is not
		 * any data in the session to match yet or if there are
		 * no protocols we want to classify.
		 */
		if (flow->if_datalen == 0 || fp->fp_inuse == 0)
			goto enqueue;

		/*
		 * Packet has not been classified yet. Attempt to classify it.
		 */
		CLASSIFY(fp, pkt, proto, flow, key, pmatch, trycount, error, errbuf);

enqueue:
		/* Drop the packet if the output queue is full */
		if (outQ.fq_size >= outQ.fq_maxsz) {
			syslog(LOG_WARNING, "packet dropped: output queue full");
			free(pkt->fp_pkt);
			free(pkt);
			continue;
		}

		/*
		 * Enqueue for writing back to divert(4) socket.
		 */
		pthread_mutex_lock(&outQ.fq_mtx);
		STAILQ_INSERT_HEAD(&outQ.fq_pkthead, pkt, fp_link);
		outQ.fq_size++;
		pthread_mutex_unlock(&outQ.fq_mtx);
		pthread_cond_signal(&outQ.fq_condvar);
	}

	/* NOTREACHED */
	return (NULL);
}

void *
write_pthread(void *arg __unused)
{
	char errbuf[LINE_MAX];
	struct ic_pkt *pkt;
	int	  error, len;

	while (1) {
		pthread_mutex_lock(&outQ.fq_mtx);
		pkt = STAILQ_LAST(&outQ.fq_pkthead, ic_pkt, fp_link);
		while (pkt == NULL) {
			error = pthread_cond_wait(&outQ.fq_condvar, &outQ.fq_mtx);
			if (error != 0) {
				strerror_r(error, errbuf, sizeof(errbuf));
				syslog(LOG_ERR,
				    "unable to wait on output queue: %s",
				    errbuf);
				    exit(EX_OSERR);
			}
			pkt = STAILQ_LAST(&outQ.fq_pkthead, ic_pkt, fp_link);
		}
		STAILQ_REMOVE(&outQ.fq_pkthead, pkt, ic_pkt, fp_link);
		outQ.fq_size--;
		pthread_mutex_unlock(&outQ.fq_mtx);

		len = sendto(dvtS, (void *)pkt->fp_pkt, pkt->fp_pktlen, 0,
		    (const struct sockaddr *)&pkt->fp_saddr, pkt->fp_salen);
		if (len == -1)
			syslog(LOG_WARNING,
			    "unable to write to divert socket: %m");
		else if ((size_t)len != pkt->fp_pktlen)
			syslog(LOG_WARNING,
			    "complete packet not written: wrote %d of %d", len,
			    pkt->fp_pktlen);
	
		/*
		* Cleanup
		*/
		free(pkt->fp_pkt);
		free(pkt);
	}

	/* NOTREACHED */
	return (NULL);
}

/*
 * NOTE: The protocol list (plist) passed as an argument is a global
 *	 variable. It is accessed from 3 functions: classify_pthread,
 *	 re_test, and handle_signal. However, we don't need to implement
 *	 syncronization mechanisms (like mutexes) because only one
 *	 of them at a time will have access to it: the first and
 *	 second functions run in mutually exclusive contexts, and
 *	 since handle_signal is a signal handler there is no chance that
 *	 it will run concurrently with either of the other two. Second,
 *	 the list is created once and no additions or deletions are
 *	 made during the lifetime of the program. The only modification
 *	 this function makes is to change the firewall rule associated
 *	 with a protocol.
 */
static int
read_config(const char *file, struct ic_protocols *plist)
{
	struct protocol *proto;
	properties	props;
	const char	*errmsg, *name, *value;
	int		fd;
	uint16_t	rule;

	fd = open(file, O_RDONLY);
	if (fd == -1) {
		syslog(LOG_ERR, "unable to open configuration file");
		return (EX_OSERR);
	}
	props = properties_read(fd);
	if (props == NULL) {
		syslog(LOG_ERR, "error reading configuration file");
		return (EX_DATAERR);
	}
	plist->fp_inuse = 0;
	SLIST_FOREACH(proto, &plist->fp_p, p_next) {
		name = proto->p_name;
		value = property_find(props, name);
		/* Do not match traffic against this pattern */
		if (value == NULL)
			continue;
		rule = strtonum(value, 1, 65535, &errmsg);
		if (rule == 0) {
			syslog(LOG_WARNING,
			    "invalid rule number for %s protocol: %s",
			    proto->p_name, errmsg);
			continue;
		}
		proto->p_fwrule = rule;
		plist->fp_inuse++;
		syslog(LOG_NOTICE, "Loaded Protocol: %s (rule %d)",
		    proto->p_name, proto->p_fwrule);
	}
	properties_free(props);
	return (0);
}

static void
test_re()
{
	char		 regerr[LINE_MAX];
	struct ip_flow_key key0;
	struct ip_flow	 *flow, flow0;
	struct ic_pkt	 *pkt;
	struct protocol	 *proto;
	regmatch_t	 pmatch;
	uint16_t	 trycount;
	int		 error, len;

	/*
	 * Initialize list of available protocols.
	 */
	fp = init_protocols(protoDir);
	if (fp == NULL)
		err(EX_SOFTWARE, "unable to initialize list of protocols");

	/*
	 * Match protocol to ipfw(4) rule from configuration file.
	 */
	error = read_config(conf, fp);
	if (error != 0){
		syslog(LOG_ERR, "unable to open configuration file");
		exit(error);
	}

	pkt = (struct ic_pkt *)malloc(sizeof(struct ic_pkt));
	if (pkt == NULL)
		err(EX_TEMPFAIL, "malloc of pkt structure failed");
	pkt->fp_pkt = (char *)malloc(IC_PKTSZ);
	if (pkt->fp_pkt == NULL)
		err(EX_TEMPFAIL, "malloc of buffer for pkt failed");

	len = read(STDIN_FILENO, pkt->fp_pkt, IC_PKTSZ);
	if (len == -1)
		err(EX_OSERR, "unable to read input");
	else if (len == 0)
		errx(EX_SOFTWARE, "no input to read");

	flow = &flow0;
	pkt->fp_pktlen = len;
	flow->if_fwrule = 0;
	flow->if_data = pkt->fp_pkt;
	flow->if_datalen = pkt->fp_pktlen;
	memset((void *)&key0, 0, sizeof(struct ip_flow_key));

	CLASSIFY(fp, pkt, proto, flow, &key0, pmatch, trycount, error, regerr);

	free(pkt->fp_pkt);
	free(pkt);

	return;
}

static void
handle_signal(int sig)
{
	switch(sig) {
	case SIGHUP:
		read_config(conf, fp);
		break;
	case SIGTERM:
		exit(0);
		break;
	default:
		syslog(LOG_WARNING, "unhandled signal");
	}
}

static void
usage(const char *arg0)
{
	printf("usage: %s [-h] [-c file] [-p port] [-P dir] [-q length]\n", basename(arg0));
	printf("usage: %s -t -P dir\n", basename(arg0));
	printf(	"    -c file   : path to configuration file\n"
		"    -h        : this help screen\n"
		"    -P dir    : directory containing protocol patterns\n"
		"    -p port   : port number of divert socket\n"
		"    -q length : max length (in packets) of in/out queues\n"
		"    -t        : test the sample protocol data supplied on "
		"the standard input stream\n");
}

/*
 * Credits: Christopher Clark <firstname.lastname@cl.cam.ac.uk>
 */
static unsigned int
hashfromkey(void *ky)
{
    struct ip_flow_key *k = (struct ip_flow_key *)ky;
    return (((k->ik_src.s_addr << 17) | (k->ik_src.s_addr >> 15)) ^ k->ik_dst.s_addr) +
            (k->ik_sport * 17) + (k->ik_dport * 13 * 29);
}

static int
equalkeys(void *k1, void *k2)
{
    return (0 == memcmp(k1,k2,sizeof(struct ip_flow_key)));
}

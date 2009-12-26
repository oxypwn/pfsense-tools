/*-
 * Copyright (c) 2008 Michael Telahun Makonnen <mtm@FreeBSD.Org>
 * Copyright (c) 2009 Ermal Luçi <eri@pfsense.org>
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
 * $Id: classifyd.c 580 2008-08-02 12:48:12Z mtm $
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/time.h>

#include <net/if.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <net/pfvar.h>

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
#include <time.h>
#include <errno.h>

#include "hashtable.h"
#include "hashtable_private.h"
#include "pathnames.h"
#include "protocols.h"

#define IC_DPORT	7777
#define IC_HASHSZ	4096
static int IC_PKTMAXMATCH = 5;
#define IC_PKTSZ	1500
#define IC_QMAXSZ	256

#define DIVERT_ALTQ 0x1000
#define DIVERT_DNCOOKIE 0x2000
#define DIVERT_ACTION 0x4000
#define DIVERT_TAG 0x8000

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
	struct hashtable *hash;		/* hashtable for flows */
	pthread_cond_t	fq_condvar;	/* signaled when pkts are available */
	pthread_cond_t	gq_condvar;	/* signaled when pkts need GC */
	pthread_mutex_t fq_mtx;		/* syncronization mutex */
	struct pkt_head fq_pkthead;	/* queue head */
	int fq_maxsz;			/* max size (in packets) of queue */
	int fq_size;			/* current size */
	pthread_t	classifytd;	/* classify thread */
	pthread_t	garbagetd;	/* garbage collect thread */
};

/*
 * Contains information about a particular ip flow.
 */
struct ip_flow {
	char	 *if_data;	/* concatenated payload (max QMAXSZ pkts) */
	uint32_t if_datalen;	/* length in bytes of if_data */
	uint16_t if_pktcount;	/* number of packets concatenated */
	uint16_t if_fwrule;	/* ipfw(4) rule associated with flow */
	time_t	 expire;	/* flow expire time */
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
static struct ic_queue inQTCP;
static struct ic_queue inQUDP;
static struct ic_queue outQ;

pthread_mutex_t time_mtx;

/*
 * Since getting time is a expensive operation dedicate 
 * a thread to it.
 */
static struct timeval   t_time;

/* divert(4) socket */
static int dvtSin = 0;
static int dvtSout = 0;

/* config file path */
static const char *conf = IC_CONFIG_PATH;

/* Directory containing protocol files with matching RE patterns */
static const char *protoDir = IC_PROTO_PATH;

/* List of protocols available to the system */
pthread_rwlock_t fp_lock;
#define FP_LOCK_INIT    pthread_rwlock_init(&fp_lock, NULL)
#define FP_LOCK         pthread_rwlock_rdlock(&fp_lock)
#define FP_UNLOCK       pthread_rwlock_unlock(&fp_lock)
#define FP_WLOCK        pthread_rwlock_wrlock(&fp_lock)
struct ic_protocols *fp;

/* number of packets before kicking garbage collector */
static unsigned int npackets = 250; 

static time_t time_expire = 40; /* 40 seconds */
/*
 * Forward function declarations.
 */
void		*classify_pthread(void *);
void		*read_pthread(void *);
void		*write_pthread(void *);
void		*garbage_pthread(void *);
void		*classifyd_get_time(void *);
static int	equalkeys(void *, void *);
static unsigned int hashfromkey(void *);
static void	test_re(void);
static int	init_queue(struct ic_queue *, uint16_t);
static void	clean_queue(struct ic_queue *);
static void	handle_signal(int);
static int	read_config(const char *, struct ic_protocols *);
static void	usage(const char *);

void *
classifyd_get_time(void *arg __unused) 
{
	struct timespec ts;

	pthread_mutex_lock(&time_mtx);

	while (1) {
		while (clock_gettime(CLOCK_REALTIME, &ts) != 0)
			;

		t_time.tv_sec = ts.tv_sec;
		ts.tv_nsec += 200 * 1000;
		pthread_mutex_timedlock(&time_mtx, &ts);
	}
}

static void
clean_queue(struct ic_queue *queue)
{
	if (queue->hash != NULL)
		hashtable_destroy(queue->hash, 1);
}

static int 
init_queue(struct ic_queue *queue, uint16_t qmaxsz)
{
	int error = 0;

	/*
         * Initialize incomming and outgoing queues.
         */
        STAILQ_INIT(&queue->fq_pkthead);
        queue->fq_maxsz = qmaxsz;
        error = pthread_mutex_init(&queue->fq_mtx, NULL);
        if (error != 0) {
                warn("unable to initialize input queue mutex at line %d", __LINE__);
		return error;
	}
        error = pthread_cond_init(&queue->fq_condvar, NULL);
        if (error != 0) {
                warn("unable to initialize input queue condvar at line %d", __LINE__);	
		return error;
	}

	queue->hash = create_hashtable(IC_HASHSZ, hashfromkey, equalkeys);
        if (queue->hash == NULL) {
                syslog(LOG_ERR, "unable to create tracking table at line %d", __LINE__);
                return (EX_SOFTWARE);
        }
	error = pthread_create(&queue->classifytd, NULL, classify_pthread, queue);
        if (error != 0) {
                syslog(LOG_ERR, "unable to create classifier thread at line %d", __LINE__);
                goto cleanup;
        }
	error = pthread_create(&queue->garbagetd, NULL, garbage_pthread, queue);
        if (error != 0) {
                syslog(LOG_ERR, "unable to create garbage collect thread at line %d", __LINE__);
                goto cleanup;
        }

	return (error);

cleanup:
	clean_queue(queue);
	
	return (error);
}

int
main(int argc, char **argv)
{
	struct sockaddr_in addr;
	struct sigaction sa;
	pthread_t  readtd, writetd, time_thread;
	const char *errstr;
	long long  num;
	uint16_t   port, qmaxsz;
	int	   ch, error, tflag;

	tflag = 0;
	port = IC_DPORT;
	qmaxsz = IC_QMAXSZ;
	while ((ch = getopt(argc, argv, "n:e:htc:P:p:q:")) != -1) {
		switch(ch) {
		case 'c':
			conf = strdup(optarg);
			if (conf == NULL)
				err(EX_TEMPFAIL, "config file path");
			break;
		case 'e':
			num = strtonum((const char *)optarg, 1, 400, &errstr);
			if (num == 0 && errstr != NULL) {
				errx(EX_USAGE, "invalud expire seconds: %s", errstr);	
			}
			time_expire = (time_t)num;
			break;
		case 'n':
                        num = strtonum((const char *)optarg, 1, 65535, &errstr);
                        if (num == 0 && errstr != NULL) {
                                errx(EX_USAGE, "invalid number for packets: %s", errstr);
                        }
                        npackets = (unsigned int)num;
			IC_PKTMAXMATCH = num;
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
	 * Create and bind the divert(4) socket.
	 */
	memset((void *)&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = INADDR_ANY;
	dvtSin = socket(PF_INET, SOCK_RAW, IPPROTO_DIVERT);
	if (dvtSin == -1)
		err(EX_OSERR, "unable to create in divert socket");
	error = bind(dvtSin, (struct sockaddr *)&addr, sizeof(addr));
	if (error != 0)
		err(EX_OSERR, "unable to bind in divert socket");
	dvtSout = socket(PF_INET, SOCK_RAW, IPPROTO_DIVERT);
	if (dvtSout == -1)
		err(EX_OSERR, "unable to create out divert socket");
	addr.sin_port = htons(port + 1);
	error = bind(dvtSout, (struct sockaddr *)&addr, sizeof(addr));
	if (error != 0)
		err(EX_OSERR, "unable to bind out divert socket");

	/*
	 * Initialize list of available protocols.
	 */
	FP_LOCK_INIT;
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

	/* Initialize the time mutex. */
	pthread_mutex_init(&time_mtx, NULL);

        /*
         * Initialize incomming and outgoing queues.
         */
        if (init_queue(&inQTCP, qmaxsz))
                err(EX_OSERR, "check your configuration and parameters to continue");
        if (init_queue(&inQUDP, qmaxsz)) {
                clean_queue(&inQTCP);
                err(EX_OSERR, "check your configuration and parameters to continue");
        }
        if (init_queue(&outQ, qmaxsz)) {
                clean_queue(&inQTCP);
                clean_queue(&inQUDP);
                err(EX_OSERR, "check your configuration and parameters to continue");
        }

	/*
	 * Create the various threads.
	 */
	error = pthread_create(&readtd, NULL, read_pthread, NULL);
	if (error != 0) {
		syslog(LOG_ERR, "unable to create reader thread");
		error = EX_OSERR;
		goto cleanup;
	}
	error = pthread_create(&writetd, NULL, write_pthread, NULL);
	if (error != 0) {
		syslog(LOG_ERR, "unable to create writer thread");
		error = EX_OSERR;
		goto cleanup;
	}
	error = pthread_create(&time_thread, NULL, classifyd_get_time, NULL);
        if (error != 0) {
                clean_queue(&inQTCP);
                clean_queue(&inQUDP);
                clean_queue(&outQ);
                syslog(LOG_ERR, "unable to create time reading thread");
                goto cleanup;
        }

	/*
	 * Wait for our threads to exit.
	 */
	pthread_join(readtd, NULL);
	pthread_join(writetd, NULL);
	pthread_join(inQTCP.classifytd, NULL);
	pthread_join(inQUDP.classifytd, NULL);
	pthread_join(inQTCP.garbagetd, NULL);
	pthread_join(inQUDP.garbagetd, NULL);
	pthread_join(time_thread, NULL);

	/*
	 * Cleanup
	 */
cleanup:
	if (dvtSin > 0)
		close(dvtSin);
	if (dvtSout > 0)
		close(dvtSout);

	FP_WLOCK;
	fini_protocols(fp);
	FP_UNLOCK;

	pthread_mutex_destroy(&time_mtx);

	return (error);
}

void *
read_pthread(void *arg __unused)
{
	struct ic_queue	   *queue;
	struct ic_pkt	   *pkt;
	struct ip *ipp;
	int	  len;
	unsigned int pcktcnt = 0;

	while (1) {
		pkt = (struct ic_pkt *)malloc(sizeof(struct ic_pkt));
		if (pkt == NULL) {
			syslog(LOG_ERR, "malloc of pkt structure failed: %m");
			continue; /* XXX */
		}
		pkt->fp_pkt = (char *)malloc(IC_PKTSZ);
		if (pkt->fp_pkt == NULL) {
			syslog(LOG_ERR, "malloc of buffer for pkt failed: %m");
			free(pkt);
			continue; /* XXX */
		}

getinput:
		memset(&pkt->fp_saddr, '\0', sizeof(struct sockaddr_in));
		pkt->fp_salen = sizeof(struct sockaddr_in);
		len = recvfrom(dvtSin, (void *)pkt->fp_pkt, IC_PKTSZ, 0,
		    (struct sockaddr *)&pkt->fp_saddr, &pkt->fp_salen);
		if (len == -1) {
			syslog(LOG_ERR, "receive from divert socket failed: %m");
			goto getinput; /* XXX */
		}
		ipp = (struct ip *)pkt->fp_pkt;

		/* Drop packets that are not TCP or UDP */
		/* XXX: Make more dynamic so protocols can be easly added. */
		switch (ipp->ip_p) {
		case IPPROTO_TCP:
			/* Drop the packet if the queue is already full */
			if (inQTCP.fq_size >= inQTCP.fq_maxsz) {
				syslog(LOG_WARNING, "packet dropped: input TCP queue full");
				goto getinput;
			}
			queue = &inQTCP;
			break;
		case IPPROTO_UDP:
			/* Drop the packet if the queue is already full */
			if (inQUDP.fq_size >= inQUDP.fq_maxsz) {
				syslog(LOG_WARNING, "packet dropped: input UDP queue full");
				goto getinput;
			}
			queue = &inQUDP;
			break;
		default:
			syslog(LOG_WARNING, "packet dropped: not TCP or UDP");
			goto getinput;
			break;
		}

		/*
		 * Enqueue incomming packet.
		 */
		pkt->fp_pktlen = len;
		pthread_mutex_lock(&queue->fq_mtx);
		STAILQ_INSERT_HEAD(&queue->fq_pkthead, pkt, fp_link);
		queue->fq_size++;
		pthread_mutex_unlock(&queue->fq_mtx);
		if (++pcktcnt > npackets) {
			pcktcnt = 0;
			pthread_cond_signal(&queue->gq_condvar);
		} else
			pthread_cond_signal(&queue->fq_condvar);
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
		FP_LOCK;							\
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
				syslog(LOG_WARNING, "Found Protocol: %s (rule %s)", \
                    			(proto)->p_name, ((proto)->p_fwrule & DIVERT_ACTION) ? "action block": \
                                        ((proto)->p_fwrule & DIVERT_DNCOOKIE) ? "dnpipe" : \
                                        ((proto)->p_fwrule & DIVERT_ALTQ) ? "altq" : "tag"); \
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
		FP_UNLOCK;							\
	} while (0)

void *
classify_pthread(void *arg)
{
	struct ic_queue	 *queue = (struct ic_queue *)arg;
	char		 errbuf[LINE_MAX];
	struct allhdr	 *hdr;
	struct ip_flow_key *key;
	struct ip_flow	 *flow;
	struct tcphdr	 *tcp = NULL;;
	struct udphdr	 *udp;
	struct ic_pkt	 *pkt;
	struct protocol	 *proto;
	regmatch_t	 pmatch;
	u_char		 *data, *payload = NULL;
	uint16_t	 trycount;
	int		 datalen = 0, error;

	flow = NULL;
	key = NULL;
	while(1) {
		pthread_mutex_lock(&queue->fq_mtx);
		pkt = STAILQ_LAST(&queue->fq_pkthead, ic_pkt, fp_link);
		while (pkt == NULL) {
			error = pthread_cond_wait(&queue->fq_condvar, &queue->fq_mtx);
			if (error != 0) {
				strerror_r(error, errbuf, sizeof(errbuf));
				syslog(EX_OSERR,
				    "unable to wait on input queue: %s",
				    errbuf);
				exit(EX_OSERR);
			}
			pkt = STAILQ_LAST(&queue->fq_pkthead, ic_pkt, fp_link);
		}
		STAILQ_REMOVE(&queue->fq_pkthead, pkt, ic_pkt, fp_link);
		queue->fq_size--;
		pthread_mutex_unlock(&queue->fq_mtx);

		/*
		 * Check if new and insert into appropriate table.
		 */
		hdr = (struct allhdr *)pkt->fp_pkt;
		if (hdr->ah_ip.ip_p == IPPROTO_TCP) {
			tcp = &hdr->ah_tcp;
			payload = (u_char *)((u_char *)tcp + (tcp->th_off * 4));
			datalen = ntohs(hdr->ah_ip.ip_len) -
			    (int)((caddr_t)payload - (caddr_t)&hdr->ah_ip);
		} else if (hdr->ah_ip.ip_p == IPPROTO_UDP) {
                        udp = &hdr->ah_udp;
                        payload = (u_char *)((u_char *)udp + ntohs(udp->uh_ulen));
                        datalen = ntohs(hdr->ah_ip.ip_len) -
                            (int)((caddr_t)payload - (caddr_t)&hdr->ah_ip);
		}

		assert(datalen >= 0);

		SET_KEY(key, hdr, tcp->th_sport, tcp->th_dport);
		if (key == NULL) {
			syslog(LOG_WARNING, "packet dropped: %m");
			free(pkt->fp_pkt);
			free(pkt);
			continue;
		}

		/*
		 * Look in the regular table first since most
		 * packets will belong to an already established
		 * session.
		 */
		flow = hashtable_search(queue->hash, (void *)key);
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
                                 memcpy((void *)data, (void *)payload, datalen);
			} else
				data = NULL;

			flow->if_data = data;
			flow->if_datalen = datalen;
                        flow->if_pktcount = 1;
                        flow->if_fwrule = 0;
                        flow->expire = t_time.tv_sec;
                        if (hashtable_insert(queue->hash, (void *)key, (void *)flow) == 0) {
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
		} else if (datalen > 0 && flow->if_pktcount < IC_PKTMAXMATCH) {
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
		} else {
			flow->expire = t_time.tv_sec;
			goto enqueue;
		}

		/*
		 * Inform divert(4) what rule to send it to by
		 * modifying the port number of the associated sockaddr_in
		 * structure. Note: we subtract one from the ipfw(4) rule
		 * number because processing in ipfw(4) will start with
		 * the next rule *after* the supplied rule number.
		 */
		if (flow != NULL && flow->if_fwrule != 0) {
			pkt->fp_saddr.sin_port = flow->if_fwrule;
			goto enqueue;
		}

		/*
		 * Do not try to match protocol patterns if there is not
		 * any data in the session to match yet or if there are
		 * no protocols we want to classify.
		 */
		if (flow != NULL && (flow->if_datalen == 0 || fp->fp_inuse == 0))
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

		len = sendto(dvtSin, (void *)pkt->fp_pkt, pkt->fp_pktlen, 0,
		    (const struct sockaddr *)&pkt->fp_saddr, pkt->fp_salen);
		if (len == -1) {
			if (errno == EACCES)
				syslog(LOG_WARNING,
					"packet dropped by security policy! %m");
			else
				syslog(LOG_WARNING,
			    		"unable to write to divert socket: %m");
		} else if ((size_t)len != pkt->fp_pktlen) {
			if (errno == EMSGSIZE)
				syslog(LOG_WARNING, "packet to big %zu bytes.",
					pkt->fp_pktlen);
			else
				syslog(LOG_WARNING,
			    	"complete packet not written: wrote %d of %zu", len,
			    		pkt->fp_pktlen);
		}
		/*
		* Cleanup
		*/
		free(pkt->fp_pkt);
		free(pkt);
	}

	/* NOTREACHED */
	return (NULL);
}

void *
garbage_pthread(void *arg)
{
	struct ic_queue	*queue = (struct ic_queue *)arg;
	char errbuf[LINE_MAX];
	struct entry *e, *f;
	unsigned int i, flows_expired, error; 

	while (1) {
		flows_expired = 0;
		t_time.tv_sec -= time_expire;

		pthread_mutex_lock(&queue->fq_mtx);
                error = pthread_cond_wait(&queue->gq_condvar, &queue->fq_mtx);
                if (error != 0) {
                        strerror_r(error, errbuf, sizeof(errbuf));
                        syslog(EX_OSERR, "unable to wait on garbage collection: %s",
                                errbuf);
                        exit(EX_OSERR);
                }

                for (i = 0; i < queue->hash->tablelength; i++) {
                        e = queue->hash->table[i];
                        while (e != NULL) {
                                f = e; e = e->next;
                                if (f->v != NULL && ((struct ip_flow *)f->v)->expire < t_time.tv_sec) {
                                        freekey(f->k);
                                        queue->hash->entrycount--;
                                        if (f->v != NULL)
                                                free(f->v);
                                        free(f);
					flows_expired++;
					queue->hash->table[i] = e;
                                }
                        }
                }

		pthread_mutex_unlock(&queue->fq_mtx);

		//syslog(LOG_WARNING, "expired %u flows", flows_expired);

		pthread_cond_signal(&queue->fq_condvar);
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
	enum { bufsize = 2048 };
	struct protocol *proto;
	properties	props;
	const char	*errmsg, *name;
	char		*value;
	int		fd, fdpf;
	uint16_t	rule;
	struct pfioc_ruleset trule;
	char **ap, *argv[bufsize];

	fdpf = open("/dev/pf", O_RDONLY);
	if (fdpf == -1) {
		syslog(LOG_ERR, "unable to open /dev/pf");
		return (EX_OSERR);
	}
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
		for (ap = argv; (*ap = strsep(&value, " \t")) != NULL;)
 	       		if (**ap != '\0')
        	     		if (++ap >= &argv[bufsize])
                			break;
		if (!strncmp(argv[0], "queue", strlen("queue"))) {
			bzero(&trule, sizeof(trule));
			strlcpy(trule.name, argv[1], sizeof(trule.name));
			if (ioctl(fdpf, DIOCGETNAMEDALTQ, &trule)) {
				syslog(LOG_WARNING, 
					"could not get ALTQ translation for"
					" queue %s", argv[1]);
				continue;
			}
			if (trule.nr == 0) {
				syslog(LOG_WARNING,
					"queue %s does not exists!", argv[1]);
				continue;
			}
			trule.nr |= DIVERT_ALTQ;
			rule = trule.nr;
		} else if (!strncmp(argv[0], "dnqueue", strlen("dnqueue"))) {
			rule = strtonum(argv[1], 1, 65535, &errmsg);
			rule |= DIVERT_DNCOOKIE;
		} else if (!strncmp(argv[0], "dnpipe", strlen("dnpipe"))) {
			rule = strtonum(argv[1], 1, 65535, &errmsg);
			rule |= DIVERT_DNCOOKIE;
		} else if (!strncmp(argv[0], "tag", strlen("tag"))) {
                        if (ioctl(fdpf, DIOCGETNAMEDTAG, &rule)) {
                                syslog(LOG_WARNING,
                                        "could not get tag translation for"
                                        " queue %s", argv[1]);
                                continue;
                        }
                        if (rule == 0) {
                                syslog(LOG_WARNING,
                                        "tag %s does not exists!", argv[1]);
                                continue;
                        }
			rule |= DIVERT_TAG;
		} else if (!strncmp(argv[0], "action", strlen("action"))) {
			if (strncmp(argv[1], "block", strlen("block"))) 
				rule = PF_DROP;
			else if (strncmp(argv[1], "allow", strlen("allow"))) 
				rule = PF_PASS;
			else
				continue;
			rule = 0;
			rule |= DIVERT_ACTION;
		} else {
			syslog(LOG_WARNING,
			    "invalid action specified for %s protocol: %s",
			    proto->p_name, errmsg);
			continue;
		}
		proto->p_fwrule = rule;
		plist->fp_inuse++;
		syslog(LOG_NOTICE, "Loaded Protocol: %s (rule %s)",
		    proto->p_name, (rule & DIVERT_ACTION) ? "action block": 
					(rule & DIVERT_DNCOOKIE) ? "dnpipe" : 
					(rule & DIVERT_ALTQ) ? "altq" : "tag");
	}
	properties_free(props);
	close(fdpf);
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
		FP_WLOCK;
		fini_protocols(fp);
		read_config(conf, fp);
		FP_UNLOCK;
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
	printf("usage: %s [-h] [-c file] [-e seconds] [-n packets] "
		"[-p port] [-P dir] [-q length]\n", basename(arg0));
	printf("usage: %s -t -P dir\n", basename(arg0));
	printf(	"    -c file   : path to configuration file\n"
		"    -e secs   : number of seconds before a flow is expired\n"
		"    -h        : this help screen\n"
		"    -n packets: number of packets before the garbage collector"
			" tries to expire flows\n"
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

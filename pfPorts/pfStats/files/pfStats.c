/*
        Copyright (C) 2010 Ermal Luçi
        All rights reserved.

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

        1. Redistributions of source code must retain the above copyright notice,
           this list of conditions and the following disclaimer.

        2. Redistributions in binary form must reproduce the above copyright
           notice, this list of conditions and the following disclaimer in the
           documentation and/or other materials provided with the distribution.

        THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
        INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
        AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
        AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
        OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
        SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
        INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
        CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
        ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
        POSSIBILITY OF SUCH DAMAGE.

*/

#include <sys/types.h>
#include <sys/resource.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <sys/stat.h>

#include <net/if.h>
#include <net/pfvar.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>

#include <syslog.h>
#include <stdarg.h>

#include <errno.h>

#include <rrd.h>

#define PFDEV "/dev/pf"
int dev = -1;

#define RRDFILENAME_FORMAT	"%s-%s.rrd"
TAILQ_HEAD(ifacehead, rrd_iface) head;
struct rrd_iface {
	TAILQ_ENTRY(rrd_iface)	entry;
	char *iface[2];
	char filename[256];
};

#define RRDSYSTEM_STATES	"system-states.rrd"
#define RRDSYSTEM_CPU		"system-processor.rrd"
#define RRDSYSTEM_MEMORY	"system-memory.rrd"

#if 0
static const char       *istats_text[2][2][2] = {
        { { "In4/Pass:", "In4/Block:" }, { "Out4/Pass:", "Out4/Block:" } },
        { { "In6/Pass:", "In6/Block:" }, { "Out6/Pass:", "Out6/Block:" } }
};
#endif

/* Check if file exists */
static int
fexist(char * filename)
{
        struct stat buf;

        if (( stat (filename, &buf)) < 0)
                return (0);

        if (! S_ISREG(buf.st_mode))
                return (0);

        return(1);
}

void *
first_thread(void *arg __unused)
{
	struct pfioc_iface ifaces;
	struct pfi_kif *p;
	struct timespec ts;
	void	*buf;
	int j;
	char buffer[2048];
	rrd_context_t	*myctx;
	struct rrd_iface *tmp;

	ts.tv_sec = 5;
        ts.tv_nsec = 0;

	while (1) {
		while ((myctx = rrd_new_context()) == NULL)
			syslog(LOG_ERR, "Could not allocate a rrdlib context.");
			
		printf("First thread running\n");

		bzero(&ifaces, sizeof ifaces);
		buf = malloc(sizeof(struct pfi_kif));
		if (buf == NULL) {
			printf("Could not allocate buffer for getting interfaces\n");
			return NULL;
		}
	
		ifaces.pfiio_esize = sizeof(struct pfi_kif);
		ifaces.pfiio_buffer = buf;
		ifaces.pfiio_size = 1;
		if (ioctl(dev, DIOCIGETIFACES, &ifaces) < 0) {
			printf("Could not ioctl pf(4)\n");
			free(buf);
			return NULL;
		}
		buf = realloc(buf, ifaces.pfiio_size * sizeof(struct pfi_kif));
		if (buf == NULL) {
			printf("Could not realloc buffer for interfaces stats.\n");
			return NULL;
		}
		if (ioctl(dev, DIOCIGETIFACES, &ifaces) < 0) {
			printf("Could not ioctl pf(4)\n");
			free(buf);
			return NULL;
		}
		p = (struct pfi_kif *)ifaces.pfiio_buffer;
		rrd_clear_error();
		for (j = 0; j < ifaces.pfiio_size; j++) {
			TAILQ_FOREACH(tmp, &head, entry) {
				if (strcmp(tmp->iface[0], p->pfik_name) == 0)
					break;;
			}
			if (tmp == NULL)
				continue;

			/*
			printf("%s", p->pfik_name);
			printf("\tCleared:     %s", ctime(&tzero));
        		printf("\tReferences:  [ States:  %-18d Rules: %-18d ]\n",
            			p->pfik_states, p->pfik_rules);
        		for (i = 0; i < 4; i++) {
                		af = (i>>2) & 1;
                		dir = (i>>1) &1;
                		act = i & 1;
                		printf("\t%-12s [ Packets: %-18llu Bytes: %-18llu ]\n",
                    			istats_text[af][dir][act],
                    			(unsigned long long)p->pfik_packets[af][dir][act],
                    			(unsigned long long)p->pfik_bytes[af][dir][act]);
        		}
			*/
			snprintf(buffer, 2047, "N:%llu:%llu:%llu:%llu",
				(unsigned long long)p->pfik_bytes[0][0][0], (unsigned long long)p->pfik_bytes[0][1][0],
				(unsigned long long)p->pfik_bytes[0][1][1], (unsigned long long)p->pfik_bytes[0][1][1]);
			snprintf(tmp->filename, sizeof(tmp->filename), RRDFILENAME_FORMAT, tmp->iface[1], "traffic");
			if (!fexist(tmp->filename)) {
				syslog(LOG_ERR, "%s does not exist", tmp->filename);
				printf("%s does not exist\n", tmp->filename);
				continue;
			}
			rrd_update_r(tmp->filename, NULL, 1, (const char **) &buffer);
			syslog(LOG_ERR, "writing this data to %s: %s, %s", tmp->filename, p->pfik_name, buffer);
			printf("writing this data to %s: %s, %s\n", tmp->filename, p->pfik_name, buffer);

			snprintf(buffer, 2047, "N:%llu:%llu:%llu:%llu",
				(unsigned long long)p->pfik_packets[2][0][0], (unsigned long long)p->pfik_packets[2][1][0],
				(unsigned long long)p->pfik_packets[2][1][1], (unsigned long long)p->pfik_packets[2][1][1]);
			snprintf(tmp->filename, sizeof(tmp->filename), RRDFILENAME_FORMAT, tmp->iface[1], "packets");
			if (!fexist(tmp->filename)) {
				syslog(LOG_ERR, "%s does not exist", tmp->filename);
				printf("%s does not exist\n", tmp->filename);
				continue;
			}
			rrd_update_r(tmp->filename, NULL, 1, (const char **) &buffer);
			syslog(LOG_ERR, "writing this data to %s: %s, %s", tmp->filename, p->pfik_name, buffer);
			printf("writing this data to %s: %s, %s\n", tmp->filename, p->pfik_name, buffer);
		}

		free(ifaces.pfiio_buffer);
		p = NULL;
		nanosleep(&ts, NULL);
	}

	rrd_free_context(myctx);
}

void *
second_thread(void *arg __unused)
{
	struct timespec ts;
	long stats[CPUSTATES];
	size_t s_stats;

	ts.tv_sec = 20;
        ts.tv_nsec = 0;

	while (1) {
		printf("Second thread running\n");
		s_stats = sizeof(long) * CPUSTATES;
		if (sysctlbyname("kern.cp_time", stats, &s_stats, NULL, 0) < 0) {
			printf("Could not fetch kernel processor times.\n");
		} else {
			printf("CPUSER %ld .\n", stats[CP_USER]);
			printf("CPNICE %ld .\n", stats[CP_NICE]);
			printf("CPSYS %ld .\n", stats[CP_SYS]);
			printf("CPINTR %ld .\n", stats[CP_INTR]);
			printf("CPIDLE %ld .\n", stats[CP_IDLE]);
		}

		nanosleep(&ts, NULL);
	}
}

void *
third_thread(void *arg __unused)
{
	struct pfioc_states ps;
	struct pf_status status;
        struct pf_state *s;
	struct pf_addr *srclist, *dstlist, *tmplist;
	struct timespec ts;
	time_t runtime;
        char *buf = NULL;
	int i, j, found;
	double rate = 0;
	/* Totally bogus size on initial allocation. */
	int tsrc = 65535, tdst = 65535, isrc, idst, total, nat;

	while((srclist = malloc(tdst * sizeof(*srclist))) == NULL)
		;
	while((dstlist = malloc(tdst * sizeof(*dstlist))) == NULL)
		;

	ts.tv_sec = 60;
        ts.tv_nsec = 0;
	
	for (;;) {
		bzero(&ps, sizeof(ps));
		bzero(srclist, sizeof(srclist));
		bzero(dstlist, sizeof(dstlist));
		if (buf != NULL)
			free(buf);
		
		if (ioctl(dev, DIOCGETSTATUS, &status)) {
			printf("DIOCGETSTATUS");
			goto sleep;
		}
		runtime = time(NULL) - status.since;
		printf("  inserts %14llu %14.1f/s\n", (unsigned long long)status.fcounters[1],
			(runtime) ? (double)status.fcounters[1] / (double)runtime : 0);
		printf("  removals %14llu %14.1f/s\n", (unsigned long long)status.fcounters[2],
			(runtime) ? (double)status.fcounters[2] / (double)runtime : 0);
		rate = (runtime) ? (double)status.fcounters[1] / (double)runtime : 0;
		rate += (runtime) ? (double)status.fcounters[2] / (double)runtime : 0;
		printf("Rate is : %lli\n", (long long)rate);

		if (ioctl(dev, DIOCGETSTATES, &ps) < 0) {
			printf("Could not get states size");
			goto sleep;
		}
		if (ps.ps_len) {
			buf = malloc(ps.ps_len * 2);
			if (buf == NULL)
				continue;
			ps.ps_buf = buf;
		} else
			goto sleep;
		if (ioctl(dev, DIOCGETSTATES, &ps) < 0) {
			printf("Could not get states");
			free(buf);
			goto sleep;
		}

		s = ps.ps_states;
		total = ps.ps_len / sizeof(*s);
		isrc = idst = nat = 0;
        	for (i = 0; i < total; i++, s++) {
			printf(".");
			if (PF_ANEQ(&s->lan.addr, &s->gwy.addr, s->af) ||
			    (s->lan.port != s->gwy.port))
				nat++;
			if (s->direction == PF_OUT) {
				found = 0;
				for (j = 0; j < tsrc; j++) {
					if (PF_AEQ(&srclist[j], &s->lan.addr, s->af)) {
						found = 1;
						break;
					}
				}
				if (found)
					continue;
				srclist[isrc++] = s->lan.addr;
				if (isrc >= tsrc) {
					tsrc *= 2;
					while ((tmplist = calloc(tsrc, sizeof(*tmplist))) == NULL)
						;
					bcopy(srclist, tmplist, sizeof(srclist));
					free(srclist);
					srclist = tmplist;
				}
			} else {
				found = 0;
				for (j = 0; j < tdst; j++) {
                                	if (PF_AEQ(&dstlist[j], &s->ext.addr, s->af)) {
						found = 1;
						break;
					}
                        	}
				if (found)
					continue;
                        	srclist[idst++] = s->ext.addr;
                        	if (idst >= tdst) {
                                	tdst *= 2;
                                	while ((tmplist = calloc(tdst, sizeof(*tmplist))) == NULL)
                                        	;
                                	bcopy(dstlist, tmplist, sizeof(dstlist));
                                	free(dstlist);
                                	dstlist = tmplist;
                        	}
			}
        	}
		printf("\n");
		printf("Found total: %d, nat: %d, srcip: %d dstip: %d states\n",
			total, nat, isrc, idst);
sleep:
		nanosleep(&ts, NULL);
	}

	if (buf != NULL)
        	free(buf);
	if (srclist != NULL)
		free(srclist);
	if (dstlist != NULL)
		free(dstlist);

        return (0);
	

}

void *
fourth_thread(void *arg __unused)
{
	struct timespec ts;
	int page_count, active_count, inactive_count, free_count,
		cache_count, wire_count;
	size_t size, csize;

	ts.tv_sec = 10;
        ts.tv_nsec = 0;

	for (;;) {
		size = csize = sizeof(int);
		if (sysctlbyname("vm.stats.vm.v_page_count", &page_count, &size, NULL, 0) < 0)
			printf("Could not fetch page_count.\n");
		size = csize;
		if (sysctlbyname("vm.stats.vm.v_active_count", &active_count, &size, NULL, 0) < 0)
			printf("Could not fetch active_count.\n");
		size = csize;
		if (sysctlbyname("vm.stats.vm.v_inactive_count", &inactive_count, &size, NULL, 0) < 0)
			printf("Could not fetch inactive_count.\n");
		size = csize;
		if (sysctlbyname("vm.stats.vm.v_free_count", &free_count, &size, NULL, 0) < 0)
			printf("Could not fetch free_count.\n");
		size = csize;
		if (sysctlbyname("vm.stats.vm.v_cache_count", &cache_count, &size, NULL, 0) < 0)
			printf("Could not fetch cache_count.\n");
		size = csize;
		if (sysctlbyname("vm.stats.vm.v_wire_count", &wire_count, &size, NULL, 0) < 0)
			printf("Could not fetch wire_count.\n");

		printf("Statistics gathered: %d, %f, %f, %f, %f, %f\n", page_count, (double)(active_count*100)/page_count,
			(double)(inactive_count*100)/page_count, (double)(free_count*100)/page_count, 
			(double)(cache_count*100)/page_count, (double)(wire_count*100)/page_count);

		nanosleep(&ts, NULL);
	}
}

int
main(int argc, char **argv)
{

	pthread_t first, second, third, fourth;
	int ch;
	struct rrd_iface *tmp;
	char **ap;

	TAILQ_INIT(&head);

	while ((ch = getopt(argc, argv, "i:")) != -1) {
		switch (ch) {
		case 'i':
			tmp = malloc(sizeof(*tmp));
			if (tmp == NULL) {
				syslog(LOG_ERR, "Exiting because %s.", strerror(errno));
				return (1);
			}
			for (ap = tmp->iface; (*ap = strsep(&optarg, ":")) != NULL;)
				if (**ap != '\0')
					if (++ap >= &tmp->iface[1])
						break;

			TAILQ_INSERT_HEAD(&head, tmp, entry);
			break;
		default:
			return 1;
			break;
		}
	}
	argc -= optind;
	argv += optind;
	
	TAILQ_FOREACH(tmp, &head, entry) {
		printf("Arguments: %s, %s.\n", tmp->iface[0], tmp->iface[1]);
	}

	if ((dev = open(PFDEV, O_RDONLY)) < 0) {
		printf("Could not open pf(4) device because %s\n", strerror(errno));
		return (1);
	}

	pthread_create(&first, NULL, first_thread, NULL);
	pthread_create(&second, NULL, second_thread, NULL);
	pthread_create(&third, NULL, third_thread, NULL);
	pthread_create(&fourth, NULL, fourth_thread, NULL);
	
	pthread_join(first, NULL);
	pthread_join(second, NULL);
	pthread_join(third, NULL);
	pthread_join(fourth, NULL);

	close(dev);

	return (0);
}

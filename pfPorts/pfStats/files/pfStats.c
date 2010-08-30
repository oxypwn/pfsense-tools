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

#include <net/if.h>
#include <net/pfvar.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>

#include <errno.h>

#include <rrd.h>

#define PFDEV "/dev/pf"
int dev = -1;

static const char       *istats_text[2][2][2] = {
        { { "In4/Pass:", "In4/Block:" }, { "Out4/Pass:", "Out4/Block:" } },
        { { "In6/Pass:", "In6/Block:" }, { "Out6/Pass:", "Out6/Block:" } }
};

void *
first_thread(void *arg __unused)
{
	struct pfioc_iface ifaces;
	struct pfi_kif *p;
	struct timespec ts;
	time_t tzero;
	void	*buf;
	int i, j, af, act, dir;

	ts.tv_sec = 5;
        ts.tv_nsec = 0;

	while (1) {
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
		for (j = 0; j < ifaces.pfiio_size; j++) {
			/*
			if (strcmp("le0", p->pfik_name) != 0) {
				p++;
				continue;
			}
			*/
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
			p++;
		}

		free(ifaces.pfiio_buffer);
		p = NULL;
		nanosleep(&ts, NULL);
	}
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
int
main(int argc, char **argv)
{

	pthread_t first, second;

	if ((dev = open(PFDEV, O_RDONLY)) < 0) {
		printf("Could not open pf(4) device because %s\n", strerror(errno));
		return (1);
	}
	pthread_create(&first, NULL, first_thread, NULL);
	pthread_create(&second, NULL, second_thread, NULL);
	
	pthread_join(first, NULL);
	pthread_join(second, NULL);

	close(dev);

	return (0);
}

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

int main(int argc, char *argv[]) {

	struct ifmibdata	ifmd;
	size_t				ifmd_size =	sizeof(ifmd);
	int					nr_network_devs;
	size_t				int_size = sizeof(nr_network_devs);
	int					name[6];
	char				*cl, *rm;
	int					i;
	struct timeval		tv;
	double				uusec;

	printf("Content-Type: text/plain\n\n");

	rm = getenv("REQUEST_METHOD");
	if (rm == NULL)
		exit(1);
	if (strcmp(rm, "GET") != 0)
		exit(1);

	cl = getenv("QUERY_STRING");

	if (cl == NULL)
		exit(1);

	if ((strlen(cl) < 3) || (strlen(cl) > 16))
		exit(1);

	/* check interface name syntax */
	for (i = 0; cl[i]; i++) {
		if (!((cl[i] >= 'a' && cl[i] <= 'z') || (cl[i] >= '0' && cl[i] <= '9')))
			exit(1);
	}

	name[0] = CTL_NET;
	name[1] = PF_LINK;
	name[2] = NETLINK_GENERIC;
	name[3] = IFMIB_IFDATA;
	name[5] = IFDATA_GENERAL;

	if (sysctlbyname("net.link.generic.system.ifcount", &nr_network_devs,
		&int_size, (void*)0, 0) == -1) {

		exit(1);

	} else {

		for (i = 1; i <= nr_network_devs; i++) {

			name[4] = i;    /* row of the ifmib table */

			if (sysctl(name, 6, &ifmd, &ifmd_size, (void*)0, 0) == -1) {
				continue;
			}

			if (strncmp(ifmd.ifmd_name, cl, strlen(cl)) == 0) {
				gettimeofday(&tv, NULL);
				uusec = (double)tv.tv_sec + (double)tv.tv_usec / 1000000.0;
				printf("%lf|%u|%u\n", uusec,
					ifmd.ifmd_data.ifi_ibytes, ifmd.ifmd_data.ifi_obytes);
				exit(0);
			}
		}
	}

	return 0;
}

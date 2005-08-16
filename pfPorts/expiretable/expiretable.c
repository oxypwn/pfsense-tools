/* $Id$ */

/*
 * Copyright (c) 2005 Henrik Gustafsson <henrik.gustafsson@fnord.se>
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

#include <sys/fcntl.h>
#include <sys/types.h>
#include <pwd.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
 
#include "ioctl_helpers.h"

void
print_address(u_int32_t a) {
	printf("%d.%d.%d.%d", a >> 24 & 255, a >> 16 & 255, a >> 8 & 255, a & 255);
}

void
usage(void) {
	extern char *__progname;

	fprintf(stderr, "usage: %s [-v] [-v] [-n] [-a anchor] [-t age] table\n", __progname);
	exit(1);
}

void
drop_privileges() {
	struct passwd *pw;
	
	if ((pw = getpwnam("nobody")) == NULL) {
		fprintf(stderr, "Failed to get pw-entry for user \"nobody\".\n");
		exit (-1);
	}
	if (setgroups(1, &pw->pw_gid) || setegid(pw->pw_gid) || setgid(pw->pw_gid)
			|| seteuid(pw->pw_uid) || setuid(pw->pw_uid)) {
		fprintf(stderr, "Could not drop privileges.\n");
		exit(-1);
	}

}

int
main(int argc, char *const *argv) {
	
	int dev;	
	struct pfr_astats *astats;
	struct pfr_table target;
	struct pfr_addr *del_addrs_list;
	int astats_count;
	int del_addrs_count;
	int del_addrs_result;
	
	long age;
	int verbose;

	long min_timestamp;
	int ch;
	int i;
	int flags;
		
	
	/* Default values for options */
	
	memset(&target, 0, sizeof(struct pfr_table));
	
	age = 60*60*3; /* 3 hours */
	verbose = 0;
	flags = PFR_FLAG_FEEDBACK;
	
	/* Parse options */
	
	while ((ch = getopt(argc, argv, "a:t:nv")) != -1) {
		switch (ch) {
		case 't': {
			age = atol(optarg);
			if (age <= 0) {
				usage();
			}
			break;
		}
		case 'a': {
			strncpy(target.pfrt_anchor, optarg, sizeof(target.pfrt_anchor));
			break;
		}
		case 'v': {
			verbose++;
			break;
		}
		case 'n': {
			flags |= PFR_FLAG_DUMMY;
			break;
		}
		default: {
			usage();
			break;
		}
		}
	}
	argc -= optind;
	argv += optind;
	
	if (*argv == NULL) {
		usage();
	}
	
	min_timestamp = (long)time(NULL) - age;
	
	strncpy(target.pfrt_name, *argv, sizeof(target.pfrt_name));	
		
	dev = open("/dev/pf", O_RDWR);
	
	if (dev == -1) {
		fprintf(stderr, "Could not open \"/dev/pf\"\n");
		return (-1);
	}

	drop_privileges();	
	
	astats_count = radix_get_astats(dev, &astats, &target,0);
	if (astats_count > 0) {
		
		del_addrs_list = NULL;
		del_addrs_count = 0;
		for (i = 0; i < astats_count; i++) {
			if (astats[i].pfras_tzero < min_timestamp) {
				del_addrs_count++;
			}
		}
		
		del_addrs_list = malloc(del_addrs_count * sizeof(struct pfr_addr) );
		if (del_addrs_list == NULL) {
				fprintf(stderr, "Failed to allocate memory.\n");
				return (-1);
		}
		
		del_addrs_count = 0;
		for (i = 0; i < astats_count; i++) {
			if (astats[i].pfras_tzero < min_timestamp) {
				del_addrs_list[del_addrs_count] = astats[i].pfras_a;
				del_addrs_count++;
			}
		}
		
		if (del_addrs_count > 0) {
			del_addrs_result = radix_del_addrs(dev, &target, del_addrs_list,
					del_addrs_count, flags);
			if (del_addrs_result  < 0) {
				fprintf(stderr, "Failed to remove address(es).\n");
				return (-1);
			}

			if (verbose > 1) {
				for (i = 0; i < del_addrs_count; i++) {
					print_address(ntohl(del_addrs_list[i].pfra_ip4addr.s_addr));
					printf(" result: ");
					switch(del_addrs_list[i].pfra_fback) {
					case PFR_FB_NONE: {
						printf("No action taken.\n");
						break;
					}
					case PFR_FB_CONFLICT: {
						printf("Conflicting entry.\n");
						break;
					}
					case PFR_FB_DUPLICATE: {
						printf("Already deleted.\n");
						break;
					}
					case PFR_FB_DELETED: {
						printf("Entry deleted.\n");
						break;
					}
					}
				}
			}
			if (verbose > 0) {
				printf("%d of %d entries deleted.\n", del_addrs_result, astats_count);
			}
			
			free(del_addrs_list);
		}
		else {
			if (verbose) {
				printf("No addresses to delete.\n");
			}
		}
	}
	else if (astats_count == 0) {
		if (verbose) {
			printf("Table \"%s\" is empty.\n", target.pfrt_name);
		}
	}
	else {
		if (target.pfrt_anchor[0]) {
			fprintf(stderr, "Error getting stats for table \"%s\", anchor \"%s\". "
					"Is the specified table valid?\n", target.pfrt_name,
					target.pfrt_anchor);
		}
		else {
			fprintf(stderr, "Error getting stats for table \"%s\". "
					"Is the specified table valid?\n", target.pfrt_name);
		} 
		
		return (-1);
	}
	
	free(astats);

	return 0;
}

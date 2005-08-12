
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>
#include <stddef.h>

int main(void) {	
	int fd;
	if ((fd = open("/dev/ukbd0", O_RDONLY)) != -1) {
		close(fd);
		printf("Enabling USB keyboard override...");
		system("/usr/sbin/kbdcontrol -k /dev/ukbd0 < /dev/console");
		printf(" done.\n");
	}
	return 0;
}

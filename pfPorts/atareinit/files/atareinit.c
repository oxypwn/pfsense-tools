#include <sys/types.h>
#include <sys/ata.h>
#include <err.h>
#include <fcntl.h>
#include <string.h>

int main() {
	int channel = 0;
	int fd;

	if ((fd = open("/dev/ata", O_RDWR)) < 0)
		err(1, "control device not found");

	if (ioctl(fd, IOCATAREINIT, &channel) < 0)
		warn("ioctl(IOCATAREINIT)");

	close(fd);
}

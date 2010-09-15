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
#include <sys/socket.h>
#include <sys/un.h>

#include <err.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>

#include "common.h"


int
main(int argc, char **argv)
{
	struct sockaddr_un sun;
	char buf[2048] = { 0 };
	char *cmd, *path = PATH;
	socklen_t len;
	int fd, n, ch;
	int ncmds = 0, nsock = 0;

	if (argc != 2)
		/* NOTREACHED */

	while ((ch = getopt(argc, argv, "c:s:")) != -1) {
		switch (ch) {
		case 'c':
			if (ncmds > 0)
				err(-3, "Wrong parameters passed for command.");
			cmd = optarg;
			ncmds++;
			break;
		case 's':
			if (nsock > 0)
				err(-3, "Wrong parameters passed for socket.");
			path = optarg;
			nsock++;
			break;
		default:
			err(-1, "cmdclient 'command string'");
			break;
		}
	}
	argc -= optind;
	argv += optind;

	fd = socket(PF_UNIX, SOCK_STREAM, 0);
	if (fd < 0)
		err(-2, "could not create socket.");
	
	bzero(&sun, sizeof(sun));
	sun.sun_family = AF_LOCAL;
	strlcpy(sun.sun_path, path, sizeof(sun.sun_path));
	len = sizeof(sun);

	if (connect(fd, (struct sockaddr *)&sun, len) < 0)
		errx(errno, "Could not connect to server.");

	if (write(fd, argv[argc - 1], strlen(argv[argc - 1])) < 0)
		errx(errno, "Could not send command to server.");

	n = read(fd, buf, sizeof(buf));
	if (n < 0)
		warnc(errno, "Reading from socket");
	else if (n > 0)
		printf("%s", buf);
	close(fd);

	return (0);
}

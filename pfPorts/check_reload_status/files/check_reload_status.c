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
#include <sys/event.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

#include <ctype.h>

#define _WITH_DPRINTF
#include <stdio.h>
#include <errno.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <signal.h>
#include <syslog.h>
#include <unistd.h>
#include <strings.h>
#include <string.h>

#include <event.h>

#include "server.h"
#include "common.h"

/* function definitions */
static void			handle_signal(int);
static void			run_command(const struct command *, char *);
static void			set_blockmode(int socket, int cmd);
const struct command *	match_command(const struct command *target, char *wordpassed);
const struct command *	parse_command(int fd, int argc, char **argv);
static void			socket_read_command(int socket, short event, void *arg);
static void			show_command_list(int fd, const struct command *list);
static void			socket_accept_command(int socket, short event, void *arg);
static void			socket_close_command(int fd, struct event *ev);
static void			write_status(const char *statusline, int when);

static pid_t ppid = -1;
static int child = 0;

static void
show_command_list(int fd, const struct command *list)
{
        int     i;
	char	value[2048];

	if (list == NULL)
		return;

        for (i = 0; list[i].action != NULLOPT; i++) {
                switch (list[i].type) {
                case NON:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <cr>\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
                case COMPOUND:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
                case ADDRESS:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <address>\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
                case PREFIX:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <address>[/len]\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
		case INTEGER:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <number>\n", list[i].keyword);
                        write(fd, value, strlen(value));
			break;
                case IFNAME:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <interface>\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
                case STRING:
			bzero(value, sizeof(value));
			snprintf(value, sizeof(value), "\t%s <string>\n", list[i].keyword);
                        write(fd, value, strlen(value));
                        break;
                }
        }
}

const struct command *
parse_command(int fd, int argc, char **argv)
{
	const struct command	*start = first_level;
	const struct command	*match = NULL;
	char *errstring = "ERROR:\tvalid commands are:\n";

	while (argc >= 0) {
		match = match_command(start, *argv);
		if (match == NULL) {
			errstring = "ERROR:\tNo match found.\n";
			goto error;
		}

		argc--;
		argv++;

		if (argc > 0 && match->next == NULL) {
			errstring = "ERROR:\textra arguments passed.\n";
			goto error;
		}
		if (argc < 0 && match->type != NON) {
			if (match->next != NULL)
				start = match->next;
			errstring = "ERROR:\tincomplete command.\n";
			goto error;
		}
		if (argc == 0 && *argv == NULL && match->type != NON) {
			if (match->next != NULL)
				start = match->next;
			errstring = "ERROR:\tincomplete command.\n";
			goto error;
		}

		if ( match->next == NULL)
			break;

		start = match->next;	
	}

	return (match);
error:
	write(fd, errstring, strlen(errstring));
	show_command_list(fd, start);
	return (NULL);
}

const struct command *
match_command(const struct command *target, char *wordpassed)
{
	int i;

	if (wordpassed == NULL)
		return NULL;

	for (i = 0; target[i].action != NULLOPT; i++) {
		if (strcmp(target[i].keyword, wordpassed) == 0)
			return &target[i];
	}

	return (NULL);
}

static void 
write_status(const char *statusline, int when)
{

	ftruncate(status, (off_t)0);
	if (when == BEFORE)
		dprintf(status, "Starting %s\n", statusline);
	else if (when == AFTER)
		dprintf(status, "After %s\n", statusline);
	else
		dprintf(status, "%s\n", statusline);
}

static void
handle_signal(int sig)
{
        switch(sig) {
        case SIGHUP:
        case SIGTERM:
		if (child)
			exit(0);
                break;
        }
}

static void
run_command(const struct command *cmd, char *argv) {
	char command[2048];

	switch (cmd->type) {
	case NON:
	case COMPOUND: /* XXX: Should never happen. */
        	syslog(LOG_NOTICE, cmd->cmd.syslog);
		break;
	case ADDRESS:
	case PREFIX:
	case INTEGER:
	case IFNAME:
	case STRING:
        	syslog(LOG_NOTICE, cmd->cmd.syslog, argv);
		break;
	}

	bzero(command, sizeof(command));
	snprintf(command, sizeof(command), cmd->cmd.command, argv);
	switch (vfork()) {
	case -1:
		break;
	case 0:
		child = 1;
		/* Possibly optimize by creating argument list and calling execve. */
		execl("/bin/sh", "sh", "-c", command, (char *)NULL);
		_exit(127); /* Protect in case execl errors out */
		break;
	default:
		child = 0;
		write_status(command, AFTER);
		break;
	}

        return;
}

static void
socket_close_command(int fd, struct event *ev)
{
	event_del(ev);
	free(ev);
        close(fd);
}

static void
socket_read_command(int fd, __unused short event, void *arg)
{
	const struct command *cmd;
	struct event *ev = arg;
	enum { bufsize = 2048 };
	char buf[bufsize];
	register int n;
	char **ap, *argv[bufsize], *p;
	int i;

	bzero(buf, sizeof(buf));
	if ((n = read (fd, buf, bufsize)) == -1) {
		if (errno != EWOULDBLOCK && errno != EINTR) {
			socket_close_command(fd, ev);
			return;
		}
	} else if (n == 0) {
		socket_close_command(fd, ev);
		return;
	}
	
	if (buf[n - 1] == '\n')
		buf[n - 1] = '\0'; /* remove stray \n */
	if (n > 1 && buf[n - 2] == '\r') {
		n--;
		buf[n - 1] = '\0';
	}
	for (i = 0; i < n - 1; i++) {
		if (!isalpha(buf[i]) && !isspace(buf[i]) && !isdigit(buf[i])) {
			write(fd, "ERROR:\tonly alphanumeric chars allowd", 37);
			socket_close_command(fd, ev);
			return;
		}
	}
	p = buf; /* blah, compiler workaround */

	i = 0;
	for (ap = argv; (*ap = strsep(&p, " \t")) != NULL;) {
		if (**ap != '\0') {
			if (++ap >= &argv[bufsize])
				break;
		}
		i++;
	}
	if (i > 0) {
		p = argv[i - 1];
		i = i - 1;
	} else {
		p = argv[i];
	}
	cmd = parse_command(fd, i, argv);
	if (cmd != NULL) {
		write(fd, "OK\n", 3);
		run_command(cmd, p);
	}

	return;
}

static void
socket_accept_command(int fd, __unused short event, __unused void *arg)
{
	struct sockaddr_un sun;
	struct event *ev;
	socklen_t len;
	int newfd;

	if ((newfd = accept(fd, (struct sockaddr *)&sun, &len)) < 0) {
		if (errno != EWOULDBLOCK && errno != EINTR)
			syslog(LOG_NOTICE, "problems on accept");
	}
	set_blockmode(fd, O_NONBLOCK);
	
	if ((ev = malloc(sizeof(*ev))) == NULL) {
		syslog(LOG_ERR, "Cannot allocate new struct event.");
		close(fd);
		return;
	}

	event_set(ev, newfd, EV_READ | EV_PERSIST, socket_read_command, ev);
	event_add(ev, NULL);
}

static void
set_blockmode(int fd, int cmd)
{
        int     flags;

        if ((flags = fcntl(fd, F_GETFL, 0)) == -1)
                errx(errno, "fcntl F_GETFL");

	flags |= cmd;

        if ((flags = fcntl(fd, F_SETFL, flags)) == -1)
                errx(errno, "fcntl F_SETFL");
}

int main(void) {
	struct event ev;
	struct sockaddr_un sun;
	struct sigaction sa;
	int fd, errcode;
	sigset_t set;

	/* daemonize */
	if (daemon(0, 0) < 0) {
		syslog(LOG_ERR, "check_reload_status could not start.");
		errcode = 1;
		goto error;
	}

	syslog(LOG_NOTICE, "check_reload_status is starting.");

	sigemptyset(&set);
	sigfillset(&set);
	sigdelset(&set, SIGHUP);
	sigdelset(&set, SIGTERM);
	sigdelset(&set, SIGCHLD);
	sigprocmask(SIG_BLOCK, &set, NULL);

	sa.sa_handler = handle_signal;
        sa.sa_flags = SA_SIGINFO|SA_RESTART;
        sigemptyset(&sa.sa_mask);
        sigaction(SIGHUP, &sa, NULL);
	sigaction(SIGTERM, &sa, NULL);
	sigaction(SIGCHLD, SIG_IGN, NULL);

	status = open(filepath, O_RDWR | O_CREAT | O_FSYNC);
	if (status < 0) {
		syslog(LOG_ERR, "check_reload_status could not open file %s", filepath);
		errcode = 2;
		goto error;
	}
	write_status("starting", NONE);

	ppid = getpid();
	if (fork() == 0) {
		/* Prepare code to monitor the parent :) */
		struct kevent kev;
		int kq;

		while (1) {
			kq = kqueue();
			EV_SET(&kev, ppid, EVFILT_PROC, EV_ADD, NOTE_EXIT, 0, NULL);
			kevent(kq, &kev, 1, NULL, 0, NULL);
			switch (kevent(kq, NULL, 0, &kev, 1, NULL)) {
			case 1:
				syslog(LOG_ERR, "Reloading check_reload_status because it exited from an error!");
				execl("/usr/local/sbin/check_reload_status", "/usr/local/sbin/check_reload_status");
				_exit(127);
				/* NOTREACHED */
				break;
			default:
				/* XXX: Should report any event?! */
				break;
			}
			close(kq);
		}
		exit(2);
	}

	fd = socket(PF_UNIX, SOCK_STREAM, 0);
	if (fd < 0) {
		errcode = -1;
		printf("Could not socket\n");
		goto error;
	}

#if 0
	if (unlink(PATH) == -1) {
		errcode = -2;
		printf("Could not unlink\n");
		close(fd);
		goto error;
	}
#else
	unlink(PATH);
#endif

	bzero(&sun, sizeof(sun));
        sun.sun_family = PF_UNIX;
        strlcpy(sun.sun_path, PATH, sizeof(sun.sun_path));
	if (bind(fd, (struct sockaddr *)&sun, sizeof(sun)) < 0) {
		errcode = -2;
		printf("Could not bind\n");
		close(fd);
		goto error;
	}

	set_blockmode(fd, O_NONBLOCK);

        if (listen(fd, 30) == -1) {
                printf("control_listen: listen");
		close(fd);
                return (-1);
        }

	event_init();
	event_set(&ev, fd, EV_READ | EV_PERSIST, socket_accept_command, &ev);
	event_add(&ev, NULL);
	event_dispatch();

	return (0);
error:
	write_status("exiting", NONE);
	syslog(LOG_NOTICE, "check_reload_status is stopping.");
	close(status);

	return (errcode);
}

/*
 *   check_reload_status.c
 *   part of the pfSense project
 *   (C) 2010 Ermal Luçi
 *   (C)2005 Scott Ullrich
 *   All rights reserved
 *
 *   This file monitors for certain files to
 *   appear in /tmp and then takes action on them.
 *   It's a mini-daemon of sorts to kick off filter
 *   reloads, sshd starting, etc.   It may be expanded
 *   down to the road to kick off any type of tasks that
 *   take up too much time from the GUI perspective.
 *
 */

#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <syslog.h>
#include <unistd.h>

#include <fcntl.h>

#include <pthread.h>

#define filepath 	"/tmp/check_reload_status"
#define LOGFILE		"/var/log/check_reload_status"
#define TMPDIR		"/tmp"

/* Default cycle time value 30 seconds*/
#define CYCLE		30

/* used for writing to the status file */
int status = -1;
#define NONE	0
#define BEFORE	1
#define AFTER	2

/* function definitions */
void	*run_command(void *arg);

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

static void 
write_status(char *statusline, int when) {

	ftruncate(status, (off_t)0);
	if (when == BEFORE)
		dprintf(status, "Starting %s\n", statusline);
	else if (when == AFTER)
		dprintf(status, "After %s\n", statusline);
	else
		dprintf(status, "%s\n", statusline);
}

/* Various commands we support */
struct commands {
	char	*file;
	char	*command;
	char	*syslog;
	int	sleep; /* in seconds */
} known[] = {
	{ "/tmp/restart_webgui",	"/usr/local/bin/php /etc/rc.restart_webgui",
		"webConfigurator restart in progress", CYCLE},
	{ "/tmp/rc.linkup", 		"/usr/local/bin/php /etc/rc.linkup `/bin/cat /tmp/rc.linkup`", "rc.linkup starting", CYCLE},
	{ "/tmp/rc.newwanip",		"/usr/local/bin/php /etc/rc.newwanip `/bin/cat /tmp/rc.newwanip`",
		"rc.newwanip starting", 10},
	{ "/tmp/filter_dirty",		"/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.filter_configure_sync",
		"reloading filter", 10},
	{ "/tmp/filter_sync",		"/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.filter_synchronize",
		"syncing firewall", CYCLE},
	{ "/tmp/reload_all",		"/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_all",
		"reloading all", CYCLE},
	{ "/tmp/reload_interfaces",	"/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_interfaces",
		"reloading interfaces", CYCLE}, 
	{ "/tmp/update_dyndns",		"/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.dyndns.update `/bin/cat /tmp/update_dyndns`",
		"updating dyndns", 20},
	{ "/tmp/interface_configure",	"/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_wan_configure `/bin/cat /tmp/interface_configure`",
		"configuring interface", 20},
	{ "/tmp/start_sshd",		"/usr/bin/nice -n20 /etc/sshd",
		"starting sshd", CYCLE},
	{ "/tmp/start_ntpd",		"/usr/bin/killall ntpd; /bin/sleep 3; /usr/local/sbin/ntpd -s -f /var/etc/ntpd.conf",
		"starting ntpd", CYCLE}
};

void *
run_command(void *arg) {
	struct commands *cmd = arg;
        int howmany, i;

	for (;;) {
        	if (fexist(cmd->file) == 1) {
        		syslog(LOG_NOTICE, cmd->syslog);
                	write_status(cmd->file, BEFORE);
                	system(cmd->command);
                	unlink(cmd->file);
                	write_status(cmd->file, AFTER);
        	}
		if (cmd->sleep)
			__sleep(cmd->sleep);
		else
			__sleep(CYCLE);
	}
        return NULL;
}

int main(void) {
	pthread_t *threads;
        int threrr = 0, err = 0, i, howmany;


	/* daemonize */
	if (daemon(0, 0) < 0) {
		syslog(LOG_ERR, "check_reload_status could not start.");
		err = 1;
		goto error;
	}

	syslog(LOG_NOTICE, "check_reload_status is starting.");

	status = open(filepath, O_RDWR | O_CREAT | O_FSYNC);
	if (status < 0) {
		syslog(LOG_ERR, "check_reload_status could not open file %s", filepath);
		err = 2;
		goto error;
	}
	write_status("starting", NONE);

	howmany = sizeof(known)/ sizeof(known[0]);
	dprintf(status, "%d commands present\n", howmany);
	threads = malloc( howmany * sizeof(pthread_t));
	if (threads == NULL) {
		write_status("could not allocate memory for threads", NONE);
		err = 4;
		goto error;
	}
	for (i = 0; i < howmany; i++) {
		threrr = pthread_create(&threads[i], NULL, run_command, (void *)&known[i]);
		if (threrr != 0)
			dprintf(status, "Could not create thread for command %s.", known[i].command);
	}
	for (i = 0; i < howmany; i++)
		pthread_join(threads[i], NULL);

error:
	write_status("exiting", NONE);
	syslog(LOG_NOTICE, "check_reload_status is stopping.");
	close(status);

	return (err);
}

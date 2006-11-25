
/*
 *   check_reload_status.c
 *   part of the pfSense project
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

#define LOGFILE		"/var/log/check_reload_status"
#define TMPDIR		"/tmp"

/* Default cycle time value 1 minute */
#define CYCLE		5

static char _sccsid[] = { " $Id$ " };

/* Check if file exists */
int fexist(char * filename)
{
  struct stat buf;

  if (( stat (filename, &buf)) < 0)
    return (0);

  if (! S_ISREG(buf.st_mode)) {
    return (0);
  }

  return(1);
}

int main(void) {
	int cycle_time;
	cycle_time = CYCLE;
	/* daemonize */
	syslog(LOG_NOTICE, "check_reload_status is starting");
	system("echo starting > /tmp/check_reload_status");
	if( fork() == 0 ) {
	  /* close stdin and stderr */
	  fclose( stdin );
	  fclose( stdout );
	  fclose( stderr );
	  /* loop forever until the cows come home */
	  while(1) {
	      if(fexist("/tmp/restart_webgui") == 1) {
	      	syslog(LOG_NOTICE, "webConfigurator restart in progress");
	        system("echo webConfigurator_Restart_Sleep > /tmp/check_reload_status");
			sleep(5);
			system("echo /tmp/restartwebgui > /tmp/check_reload_status");
			system("/bin/rm /tmp/restart_webgui");
			system("echo after /tmp/restartwebgui > /tmp/check_reload_status");
			system("/usr/local/bin/php /etc/rc.restart_webgui");
	      }
	      if(fexist("/tmp/rc.linkup") == 1) {
	      	  syslog(LOG_NOTICE, "rc.linkup starting");
			  system("echo /tmp/rc.linkup > /tmp/check_reload_status");
		      system("/etc/rc.linkup.sh");
		      system("echo after /tmp/rc.linkup > /tmp/check_reload_status");
		      system("/bin/rm /tmp/rc.linkup");
	      }
	      if(fexist("/tmp/rc.newwanip") == 1) {
		      syslog(LOG_NOTICE, "rc.newwanip starting");
			  system("echo /tmp/rc.newwanip > /tmp/check_reload_status");
		      system("/usr/local/bin/php /etc/rc.newwanip `cat /tmp/rc.newwanip`");
		      system("echo after /tmp/rc.newwanip > /tmp/check_reload_status");
		      system("/bin/rm /tmp/rc.newwanip");
	      }
	      if(fexist("/tmp/filter_dirty") == 1) {
		      syslog(LOG_NOTICE, "reloading filter");
		      system("echo reloading_filter > /tmp/check_reload_status");
		      system("/bin/rm -f /tmp/filter_dirty");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.filter_configure_sync");
		      system("echo after reloading_filter > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/reload_all") == 1) {
		      syslog(LOG_NOTICE, "reloading all");
			  system("echo /tmp/reload_all > /tmp/check_reload_status");
		      system("/bin/rm /tmp/reload_all");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_all");
		      system("echo after /tmp/reload_all > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/reload_interfaces") == 1) {
	      	  syslog(LOG_NOTICE, "reloading interfaces");
			  system("echo /tmp/reload_interfaces > /tmp/check_reload_status");
		      system("/bin/rm /tmp/reload_interfaces");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_interfaces");
		       system("echo after /tmp/reload_interfaces > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/update_dyndns") == 1) {
		      syslog(LOG_NOTICE, "updating dyndns");
			  system("echo /tmp/update_dyndns > /tmp/check_reload_status");
		      system("/bin/rm /tmp/update_dyndns");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.dyndns.update");
		      system("echo after /tmp/update_dyndns > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/interfaces_wan_configure") == 1) {
	      	  syslog(LOG_NOTICE, "configuring wan");
			  system("echo /tmp/interfaces_wan_configure > /tmp/check_reload_status");
		      system("/bin/rm  /tmp/interfaces_wan_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_wan_configure");
		      system("echo after /tmp/interfaces_wan_configure > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/interfaces_opt_configure") == 1) {
	      	  syslog(LOG_NOTICE, "configuring opt");
			  system("echo /tmp/interfaces_opt_configure > /tmp/check_reload_status");
		      system("/bin/rm /tmp/interfaces_opt_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_opt_configure");
		      system("echo after /tmp/interfaces_opt_configure > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/start_sshd") == 1) {
		      syslog(LOG_NOTICE, "starting sshd");
			  system("echo /tmp/start_sshd > /tmp/check_reload_status");
		      system("/bin/rm /tmp/start_sshd");
		      system("/usr/bin/nice -n20 /etc/sshd");
		      system("echo after /tmp/start_sshd > /tmp/check_reload_status");
	      }
	      if(fexist("/tmp/start_ntpd") == 1) {
		      syslog(LOG_NOTICE, "starting ntpd");
		      system("echo /tmp/start_ntpd > /tmp/check_reload_status");
		      system("/bin/rm /tmp/start_ntpd");
		      system("/usr/bin/killall ntpd");
		      sleep(3);
		      system("/usr/local/sbin/ntpd -s -f /var/etc/ntpd.conf");
		      system("echo after /tmp/start_ntpd > /tmp/check_reload_status");
	      }
		  system("echo sleeping > /tmp/check_reload_status");
	      sleep( cycle_time );
	  }
	  system("echo exiting > /tmp/check_reload_status");
	} else {
		  system("echo forking > /tmp/check_reload_status");
	      /* Exit parent process */
	      if( signal( SIGINT, SIG_DFL ) != SIG_DFL )
		      signal( SIGINT, SIG_DFL );
	      if( signal( SIGKILL, SIG_DFL ) != SIG_DFL )
		      signal( SIGKILL, SIG_DFL );
	      exit( 0 );
	}
	syslog(LOG_NOTICE, "check_reload_status is stopping");
	exit( 0 );
	return( 0 );
}




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
	char temp[255];
	int cycle_time;
	cycle_time = CYCLE;
	/* daemonize */
	system("echo starting > /tmp/check_reload_status");
	if( fork() == 0 ) {
	  /* close stdin and stderr */
	  fclose( stdin );
	  fclose( stdout );
	  /* loop forever until the cows come home */
	  while(1) {
	      if(fexist("/tmp/restart_webgui") == 1) {
	        system("echo webConfigurator_Restart_Sleep > /tmp/check_reload_status");
			sleep(5);
			system("echo /tmp/restartwebgui > /tmp/check_reload_status");
			system("/bin/rm /tmp/restart_webgui");
			system("/usr/bin/nice -n20 /etc/rc.restart_webgui");
	      }
	      if(fexist("/tmp/rc.linkup") == 1) {
			  system("echo /tmp/rc.linkup > /tmp/check_reload_status");
			  sprintf(temp, "/usr/local/bin/php /etc/rc.linkup `cat /tmp/rc.linkup`");
		      system(temp);
		      system("/bin/rm /tmp/rc.linkup");
	      }
	      if(fexist("/tmp/rc.newwanip") == 1) {
			  system("echo /tmp/rc.newwanip > /tmp/check_reload_status");
		      sprintf(temp, "/usr/local/bin/php /etc/rc.newwanip `cat /tmp/rc.newwanip`");
		      system(temp);
		      system("/bin/rm /tmp/rc.newwanip");
	      }
	      if(fexist("/tmp/filter_dirty") == 1) {
		      system("/bin/rm -f /tmp/filter_dirty");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.filter_configure");
	      }
	      if(fexist("/tmp/reload_all") == 1) {
			  system("echo /tmp/reload_all > /tmp/check_reload_status");
		      system("/bin/rm /tmp/reload_all");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_all");
	      }
	      if(fexist("/tmp/reload_interfaces") == 1) {
			  system("echo /tmp/reload_interfaces > /tmp/check_reload_status");
		      system("/bin/rm /tmp/reload_interfaces");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_interfaces");
	      }
	      if(fexist("/tmp/update_dyndns") == 1) {
			  system("echo /tmp/update_dyndns > /tmp/check_reload_status");
		      system("/bin/rm /tmp/update_dyndns");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.dyndns.update");
	      }
	      if(fexist("/tmp/interfaces_wan_configure") == 1) {
			  system("echo /tmp/interfaces_wan_configure > /tmp/check_reload_status");
		      system("/bin/rm  /tmp/interfaces_wan_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_wan_configure");
	      }
	      if(fexist("/tmp/interfaces_opt_configure") == 1) {
			  system("echo /tmp/interfaces_opt_configure > /tmp/check_reload_status");
		      system("/bin/rm /tmp/interfaces_opt_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_opt_configure");
	      }
	      if(fexist("/tmp/start_sshd") == 1) {
			  system("echo /tmp/start_sshd > /tmp/check_reload_status");
		      system("/bin/rm /tmp/start_sshd");
		      system("/usr/bin/nice -n20 /etc/sshd");
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
	exit( 0 );
	return( 0 );
}



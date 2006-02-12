
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
#define CYCLE		(60)

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
	char argument[255];
	char temp[255];
	int cycle_time;
	FILE *f;
	cycle_time = CYCLE;
	/* daemonize */
	if( fork() == 0 ) {
	  /* close stdin and stderr */
	  fclose( stdin );
	  fclose( stdout );
	  /* loop forever until the cows come home */
	  while(1) {
	      if(fexist("/tmp/rc.newwanip") == 1) {
		      char buf[FILENAME_MAX + 2];
		      if (!(f = fopen("/tmp/rc.newwanip", "r"))) {
			      fprintf(stderr, "Could not open /tmp/rc.newwanip for input.\n");
		      } else {
			  while (fgets(buf, sizeof buf, f))
			      fputs(buf, stdout);
			  fclose(f);
		      }
		      system("/bin/rm /tmp/rc.newwanip");
		      sprintf(temp, "/usr/local/bin/php /etc/rc.newwanip %s", buf);
		      system(temp);
	      }	  
	      if(fexist("/tmp/filter_dirty") == 1) {
		      system("/bin/rm -f /tmp/filter_dirty");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.filter_configure >/dev/null");
	      }
	      if(fexist("/tmp/reload_all") == 1) {
		      system("/bin/rm /tmp/reload_all");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_all >/dev/null");
	      }
	      if(fexist("/tmp/reload_interfaces") == 1) {
		      system("/bin/rm /tmp/reload_interfaces");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.reload_interfaces >/dev/null");
	      }
	      if(fexist("/tmp/start_sshd") == 1) {
		      system("/bin/rm /tmp/start_sshd");
		      system("/usr/bin/nice -n20 /etc/sshd");
	      }
	      if(fexist("/tmp/update_dyndns") == 1) {
		      system("/bin/rm /tmp/update_dyndns");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/rc.dyndns.update");
	      }
	      if(fexist("/tmp/interfaces_wan_configure") == 1) {
		      system("/bin/rm  /tmp/interfaces_wan_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_wan_configure");
	      }
	      if(fexist("/tmp/interfaces_wan_configure") == 1) {
		      system("/bin/rm /tmp/interfaces_wan_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_wan_configure");
	      }
	      if(fexist("/tmp/interfaces_opt_configure") == 1) {
		      system("/bin/rm /tmp/interfaces_opt_configure");
		      system("/usr/bin/nice -n20 /usr/local/bin/php /etc/interfaces_opt_configure");
	      }
	      if(fexist("/tmp/restart_webgui") == 1) {
		      system("/bin/rm /tmp/restart_webgui");
		      system("/usr/bin/nice -n20 /etc/rc.restart_webgui");
	      }	    
	      sleep( cycle_time );
	  }
	} else {
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



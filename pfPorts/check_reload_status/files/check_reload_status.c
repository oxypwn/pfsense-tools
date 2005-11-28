
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
	FILE *f;
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
		    sprintf(temp, "/usr/local/bin/php /etc/rc.newwanip %s", buf);
		    system(temp);
		    system("/bin/rm /tmp/rc.newwanip");
	    }	  
	    if(fexist("/tmp/filter_dirty") == 1) {
		    system("/usr/local/bin/php /etc/rc.filter_configure >/dev/null");
		    system("/bin/rm /tmp/filter_dirty");
	    }
	    if(fexist("/tmp/reload_all") == 1) {
		    system("/usr/local/bin/php /etc/rc.reload_all >/dev/null");
		    system("/bin/rm /tmp/reload_all");
	    }
	    if(fexist("/tmp/reload_interfaces") == 1) {
		    system("/usr/local/bin/php /etc/rc.reload_interfaces >/dev/null");
		    system("/bin/rm /tmp/reload_interfaces");
	    }
	    if(fexist("/tmp/start_sshd") == 1) {
		    system("/etc/sshd");
		    system("/bin/rm /tmp/start_sshd");
	    }
	    if(fexist("/tmp/update_dyndns") == 1) {
		    system("/usr/local/bin/php /etc/rc.dyndns.update");
		    system("/bin/rm /tmp/update_dyndns");
	    }	    
	    sleep(5);
	}
	return 0;
}



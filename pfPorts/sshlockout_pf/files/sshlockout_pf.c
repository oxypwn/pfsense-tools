/*
* SSHLOCKOUT_PF.C
*
* Written by Matthew Dillon
* Modified to use PF tables by Scott Ullrich
*
* Use: pipe syslog auth output to this program.  e.g. in /etc/syslog.conf:
*
*  auth.info;authpriv.info                         /var/log/auth.log
*  auth.info;authpriv.info                         |exec /root/adm/sshlockout
*
* Detects failed ssh login and attempts to map out the originating IP
* using PF's tables.
*
* setup a rule in your pf ruleset (near the top) similar to:
* table <sshlockout> persist
* block in log quick from <sshlockout> to any label "sshlockout"
*
* *VERY* simplistic.  ip table entries do not timeout, there are
* no checks made for local IPs or nets,
* or for prior successful logins, etc.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <syslog.h>

static void lockout(char *str);
void check_for_string(char *str, char buf[1024]);

int
main(int ac, char **av)
{
   char buf[1024];
   char *str;

   openlog("sshlockout", LOG_PID|LOG_CONS, LOG_AUTH);
   syslog(LOG_ERR, "sshlockout starting up");
   freopen("/dev/null", "w", stdout);
   freopen("/dev/null", "w", stderr);

   while (fgets(buf, sizeof(buf), stdin) != NULL) {
       /* if this is not sshd related, continue on without processing */
       if (strstr(buf, "sshd") == NULL)
           continue;

       check_for_string("Failed password for root from", buf);
       check_for_string("Failed password for admin from", buf);
       check_for_string("Failed password for invalid user", buf);
       check_for_string("Illegal user", buf);
       check_for_string("authentication error for", buf);

   }
   syslog(LOG_ERR, "sshlockout exiting");
   return(0);
}

void
check_for_string(char *str, char buf[1024])
{
	char *tmpstr = NULL;
      if ((str = strstr(buf, str)) != NULL) {
           if ((tmpstr = strstr(str, " from")) != NULL)
               lockout(tmpstr + 5);
       }
}

static void
lockout(char *str)
{
   int n1, n2, n3, n4;
   char buf[256];

   if (sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) == 4) {
       syslog(LOG_ERR, "Illegal ssh login attempt, locking out %d.%d.%d.%d\n", \
         n1, n2, n3, n4);
       snprintf(buf, sizeof(buf), "/sbin/pfctl -t sshlockout -T add %d.%d.%d.%d", \
         n1, n2, n3, n4);
       system(buf);
   }
}

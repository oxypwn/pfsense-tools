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
* block in log quick from <sshlockout> to any label "sshlockout"
*
* *VERY* simplistic.  ipfw entries do not timeout, duplicate entries may
* occur (though normally not since ssh won't see new connections from
* the IP otherwise), there are no checks made for local IPs or nets,
* or for prior successful logins, etc.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <syslog.h>

static void lockout(char *str);

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
       if (strstr(buf, "sshd") == NULL)
           continue;
       if ((str = strstr(buf, "Failed password for root from")) != NULL ||
           (str = strstr(buf, "Failed password for admin from")) != NULL
       ) {
           while (*str && (*str < '0' || *str > '9'))
               ++str;
           lockout(str);
           continue;
       }
       if ((str = strstr(buf, "Failed password for invalid user")) != NULL) {
           str += 32;
           while (*str == ' ')
               ++str;
           while (*str && *str != ' ')
               ++str;
           if (strncmp(str, " from", 5) == 0)
               lockout(str + 5);
           continue;
       }
       if ((str = strstr(buf, "Illegal user")) != NULL) {
           str += 12;
           while (*str == ' ')
               ++str;
           while (*str && *str != ' ')
               ++str;
           if (strncmp(str, " from", 5) == 0)
               lockout(str + 5);
       }
   }
   syslog(LOG_ERR, "sshlockout exiting");
   return(0);
}

static void
lockout(char *str)
{
   int n1, n2, n3, n4;
   char buf[256];

   if (sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) == 4) {
       syslog(LOG_ERR, "Detected Illegal ssh login attempt, locking out %d.%d.%d.%d\n", n1, n2, n3, n4);
       snprintf(buf, sizeof(buf), "/sbin/pfctl -t sshlockout -T add %d.%d.%d.%d", n1, n2, n3, n4);
       system(buf);
   }
}

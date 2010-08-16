/*
 *  v2.01
 *  SSHLOCKOUT_PF.C 
 *  Originally written by Matthew Dillon
 *  Heavily modified to use PF tables by Scott Ullrich and
 *  extened to keep a database of last 256 bad attempts 
 *  (MAXLOCKOUTS) and block user if they go over (MAXATTEMPTS).
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *  
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *  
 *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 *  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
 *  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 *
 *  Use: pipe syslog auth output to this program.  e.g. in /etc/syslog.conf:
 *
 *   auth.info;authpriv.info				/var/log/auth.log
 *   auth.info;authpriv.info				|exec /path/to/sshlockout_pf
 *
 *  Detects failed ssh login and attempts to map out the originating IP
 *  using PF's tables.
 *
 *  Setup instructions:
 *   setup a rule in your pf ruleset (near the top) similar to:
 *   table <sshlockout> persist
 *   block in log quick from <sshlockout> to any label "sshlockout"
 *
 *  Some things to note:
 *   1. *VERY* simplistic.  IP table entries do not timeout without expiretable
 *   2. No checks are made for local IPs or nets, or for prior good logins, etc.
 *   3. Use expiretable binary from cron to help prune the sshlockout table
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <syslog.h>
#include <time.h>

// Non changable globals
#define MAXATTEMPTS 10
#define MAXLOCKOUTS 256
#define VERSION	"2.0"

// Wall of shame (invalid login DB)
static struct sshlog 
{
	// IP ADDR Octets
	int n1;
	int n2;
	int n3;
	int n4;
	// Invalid login attempts
	int attempts;
	// Last invalid timestamp
	time_t ts;
} lockouts[MAXLOCKOUTS + 1];

// Function declarations
static void lockout(char *str);
static void lockout_remove(char *str);
static void check_for_denied_string(char *str, char *buf);
static void check_for_accepted_string(char *str, char *buf);
static void prune_oldest_record(void);
static void prune_record(int n1, int n2, int n3, int n4);
static void add_new_record(int n1, int n2, int n3, int n4);

// Start of program - main loop
int
main(void) 
{
	char buf[1024] = { 0 };

	// Initialize time conversion information
	tzset();

	// Open syslog file
	openlog("sshlockout", LOG_PID|LOG_CONS, LOG_AUTH);

	// We are starting up
	syslog(LOG_ERR, "sshlockout v%s starting up", VERSION);

	// Open up stderr and stdout to the abyss
	(void)freopen("/dev/null", "w", stdout);
	(void)freopen("/dev/null", "w", stderr);

	// Loop through reading in syslog stream looking for
	// for specific strings that indicate that a user has
	// attempted login but failed.
	while (fgets(buf, (int)sizeof(buf), stdin) != NULL) 
	{
		/* if this is not sshd related, continue on without processing */
		if (strstr(buf, "sshd") == NULL)
			continue;
		// Check for various bad (or good!) strings in stream
		check_for_denied_string("Failed password for root from", buf);
		check_for_denied_string("Failed password for admin from", buf);
		check_for_denied_string("Failed password for invalid user", buf);
		check_for_denied_string("Illegal user", buf);
		check_for_denied_string("Invalid user", buf);
		check_for_denied_string("authentication error for", buf);
		check_for_accepted_string("Accepted keyboard-interactive/pam for", buf);
	}

	// We are exiting
	syslog(LOG_ERR, "sshlockout v%s exiting", VERSION);

	// That's all folks.
	return(0);
}

// Check for passed string and lockout the 
// host if we find the log message in stream.
static void
check_for_denied_string(char *str, char *buf)
{
	char *tmpstr = NULL;
	if ((str = strstr(buf, str)) != NULL) 
	{
		if ((tmpstr = strstr(str, " from")) != NULL) {
			if (strlen(tmpstr) > 5)
				lockout(tmpstr + 5);
		}
	}
}

// Check for accepted string and remove the 
// host from the local database if found.
static void
check_for_accepted_string(char *str, char *buf)
{
	char *tmpstr = NULL;
	if ((str = strstr(buf, str)) != NULL) 
	{
		if ((tmpstr = strstr(str, " from")) != NULL) {
			if (strlen(tmpstr) > 5)
				lockout_remove(tmpstr + 5);
		}
	}
}

// Loop through and remove the oldest entry
static void 
prune_oldest_record(void) 
{
	// Loop counter, status of record in db
	int i = 0;
	int oldestrecord = 0;

	// Time tracker (unix epoch)
	time_t now = 0;
	time_t ts = 0;

	// Init
    now = time(NULL);

	// Track the oldest record id.
	// Set the known oldest to now.
	ts = time(&now);

	// Loop until we hit MAXLOCKOUTS
	// looking for an emty slot
	while(i < MAXLOCKOUTS) 
	{
		// Check to see if item is older than
		// the oldest entry found thus far.
		if(lockouts[i].ts < ts) 
			oldestrecord = i;
		// Increase by one
		i++;
	}

	// Clear the oldest record (oldestrecord)
	lockouts[oldestrecord].n1 = 0;
	lockouts[oldestrecord].n2 = 0;
	lockouts[oldestrecord].n3 = 0;
	lockouts[oldestrecord].n4 = 0;
	lockouts[oldestrecord].attempts = 0;
}

// Add new IP address to DB 
static void 
add_new_record(int n1, int n2, int n3, int n4) 
{
	// Loop counter, status of record in db
	int foundrecord = 0, i = 0;

	// Time tracker (unix epoch)
	time_t now;

	// Loop until we hit MAXLOCKOUTS
	// looking for an empty slot
	while(i < MAXLOCKOUTS && foundrecord == 0) 
	{
		// Look for the IP in the DB
		if(lockouts[i].n1 == 0 &&
			lockouts[i].n2 == 0 &&
			lockouts[i].n3 == 0 &&
			lockouts[i].n4 == 0) 
		{
			foundrecord = 1;
			break;
		}
		// If we did not find an empty slot
		// go ahead and prune a record and
		// start the empty slot search again.
		if(i == MAXLOCKOUTS) {
			prune_oldest_record();
			// Set to -1, it will ++ below (+3)
			i = -1;
		}
		// Increase by one
		i++;
	}

	// Grab the time
    now = time(NULL);

	// Add item to DB
	lockouts[i].n1 = n1;
	lockouts[i].n2 = n2;
	lockouts[i].n3 = n3;
	lockouts[i].n4 = n4;

	// Add last seen epoch
	lockouts[i].ts = time(&now);
}

// Record last IP date
static void 
record_event(int n1, int n2, int n3, int n4) 
{
	// Loop counter, status of record in db
	int i = 0;

	// Time tracker (unix epoch)
	time_t now;

	// Loop until we hit MAXLOCKOUTS
	while(i < MAXLOCKOUTS) 
	{
		// Look for the IP in the DB
		if(lockouts[i].n1 == n1 &&
			lockouts[i].n2 == n2 &&
			lockouts[i].n3 == n3 &&
			lockouts[i].n4 == n4) 
		{
			// Update the entries epoch
    		now = time(NULL);
			lockouts[i].ts = time(&now);
			// Note the invalid login attempt
			lockouts[i].attempts++;
			break;
		}
		// Increase by one
		i++;
	}
}

// Remove specific record from DB (IPADDR)
static void 
prune_record(int n1, int n2, int n3, int n4) 
{
	// Loop counter, status of record in db
	int  i = 0;

	// Loop until we hit MAXLOCKOUTS
	while(i < MAXLOCKOUTS) 
	{
		// Look for the IP in the DB
		if(lockouts[i].n1 == n1 &&
			lockouts[i].n2 == n2 &&
			lockouts[i].n3 == n3 &&
			lockouts[i].n4 == n4) 
		{
			// Reset the DB entry
			lockouts[i].n1 = 0;
			lockouts[i].n2 = 0;
			lockouts[i].n3 = 0;
			lockouts[i].n4 = 0;
			lockouts[i].attempts = 0;
			break;
		}
		// Increase by one
		i++;
	}
}

// Check string for badness and lockout IPADDR
// if we find the specified string in stream 
// and if the attempt account is == MAXATTEMPTS
static void
lockout(char *str)
{
	// IP address octets
	int n1 = 0, n2 = 0, n3 = 0, n4 = 0;

	// Error tracker
	int ret = 0;

	// Loop counter, status of record in db
	int i = 0, foundrecord = 0;

	// system() handler variable
	char buf[256];

	// Variable to track if we are blocking or adding
	// to database to track invalid logins.
	int shouldblock = 0;

	// Check passed string and parse out the IP address
	// If we cannot find a IP address then simply return.
	if (sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) > 4 || 
		sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) < 4) 
			return;

	// Track if we have found the record
	foundrecord = 0;

	// Check to see if hosts IP is in our lockout table checking
	// how many attempts.   If the attempts are over 3 then 
	// purge the host from the table and leave shouldblock = true
	while(i < MAXLOCKOUTS) 
	{
		// Try to find the IP in DB
		if(lockouts[i].n1 == n1 &&
			lockouts[i].n2 == n2 &&
			lockouts[i].n3 == n3 &&
			lockouts[i].n4 == n4) 
		{
			// Found the record, record the attempt
			record_event(n1, n2, n3, n4);
			foundrecord = 1;
			// Check to see if user is above or == MAXATTEMPTS
			if(lockouts[i].attempts >= MAXATTEMPTS) 
			{
				// Block the host
				shouldblock = 1;
				break;
			}
		}
		// Increase by one
		i++;
	}

	// Entry not found, lets add it to the DB
	if(foundrecord == 0)
		add_new_record(n1, n2, n3, n4);

	// If shouldblock is still true go ahead and block the offender
	if(shouldblock == 1)
	{
		// Remove the record we are going to block this host.
		prune_record(n1, n2, n3, n4);

		// Notify syslog of the host being blocked (IPADDR)
		syslog(LOG_ERR, "Locking out %d.%d.%d.%d after %i invalid attempts\n", \
			n1, n2, n3, n4, MAXATTEMPTS);

		// Setup buf with the pfctl command needed to block HOST
		ret = snprintf(buf, sizeof(buf), "/sbin/pfctl -t sshlockout -T add %d.%d.%d.%d", \
			n1, n2, n3, n4);
		// Check for error condition
		if(ret < 0) 
		{
			syslog(LOG_ERR, "Error Locking out %d.%d.%d.%d while allocating snprintf()\n", \
				n1, n2, n3, n4, MAXATTEMPTS);
			return;
		}

		// Execute the command in buf
		ret = system(buf);
		// Check for error condition
		if(ret != 0)
			syslog(LOG_ERR, "Error Locking out %d.%d.%d.%d while launching pfctl\n", \
				n1, n2, n3, n4, MAXATTEMPTS);
	}
}

// Remove host from logging dabtase
static void
lockout_remove(char *str)
{
	// IP address octets
	int n1 = 0, n2 = 0, n3 = 0, n4 = 0;

	// Check passed string and parse out the IP address
	// If we cannot find a IP address then simply return.
	if (sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) > 4 || 
		sscanf(str, "%d.%d.%d.%d", &n1, &n2, &n3, &n4) < 4) 
			return;

	// User auth'd.  Remove previous lockout db entries.
	prune_record(n1, n2, n3, n4);
}

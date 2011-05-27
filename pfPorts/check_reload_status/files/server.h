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

#ifndef _SERVER_H_
#define _SERVER_H_

#include <pthread.h>

#define filepath        "/tmp/check_test"

/* used for writing to the status file */
int status = -1;
#define NONE	0
#define BEFORE  1
#define AFTER   2

enum actions {
        ALL,
        FILTER,
        INTERFACE,
        GATEWAY,
        SERVICE,
        DNSSERVER,
        DYNDNS,
        DYNDNSALL,
	PACKAGES,
        SSHD,
        WEBGUI,
        NEWIP,
        NTPD,
        LINKUP,
        LINKDOWN,
        RELOAD,
        RECONFIGURE,
        RESTART,
	START,
	STOP,
        SYNC,
        NULLOPT
};

enum argtype {
        NON,
        COMPOUND,
        ADDRESS,
        PREFIX,
        STRING,
        INTEGER,
        IFNAME
};

struct run {
        const char    *command;
        const char    *syslog;
	pthread_mutex_t	serialize;
};

#define NULLRUN { NULL, NULL, PTHREAD_MUTEX_INITIALIZER }

struct command {
        enum actions    action;
        enum argtype    type;
        const char      *keyword;
        const struct command  *next;
        struct run      cmd;
};

static const struct command first_level[];
static const struct command c_interface2[];
static const struct command c_filter[];
static const struct command c_interface[];
static const struct command c_service[];
static const struct command c_service2[];


static const struct command first_level[] = {
        { FILTER, COMPOUND, "filter", c_filter, NULLRUN },
        { INTERFACE, COMPOUND, "interface", c_interface, NULLRUN },
        /* { GATEWAY, COMPOUND, "gateway", c_reload, NULLRUN }, */
        { SERVICE, COMPOUND, "service", c_service, NULLRUN },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

static const struct command c_filter[] = {
        { RELOAD, NON, "reload", NULL,
                { "/usr/local/bin/php /etc/rc.filter_configure_sync", "Reloading filter", PTHREAD_MUTEX_INITIALIZER } },
        { RECONFIGURE, NON, "reconfigure", NULL,
                { "/usr/local/bin/php /etc/rc.filter_configure_sync", "Reloading filter", PTHREAD_MUTEX_INITIALIZER } },
        { RESTART, NON, "restart", NULL,
                { "/usr/local/bin/php /etc/rc.filter_configure_sync", "Reloading filter", PTHREAD_MUTEX_INITIALIZER } },
        { SYNC, NON, "sync", NULL,
                { "/usr/local/bin/php /etc/rc.filter_synchronize", "Syncing firewall", PTHREAD_MUTEX_INITIALIZER } },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

static const struct command c_interface[] = {
        { ALL, STRING, "all", c_interface2, NULLRUN },
        { RELOAD, IFNAME, "reload", NULL,
                { "/usr/local/bin/php /etc/rc.interfaces_wan_configure %s", "Configuring interface %s", PTHREAD_MUTEX_INITIALIZER } },
        { RECONFIGURE, IFNAME, "reconfigure", NULL,
                { "/usr/local/bin/php /etc/rc.interfaces_wan_configure %s", "Configuring interface %s", PTHREAD_MUTEX_INITIALIZER } },
        { RESTART, IFNAME, "restart", NULL,
                { "/usr/local/bin/php /etc/rc.interfaces_wan_configure %s", "Configuring interface %s", PTHREAD_MUTEX_INITIALIZER } },
        { NEWIP, STRING, "newip", NULL,
                { "/usr/local/bin/php /etc/rc.newwanip %s", "rc.newwanip starting %s", PTHREAD_MUTEX_INITIALIZER } },
        { LINKUP, STRING, "linkup", c_interface2, NULLRUN },
        { SYNC, NON, "sync", NULL,
                { "/usr/local/bin/php /etc/rc.filter_configure_xmlrpc", "Reloading filter_configure_xmlrpc", PTHREAD_MUTEX_INITIALIZER } },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

static const struct command c_interface2[] = {
        { RELOAD, NON, "reload", NULL,
                { "/usr/local/bin/php /etc/rc.reload_interfaces", "Reloading interfaces", PTHREAD_MUTEX_INITIALIZER } },
	{ START, IFNAME, "start", NULL,
                { "/usr/local/bin/php /etc/rc.linkup start %s", "Linkup starting %s", PTHREAD_MUTEX_INITIALIZER } },
	{ STOP, IFNAME, "stop", NULL,
                { "/usr/local/bin/php /etc/rc.linkup stop %s", "Linkup starting %s", PTHREAD_MUTEX_INITIALIZER } },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

static const struct command c_service2[] = {
        { ALL, NON, "all", NULL,
                { "/usr/local/bin/php /etc/rc.reload_all", "Reloading all", PTHREAD_MUTEX_INITIALIZER } },
        { DNSSERVER, NON, "dns", NULL,
                { "/etc/rc.resolv_conf_generate", "Rewriting resolv.conf", PTHREAD_MUTEX_INITIALIZER } },
        { DYNDNS, STRING, "dyndns", NULL,
                { "/usr/local/bin/php /etc/rc.dyndns.update %s", "updating dyndns %s", PTHREAD_MUTEX_INITIALIZER } },
        { DYNDNSALL, NON, "dyndnsall", NULL,
                { "/usr/local/bin/php /etc/rc.dyndns.update", "Updating all dyndns", PTHREAD_MUTEX_INITIALIZER } },
        { NTPD, NON, "ntpd", NULL,
                { "/usr/bin/killall ntpd; /bin/sleep 3; /usr/local/sbin/ntpd -s -f /var/etc/ntpd.conf", "Starting nptd", PTHREAD_MUTEX_INITIALIZER } },
        { PACKAGES, NON, "packages", NULL,
                { "/usr/local/bin/php /etc/rc.start_packages", "Starting packages", PTHREAD_MUTEX_INITIALIZER } },
        { SSHD, NON, "sshd", NULL,
                { "/etc/sshd", "starting sshd", PTHREAD_MUTEX_INITIALIZER } },
        { WEBGUI, NON, "webgui", NULL,
                { "/usr/local/bin/php /etc/rc.restart_webgui", "webConfigurator restart in progress", PTHREAD_MUTEX_INITIALIZER } },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

static const struct command c_service[] = {
        { RELOAD, STRING, "reload", c_service2, NULLRUN },
        { RECONFIGURE, STRING, "reconfigure", c_service2, NULLRUN},
        { RESTART, STRING, "restart", c_service2, NULLRUN },
        { NULLOPT, NON, "", NULL, NULLRUN }
};

#endif /* _SERVER_H_ */

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

enum actions {
        ALL,
        FILTER,
        INTERFACE,
	IPSECDNS,
	OPENVPN,
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
	VOUCHERS,
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
        char    *command;
        char    *syslog;
	int aggregate;
};

struct command {
        enum actions    action;
        enum argtype    type;
        char      *keyword;
        struct command  *next;
        struct run      cmd;
};

static struct command c_interface2[];
static struct command c_filter[];
static struct command c_interface[];
static struct command c_service[];
static struct command c_service2[];


static struct command first_level[] = {
        { FILTER, COMPOUND, "filter", c_filter},
        { INTERFACE, COMPOUND, "interface", c_interface },
        /* { GATEWAY, COMPOUND, "gateway", c_reload }, */
        { SERVICE, COMPOUND, "service", c_service },
        { NULLOPT, NON, "", NULL }
};

static struct command c_filter[] = {
        { RELOAD, NON, "reload", NULL,
                { "/etc/rc.filter_configure_sync", "Reloading filter", 1 } },
        { RECONFIGURE, NON, "reconfigure", NULL,
                { "/etc/rc.filter_configure_sync", "Reloading filter", 1 } },
        { RESTART, NON, "restart", NULL,
                { "/etc/rc.filter_configure_sync", "Reloading filter", 1 } },
        { SYNC, NON, "sync", NULL,
                { "/etc/rc.filter_synchronize", "Syncing firewall", 1 } },
        { NULLOPT, NON, "", NULL }
};

static struct command c_interface[] = {
        { ALL, STRING, "all", c_interface2 },
        { RELOAD, IFNAME, "reload", NULL,
                { "/etc/rc.interfaces_wan_configure %s", "Configuring interface %s", 1 } },
        { RECONFIGURE, IFNAME, "reconfigure", NULL,
                { "/etc/rc.interfaces_wan_configure %s", "Configuring interface %s", 1 } },
        { RESTART, IFNAME, "restart", NULL,
                { "/etc/rc.interfaces_wan_configure %s", "Configuring interface %s", 1 } },
        { NEWIP, STRING, "newip", NULL,
                { "/etc/rc.newwanip %s", "rc.newwanip starting %s", 0 } },
        { LINKUP, STRING, "linkup", c_interface2 },
        { SYNC, NON, "sync", NULL,
                { "/etc/rc.filter_configure_xmlrpc", "Reloading filter_configure_xmlrpc", 1 } },
        { NULLOPT, NON, "", NULL }
};

static struct command c_interface2[] = {
        { RELOAD, NON, "reload", NULL,
                { "/etc/rc.reload_interfaces", "Reloading interfaces", 1 } },
	{ START, IFNAME, "start", NULL,
                { "/etc/rc.linkup start %s", "Linkup starting %s", 0 } },
	{ STOP, IFNAME, "stop", NULL,
                { "/etc/rc.linkup stop %s", "Linkup starting %s", 0 } },
        { NULLOPT, NON, "", NULL }
};

static struct command c_service2[] = {
        { ALL, NON, "all", NULL,
                { "/etc/rc.reload_all", "Reloading all", 1 } },
        { DNSSERVER, NON, "dns", NULL,
                { "/etc/rc.resolv_conf_generate", "Rewriting resolv.conf", 1 } },
        { IPSECDNS, NON, "ipsecdns", NULL,
                { "/etc/rc.newipsecdns", "Restarting ipsec tunnels", 1 } },
        { OPENVPN, NON, "openvpn", NULL,
                { "/etc/rc.openvpn %s", "Restarting OpenVPN tunnels/interfaces", 1 } },
        { DYNDNS, STRING, "dyndns", NULL,
                { "/etc/rc.dyndns.update %s", "updating dyndns %s", 1 } },
        { DYNDNSALL, NON, "dyndnsall", NULL,
                { "/etc/rc.dyndns.update", "Updating all dyndns", 1 } },
        { NTPD, NON, "ntpd", NULL,
                { "/usr/bin/killall ntpd; /bin/sleep 3; /usr/local/sbin/ntpd -s -f /var/etc/ntpd.conf", "Starting nptd", 1 } },
        { PACKAGES, NON, "packages", NULL,
                { "/etc/rc.start_packages", "Starting packages", 1 } },
        { SSHD, NON, "sshd", NULL,
                { "/etc/sshd", "starting sshd", 1 } },
        { WEBGUI, NON, "webgui", NULL,
                { "/etc/rc.restart_webgui", "webConfigurator restart in progress", 1 } },
        { NULLOPT, NON, "", NULL }
};

static struct command c_service_sync[] = {
	{ VOUCHERS, NON, "vouchers", NULL,
		{ "/etc/rc.savevoucher", "Synching vouchers", 1 } },
        { NULLOPT, NON, "", NULL }
};

static struct command c_service[] = {
        { RELOAD, STRING, "reload", c_service2 },
        { RECONFIGURE, STRING, "reconfigure", c_service2},
        { RESTART, STRING, "restart", c_service2 },
	{ SYNC, STRING, "sync", c_service_sync },
        { NULLOPT, NON, "", NULL }
};

#endif /* _SERVER_H_ */

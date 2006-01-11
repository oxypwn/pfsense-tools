/* 
 * $Id$
 *
 * Copyright (c) 2003, Christianity.com
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *     - Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 *     - Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     - Neither the name of Christianity.com nor the names of its
 *       contributors may be used to endorse or promote products derived from
 *       this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <err.h>
#include <syslog.h>
#include <stdarg.h>

#include <string.h>
#include <pthread.h>

#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/pfvar.h>

#include "globals.h"
#include "service.h"
#include "vsvc.h"
#include "vsvc_rules.h"
#include "config.h"
#include "printers.h"

static int      usedb = 1;

/*
 * Cgetusedb() allows the user to specify whether or not to use a .db
 * version of the database file (if it exists) in preference to the
 * text version.  By default, the getcap(3) routines will use a .db file.
 */
int
cgetusedb(int new_usedb)
{
        int old_usedb = usedb;

        usedb = new_usedb;
        return(old_usedb);
}

int
is_port(char *str)
{
	long lval;

	errno = 0;
	lval = strtol(str, NULL, 10);
	if (((errno == ERANGE) && (lval == LONG_MAX || lval == LONG_MIN)) || (lval > 65535))
		return -1;
	else
		return (int) lval;
}

int vsvc_getconfig(char *cfile) {
	int i, j, result, rport, vipport;
	char *buf, *str, *data = NULL;
	char vipstring[VIPLEN];
	struct vsvc_t *v;
	static char   *configfiles[2] = { CONFIG_FILE , NULL };
	i = j = result = rport = vipport = 0;

	SLIST_INIT(&virtualservices);

	cgetusedb(0); /* no unpredictable .db file behavior. */

#ifndef vsvc_getcap
#define	vsvc_getcap(a)	(cgetstr(buf, a, &str) > 0 ? str : NULL)
#endif

	if (cfile != NULL)
		configfiles[0] = cfile;
	
	syslog(LOG_INFO, "Using configuration file %s", configfiles[0]);

	result = cgetfirst(&buf, configfiles);

	while (result == 1) {
		switch (result) {
		case -1:
			syslog(LOG_ERR, "system error - exiting");
			err(1, "a system error occurred");
			break;
		case -2:
			syslog(LOG_ERR, "potential reference loop - exiting");
			errx(1, "potential reference loop");
			break;
		case 2:
			syslog(LOG_ERR, "unresolved tc= in config (see "
					"getcap(3) for more details) - "
					"exiting");
			errx(1, "unresolved tc= thing");
			break;
		case 1:
			v = malloc(sizeof(struct vsvc_t));
			if (v == NULL)
				warn("Could not allocate memory for v");
			memset(v, 0x0, sizeof(struct vsvc_t));

			vsvc_init(v);
			if (vsvc_lock(v))
				err(1, "Could not lock v");

			/* set anchor and ruleset */
			memcpy(v->anchor, anchorname, sizeof(v->anchor));
#ifdef OpenBSD3_5
                        memcpy(v->ruleset, rulesetname, sizeof(v->ruleset));
#endif

			/* snag vip number */
			if (cgetstr(buf, "vip", &str) <= 0)  {
				syslog(LOG_ERR, "VIP %s not found", str);
				err(1, "vip %s not found", str);
			}
			strlcpy(v->name, str, MAXNAMELEN);
			/* get vip */
			if (vsvc_setinaddr(v, str)) {
				syslog(LOG_ERR, "Couldn't set VIP for %s", str);
				err(1, "could not set vip for %s",
				    str);
			}
			if (str != NULL)
				free(str);

			/* get port */
			if (cgetstr(buf, "vip-port", &str) <= 0) {
				syslog(LOG_ERR, "Invalid port for VIP %s",
				    v->name);
				err(1, "invalid port for vip %s", v->name);
			}
			else {
				if (((vipport = is_port(str)) != -1) ||
				  (vsvc_setport(v, (in_port_t) vipport))) {
					syslog(LOG_ERR, "Invalid port for vip %s", 
				    		v->name);
					err(1, "invalid port for vip %s", v->name);
				}
			}
			if (str != NULL)
				free(str);
			syslog(LOG_INFO, "VIP %s:%d configured as \"%s\"",
			    inet_ntoa(vsvc_getinaddr(v)), vsvc_getport(v),
			    v->name);

			/* get poolname */
                        if (cgetstr(buf, "poolname", &str) <= 0) {
                                syslog(LOG_ERR, "Invalid poolname for vip %s",
                                    v->name);
                                err(1, "invalid pooolname for vip %s", v->name);
                        }
			strlcpy(v->poolname, str, MAXNAMELEN);
			if (str != NULL)
				free(str);

			/* get sitedown host */
			if (cgetstr(buf, "sitedown", &str) <= 0) {
				syslog(LOG_ERR, "Invalid sitedown for VIP %s",
				    v->name);
				err(1, "invalid sitedown for vip %s", v->name);
			}
			if (inet_aton(str, &v->sitedown.sin_addr) != 1) {
				syslog(LOG_ERR, "Couldn't inet_aton(sitedown)");
				err(1, "couldn't inet_aton(sitedown)");
			}
			if (str != NULL)
				free(str);

			if (cgetstr(buf, "sitedown-port", &str) <= 0) {
				syslog(LOG_ERR, "Invalid sitedown-port for "
				    "VIP %s", v->name);
			}
			else {
				v->sitedown.sin_port = htons((in_port_t)
				    strtol(str, NULL, 10));
				free(str);
			}

			syslog(LOG_INFO, "VIP %s:%d sitedown at %s:%d",
			    v->name, vsvc_getport(v),
			    inet_ntoa(v->sitedown.sin_addr),
			    (int) ntohs(v->sitedown.sin_port));
			
			if (cgetstr(buf, "service-port", &str) <= 0) {
				syslog(LOG_ERR, "Invalid service port for "
				    "VIP %s", v->name);
				err(1, "invalid service port for vip %s",
				    v->name);
			}
			rport = (int) strtoul(str, NULL, 10);
			free(str);

			if (cgetstr(buf, "services", &str) <= 0) {
				syslog(LOG_ERR, "Invalid number of services "
				    "for VIP %s", v->name);
				err(1, "invalid number of services "
				    "for vip %s", v->name);
			}
			v->services_len = (u_int32_t) strtol(str, NULL, 10);
			if (str != NULL)
				free(str);
			
			v->services = calloc(v->services_len,
				sizeof(struct service_t *));
			for (j = 0; j < v->services_len; j++) {
				v->services[j] = \
					malloc(sizeof(struct service_t));
				if (v->services[j] == NULL)
				    warn("Could not allocate memory for "
				        "v->services[j]");
				memset(v->services[j], 0x0, sizeof(struct service_t));
				if (init_service(v->services[j])) {
					syslog(LOG_ERR, "Could not initialize "
					    "service %d for VIP %s", j,
					    v->name);
					err(1, "could not initialize service");
				}
				if (lock_service(v->services[j])) {
					syslog(LOG_ERR, "Could not lock service"
					    " %d for VIP %s", j, v->name);
					err(1, "could not lock service");
				}
				
				if (cgetcap(buf, "tcppoll", ':') != NULL) {
					if (cgetstr(buf, "send", &str) > 0 &&
					    cgetstr(buf, "expect", &data) > 0) {
#ifdef DEBUG
						warnx("%s", str);
						warnx("%s", data);
#endif
						setservice_tcpexpect(
						    v->services[j], str, data);
						if (str != NULL)
							free(str);
						if (data != NULL)
							free(data);
					}
					else {
						if (str != NULL)
							free(str);
						if (data != NULL)
							free(data);

						setservice_tcppoll(
						    v->services[j]);
					}
					setservice_addpolltype(v->services[j],
					    SVCPOLL_TCP);
				}

				if (cgetcap(buf, "httpget", ':') != NULL && \
					cgetstr(buf, "url", &str) && \
					cgetstr(buf, "expect", &data)) {
					setservice_httpget(v->services[j],
					    str, data);
					if (str != NULL)
						free(str);
					if (data != NULL)
						free(data);
					setservice_addpolltype(v->services[j],
					    SVCPOLL_HTTPGET);
				}
				if (str != NULL)
					free(str);
				if (data != NULL)
					free(data);

				if (cgetcap(buf, "httphead", ':') != NULL && \
					cgetstr(buf, "url", &str) &&
					cgetstr(buf, "expect", &data)) {
					setservice_httphead(v->services[j],
					    str, data);
					free(str);
					free(data);
					setservice_addpolltype(v->services[j],
					    SVCPOLL_HTTPHEAD);
				}
				
				/* TODO:
				 *  - add TCP poll/expect support
				 *  - add HTTP POST support
				 */ 

				if (cgetcap(buf, "ping", ':') != NULL)
					setservice_ping(v->services[j]);
				
				/*
				 * set inaddr and port from config string
				 */
				if (snprintf(vipstring, VIPLEN, "%d", j) == -1){
					syslog(LOG_ERR, "snprintf failed.");
					errx(1, "snprintf failed");
				}
				if (cgetstr(buf, vipstring, &str) > 0) {
					if (setservice_inaddr(v->services[j],
					    str)) {
						syslog(LOG_ERR,
						    "count not set inaddr for "
						    "service %d in VIP %s", j,
						    vipstring);
						err(1, "could not set inaddr "
						    "for service %s",
						    vipstring);
					}
					free(str);
				}
				else {
					syslog(LOG_ERR, "missing real service "
					    "ip %d for VIP %s", j, v->name);
					err(1, "missing real service ip %d", j);
				}
				if (setservice_port(v->services[j], rport)) {
					syslog(LOG_ERR, "Could not set rport "
					    "for service %d on VIP %s",
					    j, v->name);
					errx(1, "could not set port");
				}
				
				setservice_down(v->services[j]);
				setservice_active(v->services[j]);
				if (unlock_service(v->services[j])) {
					syslog(LOG_ERR, "Could not unlock "
					    "service %d for VIP %s", j,
					    v->name);
					err(1, "could not unlock service");
				}
			}

			for (j = 0; j < v->services_len; j++) {
				syslog(LOG_INFO, "VIP %s:%d added real service "
				    "%s:%d", v->name, vsvc_getport(v),
				    inet_ntoa(getservice_inaddr(v->services[j])),
				    getservice_port(v->services[j]));
			}

			/* do post-config modification of vsvc_t */
			v->id = i++;
			v->rule_nr = v->id;
			v->dirty = 1;

			SLIST_INSERT_HEAD(&virtualservices, v, next);

			if (vsvc_unlock(v)) {
				syslog(LOG_ERR, "Could not unlock VIP %s at "
						"end of config loop, exiting", 
				    v->name);
				err(1, "Could not unlock v");
			}
#ifdef DEBUG
			print_vsvc(v);
#endif
			break;
		default:
#ifdef DEBUG
			warnx("end of database");
#endif
			break;
		}
		
		result = cgetnext(&buf, configfiles);
	}
	/* else printf("we read %d records.\n", i); */

	return(0);
}




--- ../ifstated-20050505.orig/ifstated.c        Thu May  5 11:51:24 2005
+++ ifstated.c  Thu May  5 12:06:07 2005
@@ -1,4 +1,5 @@
 /*	$OpenBSD: ifstated.c,v 1.21 2005/02/07 12:38:44 mcbride Exp $	*/
+/*	$OpenBSD: ifstated.c,v 1.29 2006/03/16 06:12:58 mcbride Exp $	*/
 
 /*
  * Copyright (c) 2004 Marco Pfatschbacher <mpf@openbsd.org>
@@ -23,12 +24,15 @@
  */
 
 #include <sys/types.h>
+#include <sys/event.h>
 #include <sys/time.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <sys/wait.h>
+#include <sys/sysctl.h>
 
 #include <net/if.h>
+#include <net/if_mib.h>
 #include <net/route.h>
 #include <netinet/in.h>
 
@@ -38,8 +42,6 @@
 #include <fcntl.h>
 #include <signal.h>
 #include <err.h>
-#include <event.h>
-#include <util.h>
 #include <unistd.h>
 #include <syslog.h>
 #include <stdarg.h>
@@ -52,29 +54,33 @@
 int	 opts = 0;
 int	 opt_debug = 0;
 int	 opt_inhibit = 0;
-char	*configfile = "/etc/ifstated.conf";
-struct event	rt_msg_ev, sighup_ev, startup_ev, sigchld_ev;
+char	*configfile = "%%PREFIX%%/etc/ifstated.conf";
+int      kq;
+struct kevent   kev;
 
-void	startup_handler(int, short, void *);
-void	sighup_handler(int, short, void *);
+void	startup_handler(void);
+void	sighup_handler(void);
 int	load_config(void);
 void	sigchld_handler(int, short, void *);
-void	rt_msg_handler(int, short, void *);
-void	external_handler(int, short, void *);
-void	external_async_exec(struct ifsd_external *);
+void	rt_msg_handler(int fd);
+void	external_exec(struct ifsd_external *, int);
 void	check_external_status(struct ifsd_state *);
 void	external_evtimer_setup(struct ifsd_state *, int);
-int	scan_ifstate(int, int, struct ifsd_state *);
+void	scan_ifstate(int, int, int);
+int	scan_ifstate_single(int, int, struct ifsd_state *);
 void	fetch_state(void);
 void	usage(void);
 void	adjust_expressions(struct ifsd_expression_list *, int);
+void	adjust_external_expressions(struct ifsd_state *);
 void	eval_state(struct ifsd_state *);
-void	state_change(void);
+int	state_change(void);
 void	do_action(struct ifsd_action *);
 void	remove_action(struct ifsd_action *, struct ifsd_state *);
 void	remove_expression(struct ifsd_expression *, struct ifsd_state *);
 void	log_init(int);
 void	logit(int, const char *, ...);
+int     get_ifcount(void);
+int     get_ifmib_general(int, struct ifmibdata *);
 
 void
 usage(void)
@@ -89,7 +95,7 @@
 int
 main(int argc, char *argv[])
 {
-	struct timeval tv;
+	struct timespec ts;
 	int ch;
 
 	while ((ch = getopt(argc, argv, "dD:f:hniv")) != -1) {
@@ -132,55 +138,85 @@
 	}
 
 	if (!opt_debug) {
-		daemon(0, 0);
+		daemon(1, 0);
 		setproctitle(NULL);
 	}
 
-	event_init();
+	kq = kqueue();
+
 	log_init(opt_debug);
 
-	signal_set(&sigchld_ev, SIGCHLD, sigchld_handler, &sigchld_ev);
-	signal_add(&sigchld_ev, NULL);
+	ts.tv_sec = 0;
+	ts.tv_nsec = 0;
+
+	EV_SET(&kev, SIGCHLD, EVFILT_SIGNAL, EV_ADD, 0, 0, (void *)sigchld_handler);
+	kevent(kq, &kev, 1, NULL, 0, &ts);
 
 	/* Loading the config needs to happen in the event loop */
-	tv.tv_usec = 0;
-	tv.tv_sec = 0;
-	evtimer_set(&startup_ev, startup_handler, &startup_ev);
-	evtimer_add(&startup_ev, &tv);
 
-	event_loop(0);
+	EV_SET(&kev, IFSD_EVTIMER_STARTUP, EVFILT_TIMER, EV_ADD|EV_ONESHOT, 0, 0, (void *)startup_handler);
+	kevent(kq, &kev, 1, NULL, 0, &ts);
+
+	/* event loop */
+	for(;;)
+	  {
+	    /* wait indefinitely for an event */
+	    kevent(kq, NULL, 0, &kev, 1, NULL);
+
+	    void (*handler)(void);
+	    void (*rt_handler)(int);
+	    if (kev.filter == EVFILT_READ)
+	      {
+		rt_handler = kev.udata;
+		rt_handler(kev.ident);
+	      }
+	    else if ((kev.filter == EVFILT_TIMER) && (kev.ident == IFSD_EVTIMER_EXTERNAL))
+	      {
+		external_exec((struct ifsd_external *)kev.udata,1);
+	      }
+	    else
+	      {
+		handler = kev.udata;
+		handler();
+	      }
+	  }
+
+	/* NOTREACHED */
 	exit(0);
 }
 
 void
-startup_handler(int fd, short event, void *arg)
+startup_handler()
 {
 	int rt_fd;
+	struct timespec ts;
+
+	if ((rt_fd = socket(PF_ROUTE, SOCK_RAW, 0)) < 0)
+		err(1, "no routing socket");
 
 	if (load_config() != 0) {
-		logit(IFSD_LOG_NORMAL, "unable to load config");
+		logit(IFSD_LOG_QUIET, "unable to load config");
 		exit(1);
 	}
 
-	if ((rt_fd = socket(PF_ROUTE, SOCK_RAW, 0)) < 0)
-		err(1, "no routing socket");
+	ts.tv_sec = 0;
+	ts.tv_nsec = 0;
 
-	event_set(&rt_msg_ev, rt_fd, EV_READ|EV_PERSIST,
-	    rt_msg_handler, &rt_msg_ev);
-	event_add(&rt_msg_ev, NULL);
+	EV_SET(&kev, rt_fd, EVFILT_READ, EV_ADD, 0, 0, (void *)rt_msg_handler);
+	kevent(kq, &kev, 1, NULL, 0, &ts);
 
-	signal_set(&sighup_ev, SIGHUP, sighup_handler, &sighup_ev);
-	signal_add(&sighup_ev, NULL);
+	EV_SET(&kev, SIGHUP, EVFILT_SIGNAL, EV_ADD, 0, 0, (void *)sighup_handler);
+	kevent(kq, &kev, 1, NULL, 0, &ts);
 
 	logit(IFSD_LOG_NORMAL, "started");
 }
 
 void
-sighup_handler(int fd, short event, void *arg)
+sighup_handler()
 {
 	logit(IFSD_LOG_NORMAL, "reloading config");
 	if (load_config() != 0)
-		logit(IFSD_LOG_NORMAL, "unable to reload config");
+		logit(IFSD_LOG_QUIET, "unable to reload config");
 }
 
 int
@@ -193,6 +229,8 @@
 	conf = newconf;
 	conf->always.entered = time(NULL);
 	fetch_state();
+	external_evtimer_setup(&conf->always, IFSD_EVTIMER_ADD);
+	adjust_external_expressions(&conf->always);
 	eval_state(&conf->always);
 	if (conf->curstate != NULL) {
 		logit(IFSD_LOG_NORMAL,
@@ -200,14 +238,14 @@
 		conf->curstate->entered = time(NULL);
 		conf->nextstate = conf->curstate;
 		conf->curstate = NULL;
-		eval_state(conf->nextstate);
+		while (state_change())
+			do_action(conf->curstate->always);
 	}
-	external_evtimer_setup(&conf->always, IFSD_EVTIMER_ADD);
 	return (0);
 }
 
 void
-rt_msg_handler(int fd, short event, void *arg)
+rt_msg_handler(int fd)
 {
 	char msg[2048];
 	struct rt_msghdr *rtm = (struct rt_msghdr *)&msg;
@@ -227,13 +265,7 @@
 		return;
 
 	memcpy(&ifm, rtm, sizeof(ifm));
-
-	if (scan_ifstate(ifm.ifm_index, ifm.ifm_data.ifi_link_state,
-	    &conf->always))
-		eval_state(&conf->always);
-	if ((conf->curstate != NULL) && scan_ifstate(ifm.ifm_index,
-	    ifm.ifm_data.ifi_link_state, conf->curstate))
-		eval_state(conf->curstate);
+	scan_ifstate(ifm.ifm_index, ifm.ifm_data.ifi_link_state, 1);
 }
 
 void
@@ -245,32 +277,18 @@
 }
 
 void
-external_handler(int fd, short event, void *arg)
-{
-	struct ifsd_external *external = (struct ifsd_external *)arg;
-	struct timeval tv;
-
-	/* re-schedule */
-	tv.tv_usec = 0;
-	tv.tv_sec = external->frequency;
-	evtimer_set(&external->ev, external_handler, external);
-	evtimer_add(&external->ev, &tv);
-
-	/* execute */
-	external_async_exec(external);
-}
-
-void
-external_async_exec(struct ifsd_external *external)
+external_exec(struct ifsd_external *external, int async)
 {
 	char *argp[] = {"sh", "-c", NULL, NULL};
 	pid_t pid;
+	int s;
 
 	if (external->pid > 0) {
 		logit(IFSD_LOG_NORMAL,
 		    "previous command %s [%d] still running, killing it",
 		    external->command, external->pid);
 		kill(external->pid, SIGKILL);
+		waitpid(external->pid, &s, 0);
 		external->pid = 0;
 	}
 
@@ -286,16 +304,41 @@
 	} else {
 		external->pid = pid;
 	}
+	if (!async) {
+		waitpid(external->pid, &s, 0);
+		external->pid = 0;
+		if (WIFEXITED(s))
+			external->prevstatus = WEXITSTATUS(s);
+	}
 }
 
 void
-check_external_status(struct ifsd_state *state)
+adjust_external_expressions(struct ifsd_state *state)
 {
-	struct ifsd_external *external, *end = NULL;
+	struct ifsd_external *external;
 	struct ifsd_expression_list expressions;
-	int status, s, changed = 0;
 
 	TAILQ_INIT(&expressions);
+	TAILQ_FOREACH(external, &state->external_tests, entries) {
+		struct ifsd_expression *expression;
+
+		if (external->prevstatus == -1)
+			continue;
+
+		TAILQ_FOREACH(expression, &external->expressions, entries) {
+			TAILQ_INSERT_TAIL(&expressions,
+			    expression, eval);
+			expression->truth = !external->prevstatus;
+		}
+		adjust_expressions(&expressions, conf->maxdepth);
+	}
+}
+
+void
+check_external_status(struct ifsd_state *state)
+{
+	struct ifsd_external *external, *end = NULL;
+	int status, s, changed = 0;
 
 	/* Do this manually; change ordering so the oldest is first */
 	external = TAILQ_FIRST(&state->external_tests);
@@ -323,29 +366,18 @@
 
 		if (external->prevstatus != status &&
 		    (external->prevstatus != -1 || !opt_inhibit)) {
-			struct ifsd_expression *expression;
-
 			changed = 1;
-			TAILQ_FOREACH(expression,
-			    &external->expressions, entries) {
-				TAILQ_INSERT_TAIL(&expressions,
-				    expression, eval);
-				if (status == 0)
-					expression->truth = 1;
-				else
-					expression->truth = 0;
-			}
+			external->prevstatus = status;
 		}
 		external->lastexec = time(NULL);
 		TAILQ_REMOVE(&state->external_tests, external, entries);
 		TAILQ_INSERT_TAIL(&state->external_tests, external, entries);
-		external->prevstatus = status;
 loop:
 		external = newexternal;
 	}
 
 	if (changed) {
-		adjust_expressions(&expressions, conf->maxdepth);
+		adjust_external_expressions(state);
 		eval_state(state);
 	}
 }
@@ -354,23 +386,26 @@
 external_evtimer_setup(struct ifsd_state *state, int action)
 {
 	struct ifsd_external *external;
+	struct timespec ts;
+	int s;
+	int freq;
+
+	ts.tv_nsec = 0;
+	ts.tv_sec = 0;
 
 	if (state != NULL) {
 		switch (action) {
 		case IFSD_EVTIMER_ADD:
 			TAILQ_FOREACH(external,
 			    &state->external_tests, entries) {
-				struct timeval tv;
 
 				/* run it once right away */
-				external_async_exec(external);
+				external_exec(external, 0);
 
 				/* schedule it for later */
-				tv.tv_usec = 0;
-				tv.tv_sec = external->frequency;
-				evtimer_set(&external->ev, external_handler,
-				    external);
-				evtimer_add(&external->ev, &tv);
+				freq = (external->frequency * 1000);
+				EV_SET(&kev, IFSD_EVTIMER_EXTERNAL, EVFILT_TIMER, EV_ADD, 0, freq, (void *)external);
+				kevent(kq, &kev, 1, NULL, 0, &ts);
 			}
 			break;
 		case IFSD_EVTIMER_DEL:
@@ -378,9 +413,12 @@
 			    &state->external_tests, entries) {
 				if (external->pid > 0) {
 					kill(external->pid, SIGKILL);
+					waitpid(external->pid, &s, 0);
 					external->pid = 0;
 				}
-				evtimer_del(&external->ev);
+				freq = (external->frequency * 1000);
+				EV_SET(&kev, IFSD_EVTIMER_EXTERNAL, EVFILT_TIMER, EV_DELETE, 0, freq, (void *)external);
+				kevent(kq, &kev, 1, NULL, 0, &ts);
 			}
 			break;
 		}
@@ -388,7 +426,7 @@
 }
 
 int
-scan_ifstate(int ifindex, int s, struct ifsd_state *state)
+scan_ifstate_single(int ifindex, int s, struct ifsd_state *state)
 {
 	struct ifsd_ifstate *ifstate;
 	struct ifsd_expression_list expressions;
@@ -403,10 +441,7 @@
 				struct ifsd_expression *expression;
 				int truth;
 
-				if (ifstate->ifstate == s)
-					truth = 1;
-				else
-					truth = 0;
+				truth = (ifstate->ifstate == s);
 
 				TAILQ_FOREACH(expression,
 				    &ifstate->expressions, entries) {
@@ -425,6 +460,24 @@
 	return (changed);
 }
 
+void
+scan_ifstate(int ifindex, int s, int do_eval)
+{
+	struct ifsd_state *state;
+	int cur_eval = 0;
+
+	if (scan_ifstate_single(ifindex, s, &conf->always) && do_eval)
+		eval_state(&conf->always);
+	TAILQ_FOREACH(state, &conf->states, entries) {
+		if (scan_ifstate_single(ifindex, s, state) &&
+		    (do_eval && state == conf->curstate))
+			cur_eval = 1;
+	}
+	/* execute actions _after_ all expressions have been adjusted */
+	if (cur_eval)
+		eval_state(conf->curstate);
+}
+
 /*
  * Do a bottom-up ajustment of the expression tree's truth value,
  * level-by-level to ensure that each expression's subexpressions have been
@@ -444,24 +497,15 @@
 
 			switch (expression->type) {
 			case IFSD_OPER_AND:
-				if (expression->left->truth &&
-				    expression->right->truth)
-					expression->truth = 1;
-				else
-					expression->truth = 0;
+				expression->truth = expression->left->truth &&
+				    expression->right->truth;
 				break;
 			case IFSD_OPER_OR:
-				if (expression->left->truth ||
-				    expression->right->truth)
-					expression->truth = 1;
-				else
-					expression->truth = 0;
+				expression->truth = expression->left->truth ||
+				    expression->right->truth;
 				break;
 			case IFSD_OPER_NOT:
-				if (expression->right->truth)
-					expression->truth = 0;
-				else
-					expression->truth = 1;
+				expression->truth = !expression->right->truth;
 				break;
 			default:
 				break;
@@ -490,21 +534,21 @@
 	if (external == NULL || external->lastexec >= state->entered ||
 	    external->lastexec == 0) {
 		do_action(state->always);
-		state_change();
+		while (state_change())
+			do_action(conf->curstate->always);
 	}
 }
 
 /*
  *If a previous action included a state change, process it.
  */
-void
+int
 state_change(void)
 {
 	if (conf->nextstate != NULL && conf->curstate != conf->nextstate) {
 		logit(IFSD_LOG_NORMAL, "changing state to %s",
 		    conf->nextstate->name);
 		if (conf->curstate != NULL) {
-			evtimer_del(&conf->curstate->ev);
 			external_evtimer_setup(conf->curstate,
 			    IFSD_EVTIMER_DEL);
 		}
@@ -512,10 +556,11 @@
 		conf->nextstate = NULL;
 		conf->curstate->entered = time(NULL);
 		external_evtimer_setup(conf->curstate, IFSD_EVTIMER_ADD);
-		fetch_state();
+		adjust_external_expressions(conf->curstate);
 		do_action(conf->curstate->init);
-		fetch_state();
+		return (1);
 	}
+	return (0);
 }
 
 /*
@@ -550,6 +595,48 @@
 	}
 }
 
+
+int
+get_ifcount(void)
+{
+  int name[5], count;
+  size_t len;
+
+  name[0] = CTL_NET;
+  name[1] = PF_LINK;
+  name[2] = NETLINK_GENERIC;
+  name[3] = IFMIB_SYSTEM;
+  name[4] = IFMIB_IFCOUNT;
+
+  len = sizeof(int);
+
+  if (sysctl(name, 5, &count, &len, NULL, 0) != -1)
+    return(count);
+  else
+    return(-1);
+}
+
+
+int
+get_ifmib_general(int row, struct ifmibdata *ifmd)
+{
+  int name[6];
+  size_t len;
+
+  name[0] = CTL_NET;
+  name[1] = PF_LINK;
+  name[2] = NETLINK_GENERIC;
+  name[3] = IFMIB_IFDATA;
+  name[4] = row;
+  name[5] = IFDATA_GENERAL;
+
+  len = sizeof(*ifmd);
+
+  return sysctl(name, 6, ifmd, &len, (void *)0, 0);
+}
+
+
+
 /*
  * Fetch the current link states.
  */
@@ -559,29 +646,31 @@
 	struct ifaddrs *ifap, *ifa;
 	char *oname = NULL;
 	int sock = socket(AF_INET, SOCK_DGRAM, 0);
+	int ifcount = get_ifcount();
+	int i;
 
-	if (getifaddrs(&ifap) != 0)
+	if (getifaddrs(&ifap) != 0 || ifcount == -1)
 		err(1, "getifaddrs");
 
 	for (ifa = ifap; ifa; ifa = ifa->ifa_next) {
-		struct ifreq ifr;
-		struct if_data  ifrdat;
+	        struct ifmibdata ifmd;
+		struct if_data  ifdata;
 
 		if (oname && !strcmp(oname, ifa->ifa_name))
 			continue;
 		oname = ifa->ifa_name;
 
-		strlcpy(ifr.ifr_name, ifa->ifa_name, sizeof(ifr.ifr_name));
-		ifr.ifr_data = (caddr_t)&ifrdat;
+		for (i = 1; i <= ifcount; i++)
+		  {
+		    get_ifmib_general(i, &ifmd);
+		    if (! strcmp(ifmd.ifmd_name, oname))
+		      break;
+		  }
 
-		if (ioctl(sock, SIOCGIFDATA, (caddr_t)&ifr) == -1)
-			continue;
+		ifdata = ifmd.ifmd_data;
 
 		scan_ifstate(if_nametoindex(ifa->ifa_name),
-		    ifrdat.ifi_link_state, &conf->always);
-		if (conf->curstate != NULL)
-			scan_ifstate(if_nametoindex(ifa->ifa_name),
-			    ifrdat.ifi_link_state, conf->curstate);
+		    ifdata.ifi_link_state, 0);
 	}
 	freeifaddrs(ifap);
 	close(sock);
@@ -663,7 +752,6 @@
 			TAILQ_REMOVE(&state->external_tests,
 			    expression->u.external, entries);
 			free(expression->u.external->command);
-			event_del(&expression->u.external->ev);
 			free(expression->u.external);
 		}
 		break;
@@ -692,7 +780,7 @@
 	va_list	 ap;
 	char	*nfmt;
 
-	if (conf == NULL || level > conf->loglevel)
+	if (conf != NULL && level > conf->loglevel)
 		return;
 
 	va_start(ap, fmt);
@@ -710,3 +798,4 @@
 
 	va_end(ap);
 }
+

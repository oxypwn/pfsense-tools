/* Based on code from http://www.monkeys.com/freeware/kqueue-echo.c */
/* echo.c - Simple `echo' server for N clients written using kqueue/kevent.  */

/* Modifications and adaption by Ermal Luçi */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/event.h>
#include <sys/time.h>
#include <syslog.h>

typedef struct in_addr in_addr;
typedef struct sockaddr_in sockaddr_in;
typedef struct servent servent;
typedef struct timespec timespec;

typedef void (action) (register struct kevent const *const kep);

/* Event Control Block (ecb) */
typedef struct {
    action	*do_read;
    char	*buf;
    unsigned	bufsiz;
} ecb;

static char const *pname;
static struct kevent *ke_vec = NULL;
static unsigned ke_vec_alloc = 0;
static unsigned ke_vec_used = 0;
static char const protoname[] = "tcp";
static char const servname[] = "echo";

/* XXX: make it read this from a file. */
static struct actions {
	char *command;
	char *action;
	int   nargs;
	char *descr;
	char *cmd;
} actions[] = { 
	{"reload", "filter", 0, "Reloading filter...\n", 
		"/usr/bin/nice -n 20 /usr/local/bin/php /etc/rc.filter_configure_sync" },
	{"relconfigure", "newwanip", 1, "rc.newwanip starting\n",
		"/usr/local/bin/php /etc/rc.newwanip" },
	{"restart", "webgui", 0,"webConfigurator restart in progress\n",
		"/usr/local/bin/php /etc/rc.restart_webgui" },
	{"linkup", "interface", 1, "rc.linkup starting", "/etc/rc.linkup.sh" },
	{"reload", "all", 0, "Reloading everything...\n", 
		"/usr/bin/nice -n 20 /usr/local/bin/php /etc/rc.reload_all" },
	{"reload", "interfaces", 0, "Reloading interfaces...\n",
		"/usr/local/bin/php /etc/rc.reload_interfaces" },
	{"update", "dyndns", 0, "Updating dyndns...\n",
		"/usr/bin/nice -n 20 /usr/local/bin/php /etc/rc.dyndns.update" },
	{"reload", "interface", 1, "Reconfiguring interface...\n",
		"/usr/local/bin/php /etc/interfaces_wan_configure" },
	{"start", "sshd", 0, "Starting SSH daemon...\n",
		"/etc/sshd" },
	{"start", "ntpd", 0, "Starting ntpd\n", 
		"/usr/local/sbin/ntpd -s -f /var/etc/ntpd.conf" },
	{ NULL, NULL, 0, NULL, NULL },
};

static void
vlog (char const *const fmt, va_list ap)
{
  vfprintf (stderr, fmt, ap);
  fputc ('\n', stderr);
}

static void fatal (char const *const fmt, ...)
    __attribute__ ((__noreturn__));

static void
fatal (char const *const fmt, ...)
{
  va_list ap;

  va_start (ap, fmt);
  fprintf (stderr, "%s: ", pname);
  vlog (fmt, ap);
  va_end (ap);
  exit (1);
}

static void
error (char const *const fmt, ...)
{
  va_list ap;

  va_start (ap, fmt);
  fprintf (stderr, "%s: ", pname);
  vlog (fmt, ap);
  va_end (ap);
}

static void
usage (void)
{
  fatal ("Usage `%s [-p port]'", pname);
}

static int
all_digits (register char const *const s)
{
  register char const *r;

  for (r = s; *r; r++)
    if (!isdigit (*r))
      return 0;
  return 1;
}

static void *
xmalloc (register unsigned long const size)
{
  register void *const result = malloc (size);

  if (!result)
    fatal ("Memory exhausted");
  return result;
}

static void *
xrealloc (register void *const ptr, register unsigned long const size)
{
  register void *const result = realloc (ptr, size);

  if (!result)
    fatal ("Memory exhausted");
  return result;
}

static void
ke_change (register int const ident,
	   register int const filter,
	   register int const flags,
	   register void *const udata)
{
  enum { initial_alloc = 64 };
  register struct kevent *kep;

  if (!ke_vec_alloc)
    {
      ke_vec_alloc = initial_alloc;
      ke_vec = (struct kevent *) xmalloc(ke_vec_alloc * sizeof (struct kevent));
    }
  else if (ke_vec_used == ke_vec_alloc)
    {
      ke_vec_alloc <<= 1;
      ke_vec =
	(struct kevent *) xrealloc (ke_vec,
				    ke_vec_alloc * sizeof (struct kevent));
    }

  kep = &ke_vec[ke_vec_used++];

  kep->ident = ident;
  kep->filter = filter;
  kep->flags = flags;
  kep->fflags = 0;
  kep->data = 0;
  kep->udata = udata;
}

static void
do_read (register struct kevent const *const kep)
{
  enum { bufsize = 2048 };
  char buf[bufsize];
  register int n;
  /* register ecb *const ecbp = (ecb *) kep->udata; */
  char **ap, *argv[bufsize], **pa, *varg[bufsize];
  char *p;
  pid_t pid;
  int i, found = 0;

  if ((n = read (kep->ident, buf, bufsize)) == -1)
    {
      error ("Error reading socket: %s", strerror (errno));
      close (kep->ident);
      free (kep->udata);
    }
  else if (n == 0)
    {
      error ("EOF reading socket");
      close (kep->ident);
      free (kep->udata);
    }
	buf[n - 1] = '\0'; /* remove stray \n */
	for (i = 0; i < n - 1; i++)
		if (!isalpha(buf[i]) && !isspace(buf[i]) && !isdigit(buf[i])) {
			write(kep->ident, "only alphanumeric chars allowd", 30);
			return;
		}

    p = buf; /* blah, compiler workaround */

  
  for (ap = argv; (*ap = strsep(&p, " \t")) != NULL;)
	if (**ap != '\0')
             if (++ap >= &argv[bufsize])
             	break;

  /* ke_change (kep->ident, EVFILT_READ, EV_DISABLE, kep->udata); */
  for (i = 0; actions[i].command != NULL; i++) {
	if (actions[i].action && argv[1] == NULL) {
		write(kep->ident, "unknown action\n", 15); /* just in case */
		return;
		/* goto exit; */
	}
	if (!strncmp(argv[0], actions[i].command, strlen(actions[i].command)) &&
		!strncmp(argv[1], actions[i].action, strlen(actions[i].action))) {
			/* XXX: Maybe add support for multiple arguments?! */
			if (actions[i].nargs && argv[2] == NULL) {
				write(kep->ident, "command needs more parameters\n", 30);
				return;
				/* goto exit; */
			}
			if (actions[i].nargs && argv[3] != NULL) {
                                write(kep->ident, "too many parameters\n", 20);
                                return;
                                /* goto exit; */
                        }

			found = 1;
			p = strdup(actions[i].cmd);
			if ((pid = fork()) == 0) {
				for (pa = varg; (*pa = strsep(&p, " \t")) != NULL;)
        				if (**pa != '\0') {
             					if (++pa >= &varg[bufsize])
                					break;
					}
				if (actions[i].nargs)
					varg[i] = argv[2];

				if (execv(varg[0], varg) < 0) 
					syslog(LOG_NOTICE, "failed executing command\n");
			} else {
				free(p);
				syslog(LOG_NOTICE, actions[i].descr);
				write(kep->ident, actions[i].descr, strlen(actions[i].descr));
				break;
			}
	} 
}
	if (!found)
		write(kep->ident, "action not found\n", 18);
/*
exit:
	if (kep->udata)
		free(kep->udata);
*/
}

static void
do_accept (register struct kevent const *const kep)
{
  auto sockaddr_in sin;
  auto socklen_t sinsiz;
  register int s;
  register ecb *ecbp;

  if ((s = accept (kep->ident, (struct sockaddr *)&sin, &sinsiz)) == -1)
    fatal ("Error in accept(): %s", strerror (errno));

  ecbp = (ecb *) xmalloc (sizeof (ecb));
  ecbp->do_read = do_read;
  ecbp->buf = NULL;
  ecbp->bufsiz = 0;

  ke_change (s, EVFILT_READ, EV_ADD | EV_ENABLE, ecbp);
}

static void event_loop (register int const kq)
    __attribute__ ((__noreturn__));

static void
event_loop (register int const kq)
{
  for (;;)
    {
      register int n;
      register struct kevent const *kep;

      n = kevent (kq, ke_vec, ke_vec_used, ke_vec, ke_vec_alloc, NULL);
      ke_vec_used = 0;  /* Already processed all changes.  */

      if (n == -1)
        fatal ("Error in kevent(): %s", strerror (errno));
      if (n == 0)
        fatal ("No events received!");

      for (kep = ke_vec; kep < &ke_vec[n]; kep++)
        {
          register ecb const *const ecbp = (ecb *) kep->udata;
    
	  if (kep->filter == EVFILT_READ)
	    (*ecbp->do_read) (kep);
        }
    }
}

int
main (register int const argc, register char *const argv[])
{
  auto in_addr listen_addr;
  register int optch;
  auto int one = 1;
  register int portno = 0;
  register int option_errors = 0;
  register int server_sock;
  auto sockaddr_in sin;
  register servent *servp;
  auto ecb listen_ecb;
  register int kq;

  pname = strrchr (argv[0], '/');
  pname = pname ? pname+1 : argv[0];

  listen_addr.s_addr = htonl (INADDR_ANY);  /* Default.  */

  while ((optch = getopt (argc, argv, "p:")) != EOF)
    {
      switch (optch)
        {
        case 'p':
          if (strlen (optarg) == 0 || !all_digits (optarg))
            {
              error ("Invalid argument for -p option: %s", optarg);
              option_errors++;
            }
          portno = atoi (optarg);
          if (portno == 0 || portno >= (1u << 16))
            {
              error ("Invalid argument for -p option: %s", optarg);
              option_errors++;
            }
          break;
	default:
          error ("Invalid option: -%c", optch);
          option_errors++;
        }
    }

  if (option_errors || optind != argc)
    usage ();

  if (daemon(0,0) < 0)
	perror("daemon failed");

  if (portno == 0)
    {
      if ((servp = getservbyname (servname, protoname)) == NULL)
        fatal ("Error getting port number for service `%s': %s",
               servname, strerror (errno));
      portno = ntohs (servp->s_port);
    }

  if ((server_sock = socket (PF_INET, SOCK_STREAM, 0)) == -1)
    fatal ("Error creating socket: %s", strerror (errno));

  if (setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &one, sizeof one) == -1)
    fatal ("Error setting SO_REUSEADDR for socket: %s", strerror (errno));

  memset (&sin, 0, sizeof sin);
  sin.sin_family = AF_INET;
  sin.sin_addr = listen_addr;
  sin.sin_port = htons (portno);

  if (bind (server_sock, (const struct sockaddr *)&sin, sizeof sin) == -1)
    fatal ("Error binding socket: %s", strerror (errno));

  if (listen (server_sock, 20) == -1)
    fatal ("Error listening to socket: %s", strerror (errno));

  if ((kq = kqueue ()) == -1)
    fatal ("Error creating kqueue: %s", strerror (errno));

  listen_ecb.do_read = do_accept;
  listen_ecb.buf = NULL;
  listen_ecb.buf = 0;

  ke_change (server_sock, EVFILT_READ, EV_ADD | EV_ENABLE, &listen_ecb);

  event_loop (kq);
}

#if 0 /* XXX: FIXME Parser code to be finished. */
static void
parse_config()
{

	if (lineno == 0) {
		printf("no actions registered exiting...\n");
		exit(0);
	}
	
	actions = malloc(lineno);	
	if (actions == NULL)
		err(2, "could not allocate memory for actions\n");

	for (ap = argv; (*ap = strsep(&p, " \t")) != NULL;)
        if (**ap != '\0')
             if (++ap >= &argv[bufsize])
                break;

}

static void 
read_config() 
{
	int fd;
	int c;
	int i = 0;
	char line[4086];
	char *linecpy = NULL;

	fd = open("/etc/test.conf", "r");
	if (fd < 0)
		perror("open config file\n");

again:
	while ((c =getc()) != '\n' && c != EOF) }
		if (c = '\\')
			continue;
		if (c = '\t')
			c = ' ';
		if (i >= 4086) {
			bzero(line, sizeof(line));
			i = 0;
			printf("igonring line %d which has length more than MAX of 4086\n");
			continue;
		}
		line[i] = c;
		i++;
	}
	if (c != EOF) {
		line[i++] = '\0';
		linecpy = malloc(strlen(line));
		if (linecpy != NULL) 
			err(1, "could nor allocate memory");

		memcpy(linecpy, line, strlen(line)); 
		config[lineno] = linecpy;
		lineno++;
		i = 0;
		if (lineno < 4086) {
			goto again;
		else
			printf("Ignoring other config lines. Reached limit.\n");
	}
}
#endif

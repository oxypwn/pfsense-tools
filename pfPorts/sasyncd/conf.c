#include <stdlib.h>
#ifndef lint
#ifdef __unused
__unused
#endif
static char const 
yyrcsid[] = "$FreeBSD: src/usr.bin/yacc/skeleton.c,v 1.37 2003/02/12 18:03:55 davidc Exp $";
#endif
#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYLEX yylex()
#define YYEMPTY -1
#define yyclearin (yychar=(YYEMPTY))
#define yyerrok (yyerrflag=0)
#define YYRECOVERING() (yyerrflag!=0)
#if defined(__cplusplus) || __STDC__
static int yygrowstack(void);
#else
static int yygrowstack();
#endif
#define YYPREFIX "yy"
#line 30 "conf.y"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pwd.h>

#include "sasyncd.h"
#include "net.h"

/* Global configuration context.  */
struct cfgstate cfgstate;

/* Local variables */
int     conflen = 0;
char    *confbuf, *confptr;

int     yyparse(void);
int     yylex(void);
void    yyerror(const char *);
#line 55 "conf.y"
typedef union {
        char        *string;
        int         val;
} YYSTYPE;
#line 53 "conf.c"
#define YYERRCODE 256
#define MODE 257
#define CARP 258
#define INTERFACE 259
#define INTERVAL 260
#define LISTEN 261
#define ON 262
#define PORT 263
#define PEER 264
#define SHAREDKEY 265
#define Y_SLAVE 266
#define Y_MASTER 267
#define INET 268
#define INET6 269
#define FLUSHMODE 270
#define STARTUP 271
#define NEVER 272
#define SYNC 273
#define SKIPSLAVE 274
#define STRING 275
#define VALUE 276
const short yylhs[] = {                                        -1,
    0,    0,    1,    1,    1,    2,    2,    4,    4,    7,
    7,    3,    3,    5,    5,    5,    6,    6,    6,    6,
    6,    6,
};
const short yylen[] = {                                         2,
    0,    2,    0,    1,    1,    0,    2,    1,    1,    1,
    1,    0,    2,    1,    1,    1,    4,    2,    2,    5,
    2,    2,
};
const short yydefred[] = {                                      1,
    0,    0,    0,    0,    0,    0,    0,    2,    9,    8,
   10,   11,   21,    0,    0,   19,   22,   14,   15,   16,
   18,    0,    0,    0,   17,    4,    5,    0,   13,    0,
   20,    7,
};
const short yydgoto[] = {                                       1,
   28,   31,   25,   12,   21,    8,   13,
};
const short yysindex[] = {                                      0,
 -255, -262, -259, -249, -253, -252, -254,    0,    0,    0,
    0,    0,    0, -251, -250,    0,    0,    0,    0,    0,
    0, -246, -261, -260,    0,    0,    0, -243,    0, -248,
    0,    0,
};
const short yyrindex[] = {                                      0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   11,    1,    0,    0,    0,    0,   21,    0,    0,
    0,    0,
};
const short yygindex[] = {                                      0,
    0,    0,    0,    0,    0,    0,    0,
};
#define YYTABLESIZE 291
const short yytable[] = {                                      14,
    3,    2,    3,    9,   10,    4,   26,   27,    5,    6,
   12,   11,   15,   24,    7,   29,   18,   19,   20,   30,
    6,   16,   17,   22,   23,    0,    0,   32,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    3,    3,    0,
    0,    3,    0,    3,    3,    3,    0,   12,   12,    0,
    3,   12,    0,    0,   12,   12,    0,    6,    6,    0,
   12,    6,    0,    0,    6,    6,    0,    0,    0,    0,
    6,
};
const short yycheck[] = {                                     259,
    0,  257,  258,  266,  267,  261,  268,  269,  264,  265,
    0,  274,  262,  260,  270,  276,  271,  272,  273,  263,
    0,  275,  275,  275,  275,   -1,   -1,  276,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,  257,  258,   -1,
   -1,  261,   -1,  263,  264,  265,   -1,  257,  258,   -1,
  270,  261,   -1,   -1,  264,  265,   -1,  257,  258,   -1,
  270,  261,   -1,   -1,  264,  265,   -1,   -1,   -1,   -1,
  270,
};
#define YYFINAL 1
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 276
#if YYDEBUG
const char * const yyname[] = {
"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"MODE","CARP","INTERFACE",
"INTERVAL","LISTEN","ON","PORT","PEER","SHAREDKEY","Y_SLAVE","Y_MASTER","INET",
"INET6","FLUSHMODE","STARTUP","NEVER","SYNC","SKIPSLAVE","STRING","VALUE",
};
const char * const yyrule[] = {
"$accept : settings",
"settings :",
"settings : settings setting",
"af :",
"af : INET",
"af : INET6",
"port :",
"port : PORT VALUE",
"mode : Y_MASTER",
"mode : Y_SLAVE",
"modes : SKIPSLAVE",
"modes : mode",
"interval :",
"interval : INTERVAL VALUE",
"flushmode : STARTUP",
"flushmode : NEVER",
"flushmode : SYNC",
"setting : CARP INTERFACE STRING interval",
"setting : FLUSHMODE flushmode",
"setting : PEER STRING",
"setting : LISTEN ON STRING af port",
"setting : MODE modes",
"setting : SHAREDKEY STRING",
};
#endif
#if YYDEBUG
#include <stdio.h>
#endif
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH 10000
#endif
#endif
#define YYINITSTACKSIZE 200
int yydebug;
int yynerrs;
int yyerrflag;
int yychar;
short *yyssp;
YYSTYPE *yyvsp;
YYSTYPE yyval;
YYSTYPE yylval;
short *yyss;
short *yysslim;
YYSTYPE *yyvs;
int yystacksize;
#line 183 "conf.y"
/* Program */

struct keyword {
        char *name;
        int   value;
};

static int
match_cmp(const void *a, const void *b)
{
        return strcmp(a, ((const struct keyword *)b)->name);
}

static int
match(char *token)
{
        /* Sorted */
        static const struct keyword keywords[] = {
                { "carp", CARP },
                { "flushmode", FLUSHMODE },
                { "inet", INET },
                { "inet6", INET6 },
                { "interface", INTERFACE },
                { "interval", INTERVAL },
                { "listen", LISTEN },
                { "master", Y_MASTER },
                { "mode", MODE },
                { "never", NEVER },
                { "on", ON },
                { "peer", PEER },
                { "port", PORT },
                { "sharedkey", SHAREDKEY },
                { "skipslave", SKIPSLAVE },
                { "slave", Y_SLAVE },
                { "startup", STARTUP },
                { "sync", SYNC },
        };
        const struct keyword *k;

        k = bsearch(token, keywords, sizeof keywords / sizeof keywords[0],
            sizeof keywords[0], match_cmp);

        return k ? k->value : STRING;
}

int
yylex(void) 
{
        char *p;
        int v;

        /* Locate next token */
        if (!confptr)
                confptr = confbuf;
        else {
                for (p = confptr; *p && p < confbuf + conflen; p++)
                        ;
                p++;
                if (!*p)
                        return 0;
                confptr = p;
        }

        /* Numerical token? */
        if (isdigit(*confptr)) {
                for (p = confptr; *p; p++)
                        if (*p == '.') /* IP-address, or bad input */
                                goto is_string;
                v = (int)strtol(confptr, (char **)NULL, 10);
                yylval.val = v;
                return VALUE;
        }

  is_string:
        v = match(confptr);
        if (v == STRING) {
                yylval.string = strdup(confptr);
                if (!yylval.string) {
                        log_err("yylex: strdup()");
                        exit(1);
                }
        }
        return v;
}

static int
conf_parse_file(char *cfgfile)
{
        struct stat        st;
        int                fd, r;
        char                *buf, *s, *d;
        struct passwd        *pw = getpwnam(SASYNCD_USER);

        if (stat(cfgfile, &st) != 0)
                goto bad;

        /* Valid file? */
        if ((st.st_uid && st.st_uid != pw->pw_uid) ||
            ((st.st_mode & S_IFMT) != S_IFREG) ||
            ((st.st_mode & (S_IRWXG | S_IRWXO)) != 0)) {
                log_msg(0, "configuration file has bad owner, type or mode"); 
                goto bad;
        }

        fd = open(cfgfile, O_RDONLY, 0);
        if (fd < 0)
                goto bad;

        conflen = st.st_size;
        buf = (char *)malloc(conflen + 1);
        if (!buf) {
                log_err("malloc(%d) failed", conflen + 1);
                close(fd);
                return 1;
        }

        if (read(fd, buf, conflen) != conflen) {
                log_err("read() failed");
                free(buf);
                close(fd);
                return 1;
        }
        close(fd);

        /* Prepare the buffer somewhat in the way of strsep() */
        buf[conflen] = (char)0;
        for (s = buf, d = s; *s && s < buf + conflen; s++) {
                if (isspace(*s) && isspace(*(s+1)))
                        continue;
                if (*s == '#') {
                        while (*s != '\n' && s < buf + conflen)
                                s++;
                        continue;
                }
                if (d == buf && isspace(*s))
                        continue;
                *d++ = *s;
        }
        *d = (char)0;
        for (s = buf; s <= d; s++)
                if (isspace(*s))
                        *s = (char)0;

        confbuf = buf;
        confptr = NULL;
        r = yyparse();
        free(buf);

        return r;

  bad:
        log_msg(0, "failed to open \"%s\"", cfgfile);
        return 1;
}

int
conf_init(int argc, char **argv)
{
        char        *cfgfile = 0;
        int         ch;

        memset(&cfgstate, 0, sizeof cfgstate);
        cfgstate.runstate = INIT;
        LIST_INIT(&cfgstate.peerlist);

        cfgstate.carp_check_interval = CARP_DEFAULT_INTERVAL;
        cfgstate.listen_port = SASYNCD_DEFAULT_PORT;

        while ((ch = getopt(argc, argv, "c:dv")) != -1) {
                switch (ch) {
                case 'c':
                        if (cfgfile)
                                return 2;
                        cfgfile = optarg;
                        break;
                case 'd':
                        cfgstate.debug++;
                        break;
                case 'v':
                        cfgstate.verboselevel++;
                        break;
                default:
                        return 2;
                }
        }
        argc -= optind;
        argv += optind;

        if (argc > 0)
                return 2;

        if (!cfgfile)
                cfgfile = SASYNCD_CFGFILE;

        if (conf_parse_file(cfgfile) == 0) {
                if (!cfgstate.sharedkey) {
                        fprintf(stderr, "config: "
                            "no shared key specified, cannot continue");
                        return 1;
                }
                return 0;
        }

        return 1;
}

void
yyerror(const char *s)
{
        fprintf(stderr, "config: %s\n", s);
}

#line 457 "conf.c"
/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack()
{
    int newsize, i;
    short *newss;
    YYSTYPE *newvs;

    if ((newsize = yystacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return -1;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;
    i = yyssp - yyss;
    newss = yyss ? (short *)realloc(yyss, newsize * sizeof *newss) :
      (short *)malloc(newsize * sizeof *newss);
    if (newss == NULL)
        return -1;
    yyss = newss;
    yyssp = newss + i;
    newvs = yyvs ? (YYSTYPE *)realloc(yyvs, newsize * sizeof *newvs) :
      (YYSTYPE *)malloc(newsize * sizeof *newvs);
    if (newvs == NULL)
        return -1;
    yyvs = newvs;
    yyvsp = newvs + i;
    yystacksize = newsize;
    yysslim = yyss + newsize - 1;
    return 0;
}

#define YYABORT goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR goto yyerrlab

#ifndef YYPARSE_PARAM
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG void
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG
#define YYPARSE_PARAM_DECL
#endif	/* ANSI-C/C++ */
#else	/* YYPARSE_PARAM */
#ifndef YYPARSE_PARAM_TYPE
#define YYPARSE_PARAM_TYPE void *
#endif
#if defined(__cplusplus) || __STDC__
#define YYPARSE_PARAM_ARG YYPARSE_PARAM_TYPE YYPARSE_PARAM
#define YYPARSE_PARAM_DECL
#else	/* ! ANSI-C/C++ */
#define YYPARSE_PARAM_ARG YYPARSE_PARAM
#define YYPARSE_PARAM_DECL YYPARSE_PARAM_TYPE YYPARSE_PARAM;
#endif	/* ANSI-C/C++ */
#endif	/* ! YYPARSE_PARAM */

int
yyparse (YYPARSE_PARAM_ARG)
    YYPARSE_PARAM_DECL
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")))
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = (-1);

    if (yyss == NULL && yygrowstack()) goto yyoverflow;
    yyssp = yyss;
    yyvsp = yyvs;
    *yyssp = yystate = 0;

yyloop:
    if ((yyn = yydefred[yystate])) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yyssp >= yysslim && yygrowstack())
        {
            goto yyoverflow;
        }
        *++yyssp = yystate = yytable[yyn];
        *++yyvsp = yylval;
        yychar = (-1);
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;
#if defined(lint) || defined(__GNUC__)
    goto yynewerror;
#endif
yynewerror:
    yyerror("syntax error");
#if defined(lint) || defined(__GNUC__)
    goto yyerrlab;
#endif
yyerrlab:
    ++yynerrs;
yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yyssp]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yyssp, yytable[yyn]);
#endif
                if (yyssp >= yysslim && yygrowstack())
                {
                    goto yyoverflow;
                }
                *++yyssp = yystate = yytable[yyn];
                *++yyvsp = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yyssp);
#endif
                if (yyssp <= yyss) goto yyabort;
                --yyssp;
                --yyvsp;
            }
        }
    }
    else
    {
        if (yychar == 0) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = (-1);
        goto yyloop;
    }
yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    yyval = yyvsp[1-yym];
    switch (yyn)
    {
case 3:
#line 74 "conf.y"
{ yyval.val = AF_UNSPEC; }
break;
case 4:
#line 75 "conf.y"
{ yyval.val = AF_INET; }
break;
case 5:
#line 76 "conf.y"
{ yyval.val = AF_INET6; }
break;
case 6:
#line 79 "conf.y"
{ yyval.val = SASYNCD_DEFAULT_PORT; }
break;
case 7:
#line 80 "conf.y"
{ yyval.val = yyvsp[0].val; }
break;
case 8:
#line 83 "conf.y"
{ yyval.val = MASTER; }
break;
case 9:
#line 84 "conf.y"
{ yyval.val = SLAVE; }
break;
case 10:
#line 88 "conf.y"
{
                        cfgstate.flags |= SKIP_LOCAL_SAS;
                        log_msg(2, "config: not syncing SA to peers");
                }
break;
case 11:
#line 93 "conf.y"
{
                        const char *m[] = CARPSTATES;
                        cfgstate.lockedstate = yyvsp[0].val;
                        log_msg(2, "config: mode set to %s", m[yyvsp[0].val]);
                }
break;
case 12:
#line 100 "conf.y"
{ yyval.val = CARP_DEFAULT_INTERVAL; }
break;
case 13:
#line 101 "conf.y"
{ yyval.val = yyvsp[0].val; }
break;
case 14:
#line 104 "conf.y"
{ yyval.val = FM_STARTUP; }
break;
case 15:
#line 105 "conf.y"
{ yyval.val = FM_NEVER; }
break;
case 16:
#line 106 "conf.y"
{ yyval.val = FM_SYNC; }
break;
case 17:
#line 110 "conf.y"
{
                        if (cfgstate.carp_ifname)
                                free(cfgstate.carp_ifname);
                        cfgstate.carp_ifname = yyvsp[-1].string;
                        cfgstate.carp_check_interval = yyvsp[0].val;
                        log_msg(2, "config: carp interface %s interval %d",
                            yyvsp[-1].string, yyvsp[0].val);
                }
break;
case 18:
#line 119 "conf.y"
{
                        const char *fm[] = { "STARTUP", "NEVER", "SYNC" };
                        cfgstate.flags |= yyvsp[0].val;
                        log_msg(2, "config: flush mode set to %s", fm[yyvsp[0].val]);
                }
break;
case 19:
#line 125 "conf.y"
{
                        struct syncpeer        *peer;
                        int                 dup = 0;

                        for (peer = LIST_FIRST(&cfgstate.peerlist); peer;
                             peer = LIST_NEXT(peer, link))
                                if (strcmp(yyvsp[0].string, peer->name) == 0) {
                                        dup++;
                                        break;
                                }
                        if (dup)
                                free(yyvsp[0].string);
                        else {
                                peer = (struct syncpeer *)calloc(1,
                                    sizeof *peer);
                                if (!peer) {
                                        log_err("config: calloc(1, %lu) "
                                            "failed", sizeof *peer);
                                        YYERROR;
                                }
                                peer->name = yyvsp[0].string;
                        }
                        LIST_INSERT_HEAD(&cfgstate.peerlist, peer, link);
                        log_msg(2, "config: add peer %s", peer->name);
                }
break;
case 20:
#line 151 "conf.y"
{
                        char pstr[20];

                        if (cfgstate.listen_on)
                                free(cfgstate.listen_on);
                        cfgstate.listen_on = yyvsp[-2].string;
                        cfgstate.listen_family = yyvsp[-1].val;
                        cfgstate.listen_port = yyvsp[0].val;
                        if (cfgstate.listen_port < 1 ||
                            cfgstate.listen_port > 65534) {
                                cfgstate.listen_port = SASYNCD_DEFAULT_PORT;
                                log_msg(0, "config: bad port, listen-port "
                                    "reset to %u", SASYNCD_DEFAULT_PORT);
                        }
                        if (yyvsp[0].val != SASYNCD_DEFAULT_PORT)
                                snprintf(pstr, sizeof pstr, "port %d",yyvsp[0].val);
                        log_msg(2, "config: listen on %s %s%s",
                            cfgstate.listen_on, yyvsp[-1].val == AF_INET6 ? "(IPv6) " :
                            (yyvsp[-1].val == AF_INET ? "(IPv4) " : ""),
                            yyvsp[0].val != SASYNCD_DEFAULT_PORT ? pstr : "");
                }
break;
case 22:
#line 174 "conf.y"
{
                        if (cfgstate.sharedkey)
                                free(cfgstate.sharedkey);
                        cfgstate.sharedkey = yyvsp[0].string;
                        log_msg(2, "config: shared key set");
                }
break;
#line 795 "conf.c"
    }
    yyssp -= yym;
    yystate = *yyssp;
    yyvsp -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yyssp = YYFINAL;
        *++yyvsp = yyval;
        if (yychar < 0)
        {
            if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
            if (yydebug)
            {
                yys = 0;
                if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
                if (!yys) yys = "illegal-symbol";
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == 0) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yyssp, yystate);
#endif
    if (yyssp >= yysslim && yygrowstack())
    {
        goto yyoverflow;
    }
    *++yyssp = yystate;
    *++yyvsp = yyval;
    goto yyloop;
yyoverflow:
    yyerror("yacc stack overflow");
yyabort:
    return (1);
yyaccept:
    return (0);
}

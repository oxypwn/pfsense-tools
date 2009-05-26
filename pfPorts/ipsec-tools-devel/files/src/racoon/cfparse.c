/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     PRIVSEP = 258,
     USER = 259,
     GROUP = 260,
     CHROOT = 261,
     PATH = 262,
     PATHTYPE = 263,
     INCLUDE = 264,
     PFKEY_BUFFER = 265,
     LOGGING = 266,
     LOGLEV = 267,
     PADDING = 268,
     PAD_RANDOMIZE = 269,
     PAD_RANDOMIZELEN = 270,
     PAD_MAXLEN = 271,
     PAD_STRICT = 272,
     PAD_EXCLTAIL = 273,
     LISTEN = 274,
     X_ISAKMP = 275,
     X_ISAKMP_NATT = 276,
     X_ADMIN = 277,
     STRICT_ADDRESS = 278,
     ADMINSOCK = 279,
     DISABLED = 280,
     LDAPCFG = 281,
     LDAP_HOST = 282,
     LDAP_PORT = 283,
     LDAP_PVER = 284,
     LDAP_BASE = 285,
     LDAP_BIND_DN = 286,
     LDAP_BIND_PW = 287,
     LDAP_SUBTREE = 288,
     LDAP_ATTR_USER = 289,
     LDAP_ATTR_ADDR = 290,
     LDAP_ATTR_MASK = 291,
     LDAP_ATTR_GROUP = 292,
     LDAP_ATTR_MEMBER = 293,
     RADCFG = 294,
     RAD_AUTH = 295,
     RAD_ACCT = 296,
     RAD_TIMEOUT = 297,
     RAD_RETRIES = 298,
     MODECFG = 299,
     CFG_NET4 = 300,
     CFG_MASK4 = 301,
     CFG_DNS4 = 302,
     CFG_NBNS4 = 303,
     CFG_DEFAULT_DOMAIN = 304,
     CFG_AUTH_SOURCE = 305,
     CFG_AUTH_GROUPS = 306,
     CFG_SYSTEM = 307,
     CFG_RADIUS = 308,
     CFG_PAM = 309,
     CFG_LDAP = 310,
     CFG_LOCAL = 311,
     CFG_NONE = 312,
     CFG_GROUP_SOURCE = 313,
     CFG_ACCOUNTING = 314,
     CFG_CONF_SOURCE = 315,
     CFG_MOTD = 316,
     CFG_POOL_SIZE = 317,
     CFG_AUTH_THROTTLE = 318,
     CFG_SPLIT_NETWORK = 319,
     CFG_SPLIT_LOCAL = 320,
     CFG_SPLIT_INCLUDE = 321,
     CFG_SPLIT_DNS = 322,
     CFG_PFS_GROUP = 323,
     CFG_SAVE_PASSWD = 324,
     RETRY = 325,
     RETRY_COUNTER = 326,
     RETRY_INTERVAL = 327,
     RETRY_PERSEND = 328,
     RETRY_PHASE1 = 329,
     RETRY_PHASE2 = 330,
     NATT_KA = 331,
     ALGORITHM_CLASS = 332,
     ALGORITHMTYPE = 333,
     STRENGTHTYPE = 334,
     SAINFO = 335,
     FROM = 336,
     REMOTE = 337,
     ANONYMOUS = 338,
     CLIENTADDR = 339,
     INHERIT = 340,
     REMOTE_ADDRESS = 341,
     EXCHANGE_MODE = 342,
     EXCHANGETYPE = 343,
     DOI = 344,
     DOITYPE = 345,
     SITUATION = 346,
     SITUATIONTYPE = 347,
     CERTIFICATE_TYPE = 348,
     CERTTYPE = 349,
     PEERS_CERTFILE = 350,
     CA_TYPE = 351,
     VERIFY_CERT = 352,
     SEND_CERT = 353,
     SEND_CR = 354,
     MATCH_EMPTY_CR = 355,
     IDENTIFIERTYPE = 356,
     IDENTIFIERQUAL = 357,
     MY_IDENTIFIER = 358,
     PEERS_IDENTIFIER = 359,
     VERIFY_IDENTIFIER = 360,
     DNSSEC = 361,
     CERT_X509 = 362,
     CERT_PLAINRSA = 363,
     NONCE_SIZE = 364,
     DH_GROUP = 365,
     KEEPALIVE = 366,
     PASSIVE = 367,
     INITIAL_CONTACT = 368,
     NAT_TRAVERSAL = 369,
     REMOTE_FORCE_LEVEL = 370,
     PROPOSAL_CHECK = 371,
     PROPOSAL_CHECK_LEVEL = 372,
     GENERATE_POLICY = 373,
     GENERATE_LEVEL = 374,
     SUPPORT_PROXY = 375,
     PROPOSAL = 376,
     EXEC_PATH = 377,
     EXEC_COMMAND = 378,
     EXEC_SUCCESS = 379,
     EXEC_FAILURE = 380,
     GSS_ID = 381,
     GSS_ID_ENC = 382,
     GSS_ID_ENCTYPE = 383,
     COMPLEX_BUNDLE = 384,
     DPD = 385,
     DPD_DELAY = 386,
     DPD_RETRY = 387,
     DPD_MAXFAIL = 388,
     PH1ID = 389,
     XAUTH_LOGIN = 390,
     WEAK_PHASE1_CHECK = 391,
     REKEY = 392,
     PREFIX = 393,
     PORT = 394,
     PORTANY = 395,
     UL_PROTO = 396,
     ANY = 397,
     IKE_FRAG = 398,
     ESP_FRAG = 399,
     MODE_CFG = 400,
     PFS_GROUP = 401,
     LIFETIME = 402,
     LIFETYPE_TIME = 403,
     LIFETYPE_BYTE = 404,
     STRENGTH = 405,
     REMOTEID = 406,
     SCRIPT = 407,
     PHASE1_UP = 408,
     PHASE1_DOWN = 409,
     NUMBER = 410,
     SWITCH = 411,
     BOOLEAN = 412,
     HEXSTRING = 413,
     QUOTEDSTRING = 414,
     ADDRSTRING = 415,
     ADDRRANGE = 416,
     UNITTYPE_BYTE = 417,
     UNITTYPE_KBYTES = 418,
     UNITTYPE_MBYTES = 419,
     UNITTYPE_TBYTES = 420,
     UNITTYPE_SEC = 421,
     UNITTYPE_MIN = 422,
     UNITTYPE_HOUR = 423,
     EOS = 424,
     BOC = 425,
     EOC = 426,
     COMMA = 427
   };
#endif
/* Tokens.  */
#define PRIVSEP 258
#define USER 259
#define GROUP 260
#define CHROOT 261
#define PATH 262
#define PATHTYPE 263
#define INCLUDE 264
#define PFKEY_BUFFER 265
#define LOGGING 266
#define LOGLEV 267
#define PADDING 268
#define PAD_RANDOMIZE 269
#define PAD_RANDOMIZELEN 270
#define PAD_MAXLEN 271
#define PAD_STRICT 272
#define PAD_EXCLTAIL 273
#define LISTEN 274
#define X_ISAKMP 275
#define X_ISAKMP_NATT 276
#define X_ADMIN 277
#define STRICT_ADDRESS 278
#define ADMINSOCK 279
#define DISABLED 280
#define LDAPCFG 281
#define LDAP_HOST 282
#define LDAP_PORT 283
#define LDAP_PVER 284
#define LDAP_BASE 285
#define LDAP_BIND_DN 286
#define LDAP_BIND_PW 287
#define LDAP_SUBTREE 288
#define LDAP_ATTR_USER 289
#define LDAP_ATTR_ADDR 290
#define LDAP_ATTR_MASK 291
#define LDAP_ATTR_GROUP 292
#define LDAP_ATTR_MEMBER 293
#define RADCFG 294
#define RAD_AUTH 295
#define RAD_ACCT 296
#define RAD_TIMEOUT 297
#define RAD_RETRIES 298
#define MODECFG 299
#define CFG_NET4 300
#define CFG_MASK4 301
#define CFG_DNS4 302
#define CFG_NBNS4 303
#define CFG_DEFAULT_DOMAIN 304
#define CFG_AUTH_SOURCE 305
#define CFG_AUTH_GROUPS 306
#define CFG_SYSTEM 307
#define CFG_RADIUS 308
#define CFG_PAM 309
#define CFG_LDAP 310
#define CFG_LOCAL 311
#define CFG_NONE 312
#define CFG_GROUP_SOURCE 313
#define CFG_ACCOUNTING 314
#define CFG_CONF_SOURCE 315
#define CFG_MOTD 316
#define CFG_POOL_SIZE 317
#define CFG_AUTH_THROTTLE 318
#define CFG_SPLIT_NETWORK 319
#define CFG_SPLIT_LOCAL 320
#define CFG_SPLIT_INCLUDE 321
#define CFG_SPLIT_DNS 322
#define CFG_PFS_GROUP 323
#define CFG_SAVE_PASSWD 324
#define RETRY 325
#define RETRY_COUNTER 326
#define RETRY_INTERVAL 327
#define RETRY_PERSEND 328
#define RETRY_PHASE1 329
#define RETRY_PHASE2 330
#define NATT_KA 331
#define ALGORITHM_CLASS 332
#define ALGORITHMTYPE 333
#define STRENGTHTYPE 334
#define SAINFO 335
#define FROM 336
#define REMOTE 337
#define ANONYMOUS 338
#define CLIENTADDR 339
#define INHERIT 340
#define REMOTE_ADDRESS 341
#define EXCHANGE_MODE 342
#define EXCHANGETYPE 343
#define DOI 344
#define DOITYPE 345
#define SITUATION 346
#define SITUATIONTYPE 347
#define CERTIFICATE_TYPE 348
#define CERTTYPE 349
#define PEERS_CERTFILE 350
#define CA_TYPE 351
#define VERIFY_CERT 352
#define SEND_CERT 353
#define SEND_CR 354
#define MATCH_EMPTY_CR 355
#define IDENTIFIERTYPE 356
#define IDENTIFIERQUAL 357
#define MY_IDENTIFIER 358
#define PEERS_IDENTIFIER 359
#define VERIFY_IDENTIFIER 360
#define DNSSEC 361
#define CERT_X509 362
#define CERT_PLAINRSA 363
#define NONCE_SIZE 364
#define DH_GROUP 365
#define KEEPALIVE 366
#define PASSIVE 367
#define INITIAL_CONTACT 368
#define NAT_TRAVERSAL 369
#define REMOTE_FORCE_LEVEL 370
#define PROPOSAL_CHECK 371
#define PROPOSAL_CHECK_LEVEL 372
#define GENERATE_POLICY 373
#define GENERATE_LEVEL 374
#define SUPPORT_PROXY 375
#define PROPOSAL 376
#define EXEC_PATH 377
#define EXEC_COMMAND 378
#define EXEC_SUCCESS 379
#define EXEC_FAILURE 380
#define GSS_ID 381
#define GSS_ID_ENC 382
#define GSS_ID_ENCTYPE 383
#define COMPLEX_BUNDLE 384
#define DPD 385
#define DPD_DELAY 386
#define DPD_RETRY 387
#define DPD_MAXFAIL 388
#define PH1ID 389
#define XAUTH_LOGIN 390
#define WEAK_PHASE1_CHECK 391
#define REKEY 392
#define PREFIX 393
#define PORT 394
#define PORTANY 395
#define UL_PROTO 396
#define ANY 397
#define IKE_FRAG 398
#define ESP_FRAG 399
#define MODE_CFG 400
#define PFS_GROUP 401
#define LIFETIME 402
#define LIFETYPE_TIME 403
#define LIFETYPE_BYTE 404
#define STRENGTH 405
#define REMOTEID 406
#define SCRIPT 407
#define PHASE1_UP 408
#define PHASE1_DOWN 409
#define NUMBER 410
#define SWITCH 411
#define BOOLEAN 412
#define HEXSTRING 413
#define QUOTEDSTRING 414
#define ADDRSTRING 415
#define ADDRRANGE 416
#define UNITTYPE_BYTE 417
#define UNITTYPE_KBYTES 418
#define UNITTYPE_MBYTES 419
#define UNITTYPE_TBYTES 420
#define UNITTYPE_SEC 421
#define UNITTYPE_MIN 422
#define UNITTYPE_HOUR 423
#define EOS 424
#define BOC 425
#define EOC 426
#define COMMA 427




/* Copy the first part of user declarations.  */
#line 5 "cfparse.y"

/*
 * Copyright (C) 1995, 1996, 1997, 1998, 1999, 2000, 2001, 2002 and 2003 WIDE Project.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the project nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "config.h"

#include <sys/types.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <sys/socket.h>

#include <netinet/in.h>
#include PATH_IPSEC_H

#ifdef ENABLE_HYBRID
#include <arpa/inet.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <netdb.h>
#include <pwd.h>
#include <grp.h>

#include "var.h"
#include "misc.h"
#include "vmbuf.h"
#include "plog.h"
#include "sockmisc.h"
#include "str2val.h"
#include "genlist.h"
#include "debug.h"

#include "admin.h"
#include "privsep.h"
#include "cfparse_proto.h"
#include "cftoken_proto.h"
#include "algorithm.h"
#include "localconf.h"
#include "policy.h"
#include "sainfo.h"
#include "oakley.h"
#include "pfkey.h"
#include "remoteconf.h"
#include "grabmyaddr.h"
#include "isakmp_var.h"
#include "handler.h"
#include "isakmp.h"
#include "nattraversal.h"
#include "isakmp_frag.h"
#ifdef ENABLE_HYBRID
#include "resolv.h"
#include "isakmp_unity.h"
#include "isakmp_xauth.h"
#include "isakmp_cfg.h"
#endif
#include "ipsec_doi.h"
#include "strnames.h"
#include "gcmalloc.h"
#ifdef HAVE_GSSAPI
#include "gssapi.h"
#endif
#include "vendorid.h"
#include "rsalist.h"
#include "crypto_openssl.h"

struct secprotospec {
	int prop_no;
	int trns_no;
	int strength;		/* for isakmp/ipsec */
	int encklen;		/* for isakmp/ipsec */
	time_t lifetime;	/* for isakmp */
	int lifebyte;		/* for isakmp */
	int proto_id;		/* for ipsec (isakmp?) */
	int ipsec_level;	/* for ipsec */
	int encmode;		/* for ipsec */
	int vendorid;		/* for isakmp */
	char *gssid;
	struct sockaddr *remote;
	int algclass[MAXALGCLASS];

	struct secprotospec *next;	/* the tail is the most prefiered. */
	struct secprotospec *prev;
};

static int num2dhgroup[] = {
	0,
	OAKLEY_ATTR_GRP_DESC_MODP768,
	OAKLEY_ATTR_GRP_DESC_MODP1024,
	OAKLEY_ATTR_GRP_DESC_EC2N155,
	OAKLEY_ATTR_GRP_DESC_EC2N185,
	OAKLEY_ATTR_GRP_DESC_MODP1536,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	OAKLEY_ATTR_GRP_DESC_MODP2048,
	OAKLEY_ATTR_GRP_DESC_MODP3072,
	OAKLEY_ATTR_GRP_DESC_MODP4096,
	OAKLEY_ATTR_GRP_DESC_MODP6144,
	OAKLEY_ATTR_GRP_DESC_MODP8192
};

static struct remoteconf *cur_rmconf;
static int tmpalgtype[MAXALGCLASS];
static struct sainfo *cur_sainfo;
static int cur_algclass;
static int oldloglevel = LLV_BASE;

static struct secprotospec *newspspec __P((void));
static void insspspec __P((struct remoteconf *, struct secprotospec *));
static void adminsock_conf __P((vchar_t *, vchar_t *, vchar_t *, int));

static int set_isakmp_proposal __P((struct remoteconf *));
static void clean_tmpalgtype __P((void));
static int expand_isakmpspec __P((int, int, int *,
	int, int, time_t, int, int, int, char *, struct remoteconf *));

void freeetypes (struct etypes **etypes);

static int load_x509(const char *file, char **filenameptr,
		     vchar_t **certptr)
{
	char path[PATH_MAX];

	getpathname(path, sizeof(path), LC_PATHTYPE_CERT, file);
	*certptr = eay_get_x509cert(path);
	if (*certptr == NULL)
		return -1;

	*filenameptr = racoon_strdup(file);
	STRDUP_FATAL(*filenameptr);

	return 0;
}



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 175 "cfparse.y"
{
	unsigned long num;
	vchar_t *val;
	struct remoteconf *rmconf;
	struct sockaddr *saddr;
	struct sainfoalg *alg;
}
/* Line 187 of yacc.c.  */
#line 618 "cfparse.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 631 "cfparse.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   522

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  173
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  202
/* YYNRULES -- Number of rules.  */
#define YYNRULES  377
/* YYNRULES -- Number of states.  */
#define YYNSTATES  686

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   427

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138,   139,   140,   141,   142,   143,   144,
     145,   146,   147,   148,   149,   150,   151,   152,   153,   154,
     155,   156,   157,   158,   159,   160,   161,   162,   163,   164,
     165,   166,   167,   168,   169,   170,   171,   172
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     4,     7,     9,    11,    13,    15,    17,
      19,    21,    23,    25,    27,    29,    31,    33,    35,    37,
      42,    43,    46,    47,    52,    53,    58,    59,    64,    65,
      70,    71,    76,    77,    83,    84,    89,    93,    97,   101,
     105,   107,   112,   113,   116,   117,   122,   123,   128,   129,
     134,   135,   140,   141,   146,   151,   152,   155,   156,   161,
     162,   167,   168,   176,   177,   182,   183,   188,   189,   193,
     196,   197,   199,   200,   206,   207,   210,   211,   217,   218,
     225,   226,   232,   233,   240,   241,   246,   247,   252,   253,
     259,   260,   263,   264,   269,   270,   275,   276,   281,   282,
     287,   288,   293,   294,   299,   300,   305,   306,   311,   312,
     317,   318,   323,   324,   329,   330,   335,   340,   341,   344,
     345,   350,   351,   356,   360,   364,   365,   371,   372,   378,
     379,   384,   385,   390,   391,   396,   397,   402,   403,   408,
     409,   414,   415,   420,   421,   426,   427,   432,   433,   438,
     439,   444,   445,   450,   451,   456,   457,   462,   463,   468,
     469,   474,   475,   480,   481,   486,   487,   492,   493,   498,
     499,   504,   506,   510,   512,   514,   518,   520,   522,   526,
     529,   531,   535,   537,   539,   543,   545,   550,   551,   554,
     555,   560,   561,   567,   568,   573,   574,   580,   581,   587,
     588,   594,   595,   596,   605,   607,   610,   613,   616,   619,
     622,   628,   635,   638,   639,   643,   646,   647,   650,   651,
     656,   657,   662,   663,   670,   671,   678,   679,   684,   686,
     687,   692,   695,   696,   698,   699,   701,   703,   705,   707,
     709,   710,   712,   713,   720,   721,   726,   727,   734,   735,
     740,   744,   747,   749,   750,   753,   754,   759,   760,   765,
     766,   771,   772,   777,   780,   781,   786,   787,   793,   794,
     800,   801,   806,   807,   813,   814,   819,   820,   825,   826,
     831,   832,   837,   838,   844,   845,   852,   853,   858,   859,
     865,   866,   873,   874,   879,   880,   885,   886,   891,   892,
     897,   898,   903,   904,   909,   910,   915,   916,   922,   923,
     929,   930,   935,   936,   941,   942,   947,   948,   953,   954,
     959,   960,   965,   966,   971,   972,   977,   978,   983,   984,
     989,   990,   995,   996,  1001,  1002,  1007,  1008,  1013,  1014,
    1019,  1020,  1027,  1028,  1033,  1034,  1041,  1042,  1048,  1049,
    1052,  1053,  1059,  1060,  1065,  1067,  1069,  1070,  1072,  1074,
    1075,  1078,  1079,  1086,  1087,  1094,  1095,  1100,  1101,  1106,
    1107,  1113,  1115,  1117,  1119,  1121,  1123,  1125
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     174,     0,    -1,    -1,   174,   175,    -1,   176,    -1,   184,
      -1,   188,    -1,   189,    -1,   190,    -1,   191,    -1,   193,
      -1,   201,    -1,   222,    -1,   212,    -1,   238,    -1,   276,
      -1,   285,    -1,   305,    -1,   186,    -1,     3,   170,   177,
     171,    -1,    -1,   177,   178,    -1,    -1,     4,   159,   179,
     169,    -1,    -1,     4,   155,   180,   169,    -1,    -1,     5,
     159,   181,   169,    -1,    -1,     5,   155,   182,   169,    -1,
      -1,     6,   159,   183,   169,    -1,    -1,     7,     8,   159,
     185,   169,    -1,    -1,   129,   156,   187,   169,    -1,     9,
     159,   169,    -1,    10,   155,   169,    -1,   127,   128,   169,
      -1,    11,   192,   169,    -1,    12,    -1,    13,   170,   194,
     171,    -1,    -1,   194,   195,    -1,    -1,    14,   156,   196,
     169,    -1,    -1,    15,   156,   197,   169,    -1,    -1,    16,
     155,   198,   169,    -1,    -1,    17,   156,   199,   169,    -1,
      -1,    18,   156,   200,   169,    -1,    19,   170,   202,   171,
      -1,    -1,   202,   203,    -1,    -1,    20,   210,   204,   169,
      -1,    -1,    21,   210,   205,   169,    -1,    -1,    24,   159,
     159,   159,   155,   206,   169,    -1,    -1,    24,   159,   207,
     169,    -1,    -1,    24,    25,   208,   169,    -1,    -1,    23,
     209,   169,    -1,   160,   211,    -1,    -1,   139,    -1,    -1,
      39,   213,   170,   214,   171,    -1,    -1,   214,   215,    -1,
      -1,    40,   159,   159,   216,   169,    -1,    -1,    40,   159,
     155,   159,   217,   169,    -1,    -1,    41,   159,   159,   218,
     169,    -1,    -1,    41,   159,   155,   159,   219,   169,    -1,
      -1,    42,   155,   220,   169,    -1,    -1,    43,   155,   221,
     169,    -1,    -1,    26,   223,   170,   224,   171,    -1,    -1,
     224,   225,    -1,    -1,    29,   155,   226,   169,    -1,    -1,
      27,   159,   227,   169,    -1,    -1,    28,   155,   228,   169,
      -1,    -1,    30,   159,   229,   169,    -1,    -1,    33,   156,
     230,   169,    -1,    -1,    31,   159,   231,   169,    -1,    -1,
      32,   159,   232,   169,    -1,    -1,    34,   159,   233,   169,
      -1,    -1,    35,   159,   234,   169,    -1,    -1,    36,   159,
     235,   169,    -1,    -1,    37,   159,   236,   169,    -1,    -1,
      38,   159,   237,   169,    -1,    44,   170,   239,   171,    -1,
      -1,   239,   240,    -1,    -1,    45,   160,   241,   169,    -1,
      -1,    46,   160,   242,   169,    -1,    47,   266,   169,    -1,
      48,   268,   169,    -1,    -1,    64,    65,   270,   243,   169,
      -1,    -1,    64,    66,   270,   244,   169,    -1,    -1,    67,
     274,   245,   169,    -1,    -1,    49,   159,   246,   169,    -1,
      -1,    50,    52,   247,   169,    -1,    -1,    50,    53,   248,
     169,    -1,    -1,    50,    54,   249,   169,    -1,    -1,    50,
      55,   250,   169,    -1,    -1,    51,   272,   251,   169,    -1,
      -1,    58,    52,   252,   169,    -1,    -1,    58,    55,   253,
     169,    -1,    -1,    59,    57,   254,   169,    -1,    -1,    59,
      52,   255,   169,    -1,    -1,    59,    53,   256,   169,    -1,
      -1,    59,    54,   257,   169,    -1,    -1,    62,   155,   258,
     169,    -1,    -1,    68,   155,   259,   169,    -1,    -1,    69,
     156,   260,   169,    -1,    -1,    63,   155,   261,   169,    -1,
      -1,    60,    56,   262,   169,    -1,    -1,    60,    53,   263,
     169,    -1,    -1,    60,    55,   264,   169,    -1,    -1,    61,
     159,   265,   169,    -1,   267,    -1,   267,   172,   266,    -1,
     160,    -1,   269,    -1,   269,   172,   268,    -1,   160,    -1,
     271,    -1,   270,   172,   271,    -1,   160,   138,    -1,   273,
      -1,   273,   172,   272,    -1,   159,    -1,   275,    -1,   275,
     172,   274,    -1,   159,    -1,    70,   170,   277,   171,    -1,
      -1,   277,   278,    -1,    -1,    71,   155,   279,   169,    -1,
      -1,    72,   155,   373,   280,   169,    -1,    -1,    73,   155,
     281,   169,    -1,    -1,    74,   155,   373,   282,   169,    -1,
      -1,    75,   155,   373,   283,   169,    -1,    -1,    76,   155,
     373,   284,   169,    -1,    -1,    -1,    80,   286,   288,   290,
     170,   291,   287,   171,    -1,    83,    -1,    83,    84,    -1,
      83,   289,    -1,   289,    83,    -1,   289,    84,    -1,   289,
     289,    -1,   101,   160,   301,   302,   303,    -1,   101,   160,
     161,   301,   302,   303,    -1,   101,   159,    -1,    -1,    81,
     101,   365,    -1,     5,   159,    -1,    -1,   291,   292,    -1,
      -1,   146,   364,   293,   169,    -1,    -1,   151,   155,   294,
     169,    -1,    -1,   147,   148,   155,   373,   295,   169,    -1,
      -1,   147,   149,   155,   374,   296,   169,    -1,    -1,    77,
     297,   298,   169,    -1,   300,    -1,    -1,   300,   299,   172,
     298,    -1,    78,   304,    -1,    -1,   138,    -1,    -1,   139,
      -1,   140,    -1,   155,    -1,   141,    -1,   142,    -1,    -1,
     155,    -1,    -1,    82,   159,    85,   159,   306,   310,    -1,
      -1,    82,   159,   307,   310,    -1,    -1,    82,   311,    85,
     311,   308,   310,    -1,    -1,    82,   311,   309,   310,    -1,
     170,   312,   171,    -1,    83,   211,    -1,   210,    -1,    -1,
     312,   313,    -1,    -1,    86,   210,   314,   169,    -1,    -1,
      87,   315,   360,   169,    -1,    -1,    89,    90,   316,   169,
      -1,    -1,    91,    92,   317,   169,    -1,    93,   361,    -1,
      -1,    95,   159,   318,   169,    -1,    -1,    95,   107,   159,
     319,   169,    -1,    -1,    95,   108,   159,   320,   169,    -1,
      -1,    95,   106,   321,   169,    -1,    -1,    96,   107,   159,
     322,   169,    -1,    -1,    97,   156,   323,   169,    -1,    -1,
      98,   156,   324,   169,    -1,    -1,    99,   156,   325,   169,
      -1,    -1,   100,   156,   326,   169,    -1,    -1,   103,   101,
     365,   327,   169,    -1,    -1,   103,   101,   102,   365,   328,
     169,    -1,    -1,   135,   365,   329,   169,    -1,    -1,   104,
     101,   365,   330,   169,    -1,    -1,   104,   101,   102,   365,
     331,   169,    -1,    -1,   105,   156,   332,   169,    -1,    -1,
     109,   155,   333,   169,    -1,    -1,   110,   334,   364,   169,
      -1,    -1,   112,   156,   335,   169,    -1,    -1,   143,   156,
     336,   169,    -1,    -1,   143,   115,   337,   169,    -1,    -1,
     144,   155,   338,   169,    -1,    -1,   152,   159,   153,   339,
     169,    -1,    -1,   152,   159,   154,   340,   169,    -1,    -1,
     145,   156,   341,   169,    -1,    -1,   136,   156,   342,   169,
      -1,    -1,   118,   156,   343,   169,    -1,    -1,   118,   119,
     344,   169,    -1,    -1,   120,   156,   345,   169,    -1,    -1,
     113,   156,   346,   169,    -1,    -1,   114,   156,   347,   169,
      -1,    -1,   114,   115,   348,   169,    -1,    -1,   130,   156,
     349,   169,    -1,    -1,   131,   155,   350,   169,    -1,    -1,
     132,   155,   351,   169,    -1,    -1,   133,   155,   352,   169,
      -1,    -1,   137,   156,   353,   169,    -1,    -1,   137,   115,
     354,   169,    -1,    -1,   134,   155,   355,   169,    -1,    -1,
     147,   148,   155,   373,   356,   169,    -1,    -1,   116,   117,
     357,   169,    -1,    -1,   147,   149,   155,   374,   358,   169,
      -1,    -1,   121,   359,   170,   366,   171,    -1,    -1,   360,
      88,    -1,    -1,   107,   159,   159,   362,   169,    -1,    -1,
     108,   159,   363,   169,    -1,    78,    -1,   155,    -1,    -1,
     160,    -1,   159,    -1,    -1,   366,   367,    -1,    -1,   147,
     148,   155,   373,   368,   169,    -1,    -1,   147,   149,   155,
     374,   369,   169,    -1,    -1,   110,   364,   370,   169,    -1,
      -1,   126,   159,   371,   169,    -1,    -1,    77,    78,   304,
     372,   169,    -1,   166,    -1,   167,    -1,   168,    -1,   162,
      -1,   163,    -1,   164,    -1,   165,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   264,   264,   266,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   288,
     290,   292,   296,   295,   306,   306,   308,   307,   318,   318,
     319,   319,   325,   324,   345,   345,   350,   364,   371,   383,
     386,   400,   402,   404,   407,   407,   408,   408,   409,   409,
     410,   410,   411,   411,   416,   418,   420,   424,   423,   429,
     428,   438,   437,   447,   446,   456,   455,   464,   464,   467,
     479,   480,   485,   485,   502,   504,   508,   507,   526,   525,
     544,   543,   562,   561,   580,   579,   589,   588,   601,   601,
     612,   614,   618,   617,   629,   628,   640,   639,   649,   648,
     660,   659,   669,   668,   680,   679,   691,   690,   702,   701,
     713,   712,   724,   723,   735,   734,   749,   751,   753,   757,
     756,   768,   767,   778,   780,   783,   782,   792,   791,   801,
     800,   808,   807,   820,   819,   829,   828,   842,   841,   855,
     854,   868,   867,   875,   874,   884,   883,   897,   896,   906,
     905,   915,   914,   928,   927,   941,   940,   951,   950,   960,
     959,   969,   968,   978,   977,   987,   986,  1000,   999,  1013,
    1012,  1026,  1027,  1030,  1047,  1048,  1051,  1068,  1069,  1072,
    1095,  1096,  1099,  1133,  1134,  1137,  1174,  1176,  1178,  1182,
    1181,  1187,  1186,  1192,  1191,  1197,  1196,  1202,  1201,  1207,
    1206,  1223,  1231,  1222,  1270,  1275,  1280,  1285,  1290,  1295,
    1302,  1351,  1416,  1445,  1448,  1473,  1486,  1488,  1492,  1491,
    1497,  1496,  1502,  1501,  1507,  1506,  1518,  1518,  1525,  1530,
    1529,  1536,  1592,  1593,  1596,  1597,  1598,  1601,  1602,  1603,
    1606,  1607,  1613,  1612,  1643,  1642,  1663,  1662,  1685,  1684,
    1701,  1770,  1776,  1785,  1787,  1791,  1790,  1800,  1799,  1804,
    1804,  1805,  1805,  1806,  1808,  1807,  1828,  1827,  1845,  1844,
    1875,  1874,  1889,  1888,  1905,  1905,  1906,  1906,  1907,  1907,
    1908,  1908,  1910,  1909,  1919,  1918,  1928,  1927,  1945,  1944,
    1962,  1961,  1978,  1978,  1979,  1979,  1981,  1980,  1986,  1986,
    1987,  1987,  1988,  1988,  1989,  1989,  1999,  1999,  2006,  2006,
    2013,  2013,  2014,  2014,  2017,  2017,  2018,  2018,  2019,  2019,
    2020,  2020,  2022,  2021,  2033,  2032,  2044,  2043,  2052,  2051,
    2061,  2060,  2070,  2069,  2078,  2078,  2079,  2079,  2081,  2080,
    2086,  2085,  2090,  2090,  2092,  2091,  2106,  2105,  2116,  2118,
    2142,  2141,  2163,  2162,  2196,  2204,  2216,  2217,  2218,  2220,
    2222,  2226,  2225,  2231,  2230,  2243,  2242,  2248,  2247,  2261,
    2260,  2358,  2359,  2360,  2363,  2364,  2365,  2366
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "PRIVSEP", "USER", "GROUP", "CHROOT",
  "PATH", "PATHTYPE", "INCLUDE", "PFKEY_BUFFER", "LOGGING", "LOGLEV",
  "PADDING", "PAD_RANDOMIZE", "PAD_RANDOMIZELEN", "PAD_MAXLEN",
  "PAD_STRICT", "PAD_EXCLTAIL", "LISTEN", "X_ISAKMP", "X_ISAKMP_NATT",
  "X_ADMIN", "STRICT_ADDRESS", "ADMINSOCK", "DISABLED", "LDAPCFG",
  "LDAP_HOST", "LDAP_PORT", "LDAP_PVER", "LDAP_BASE", "LDAP_BIND_DN",
  "LDAP_BIND_PW", "LDAP_SUBTREE", "LDAP_ATTR_USER", "LDAP_ATTR_ADDR",
  "LDAP_ATTR_MASK", "LDAP_ATTR_GROUP", "LDAP_ATTR_MEMBER", "RADCFG",
  "RAD_AUTH", "RAD_ACCT", "RAD_TIMEOUT", "RAD_RETRIES", "MODECFG",
  "CFG_NET4", "CFG_MASK4", "CFG_DNS4", "CFG_NBNS4", "CFG_DEFAULT_DOMAIN",
  "CFG_AUTH_SOURCE", "CFG_AUTH_GROUPS", "CFG_SYSTEM", "CFG_RADIUS",
  "CFG_PAM", "CFG_LDAP", "CFG_LOCAL", "CFG_NONE", "CFG_GROUP_SOURCE",
  "CFG_ACCOUNTING", "CFG_CONF_SOURCE", "CFG_MOTD", "CFG_POOL_SIZE",
  "CFG_AUTH_THROTTLE", "CFG_SPLIT_NETWORK", "CFG_SPLIT_LOCAL",
  "CFG_SPLIT_INCLUDE", "CFG_SPLIT_DNS", "CFG_PFS_GROUP", "CFG_SAVE_PASSWD",
  "RETRY", "RETRY_COUNTER", "RETRY_INTERVAL", "RETRY_PERSEND",
  "RETRY_PHASE1", "RETRY_PHASE2", "NATT_KA", "ALGORITHM_CLASS",
  "ALGORITHMTYPE", "STRENGTHTYPE", "SAINFO", "FROM", "REMOTE", "ANONYMOUS",
  "CLIENTADDR", "INHERIT", "REMOTE_ADDRESS", "EXCHANGE_MODE",
  "EXCHANGETYPE", "DOI", "DOITYPE", "SITUATION", "SITUATIONTYPE",
  "CERTIFICATE_TYPE", "CERTTYPE", "PEERS_CERTFILE", "CA_TYPE",
  "VERIFY_CERT", "SEND_CERT", "SEND_CR", "MATCH_EMPTY_CR",
  "IDENTIFIERTYPE", "IDENTIFIERQUAL", "MY_IDENTIFIER", "PEERS_IDENTIFIER",
  "VERIFY_IDENTIFIER", "DNSSEC", "CERT_X509", "CERT_PLAINRSA",
  "NONCE_SIZE", "DH_GROUP", "KEEPALIVE", "PASSIVE", "INITIAL_CONTACT",
  "NAT_TRAVERSAL", "REMOTE_FORCE_LEVEL", "PROPOSAL_CHECK",
  "PROPOSAL_CHECK_LEVEL", "GENERATE_POLICY", "GENERATE_LEVEL",
  "SUPPORT_PROXY", "PROPOSAL", "EXEC_PATH", "EXEC_COMMAND", "EXEC_SUCCESS",
  "EXEC_FAILURE", "GSS_ID", "GSS_ID_ENC", "GSS_ID_ENCTYPE",
  "COMPLEX_BUNDLE", "DPD", "DPD_DELAY", "DPD_RETRY", "DPD_MAXFAIL",
  "PH1ID", "XAUTH_LOGIN", "WEAK_PHASE1_CHECK", "REKEY", "PREFIX", "PORT",
  "PORTANY", "UL_PROTO", "ANY", "IKE_FRAG", "ESP_FRAG", "MODE_CFG",
  "PFS_GROUP", "LIFETIME", "LIFETYPE_TIME", "LIFETYPE_BYTE", "STRENGTH",
  "REMOTEID", "SCRIPT", "PHASE1_UP", "PHASE1_DOWN", "NUMBER", "SWITCH",
  "BOOLEAN", "HEXSTRING", "QUOTEDSTRING", "ADDRSTRING", "ADDRRANGE",
  "UNITTYPE_BYTE", "UNITTYPE_KBYTES", "UNITTYPE_MBYTES", "UNITTYPE_TBYTES",
  "UNITTYPE_SEC", "UNITTYPE_MIN", "UNITTYPE_HOUR", "EOS", "BOC", "EOC",
  "COMMA", "$accept", "statements", "statement", "privsep_statement",
  "privsep_stmts", "privsep_stmt", "@1", "@2", "@3", "@4", "@5",
  "path_statement", "@6", "special_statement", "@7", "include_statement",
  "pfkey_statement", "gssenc_statement", "logging_statement", "log_level",
  "padding_statement", "padding_stmts", "padding_stmt", "@8", "@9", "@10",
  "@11", "@12", "listen_statement", "listen_stmts", "listen_stmt", "@13",
  "@14", "@15", "@16", "@17", "@18", "ike_addrinfo_port", "ike_port",
  "radcfg_statement", "@19", "radcfg_stmts", "radcfg_stmt", "@20", "@21",
  "@22", "@23", "@24", "@25", "ldapcfg_statement", "@26", "ldapcfg_stmts",
  "ldapcfg_stmt", "@27", "@28", "@29", "@30", "@31", "@32", "@33", "@34",
  "@35", "@36", "@37", "@38", "modecfg_statement", "modecfg_stmts",
  "modecfg_stmt", "@39", "@40", "@41", "@42", "@43", "@44", "@45", "@46",
  "@47", "@48", "@49", "@50", "@51", "@52", "@53", "@54", "@55", "@56",
  "@57", "@58", "@59", "@60", "@61", "@62", "@63", "addrdnslist",
  "addrdns", "addrwinslist", "addrwins", "splitnetlist", "splitnet",
  "authgrouplist", "authgroup", "splitdnslist", "splitdns",
  "timer_statement", "timer_stmts", "timer_stmt", "@64", "@65", "@66",
  "@67", "@68", "@69", "sainfo_statement", "@70", "@71", "sainfo_name",
  "sainfo_id", "sainfo_param", "sainfo_specs", "sainfo_spec", "@72", "@73",
  "@74", "@75", "@76", "algorithms", "@77", "algorithm", "prefix", "port",
  "ul_proto", "keylength", "remote_statement", "@78", "@79", "@80", "@81",
  "remote_specs_block", "remote_index", "remote_specs", "remote_spec",
  "@82", "@83", "@84", "@85", "@86", "@87", "@88", "@89", "@90", "@91",
  "@92", "@93", "@94", "@95", "@96", "@97", "@98", "@99", "@100", "@101",
  "@102", "@103", "@104", "@105", "@106", "@107", "@108", "@109", "@110",
  "@111", "@112", "@113", "@114", "@115", "@116", "@117", "@118", "@119",
  "@120", "@121", "@122", "@123", "@124", "@125", "@126", "@127",
  "exchange_types", "cert_spec", "@128", "@129", "dh_group_num",
  "identifierstring", "isakmpproposal_specs", "isakmpproposal_spec",
  "@130", "@131", "@132", "@133", "@134", "unittype_time", "unittype_byte", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,   360,   361,   362,   363,   364,
     365,   366,   367,   368,   369,   370,   371,   372,   373,   374,
     375,   376,   377,   378,   379,   380,   381,   382,   383,   384,
     385,   386,   387,   388,   389,   390,   391,   392,   393,   394,
     395,   396,   397,   398,   399,   400,   401,   402,   403,   404,
     405,   406,   407,   408,   409,   410,   411,   412,   413,   414,
     415,   416,   417,   418,   419,   420,   421,   422,   423,   424,
     425,   426,   427
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint16 yyr1[] =
{
       0,   173,   174,   174,   175,   175,   175,   175,   175,   175,
     175,   175,   175,   175,   175,   175,   175,   175,   175,   176,
     177,   177,   179,   178,   180,   178,   181,   178,   182,   178,
     183,   178,   185,   184,   187,   186,   188,   189,   190,   191,
     192,   193,   194,   194,   196,   195,   197,   195,   198,   195,
     199,   195,   200,   195,   201,   202,   202,   204,   203,   205,
     203,   206,   203,   207,   203,   208,   203,   209,   203,   210,
     211,   211,   213,   212,   214,   214,   216,   215,   217,   215,
     218,   215,   219,   215,   220,   215,   221,   215,   223,   222,
     224,   224,   226,   225,   227,   225,   228,   225,   229,   225,
     230,   225,   231,   225,   232,   225,   233,   225,   234,   225,
     235,   225,   236,   225,   237,   225,   238,   239,   239,   241,
     240,   242,   240,   240,   240,   243,   240,   244,   240,   245,
     240,   246,   240,   247,   240,   248,   240,   249,   240,   250,
     240,   251,   240,   252,   240,   253,   240,   254,   240,   255,
     240,   256,   240,   257,   240,   258,   240,   259,   240,   260,
     240,   261,   240,   262,   240,   263,   240,   264,   240,   265,
     240,   266,   266,   267,   268,   268,   269,   270,   270,   271,
     272,   272,   273,   274,   274,   275,   276,   277,   277,   279,
     278,   280,   278,   281,   278,   282,   278,   283,   278,   284,
     278,   286,   287,   285,   288,   288,   288,   288,   288,   288,
     289,   289,   289,   290,   290,   290,   291,   291,   293,   292,
     294,   292,   295,   292,   296,   292,   297,   292,   298,   299,
     298,   300,   301,   301,   302,   302,   302,   303,   303,   303,
     304,   304,   306,   305,   307,   305,   308,   305,   309,   305,
     310,   311,   311,   312,   312,   314,   313,   315,   313,   316,
     313,   317,   313,   313,   318,   313,   319,   313,   320,   313,
     321,   313,   322,   313,   323,   313,   324,   313,   325,   313,
     326,   313,   327,   313,   328,   313,   329,   313,   330,   313,
     331,   313,   332,   313,   333,   313,   334,   313,   335,   313,
     336,   313,   337,   313,   338,   313,   339,   313,   340,   313,
     341,   313,   342,   313,   343,   313,   344,   313,   345,   313,
     346,   313,   347,   313,   348,   313,   349,   313,   350,   313,
     351,   313,   352,   313,   353,   313,   354,   313,   355,   313,
     356,   313,   357,   313,   358,   313,   359,   313,   360,   360,
     362,   361,   363,   361,   364,   364,   365,   365,   365,   366,
     366,   368,   367,   369,   367,   370,   367,   371,   367,   372,
     367,   373,   373,   373,   374,   374,   374,   374
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     4,
       0,     2,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     5,     0,     4,     3,     3,     3,     3,
       1,     4,     0,     2,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     4,     0,     2,     0,     4,     0,
       4,     0,     7,     0,     4,     0,     4,     0,     3,     2,
       0,     1,     0,     5,     0,     2,     0,     5,     0,     6,
       0,     5,     0,     6,     0,     4,     0,     4,     0,     5,
       0,     2,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     0,     4,     4,     0,     2,     0,
       4,     0,     4,     3,     3,     0,     5,     0,     5,     0,
       4,     0,     4,     0,     4,     0,     4,     0,     4,     0,
       4,     0,     4,     0,     4,     0,     4,     0,     4,     0,
       4,     0,     4,     0,     4,     0,     4,     0,     4,     0,
       4,     0,     4,     0,     4,     0,     4,     0,     4,     0,
       4,     1,     3,     1,     1,     3,     1,     1,     3,     2,
       1,     3,     1,     1,     3,     1,     4,     0,     2,     0,
       4,     0,     5,     0,     4,     0,     5,     0,     5,     0,
       5,     0,     0,     8,     1,     2,     2,     2,     2,     2,
       5,     6,     2,     0,     3,     2,     0,     2,     0,     4,
       0,     4,     0,     6,     0,     6,     0,     4,     1,     0,
       4,     2,     0,     1,     0,     1,     1,     1,     1,     1,
       0,     1,     0,     6,     0,     4,     0,     6,     0,     4,
       3,     2,     1,     0,     2,     0,     4,     0,     4,     0,
       4,     0,     4,     2,     0,     4,     0,     5,     0,     5,
       0,     4,     0,     5,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     5,     0,     6,     0,     4,     0,     5,
       0,     6,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     0,     4,     0,     5,     0,     5,
       0,     4,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     4,     0,     4,     0,     4,     0,     4,     0,     4,
       0,     6,     0,     4,     0,     6,     0,     5,     0,     2,
       0,     5,     0,     4,     1,     1,     0,     1,     1,     0,
       2,     0,     6,     0,     6,     0,     4,     0,     4,     0,
       5,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
       2,     0,     1,     0,     0,     0,     0,     0,     0,     0,
      88,    72,     0,     0,   201,     0,     0,     0,     3,     4,
       5,    18,     6,     7,     8,     9,    10,    11,    13,    12,
      14,    15,    16,    17,    20,     0,     0,     0,    40,     0,
      42,    55,     0,     0,   117,   187,     0,    70,   244,    70,
     252,   248,     0,    34,     0,    32,    36,    37,    39,     0,
       0,    90,    74,     0,     0,   204,     0,   213,     0,    71,
     251,     0,     0,    69,     0,     0,    38,     0,     0,     0,
       0,    19,    21,     0,     0,     0,     0,     0,     0,    41,
      43,     0,     0,    67,     0,    54,    56,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   116,   118,     0,     0,
       0,     0,     0,     0,   186,   188,   205,   206,   212,   232,
       0,     0,     0,   207,   208,   209,   242,   253,   245,   246,
     249,    35,    24,    22,    28,    26,    30,    33,    44,    46,
      48,    50,    52,    57,    59,     0,    65,    63,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      89,    91,     0,     0,     0,     0,    73,    75,   119,   121,
     173,     0,   171,   176,     0,   174,   131,   133,   135,   137,
     139,   182,   141,   180,   143,   145,   149,   151,   153,   147,
     165,   167,   163,   169,   155,   161,     0,     0,   185,   129,
     183,   157,   159,   189,     0,   193,     0,     0,     0,   233,
     232,   234,   215,   356,   216,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      68,     0,     0,     0,    94,    96,    92,    98,   102,   104,
     100,   106,   108,   110,   112,   114,     0,     0,    84,    86,
       0,     0,   123,     0,   124,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   125,   177,   127,     0,
       0,     0,     0,     0,   371,   372,   373,   191,     0,   195,
     197,   199,   234,   235,   236,     0,   358,   357,   214,   202,
     243,     0,   257,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   296,     0,     0,     0,
       0,     0,     0,   346,     0,     0,     0,     0,     0,   356,
       0,     0,     0,     0,     0,     0,     0,   250,   254,   247,
      25,    23,    29,    27,    31,    45,    47,    49,    51,    53,
      58,    60,    66,     0,    64,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    76,     0,
      80,     0,     0,   120,   122,   172,   175,   132,   134,   136,
     138,   140,   142,   181,   144,   146,   150,   152,   154,   148,
     166,   168,   164,   170,   156,   162,   179,     0,     0,     0,
     130,   184,   158,   160,   190,     0,   194,     0,     0,     0,
       0,   238,   239,   237,   210,   226,     0,     0,     0,     0,
     217,   255,   348,   259,   261,     0,     0,   263,   270,     0,
       0,   264,     0,   274,   276,   278,   280,   356,   356,   292,
     294,     0,   298,   320,   324,   322,   342,   316,   314,   318,
       0,   326,   328,   330,   332,   338,   286,   312,   336,   334,
     302,   300,   304,   310,     0,     0,     0,    61,    95,    97,
      93,    99,   103,   105,   101,   107,   109,   111,   113,   115,
      78,     0,    82,     0,    85,    87,   178,   126,   128,   192,
     196,   198,   200,   211,     0,   354,   355,   218,     0,     0,
     220,   203,     0,     0,     0,     0,     0,   352,     0,   266,
     268,     0,   272,     0,     0,     0,     0,   356,   282,   356,
     288,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   359,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   306,   308,
       0,     0,    77,     0,    81,   240,     0,   228,     0,     0,
       0,     0,   256,   349,   258,   260,   262,   350,     0,   271,
       0,     0,   265,     0,   275,   277,   279,   281,   284,     0,
     290,     0,   293,   295,   297,   299,   321,   325,   323,   343,
     317,   315,   319,     0,   327,   329,   331,   333,   339,   287,
     313,   337,   335,   303,   301,   305,   311,   340,   374,   375,
     376,   377,   344,     0,     0,    62,    79,    83,   241,   231,
     227,     0,   219,   222,   224,   221,     0,   353,   267,   269,
     273,     0,   283,     0,   289,     0,     0,     0,     0,   347,
     360,     0,     0,   307,   309,     0,     0,     0,   351,   285,
     291,   240,   365,   367,     0,     0,   341,   345,   230,   223,
     225,   369,     0,     0,     0,     0,     0,   366,   368,   361,
     363,   370,     0,     0,   362,   364
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     1,    18,    19,    54,    82,   229,   228,   231,   230,
     232,    20,    83,    21,    77,    22,    23,    24,    25,    39,
      26,    59,    90,   233,   234,   235,   236,   237,    27,    60,
      96,   238,   239,   560,   243,   241,   155,    50,    70,    28,
      43,    98,   177,   491,   561,   493,   563,   381,   382,    29,
      42,    97,   171,   367,   365,   366,   368,   371,   369,   370,
     372,   373,   374,   375,   376,    30,    63,   117,   260,   261,
     408,   409,   289,   266,   267,   268,   269,   270,   271,   273,
     274,   278,   275,   276,   277,   283,   291,   292,   284,   281,
     279,   280,   282,   181,   182,   184,   185,   286,   287,   192,
     193,   209,   210,    31,    64,   125,   293,   415,   298,   417,
     418,   419,    32,    46,   429,    67,    68,   132,   309,   430,
     568,   571,   656,   657,   504,   566,   631,   567,   221,   305,
     424,   629,    33,   225,    72,   227,    75,   138,    51,   226,
     348,   512,   432,   514,   515,   521,   580,   581,   518,   583,
     523,   524,   525,   526,   589,   641,   548,   591,   643,   531,
     532,   451,   534,   553,   552,   554,   623,   624,   555,   549,
     540,   539,   541,   535,   537,   536,   543,   544,   545,   546,
     551,   550,   547,   651,   538,   652,   460,   513,   437,   636,
     578,   507,   308,   603,   650,   682,   683,   672,   673,   676,
     297,   622
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -554
static const yytype_int16 yypact[] =
{
    -554,    46,  -554,  -146,    50,  -121,  -104,    86,   -81,   -53,
    -554,  -554,    -7,     2,  -554,   -36,    27,    20,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,    34,    28,    36,  -554,    37,
    -554,  -554,    25,    39,  -554,  -554,    30,    72,   128,    72,
    -554,   130,    58,  -554,     3,  -554,  -554,  -554,  -554,    -4,
      -2,  -554,  -554,    33,    32,    49,    22,    18,   -13,  -554,
    -554,    63,    59,  -554,   -39,    59,  -554,    67,   -86,   -23,
      69,  -554,  -554,    71,    76,    82,    88,    89,    90,  -554,
    -554,    84,    84,  -554,   -10,  -554,  -554,    -1,     0,    87,
      99,   100,   101,    91,    93,   103,   109,    10,    98,   104,
      94,   112,    77,   110,   115,    92,  -554,  -554,   116,   117,
     119,   120,   122,   123,  -554,  -554,  -554,  -554,  -554,   -93,
     124,   175,   111,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,   113,  -554,   125,   126,   131,
     132,   129,   134,   135,   133,   136,   137,   138,   139,   140,
    -554,  -554,   141,   142,   147,   148,  -554,  -554,  -554,  -554,
    -554,   143,   107,  -554,   144,   108,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,   118,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,   145,   145,  -554,  -554,
     146,  -554,  -554,  -554,    11,  -554,    11,    11,    11,  -554,
     153,    44,  -554,    26,  -554,    59,   121,    59,   150,   151,
     152,   154,   155,   156,   157,   158,   159,   160,   161,   162,
    -554,   163,   149,   164,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,   -18,   -15,  -554,  -554,
     165,   166,  -554,   100,  -554,   101,   167,   168,   169,   170,
     172,   173,   103,   174,   176,   177,   178,   179,   180,   181,
     182,   183,   185,   186,   187,   171,   188,  -554,   188,   189,
     110,   190,   192,   193,  -554,  -554,  -554,  -554,   194,  -554,
    -554,  -554,    44,  -554,  -554,    -3,  -554,  -554,  -554,   -17,
    -554,    84,  -554,   214,   215,    80,   -32,   199,   201,   208,
     209,   210,   213,   216,   211,   217,  -554,   212,   218,   -95,
     198,   -69,   219,  -554,   220,   222,   223,   224,   225,    26,
     226,   -90,   -38,   228,   229,    41,   227,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,   232,  -554,   200,   202,   204,   221,   230,
     231,   233,   234,   235,   236,   237,   238,   239,  -554,   242,
    -554,   240,   241,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,   145,   243,   244,
    -554,  -554,  -554,  -554,  -554,   245,  -554,   246,   247,   248,
      -3,  -554,  -554,  -554,  -554,  -554,   -30,    43,   253,   249,
    -554,  -554,  -554,  -554,  -554,   252,   259,  -554,  -554,   260,
     262,  -554,   263,  -554,  -554,  -554,  -554,   -50,   -48,  -554,
    -554,   -30,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
     254,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,   268,   270,    45,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,   257,  -554,   258,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,   266,  -554,  -554,  -554,   273,   274,
    -554,  -554,   261,   -49,   264,   265,   272,  -554,   267,  -554,
    -554,   269,  -554,   271,   275,   276,   277,    26,  -554,    26,
    -554,   278,   279,   280,   281,   282,   283,   284,   285,   286,
     287,   288,  -554,   290,   291,   292,   293,   294,   295,   296,
     297,   298,   299,   300,   301,   302,    11,    -5,  -554,  -554,
     303,   304,  -554,   305,  -554,   320,   307,   306,   308,    11,
      -5,   310,  -554,  -554,  -554,  -554,  -554,  -554,   311,  -554,
     312,   313,  -554,   314,  -554,  -554,  -554,  -554,  -554,   315,
    -554,   316,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,     9,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,   317,   318,  -554,  -554,  -554,  -554,  -554,
    -554,   319,  -554,  -554,  -554,  -554,   321,  -554,  -554,  -554,
    -554,   323,  -554,   324,  -554,   354,   -30,   329,    53,  -554,
    -554,   325,   326,  -554,  -554,   266,   327,   328,  -554,  -554,
    -554,   320,  -554,  -554,   334,   343,  -554,  -554,  -554,  -554,
    -554,  -554,   330,   331,    11,    -5,   332,  -554,  -554,  -554,
    -554,  -554,   333,   335,  -554,  -554
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,   -88,   339,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,    47,  -554,    51,  -554,   184,   -96,   250,
    -554,   102,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,    97,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -285,  -554,  -554,   289,    79,
     -98,  -277,  -554,  -554,  -554,  -554,  -554,   -59,   322,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -554,  -446,  -333,  -554,  -554,  -554,  -554,  -554,  -554,  -554,
    -216,  -553
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -230
static const yytype_int16 yytable[] =
{
     299,   300,   301,   153,   154,   533,   466,    78,    79,    80,
      84,    85,    86,    87,    88,   156,   140,   634,    91,    92,
     454,    93,    94,   130,    34,   468,   158,   159,   160,   161,
     162,   163,   164,   165,   166,   167,   168,   169,    36,   573,
     172,   173,   174,   175,    47,   219,     2,    47,   505,     3,
     457,    37,   527,     4,   529,     5,     6,     7,    35,     8,
     425,   455,   196,   197,   198,     9,   469,   199,   220,   142,
     133,   134,    10,   143,   438,   439,   440,   470,    99,   100,
     101,   102,   103,   104,   105,    11,   645,   458,    66,    40,
      12,   106,   107,   108,   109,   110,   111,   112,    38,   131,
     113,   114,   115,   118,   119,   120,   121,   122,   123,   306,
     307,   306,   307,    65,   528,   530,    13,    41,   471,   646,
     574,    49,   680,    48,    49,   506,    14,   441,    15,   426,
     427,    66,   144,   126,   428,   647,   145,   377,   421,   422,
     379,   378,   206,   207,   380,   187,   188,   189,   190,   157,
      66,   200,   423,   201,   202,    52,   648,   618,   619,   620,
     621,   194,   127,    44,   195,   135,   310,    89,   349,    95,
     170,   176,    45,    16,    81,    17,    53,   294,   295,   296,
     649,   128,   129,   303,   304,   306,   307,   435,   436,   474,
     475,   508,   509,    55,   588,    61,   590,    56,   558,   559,
     662,   664,   665,   124,   116,    57,    58,   311,   312,    62,
     313,    69,   314,    71,   315,    74,   316,   317,   318,   319,
     320,   321,   136,   431,   322,   323,   324,    76,   146,   137,
     325,   326,   148,   327,   328,   329,   141,   330,   149,   331,
     147,   332,   333,   150,    49,   151,   152,   178,   212,   204,
     186,   334,   335,   336,   337,   338,   339,   340,   341,   179,
     180,   183,   191,   203,   342,   343,   344,   205,   345,   208,
     211,   213,   214,   346,   215,   216,   223,   217,   218,   263,
     265,   224,   240,   222,   242,   244,   245,   246,   247,   250,
     272,   219,   347,   248,   249,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   433,   285,   442,   434,   363,   406,
     385,   496,   262,   264,   447,   456,   386,   448,   290,   350,
     351,   352,   503,   353,   354,   355,   356,   357,   358,   359,
     360,   361,   362,   364,   383,   384,   387,   388,   389,   390,
     617,   391,   392,   394,   565,   395,   396,   397,   398,   399,
     400,   401,   402,   633,   403,   404,   405,   443,   410,   412,
     407,   413,   414,   416,   444,   445,   446,   449,   452,   478,
     668,   479,   450,   480,   453,   459,   461,   462,   463,   464,
     465,   420,   467,   472,   671,   473,   476,   477,    73,     0,
     481,   288,   411,     0,     0,     0,   139,     0,   490,   482,
     483,   492,   484,   485,   486,   487,   488,   489,   510,   494,
     495,   516,   497,   498,   499,   500,   501,   502,   517,   519,
     511,   520,   522,   556,   542,   557,   562,   564,   569,   570,
     572,   577,   661,   575,   576,     0,   579,     0,   582,     0,
     584,     0,     0,     0,   585,   586,   587,   592,   593,   594,
     595,   596,   597,   598,   599,   600,   601,   602,   679,   604,
     605,   606,   607,   608,   609,   610,   611,   612,   613,   614,
     615,   616,   625,   626,   627,   628,   630,   632,  -229,   635,
     637,   638,   639,   640,   642,   644,   653,   654,   663,   674,
     658,   655,   659,   660,   666,   667,   669,   670,   675,   677,
     678,   681,   684,     0,   685,     0,     0,     0,     0,   302,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   393
};

static const yytype_int16 yycheck[] =
{
     216,   217,   218,    91,    92,   451,   339,     4,     5,     6,
      14,    15,    16,    17,    18,    25,    75,   570,    20,    21,
     115,    23,    24,     5,   170,   115,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,   159,    88,
      40,    41,    42,    43,    83,   138,     0,    83,    78,     3,
     119,   155,   102,     7,   102,     9,    10,    11,     8,    13,
      77,   156,    52,    53,    54,    19,   156,    57,   161,   155,
      83,    84,    26,   159,   106,   107,   108,   115,    45,    46,
      47,    48,    49,    50,    51,    39,    77,   156,   101,   170,
      44,    58,    59,    60,    61,    62,    63,    64,    12,    81,
      67,    68,    69,    71,    72,    73,    74,    75,    76,   159,
     160,   159,   160,    83,   447,   448,    70,   170,   156,   110,
     169,   160,   675,   159,   160,   155,    80,   159,    82,   146,
     147,   101,   155,    84,   151,   126,   159,   155,   141,   142,
     155,   159,    65,    66,   159,    52,    53,    54,    55,   159,
     101,    53,   155,    55,    56,   128,   147,   162,   163,   164,
     165,    52,    65,   170,    55,    68,   225,   171,   227,   171,
     171,   171,   170,   127,   171,   129,   156,   166,   167,   168,
     171,   159,   160,   139,   140,   159,   160,   107,   108,   148,
     149,   148,   149,   159,   527,   170,   529,   169,   153,   154,
     646,   148,   149,   171,   171,   169,   169,    86,    87,   170,
      89,   139,    91,    85,    93,    85,    95,    96,    97,    98,
      99,   100,   159,   311,   103,   104,   105,   169,   159,   170,
     109,   110,   156,   112,   113,   114,   169,   116,   156,   118,
     169,   120,   121,   155,   160,   156,   156,   160,   156,   155,
     159,   130,   131,   132,   133,   134,   135,   136,   137,   160,
     160,   160,   159,   159,   143,   144,   145,   155,   147,   159,
     155,   155,   155,   152,   155,   155,   101,   155,   155,   172,
     172,   170,   169,   159,   159,   159,   155,   155,   159,   156,
     172,   138,   171,   159,   159,   159,   159,   159,   159,   159,
     159,   159,   155,   155,    90,   160,   107,    92,   159,   138,
     263,   407,   169,   169,   101,   117,   265,   101,   172,   169,
     169,   169,   420,   169,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   169,   169,   169,   169,   169,   169,   169,
     556,   169,   169,   169,    78,   169,   169,   169,   169,   169,
     169,   169,   169,   569,   169,   169,   169,   156,   169,   169,
     172,   169,   169,   169,   156,   156,   156,   156,   156,   169,
     655,   169,   155,   169,   156,   156,   156,   155,   155,   155,
     155,   302,   156,   155,   661,   156,   159,   155,    49,    -1,
     169,   207,   290,    -1,    -1,    -1,    74,    -1,   159,   169,
     169,   159,   169,   169,   169,   169,   169,   169,   155,   169,
     169,   159,   169,   169,   169,   169,   169,   169,   159,   159,
     171,   159,   159,   155,   170,   155,   169,   169,   155,   155,
     169,   159,    78,   169,   169,    -1,   169,    -1,   169,    -1,
     169,    -1,    -1,    -1,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   169,   169,   169,   169,   169,   674,   169,
     169,   169,   169,   169,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   169,   169,   155,   169,   169,   172,   169,
     169,   169,   169,   169,   169,   169,   169,   169,   159,   155,
     169,   172,   169,   169,   169,   169,   169,   169,   155,   169,
     169,   169,   169,    -1,   169,    -1,    -1,    -1,    -1,   220,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   272
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint16 yystos[] =
{
       0,   174,     0,     3,     7,     9,    10,    11,    13,    19,
      26,    39,    44,    70,    80,    82,   127,   129,   175,   176,
     184,   186,   188,   189,   190,   191,   193,   201,   212,   222,
     238,   276,   285,   305,   170,     8,   159,   155,    12,   192,
     170,   170,   223,   213,   170,   170,   286,    83,   159,   160,
     210,   311,   128,   156,   177,   159,   169,   169,   169,   194,
     202,   170,   170,   239,   277,    83,   101,   288,   289,   139,
     211,    85,   307,   211,    85,   309,   169,   187,     4,     5,
       6,   171,   178,   185,    14,    15,    16,    17,    18,   171,
     195,    20,    21,    23,    24,   171,   203,   224,   214,    45,
      46,    47,    48,    49,    50,    51,    58,    59,    60,    61,
      62,    63,    64,    67,    68,    69,   171,   240,    71,    72,
      73,    74,    75,    76,   171,   278,    84,   289,   159,   160,
       5,    81,   290,    83,    84,   289,   159,   170,   310,   311,
     310,   169,   155,   159,   155,   159,   159,   169,   156,   156,
     155,   156,   156,   210,   210,   209,    25,   159,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
     171,   225,    40,    41,    42,    43,   171,   215,   160,   160,
     160,   266,   267,   160,   268,   269,   159,    52,    53,    54,
      55,   159,   272,   273,    52,    55,    52,    53,    54,    57,
      53,    55,    56,   159,   155,   155,    65,    66,   159,   274,
     275,   155,   156,   155,   155,   155,   155,   155,   155,   138,
     161,   301,   159,   101,   170,   306,   312,   308,   180,   179,
     182,   181,   183,   196,   197,   198,   199,   200,   204,   205,
     169,   208,   159,   207,   159,   155,   155,   159,   159,   159,
     156,   159,   159,   159,   159,   159,   159,   159,   155,   155,
     241,   242,   169,   172,   169,   172,   246,   247,   248,   249,
     250,   251,   172,   252,   253,   255,   256,   257,   254,   263,
     264,   262,   265,   258,   261,   160,   270,   271,   270,   245,
     172,   259,   260,   279,   166,   167,   168,   373,   281,   373,
     373,   373,   301,   139,   140,   302,   159,   160,   365,   291,
     310,    86,    87,    89,    91,    93,    95,    96,    97,    98,
      99,   100,   103,   104,   105,   109,   110,   112,   113,   114,
     116,   118,   120,   121,   130,   131,   132,   133,   134,   135,
     136,   137,   143,   144,   145,   147,   152,   171,   313,   310,
     169,   169,   169,   169,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   159,   169,   227,   228,   226,   229,   231,
     232,   230,   233,   234,   235,   236,   237,   155,   159,   155,
     159,   220,   221,   169,   169,   266,   268,   169,   169,   169,
     169,   169,   169,   272,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   169,   169,   169,   138,   172,   243,   244,
     169,   274,   169,   169,   169,   280,   169,   282,   283,   284,
     302,   141,   142,   155,   303,    77,   146,   147,   151,   287,
     292,   210,   315,    90,    92,   107,   108,   361,   106,   107,
     108,   159,   107,   156,   156,   156,   156,   101,   101,   156,
     155,   334,   156,   156,   115,   156,   117,   119,   156,   156,
     359,   156,   155,   155,   155,   155,   365,   156,   115,   156,
     115,   156,   155,   156,   148,   149,   159,   155,   169,   169,
     169,   169,   169,   169,   169,   169,   169,   169,   169,   169,
     159,   216,   159,   218,   169,   169,   271,   169,   169,   169,
     169,   169,   169,   303,   297,    78,   155,   364,   148,   149,
     155,   171,   314,   360,   316,   317,   159,   159,   321,   159,
     159,   318,   159,   323,   324,   325,   326,   102,   365,   102,
     365,   332,   333,   364,   335,   346,   348,   347,   357,   344,
     343,   345,   170,   349,   350,   351,   352,   355,   329,   342,
     354,   353,   337,   336,   338,   341,   155,   155,   153,   154,
     206,   217,   169,   219,   169,    78,   298,   300,   293,   155,
     155,   294,   169,    88,   169,   169,   169,   159,   363,   169,
     319,   320,   169,   322,   169,   169,   169,   169,   365,   327,
     365,   330,   169,   169,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   366,   169,   169,   169,   169,   169,   169,
     169,   169,   169,   169,   169,   169,   169,   373,   162,   163,
     164,   165,   374,   339,   340,   169,   169,   169,   155,   304,
     169,   299,   169,   373,   374,   169,   362,   169,   169,   169,
     169,   328,   169,   331,   169,    77,   110,   126,   147,   171,
     367,   356,   358,   169,   169,   172,   295,   296,   169,   169,
     169,    78,   364,   159,   148,   149,   169,   169,   298,   169,
     169,   304,   370,   371,   155,   155,   372,   169,   169,   373,
     374,   169,   368,   369,   169,   169
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 22:
#line 296 "cfparse.y"
    {
			struct passwd *pw;

			if ((pw = getpwnam((yyvsp[(2) - (2)].val)->v)) == NULL) {
				yyerror("unknown user \"%s\"", (yyvsp[(2) - (2)].val)->v);
				return -1;
			}
			lcconf->uid = pw->pw_uid;
		}
    break;

  case 24:
#line 306 "cfparse.y"
    { lcconf->uid = (yyvsp[(2) - (2)].num); }
    break;

  case 26:
#line 308 "cfparse.y"
    {
			struct group *gr;

			if ((gr = getgrnam((yyvsp[(2) - (2)].val)->v)) == NULL) {
				yyerror("unknown group \"%s\"", (yyvsp[(2) - (2)].val)->v);
				return -1;
			}
			lcconf->gid = gr->gr_gid;
		}
    break;

  case 28:
#line 318 "cfparse.y"
    { lcconf->gid = (yyvsp[(2) - (2)].num); }
    break;

  case 30:
#line 319 "cfparse.y"
    { lcconf->chroot = (yyvsp[(2) - (2)].val)->v; }
    break;

  case 32:
#line 325 "cfparse.y"
    {
			if ((yyvsp[(2) - (3)].num) >= LC_PATHTYPE_MAX) {
				yyerror("invalid path type %d", (yyvsp[(2) - (3)].num));
				return -1;
			}

			/* free old pathinfo */
			if (lcconf->pathinfo[(yyvsp[(2) - (3)].num)])
				racoon_free(lcconf->pathinfo[(yyvsp[(2) - (3)].num)]);

			/* set new pathinfo */
			lcconf->pathinfo[(yyvsp[(2) - (3)].num)] = racoon_strdup((yyvsp[(3) - (3)].val)->v);
			STRDUP_FATAL(lcconf->pathinfo[(yyvsp[(2) - (3)].num)]);
			vfree((yyvsp[(3) - (3)].val));
		}
    break;

  case 34:
#line 345 "cfparse.y"
    { lcconf->complex_bundle = (yyvsp[(2) - (2)].num); }
    break;

  case 36:
#line 351 "cfparse.y"
    {
			char path[MAXPATHLEN];

			getpathname(path, sizeof(path),
				LC_PATHTYPE_INCLUDE, (yyvsp[(2) - (3)].val)->v);
			vfree((yyvsp[(2) - (3)].val));
			if (yycf_switch_buffer(path) != 0)
				return -1;
		}
    break;

  case 37:
#line 365 "cfparse.y"
    {
			lcconf->pfkey_buffer_size = (yyvsp[(2) - (3)].num);
        }
    break;

  case 38:
#line 372 "cfparse.y"
    {
			if ((yyvsp[(2) - (3)].num) >= LC_GSSENC_MAX) {
				yyerror("invalid GSS ID encoding %d", (yyvsp[(2) - (3)].num));
				return -1;
			}
			lcconf->gss_id_enc = (yyvsp[(2) - (3)].num);
		}
    break;

  case 40:
#line 387 "cfparse.y"
    {
			/*
			 * set the loglevel to the value specified
			 * in the configuration file plus the number
			 * of -d options specified on the command line
			 */
			loglevel += (yyvsp[(1) - (1)].num) - oldloglevel;
			oldloglevel = (yyvsp[(1) - (1)].num);
		}
    break;

  case 44:
#line 407 "cfparse.y"
    { lcconf->pad_random = (yyvsp[(2) - (2)].num); }
    break;

  case 46:
#line 408 "cfparse.y"
    { lcconf->pad_randomlen = (yyvsp[(2) - (2)].num); }
    break;

  case 48:
#line 409 "cfparse.y"
    { lcconf->pad_maxsize = (yyvsp[(2) - (2)].num); }
    break;

  case 50:
#line 410 "cfparse.y"
    { lcconf->pad_strict = (yyvsp[(2) - (2)].num); }
    break;

  case 52:
#line 411 "cfparse.y"
    { lcconf->pad_excltail = (yyvsp[(2) - (2)].num); }
    break;

  case 57:
#line 424 "cfparse.y"
    {
			myaddr_listen((yyvsp[(2) - (2)].saddr), FALSE);
		}
    break;

  case 59:
#line 429 "cfparse.y"
    {
#ifdef ENABLE_NATT
			myaddr_listen((yyvsp[(2) - (2)].saddr), TRUE);
#else
			yyerror("NAT-T support not compiled in.");
#endif
		}
    break;

  case 61:
#line 438 "cfparse.y"
    {
#ifdef ENABLE_ADMINPORT
			adminsock_conf((yyvsp[(2) - (5)].val), (yyvsp[(3) - (5)].val), (yyvsp[(4) - (5)].val), (yyvsp[(5) - (5)].num));
#else
			yywarn("admin port support not compiled in");
#endif
		}
    break;

  case 63:
#line 447 "cfparse.y"
    {
#ifdef ENABLE_ADMINPORT
			adminsock_conf((yyvsp[(2) - (2)].val), NULL, NULL, -1);
#else
			yywarn("admin port support not compiled in");
#endif
		}
    break;

  case 65:
#line 456 "cfparse.y"
    {
#ifdef ENABLE_ADMINPORT
			adminsock_path = NULL;
#else
			yywarn("admin port support not compiled in");
#endif
		}
    break;

  case 67:
#line 464 "cfparse.y"
    { lcconf->strict_address = TRUE; }
    break;

  case 69:
#line 468 "cfparse.y"
    {
			char portbuf[10];

			snprintf(portbuf, sizeof(portbuf), "%ld", (yyvsp[(2) - (2)].num));
			(yyval.saddr) = str2saddr((yyvsp[(1) - (2)].val)->v, portbuf);
			vfree((yyvsp[(1) - (2)].val));
			if (!(yyval.saddr))
				return -1;
		}
    break;

  case 70:
#line 479 "cfparse.y"
    { (yyval.num) = PORT_ISAKMP; }
    break;

  case 71:
#line 480 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 72:
#line 485 "cfparse.y"
    {
#ifndef ENABLE_HYBRID
			yyerror("racoon not configured with --enable-hybrid");
			return -1;
#endif
#ifndef HAVE_LIBRADIUS
			yyerror("racoon not configured with --with-libradius");
			return -1;
#endif
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			xauth_rad_config.timeout = 3;
			xauth_rad_config.retries = 3;
#endif
#endif
		}
    break;

  case 76:
#line 508 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			int i = xauth_rad_config.auth_server_count;
			if (i == RADIUS_MAX_SERVERS) {
				yyerror("maximum radius auth servers exceeded");
				return -1;
			}

			xauth_rad_config.auth_server_list[i].host = vdup((yyvsp[(2) - (3)].val));
			xauth_rad_config.auth_server_list[i].secret = vdup((yyvsp[(3) - (3)].val));
			xauth_rad_config.auth_server_list[i].port = 0; // default port
			xauth_rad_config.auth_server_count++;
#endif
#endif
		}
    break;

  case 78:
#line 526 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			int i = xauth_rad_config.auth_server_count;
			if (i == RADIUS_MAX_SERVERS) {
				yyerror("maximum radius auth servers exceeded");
				return -1;
			}

			xauth_rad_config.auth_server_list[i].host = vdup((yyvsp[(2) - (4)].val));
			xauth_rad_config.auth_server_list[i].secret = vdup((yyvsp[(4) - (4)].val));
			xauth_rad_config.auth_server_list[i].port = (yyvsp[(3) - (4)].num);
			xauth_rad_config.auth_server_count++;
#endif
#endif
		}
    break;

  case 80:
#line 544 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			int i = xauth_rad_config.acct_server_count;
			if (i == RADIUS_MAX_SERVERS) {
				yyerror("maximum radius account servers exceeded");
				return -1;
			}

			xauth_rad_config.acct_server_list[i].host = vdup((yyvsp[(2) - (3)].val));
			xauth_rad_config.acct_server_list[i].secret = vdup((yyvsp[(3) - (3)].val));
			xauth_rad_config.acct_server_list[i].port = 0; // default port
			xauth_rad_config.acct_server_count++;
#endif
#endif
		}
    break;

  case 82:
#line 562 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			int i = xauth_rad_config.acct_server_count;
			if (i == RADIUS_MAX_SERVERS) {
				yyerror("maximum radius account servers exceeded");
				return -1;
			}

			xauth_rad_config.acct_server_list[i].host = vdup((yyvsp[(2) - (4)].val));
			xauth_rad_config.acct_server_list[i].secret = vdup((yyvsp[(4) - (4)].val));
			xauth_rad_config.acct_server_list[i].port = (yyvsp[(3) - (4)].num);
			xauth_rad_config.acct_server_count++;
#endif
#endif
		}
    break;

  case 84:
#line 580 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			xauth_rad_config.timeout = (yyvsp[(2) - (2)].num);
#endif
#endif
		}
    break;

  case 86:
#line 589 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			xauth_rad_config.retries = (yyvsp[(2) - (2)].num);
#endif
#endif
		}
    break;

  case 88:
#line 601 "cfparse.y"
    {
#ifndef ENABLE_HYBRID
			yyerror("racoon not configured with --enable-hybrid");
			return -1;
#endif
#ifndef HAVE_LIBLDAP
			yyerror("racoon not configured with --with-libldap");
			return -1;
#endif
		}
    break;

  case 92:
#line 618 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (((yyvsp[(2) - (2)].num)<2)||((yyvsp[(2) - (2)].num)>3))
				yyerror("invalid ldap protocol version (2|3)");
			xauth_ldap_config.pver = (yyvsp[(2) - (2)].num);
#endif
#endif
		}
    break;

  case 94:
#line 629 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.host != NULL)
				vfree(xauth_ldap_config.host);
			xauth_ldap_config.host = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 96:
#line 640 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			xauth_ldap_config.port = (yyvsp[(2) - (2)].num);
#endif
#endif
		}
    break;

  case 98:
#line 649 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.base != NULL)
				vfree(xauth_ldap_config.base);
			xauth_ldap_config.base = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 100:
#line 660 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			xauth_ldap_config.subtree = (yyvsp[(2) - (2)].num);
#endif
#endif
		}
    break;

  case 102:
#line 669 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.bind_dn != NULL)
				vfree(xauth_ldap_config.bind_dn);
			xauth_ldap_config.bind_dn = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 104:
#line 680 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.bind_pw != NULL)
				vfree(xauth_ldap_config.bind_pw);
			xauth_ldap_config.bind_pw = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 106:
#line 691 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.attr_user != NULL)
				vfree(xauth_ldap_config.attr_user);
			xauth_ldap_config.attr_user = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 108:
#line 702 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.attr_addr != NULL)
				vfree(xauth_ldap_config.attr_addr);
			xauth_ldap_config.attr_addr = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 110:
#line 713 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.attr_mask != NULL)
				vfree(xauth_ldap_config.attr_mask);
			xauth_ldap_config.attr_mask = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 112:
#line 724 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.attr_group != NULL)
				vfree(xauth_ldap_config.attr_group);
			xauth_ldap_config.attr_group = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 114:
#line 735 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			if (xauth_ldap_config.attr_member != NULL)
				vfree(xauth_ldap_config.attr_member);
			xauth_ldap_config.attr_member = vdup((yyvsp[(2) - (2)].val));
#endif
#endif
		}
    break;

  case 119:
#line 757 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			if (inet_pton(AF_INET, (yyvsp[(2) - (2)].val)->v,
			     &isakmp_cfg_config.network4) != 1)
				yyerror("bad IPv4 network address.");
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 121:
#line 768 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			if (inet_pton(AF_INET, (yyvsp[(2) - (2)].val)->v,
			    &isakmp_cfg_config.netmask4) != 1)
				yyerror("bad IPv4 netmask address.");
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 125:
#line 783 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.splitnet_type = UNITY_LOCAL_LAN;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 127:
#line 792 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.splitnet_type = UNITY_SPLIT_INCLUDE;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 129:
#line 801 "cfparse.y"
    {
#ifndef ENABLE_HYBRID
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 131:
#line 808 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			strncpy(&isakmp_cfg_config.default_domain[0], 
			    (yyvsp[(2) - (2)].val)->v, MAXPATHLEN);
			isakmp_cfg_config.default_domain[MAXPATHLEN] = '\0';
			vfree((yyvsp[(2) - (2)].val));
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 133:
#line 820 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.authsource = ISAKMP_CFG_AUTH_SYSTEM;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 135:
#line 829 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			isakmp_cfg_config.authsource = ISAKMP_CFG_AUTH_RADIUS;
#else /* HAVE_LIBRADIUS */
			yyerror("racoon not configured with --with-libradius");
#endif /* HAVE_LIBRADIUS */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 137:
#line 842 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBPAM
			isakmp_cfg_config.authsource = ISAKMP_CFG_AUTH_PAM;
#else /* HAVE_LIBPAM */
			yyerror("racoon not configured with --with-libpam");
#endif /* HAVE_LIBPAM */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 139:
#line 855 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			isakmp_cfg_config.authsource = ISAKMP_CFG_AUTH_LDAP;
#else /* HAVE_LIBLDAP */
			yyerror("racoon not configured with --with-libldap");
#endif /* HAVE_LIBLDAP */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 141:
#line 868 "cfparse.y"
    {
#ifndef ENABLE_HYBRID
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 143:
#line 875 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.groupsource = ISAKMP_CFG_GROUP_SYSTEM;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 145:
#line 884 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			isakmp_cfg_config.groupsource = ISAKMP_CFG_GROUP_LDAP;
#else /* HAVE_LIBLDAP */
			yyerror("racoon not configured with --with-libldap");
#endif /* HAVE_LIBLDAP */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 147:
#line 897 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.accounting = ISAKMP_CFG_ACCT_NONE;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 149:
#line 906 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.accounting = ISAKMP_CFG_ACCT_SYSTEM;
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 151:
#line 915 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			isakmp_cfg_config.accounting = ISAKMP_CFG_ACCT_RADIUS;
#else /* HAVE_LIBRADIUS */
			yyerror("racoon not configured with --with-libradius");
#endif /* HAVE_LIBRADIUS */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 153:
#line 928 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBPAM
			isakmp_cfg_config.accounting = ISAKMP_CFG_ACCT_PAM;
#else /* HAVE_LIBPAM */
			yyerror("racoon not configured with --with-libpam");
#endif /* HAVE_LIBPAM */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 155:
#line 941 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			if (isakmp_cfg_resize_pool((yyvsp[(2) - (2)].num)) != 0)
				yyerror("cannot allocate memory for pool");
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 157:
#line 951 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.pfs_group = (yyvsp[(2) - (2)].num);
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 159:
#line 960 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.save_passwd = (yyvsp[(2) - (2)].num);
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 161:
#line 969 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.auth_throttle = (yyvsp[(2) - (2)].num);
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 163:
#line 978 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			isakmp_cfg_config.confsource = ISAKMP_CFG_CONF_LOCAL;
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 165:
#line 987 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBRADIUS
			isakmp_cfg_config.confsource = ISAKMP_CFG_CONF_RADIUS;
#else /* HAVE_LIBRADIUS */
			yyerror("racoon not configured with --with-libradius");
#endif /* HAVE_LIBRADIUS */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 167:
#line 1000 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
#ifdef HAVE_LIBLDAP
			isakmp_cfg_config.confsource = ISAKMP_CFG_CONF_LDAP;
#else /* HAVE_LIBLDAP */
			yyerror("racoon not configured with --with-libldap");
#endif /* HAVE_LIBLDAP */
#else /* ENABLE_HYBRID */
			yyerror("racoon not configured with --enable-hybrid");
#endif /* ENABLE_HYBRID */
		}
    break;

  case 169:
#line 1013 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			strncpy(&isakmp_cfg_config.motd[0], (yyvsp[(2) - (2)].val)->v, MAXPATHLEN);
			isakmp_cfg_config.motd[MAXPATHLEN] = '\0';
			vfree((yyvsp[(2) - (2)].val));
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 173:
#line 1031 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			struct isakmp_cfg_config *icc = &isakmp_cfg_config;

			if (icc->dns4_index > MAXNS)
				yyerror("No more than %d DNS", MAXNS);
			if (inet_pton(AF_INET, (yyvsp[(1) - (1)].val)->v,
			    &icc->dns4[icc->dns4_index++]) != 1)
				yyerror("bad IPv4 DNS address.");
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 176:
#line 1052 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			struct isakmp_cfg_config *icc = &isakmp_cfg_config;

			if (icc->nbns4_index > MAXWINS)
				yyerror("No more than %d WINS", MAXWINS);
			if (inet_pton(AF_INET, (yyvsp[(1) - (1)].val)->v,
			    &icc->nbns4[icc->nbns4_index++]) != 1)
				yyerror("bad IPv4 WINS address.");
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 179:
#line 1073 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			struct isakmp_cfg_config *icc = &isakmp_cfg_config;
			struct unity_network network;
			memset(&network,0,sizeof(network));

			if (inet_pton(AF_INET, (yyvsp[(1) - (2)].val)->v, &network.addr4) != 1)
				yyerror("bad IPv4 SPLIT address.");

			/* Turn $2 (the prefix) into a subnet mask */
			network.mask4.s_addr = ((yyvsp[(2) - (2)].num)) ? htonl(~((1 << (32 - (yyvsp[(2) - (2)].num))) - 1)) : 0;

			/* add the network to our list */ 
			if (splitnet_list_add(&icc->splitnet_list, &network,&icc->splitnet_count))
				yyerror("Unable to allocate split network");
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 182:
#line 1100 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			char * groupname = NULL;
			char ** grouplist = NULL;
			struct isakmp_cfg_config *icc = &isakmp_cfg_config;

			grouplist = racoon_realloc(icc->grouplist,
					sizeof(char**)*(icc->groupcount+1));
			if (grouplist == NULL) {
				yyerror("unable to allocate auth group list");
				return -1;
			}

			groupname = racoon_malloc((yyvsp[(1) - (1)].val)->l+1);
			if (groupname == NULL) {
				yyerror("unable to allocate auth group name");
				return -1;
			}

			memcpy(groupname,(yyvsp[(1) - (1)].val)->v,(yyvsp[(1) - (1)].val)->l);
			groupname[(yyvsp[(1) - (1)].val)->l]=0;
			grouplist[icc->groupcount]=groupname;
			icc->grouplist = grouplist;
			icc->groupcount++;

			vfree((yyvsp[(1) - (1)].val));
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 185:
#line 1138 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			struct isakmp_cfg_config *icc = &isakmp_cfg_config;

			if (!icc->splitdns_len)
			{
				icc->splitdns_list = racoon_malloc((yyvsp[(1) - (1)].val)->l);
				if(icc->splitdns_list == NULL) {
					yyerror("error allocating splitdns list buffer");
					return -1;
				}
				memcpy(icc->splitdns_list,(yyvsp[(1) - (1)].val)->v,(yyvsp[(1) - (1)].val)->l);
				icc->splitdns_len = (yyvsp[(1) - (1)].val)->l;
			}
			else
			{
				int len = icc->splitdns_len + (yyvsp[(1) - (1)].val)->l + 1;
				icc->splitdns_list = racoon_realloc(icc->splitdns_list,len);
				if(icc->splitdns_list == NULL) {
					yyerror("error allocating splitdns list buffer");
					return -1;
				}
				icc->splitdns_list[icc->splitdns_len] = ',';
				memcpy(icc->splitdns_list + icc->splitdns_len + 1, (yyvsp[(1) - (1)].val)->v, (yyvsp[(1) - (1)].val)->l);
				icc->splitdns_len = len;
			}
			vfree((yyvsp[(1) - (1)].val));
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 189:
#line 1182 "cfparse.y"
    {
			lcconf->retry_counter = (yyvsp[(2) - (2)].num);
		}
    break;

  case 191:
#line 1187 "cfparse.y"
    {
			lcconf->retry_interval = (yyvsp[(2) - (3)].num) * (yyvsp[(3) - (3)].num);
		}
    break;

  case 193:
#line 1192 "cfparse.y"
    {
			lcconf->count_persend = (yyvsp[(2) - (2)].num);
		}
    break;

  case 195:
#line 1197 "cfparse.y"
    {
			lcconf->retry_checkph1 = (yyvsp[(2) - (3)].num) * (yyvsp[(3) - (3)].num);
		}
    break;

  case 197:
#line 1202 "cfparse.y"
    {
			lcconf->wait_ph2complete = (yyvsp[(2) - (3)].num) * (yyvsp[(3) - (3)].num);
		}
    break;

  case 199:
#line 1207 "cfparse.y"
    {
#ifdef ENABLE_NATT
        		if (libipsec_opt & LIBIPSEC_OPT_NATT)
				lcconf->natt_ka_interval = (yyvsp[(2) - (3)].num) * (yyvsp[(3) - (3)].num);
			else
                		yyerror("libipsec lacks NAT-T support");
#else
			yyerror("NAT-T support not compiled in.");
#endif
		}
    break;

  case 201:
#line 1223 "cfparse.y"
    {
			cur_sainfo = newsainfo();
			if (cur_sainfo == NULL) {
				yyerror("failed to allocate sainfo");
				return -1;
			}
		}
    break;

  case 202:
#line 1231 "cfparse.y"
    {
			struct sainfo *check;

			/* default */
			if (cur_sainfo->algs[algclass_ipsec_enc] == 0) {
				yyerror("no encryption algorithm at %s",
					sainfo2str(cur_sainfo));
				return -1;
			}
			if (cur_sainfo->algs[algclass_ipsec_auth] == 0) {
				yyerror("no authentication algorithm at %s",
					sainfo2str(cur_sainfo));
				return -1;
			}
			if (cur_sainfo->algs[algclass_ipsec_comp] == 0) {
				yyerror("no compression algorithm at %s",
					sainfo2str(cur_sainfo));
				return -1;
			}

			/* duplicate check */
			check = getsainfo(cur_sainfo->idsrc,
					  cur_sainfo->iddst,
					  cur_sainfo->id_i,
					  NULL,
					  cur_sainfo->remoteid);

			if (check && ((check->idsrc != SAINFO_ANONYMOUS) &&
				      (cur_sainfo->idsrc != SAINFO_ANONYMOUS))) {
				yyerror("duplicated sainfo: %s",
					sainfo2str(cur_sainfo));
				return -1;
			}

			inssainfo(cur_sainfo);
		}
    break;

  case 204:
#line 1271 "cfparse.y"
    {
			cur_sainfo->idsrc = SAINFO_ANONYMOUS;
			cur_sainfo->iddst = SAINFO_ANONYMOUS;
		}
    break;

  case 205:
#line 1276 "cfparse.y"
    {
			cur_sainfo->idsrc = SAINFO_ANONYMOUS;
			cur_sainfo->iddst = SAINFO_CLIENTADDR;
		}
    break;

  case 206:
#line 1281 "cfparse.y"
    {
			cur_sainfo->idsrc = SAINFO_ANONYMOUS;
			cur_sainfo->iddst = (yyvsp[(2) - (2)].val);
		}
    break;

  case 207:
#line 1286 "cfparse.y"
    {
			cur_sainfo->idsrc = (yyvsp[(1) - (2)].val);
			cur_sainfo->iddst = SAINFO_ANONYMOUS;
		}
    break;

  case 208:
#line 1291 "cfparse.y"
    {
			cur_sainfo->idsrc = (yyvsp[(1) - (2)].val);
			cur_sainfo->iddst = SAINFO_CLIENTADDR;
		}
    break;

  case 209:
#line 1296 "cfparse.y"
    {
			cur_sainfo->idsrc = (yyvsp[(1) - (2)].val);
			cur_sainfo->iddst = (yyvsp[(2) - (2)].val);
		}
    break;

  case 210:
#line 1303 "cfparse.y"
    {
			char portbuf[10];
			struct sockaddr *saddr;

			if (((yyvsp[(5) - (5)].num) == IPPROTO_ICMP || (yyvsp[(5) - (5)].num) == IPPROTO_ICMPV6)
			 && ((yyvsp[(4) - (5)].num) != IPSEC_PORT_ANY || (yyvsp[(4) - (5)].num) != IPSEC_PORT_ANY)) {
				yyerror("port number must be \"any\".");
				return -1;
			}

			snprintf(portbuf, sizeof(portbuf), "%lu", (yyvsp[(4) - (5)].num));
			saddr = str2saddr((yyvsp[(2) - (5)].val)->v, portbuf);
			vfree((yyvsp[(2) - (5)].val));
			if (saddr == NULL)
				return -1;

			switch (saddr->sa_family) {
			case AF_INET:
				if ((yyvsp[(5) - (5)].num) == IPPROTO_ICMPV6) {
					yyerror("upper layer protocol mismatched.\n");
					racoon_free(saddr);
					return -1;
				}
				(yyval.val) = ipsecdoi_sockaddr2id(saddr,
										  (yyvsp[(3) - (5)].num) == ~0 ? (sizeof(struct in_addr) << 3): (yyvsp[(3) - (5)].num),
										  (yyvsp[(5) - (5)].num));
				break;
#ifdef INET6
			case AF_INET6:
				if ((yyvsp[(5) - (5)].num) == IPPROTO_ICMP) {
					yyerror("upper layer protocol mismatched.\n");
					racoon_free(saddr);
					return -1;
				}
				(yyval.val) = ipsecdoi_sockaddr2id(saddr, 
										  (yyvsp[(3) - (5)].num) == ~0 ? (sizeof(struct in6_addr) << 3): (yyvsp[(3) - (5)].num),
										  (yyvsp[(5) - (5)].num));
				break;
#endif
			default:
				yyerror("invalid family: %d", saddr->sa_family);
				(yyval.val) = NULL;
				break;
			}
			racoon_free(saddr);
			if ((yyval.val) == NULL)
				return -1;
		}
    break;

  case 211:
#line 1352 "cfparse.y"
    {
			char portbuf[10];
			struct sockaddr *laddr = NULL, *haddr = NULL;
			char *cur = NULL;

			if (((yyvsp[(6) - (6)].num) == IPPROTO_ICMP || (yyvsp[(6) - (6)].num) == IPPROTO_ICMPV6)
			 && ((yyvsp[(5) - (6)].num) != IPSEC_PORT_ANY || (yyvsp[(5) - (6)].num) != IPSEC_PORT_ANY)) {
				yyerror("port number must be \"any\".");
				return -1;
			}

			snprintf(portbuf, sizeof(portbuf), "%lu", (yyvsp[(5) - (6)].num));
			
			laddr = str2saddr((yyvsp[(2) - (6)].val)->v, portbuf);
			if (laddr == NULL) {
			    return -1;
			}
			vfree((yyvsp[(2) - (6)].val));
			haddr = str2saddr((yyvsp[(3) - (6)].val)->v, portbuf);
			if (haddr == NULL) {
			    racoon_free(laddr);
			    return -1;
			}
			vfree((yyvsp[(3) - (6)].val));

			switch (laddr->sa_family) {
			case AF_INET:
				if ((yyvsp[(6) - (6)].num) == IPPROTO_ICMPV6) {
				    yyerror("upper layer protocol mismatched.\n");
				    if (laddr)
					racoon_free(laddr);
				    if (haddr)
					racoon_free(haddr);
				    return -1;
				}
                                (yyval.val) = ipsecdoi_sockrange2id(laddr, haddr, 
							   (yyvsp[(6) - (6)].num));
				break;
#ifdef INET6
			case AF_INET6:
				if ((yyvsp[(6) - (6)].num) == IPPROTO_ICMP) {
					yyerror("upper layer protocol mismatched.\n");
					if (laddr)
					    racoon_free(laddr);
					if (haddr)
					    racoon_free(haddr);
					return -1;
				}
				(yyval.val) = ipsecdoi_sockrange2id(laddr, haddr, 
							       (yyvsp[(6) - (6)].num));
				break;
#endif
			default:
				yyerror("invalid family: %d", laddr->sa_family);
				(yyval.val) = NULL;
				break;
			}
			if (laddr)
			    racoon_free(laddr);
			if (haddr)
			    racoon_free(haddr);
			if ((yyval.val) == NULL)
				return -1;
		}
    break;

  case 212:
#line 1417 "cfparse.y"
    {
			struct ipsecdoi_id_b *id_b;

			if ((yyvsp[(1) - (2)].num) == IDTYPE_ASN1DN) {
				yyerror("id type forbidden: %d", (yyvsp[(1) - (2)].num));
				(yyval.val) = NULL;
				return -1;
			}

			(yyvsp[(2) - (2)].val)->l--;

			(yyval.val) = vmalloc(sizeof(*id_b) + (yyvsp[(2) - (2)].val)->l);
			if ((yyval.val) == NULL) {
				yyerror("failed to allocate identifier");
				return -1;
			}

			id_b = (struct ipsecdoi_id_b *)(yyval.val)->v;
			id_b->type = idtype2doi((yyvsp[(1) - (2)].num));

			id_b->proto_id = 0;
			id_b->port = 0;

			memcpy((yyval.val)->v + sizeof(*id_b), (yyvsp[(2) - (2)].val)->v, (yyvsp[(2) - (2)].val)->l);
		}
    break;

  case 213:
#line 1445 "cfparse.y"
    {
			cur_sainfo->id_i = NULL;
		}
    break;

  case 214:
#line 1449 "cfparse.y"
    {
			struct ipsecdoi_id_b *id_b;
			vchar_t *idv;

			if (set_identifier(&idv, (yyvsp[(2) - (3)].num), (yyvsp[(3) - (3)].val)) != 0) {
				yyerror("failed to set identifer.\n");
				return -1;
			}
			cur_sainfo->id_i = vmalloc(sizeof(*id_b) + idv->l);
			if (cur_sainfo->id_i == NULL) {
				yyerror("failed to allocate identifier");
				return -1;
			}

			id_b = (struct ipsecdoi_id_b *)cur_sainfo->id_i->v;
			id_b->type = idtype2doi((yyvsp[(2) - (3)].num));

			id_b->proto_id = 0;
			id_b->port = 0;

			memcpy(cur_sainfo->id_i->v + sizeof(*id_b),
			       idv->v, idv->l);
			vfree(idv);
		}
    break;

  case 215:
#line 1474 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			if ((cur_sainfo->group = vdup((yyvsp[(2) - (2)].val))) == NULL) {
				yyerror("failed to set sainfo xauth group.\n");
				return -1;
			}
#else
			yyerror("racoon not configured with --enable-hybrid");
			return -1;
#endif
 		}
    break;

  case 218:
#line 1492 "cfparse.y"
    {
			cur_sainfo->pfs_group = (yyvsp[(2) - (2)].num);
		}
    break;

  case 220:
#line 1497 "cfparse.y"
    {
			cur_sainfo->remoteid = (yyvsp[(2) - (2)].num);
		}
    break;

  case 222:
#line 1502 "cfparse.y"
    {
			cur_sainfo->lifetime = (yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num);
		}
    break;

  case 224:
#line 1507 "cfparse.y"
    {
#if 1
			yyerror("byte lifetime support is deprecated");
			return -1;
#else
			cur_sainfo->lifebyte = fix_lifebyte((yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num));
			if (cur_sainfo->lifebyte == 0)
				return -1;
#endif
		}
    break;

  case 226:
#line 1518 "cfparse.y"
    {
			cur_algclass = (yyvsp[(1) - (1)].num);
		}
    break;

  case 228:
#line 1526 "cfparse.y"
    {
			inssainfoalg(&cur_sainfo->algs[cur_algclass], (yyvsp[(1) - (1)].alg));
		}
    break;

  case 229:
#line 1530 "cfparse.y"
    {
			inssainfoalg(&cur_sainfo->algs[cur_algclass], (yyvsp[(1) - (1)].alg));
		}
    break;

  case 231:
#line 1537 "cfparse.y"
    {
			int defklen;

			(yyval.alg) = newsainfoalg();
			if ((yyval.alg) == NULL) {
				yyerror("failed to get algorithm allocation");
				return -1;
			}

			(yyval.alg)->alg = algtype2doi(cur_algclass, (yyvsp[(1) - (2)].num));
			if ((yyval.alg)->alg == -1) {
				yyerror("algorithm mismatched");
				racoon_free((yyval.alg));
				(yyval.alg) = NULL;
				return -1;
			}

			defklen = default_keylen(cur_algclass, (yyvsp[(1) - (2)].num));
			if (defklen == 0) {
				if ((yyvsp[(2) - (2)].num)) {
					yyerror("keylen not allowed");
					racoon_free((yyval.alg));
					(yyval.alg) = NULL;
					return -1;
				}
			} else {
				if ((yyvsp[(2) - (2)].num) && check_keylen(cur_algclass, (yyvsp[(1) - (2)].num), (yyvsp[(2) - (2)].num)) < 0) {
					yyerror("invalid keylen %d", (yyvsp[(2) - (2)].num));
					racoon_free((yyval.alg));
					(yyval.alg) = NULL;
					return -1;
				}
			}

			if ((yyvsp[(2) - (2)].num))
				(yyval.alg)->encklen = (yyvsp[(2) - (2)].num);
			else
				(yyval.alg)->encklen = defklen;

			/* check if it's supported algorithm by kernel */
			if (!(cur_algclass == algclass_ipsec_auth && (yyvsp[(1) - (2)].num) == algtype_non_auth)
			 && pk_checkalg(cur_algclass, (yyvsp[(1) - (2)].num), (yyval.alg)->encklen)) {
				int a = algclass2doi(cur_algclass);
				int b = algtype2doi(cur_algclass, (yyvsp[(1) - (2)].num));
				if (a == IPSECDOI_ATTR_AUTH)
					a = IPSECDOI_PROTO_IPSEC_AH;
				yyerror("algorithm %s not supported by the kernel (missing module?)",
					s_ipsecdoi_trns(a, b));
				racoon_free((yyval.alg));
				(yyval.alg) = NULL;
				return -1;
			}
		}
    break;

  case 232:
#line 1592 "cfparse.y"
    { (yyval.num) = ~0; }
    break;

  case 233:
#line 1593 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 234:
#line 1596 "cfparse.y"
    { (yyval.num) = IPSEC_PORT_ANY; }
    break;

  case 235:
#line 1597 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 236:
#line 1598 "cfparse.y"
    { (yyval.num) = IPSEC_PORT_ANY; }
    break;

  case 237:
#line 1601 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 238:
#line 1602 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 239:
#line 1603 "cfparse.y"
    { (yyval.num) = IPSEC_ULPROTO_ANY; }
    break;

  case 240:
#line 1606 "cfparse.y"
    { (yyval.num) = 0; }
    break;

  case 241:
#line 1607 "cfparse.y"
    { (yyval.num) = (yyvsp[(1) - (1)].num); }
    break;

  case 242:
#line 1613 "cfparse.y"
    {
			struct remoteconf *from, *new;

			if (getrmconf_by_name((yyvsp[(2) - (4)].val)->v) != NULL) {
				yyerror("named remoteconf \"%s\" already exists.");
				return -1;
			}

			from = getrmconf_by_name((yyvsp[(4) - (4)].val)->v);
			if (from == NULL) {
				yyerror("named parent remoteconf \"%s\" does not exist.",
					(yyvsp[(4) - (4)].val)->v);
				return -1;
			}

			new = duprmconf(from);
			if (new == NULL) {
				yyerror("failed to duplicate remoteconf from \"%s\".",
					(yyvsp[(4) - (4)].val)->v);
				return -1;
			}

			new->name = racoon_strdup((yyvsp[(2) - (4)].val)->v);
			cur_rmconf = new;

			vfree((yyvsp[(2) - (4)].val));
			vfree((yyvsp[(4) - (4)].val));
		}
    break;

  case 244:
#line 1643 "cfparse.y"
    {
			struct remoteconf *new;

			if (getrmconf_by_name((yyvsp[(2) - (2)].val)->v) != NULL) {
				yyerror("Named remoteconf \"%s\" already exists.");
				return -1;
			}

			new = newrmconf();
			if (new == NULL) {
				yyerror("failed to get new remoteconf.");
				return -1;
			}
			new->name = racoon_strdup((yyvsp[(2) - (2)].val)->v);
			cur_rmconf = new;

			vfree((yyvsp[(2) - (2)].val));
		}
    break;

  case 246:
#line 1663 "cfparse.y"
    {
			struct remoteconf *from, *new;

			from = getrmconf((yyvsp[(4) - (4)].saddr), GETRMCONF_F_NO_ANONYMOUS);
			if (from == NULL) {
				yyerror("failed to get remoteconf for %s.",
					saddr2str((yyvsp[(4) - (4)].saddr)));
				return -1;
			}

			new = duprmconf(from);
			if (new == NULL) {
				yyerror("failed to duplicate remoteconf from %s.",
					saddr2str((yyvsp[(4) - (4)].saddr)));
				return -1;
			}

			new->remote = (yyvsp[(2) - (4)].saddr);
			cur_rmconf = new;
		}
    break;

  case 248:
#line 1685 "cfparse.y"
    {
			struct remoteconf *new;

			new = newrmconf();
			if (new == NULL) {
				yyerror("failed to get new remoteconf.");
				return -1;
			}

			new->remote = (yyvsp[(2) - (2)].saddr);
			cur_rmconf = new;
		}
    break;

  case 250:
#line 1702 "cfparse.y"
    {
			/* check a exchange mode */
			if (cur_rmconf->etypes == NULL) {
				yyerror("no exchange mode specified.\n");
				return -1;
			}

			if (cur_rmconf->idvtype == IDTYPE_UNDEFINED)
				cur_rmconf->idvtype = IDTYPE_ADDRESS;

			if (cur_rmconf->idvtype == IDTYPE_ASN1DN) {
				if (cur_rmconf->mycertfile) {
					if (cur_rmconf->idv)
						yywarn("Both CERT and ASN1 ID "
						       "are set. Hope this is OK.\n");
					/* TODO: Preparse the DN here */
				} else if (cur_rmconf->idv) {
					/* OK, using asn1dn without X.509. */
				} else {
					yyerror("ASN1 ID not specified "
						"and no CERT defined!\n");
					return -1;
				}
			}
			
			if (cur_rmconf->spspec == NULL &&
			    cur_rmconf->inherited_from != NULL) {
				cur_rmconf->spspec = cur_rmconf->inherited_from->spspec;
			}
			if (set_isakmp_proposal(cur_rmconf) != 0)
				return -1;

			/* DH group settting if aggressive mode is there. */
			if (check_etypeok(cur_rmconf, (void*) ISAKMP_ETYPE_AGG)) {
				struct isakmpsa *p;
				int b = 0;

				/* DH group */
				for (p = cur_rmconf->proposal; p; p = p->next) {
					if (b == 0 || (b && b == p->dh_group)) {
						b = p->dh_group;
						continue;
					}
					yyerror("DH group must be equal "
						"in all proposals "
						"when aggressive mode is "
						"used.\n");
					return -1;
				}
				cur_rmconf->dh_group = b;

				if (cur_rmconf->dh_group == 0) {
					yyerror("DH group must be set in the proposal.\n");
					return -1;
				}

				/* DH group settting if PFS is required. */
				if (oakley_setdhgroup(cur_rmconf->dh_group,
						&cur_rmconf->dhgrp) < 0) {
					yyerror("failed to set DH value.\n");
					return -1;
				}
			}

			insrmconf(cur_rmconf);
		}
    break;

  case 251:
#line 1771 "cfparse.y"
    {
			(yyval.saddr) = newsaddr(sizeof(struct sockaddr));
			(yyval.saddr)->sa_family = AF_UNSPEC;
			((struct sockaddr_in *)(yyval.saddr))->sin_port = htons((yyvsp[(2) - (2)].num));
		}
    break;

  case 252:
#line 1777 "cfparse.y"
    {
			(yyval.saddr) = (yyvsp[(1) - (1)].saddr);
			if ((yyval.saddr) == NULL) {
				yyerror("failed to allocate sockaddr");
				return -1;
			}
		}
    break;

  case 255:
#line 1791 "cfparse.y"
    {
			if (cur_rmconf->remote != NULL) {
				yyerror("remote_address already specified");
				return -1;
			}
			cur_rmconf->remote = (yyvsp[(2) - (2)].saddr);
		}
    break;

  case 257:
#line 1800 "cfparse.y"
    {
			cur_rmconf->etypes = NULL;
		}
    break;

  case 259:
#line 1804 "cfparse.y"
    { cur_rmconf->doitype = (yyvsp[(2) - (2)].num); }
    break;

  case 261:
#line 1805 "cfparse.y"
    { cur_rmconf->sittype = (yyvsp[(2) - (2)].num); }
    break;

  case 264:
#line 1808 "cfparse.y"
    {
			yywarn("This directive without certtype will be removed!\n");
			yywarn("Please use 'peers_certfile x509 \"%s\";' instead\n", (yyvsp[(2) - (2)].val)->v);

			if (cur_rmconf->peerscert != NULL) {
				yyerror("peers_certfile already defined\n");
				return -1;
			}

			if (load_x509((yyvsp[(2) - (2)].val)->v, &cur_rmconf->peerscertfile,
				      &cur_rmconf->peerscert)) {
				yyerror("failed to load certificate \"%s\"\n",
					(yyvsp[(2) - (2)].val)->v);
				return -1;
			}

			vfree((yyvsp[(2) - (2)].val));
		}
    break;

  case 266:
#line 1828 "cfparse.y"
    {
			if (cur_rmconf->peerscert != NULL) {
				yyerror("peers_certfile already defined\n");
				return -1;
			}

			if (load_x509((yyvsp[(3) - (3)].val)->v, &cur_rmconf->peerscertfile,
				      &cur_rmconf->peerscert)) {
				yyerror("failed to load certificate \"%s\"\n",
					(yyvsp[(3) - (3)].val)->v);
				return -1;
			}

			vfree((yyvsp[(3) - (3)].val));
		}
    break;

  case 268:
#line 1845 "cfparse.y"
    {
			char path[MAXPATHLEN];
			int ret = 0;

			if (cur_rmconf->peerscert != NULL) {
				yyerror("peers_certfile already defined\n");
				return -1;
			}

			cur_rmconf->peerscert = vmalloc(1);
			if (cur_rmconf->peerscert == NULL) {
				yyerror("failed to allocate peerscert");
				return -1;
			}
			cur_rmconf->peerscert->v[0] = ISAKMP_CERT_PLAINRSA;

			getpathname(path, sizeof(path),
				    LC_PATHTYPE_CERT, (yyvsp[(3) - (3)].val)->v);
			if (rsa_parse_file(cur_rmconf->rsa_public, path,
					   RSA_TYPE_PUBLIC)) {
				yyerror("Couldn't parse keyfile.\n", path);
				return -1;
			}
			plog(LLV_DEBUG, LOCATION, NULL,
			     "Public PlainRSA keyfile parsed: %s\n", path);

			vfree((yyvsp[(3) - (3)].val));
		}
    break;

  case 270:
#line 1875 "cfparse.y"
    {
			if (cur_rmconf->peerscert != NULL) {
				yyerror("peers_certfile already defined\n");
				return -1;
			}
			cur_rmconf->peerscert = vmalloc(1);
			if (cur_rmconf->peerscert == NULL) {
				yyerror("failed to allocate peerscert");
				return -1;
			}
			cur_rmconf->peerscert->v[0] = ISAKMP_CERT_DNS;
		}
    break;

  case 272:
#line 1889 "cfparse.y"
    {
			if (cur_rmconf->cacert != NULL) {
				yyerror("ca_type already defined\n");
				return -1;
			}

			if (load_x509((yyvsp[(3) - (3)].val)->v, &cur_rmconf->cacertfile,
				      &cur_rmconf->cacert)) {
				yyerror("failed to load certificate \"%s\"\n",
					(yyvsp[(3) - (3)].val)->v);
				return -1;
			}

			vfree((yyvsp[(3) - (3)].val));
		}
    break;

  case 274:
#line 1905 "cfparse.y"
    { cur_rmconf->verify_cert = (yyvsp[(2) - (2)].num); }
    break;

  case 276:
#line 1906 "cfparse.y"
    { cur_rmconf->send_cert = (yyvsp[(2) - (2)].num); }
    break;

  case 278:
#line 1907 "cfparse.y"
    { cur_rmconf->send_cr = (yyvsp[(2) - (2)].num); }
    break;

  case 280:
#line 1908 "cfparse.y"
    { cur_rmconf->match_empty_cr = (yyvsp[(2) - (2)].num); }
    break;

  case 282:
#line 1910 "cfparse.y"
    {
			if (set_identifier(&cur_rmconf->idv, (yyvsp[(2) - (3)].num), (yyvsp[(3) - (3)].val)) != 0) {
				yyerror("failed to set identifer.\n");
				return -1;
			}
			cur_rmconf->idvtype = (yyvsp[(2) - (3)].num);
		}
    break;

  case 284:
#line 1919 "cfparse.y"
    {
			if (set_identifier_qual(&cur_rmconf->idv, (yyvsp[(2) - (4)].num), (yyvsp[(4) - (4)].val), (yyvsp[(3) - (4)].num)) != 0) {
				yyerror("failed to set identifer.\n");
				return -1;
			}
			cur_rmconf->idvtype = (yyvsp[(2) - (4)].num);
		}
    break;

  case 286:
#line 1928 "cfparse.y"
    {
#ifdef ENABLE_HYBRID
			/* formerly identifier type login */
			if (xauth_rmconf_used(&cur_rmconf->xauth) == -1) {
				yyerror("failed to allocate xauth state\n");
				return -1;
			}
			if ((cur_rmconf->xauth->login = vdup((yyvsp[(2) - (2)].val))) == NULL) {
				yyerror("failed to set identifer.\n");
				return -1;
			}
#else
			yyerror("racoon not configured with --enable-hybrid");
#endif
		}
    break;

  case 288:
#line 1945 "cfparse.y"
    {
			struct idspec  *id;
			id = newidspec();
			if (id == NULL) {
				yyerror("failed to allocate idspec");
				return -1;
			}
			if (set_identifier(&id->id, (yyvsp[(2) - (3)].num), (yyvsp[(3) - (3)].val)) != 0) {
				yyerror("failed to set identifer.\n");
				racoon_free(id);
				return -1;
			}
			id->idtype = (yyvsp[(2) - (3)].num);
			genlist_append (cur_rmconf->idvl_p, id);
		}
    break;

  case 290:
#line 1962 "cfparse.y"
    {
			struct idspec  *id;
			id = newidspec();
			if (id == NULL) {
				yyerror("failed to allocate idspec");
				return -1;
			}
			if (set_identifier_qual(&id->id, (yyvsp[(2) - (4)].num), (yyvsp[(4) - (4)].val), (yyvsp[(3) - (4)].num)) != 0) {
				yyerror("failed to set identifer.\n");
				racoon_free(id);
				return -1;
			}
			id->idtype = (yyvsp[(2) - (4)].num);
			genlist_append (cur_rmconf->idvl_p, id);
		}
    break;

  case 292:
#line 1978 "cfparse.y"
    { cur_rmconf->verify_identifier = (yyvsp[(2) - (2)].num); }
    break;

  case 294:
#line 1979 "cfparse.y"
    { cur_rmconf->nonce_size = (yyvsp[(2) - (2)].num); }
    break;

  case 296:
#line 1981 "cfparse.y"
    {
			yyerror("dh_group cannot be defined here.");
			return -1;
		}
    break;

  case 298:
#line 1986 "cfparse.y"
    { cur_rmconf->passive = (yyvsp[(2) - (2)].num); }
    break;

  case 300:
#line 1987 "cfparse.y"
    { cur_rmconf->ike_frag = (yyvsp[(2) - (2)].num); }
    break;

  case 302:
#line 1988 "cfparse.y"
    { cur_rmconf->ike_frag = ISAKMP_FRAG_FORCE; }
    break;

  case 304:
#line 1989 "cfparse.y"
    { 
#ifdef SADB_X_EXT_NAT_T_FRAG
        		if (libipsec_opt & LIBIPSEC_OPT_FRAG)
				cur_rmconf->esp_frag = (yyvsp[(2) - (2)].num); 
			else
                		yywarn("libipsec lacks IKE frag support");
#else
			yywarn("Your kernel does not support esp_frag");
#endif
		}
    break;

  case 306:
#line 1999 "cfparse.y"
    { 
			if (cur_rmconf->script[SCRIPT_PHASE1_UP] != NULL)
				vfree(cur_rmconf->script[SCRIPT_PHASE1_UP]);

			cur_rmconf->script[SCRIPT_PHASE1_UP] = 
			    script_path_add(vdup((yyvsp[(2) - (3)].val)));
		}
    break;

  case 308:
#line 2006 "cfparse.y"
    { 
			if (cur_rmconf->script[SCRIPT_PHASE1_DOWN] != NULL)
				vfree(cur_rmconf->script[SCRIPT_PHASE1_DOWN]);

			cur_rmconf->script[SCRIPT_PHASE1_DOWN] = 
			    script_path_add(vdup((yyvsp[(2) - (3)].val)));
		}
    break;

  case 310:
#line 2013 "cfparse.y"
    { cur_rmconf->mode_cfg = (yyvsp[(2) - (2)].num); }
    break;

  case 312:
#line 2014 "cfparse.y"
    {
			cur_rmconf->weak_phase1_check = (yyvsp[(2) - (2)].num);
		}
    break;

  case 314:
#line 2017 "cfparse.y"
    { cur_rmconf->gen_policy = (yyvsp[(2) - (2)].num); }
    break;

  case 316:
#line 2018 "cfparse.y"
    { cur_rmconf->gen_policy = (yyvsp[(2) - (2)].num); }
    break;

  case 318:
#line 2019 "cfparse.y"
    { cur_rmconf->support_proxy = (yyvsp[(2) - (2)].num); }
    break;

  case 320:
#line 2020 "cfparse.y"
    { cur_rmconf->ini_contact = (yyvsp[(2) - (2)].num); }
    break;

  case 322:
#line 2022 "cfparse.y"
    {
#ifdef ENABLE_NATT
        		if (libipsec_opt & LIBIPSEC_OPT_NATT)
				cur_rmconf->nat_traversal = (yyvsp[(2) - (2)].num);
			else
                		yyerror("libipsec lacks NAT-T support");
#else
			yyerror("NAT-T support not compiled in.");
#endif
		}
    break;

  case 324:
#line 2033 "cfparse.y"
    {
#ifdef ENABLE_NATT
			if (libipsec_opt & LIBIPSEC_OPT_NATT)
				cur_rmconf->nat_traversal = NATT_FORCE;
			else
                		yyerror("libipsec lacks NAT-T support");
#else
			yyerror("NAT-T support not compiled in.");
#endif
		}
    break;

  case 326:
#line 2044 "cfparse.y"
    {
#ifdef ENABLE_DPD
			cur_rmconf->dpd = (yyvsp[(2) - (2)].num);
#else
			yyerror("DPD support not compiled in.");
#endif
		}
    break;

  case 328:
#line 2052 "cfparse.y"
    {
#ifdef ENABLE_DPD
			cur_rmconf->dpd_interval = (yyvsp[(2) - (2)].num);
#else
			yyerror("DPD support not compiled in.");
#endif
		}
    break;

  case 330:
#line 2061 "cfparse.y"
    {
#ifdef ENABLE_DPD
			cur_rmconf->dpd_retry = (yyvsp[(2) - (2)].num);
#else
			yyerror("DPD support not compiled in.");
#endif
		}
    break;

  case 332:
#line 2070 "cfparse.y"
    {
#ifdef ENABLE_DPD
			cur_rmconf->dpd_maxfails = (yyvsp[(2) - (2)].num);
#else
			yyerror("DPD support not compiled in.");
#endif
		}
    break;

  case 334:
#line 2078 "cfparse.y"
    { cur_rmconf->rekey = (yyvsp[(2) - (2)].num); }
    break;

  case 336:
#line 2079 "cfparse.y"
    { cur_rmconf->rekey = REKEY_FORCE; }
    break;

  case 338:
#line 2081 "cfparse.y"
    {
			cur_rmconf->ph1id = (yyvsp[(2) - (2)].num);
		}
    break;

  case 340:
#line 2086 "cfparse.y"
    {
			cur_rmconf->lifetime = (yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num);
		}
    break;

  case 342:
#line 2090 "cfparse.y"
    { cur_rmconf->pcheck_level = (yyvsp[(2) - (2)].num); }
    break;

  case 344:
#line 2092 "cfparse.y"
    {
#if 1
			yyerror("byte lifetime support is deprecated in Phase1");
			return -1;
#else
			yywarn("the lifetime of bytes in phase 1 "
				"will be ignored at the moment.");
			cur_rmconf->lifebyte = fix_lifebyte((yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num));
			if (cur_rmconf->lifebyte == 0)
				return -1;
#endif
		}
    break;

  case 346:
#line 2106 "cfparse.y"
    {
			struct secprotospec *spspec;

			spspec = newspspec();
			if (spspec == NULL)
				return -1;
			insspspec(cur_rmconf, spspec);
		}
    break;

  case 349:
#line 2119 "cfparse.y"
    {
			struct etypes *new;
			new = racoon_malloc(sizeof(struct etypes));
			if (new == NULL) {
				yyerror("failed to allocate etypes");
				return -1;
			}
			new->type = (yyvsp[(2) - (2)].num);
			new->next = NULL;
			if (cur_rmconf->etypes == NULL)
				cur_rmconf->etypes = new;
			else {
				struct etypes *p;
				for (p = cur_rmconf->etypes;
				     p->next != NULL;
				     p = p->next)
					;
				p->next = new;
			}
		}
    break;

  case 350:
#line 2142 "cfparse.y"
    {
			if (cur_rmconf->mycert != NULL) {
				yyerror("certificate_type already defined\n");
				return -1;
			}

			if (load_x509((yyvsp[(2) - (3)].val)->v, &cur_rmconf->mycertfile,
				      &cur_rmconf->mycert)) {
				yyerror("failed to load certificate \"%s\"\n",
					(yyvsp[(2) - (3)].val)->v);
				return -1;
			}

			cur_rmconf->myprivfile = racoon_strdup((yyvsp[(3) - (3)].val)->v);
			STRDUP_FATAL(cur_rmconf->myprivfile);

			vfree((yyvsp[(2) - (3)].val));
			vfree((yyvsp[(3) - (3)].val));
		}
    break;

  case 352:
#line 2163 "cfparse.y"
    {
			char path[MAXPATHLEN];
			int ret = 0;

			if (cur_rmconf->mycert != NULL) {
				yyerror("certificate_type already defined\n");
				return -1;
			}

			cur_rmconf->mycert = vmalloc(1);
			if (cur_rmconf->mycert == NULL) {
				yyerror("failed to allocate mycert");
				return -1;
			}
			cur_rmconf->mycert->v[0] = ISAKMP_CERT_PLAINRSA;

			getpathname(path, sizeof(path),
				    LC_PATHTYPE_CERT, (yyvsp[(2) - (2)].val)->v);
			cur_rmconf->send_cr = FALSE;
			cur_rmconf->send_cert = FALSE;
			cur_rmconf->verify_cert = FALSE;
			if (rsa_parse_file(cur_rmconf->rsa_private, path,
					   RSA_TYPE_PRIVATE)) {
				yyerror("Couldn't parse keyfile.\n", path);
				return -1;
			}
			plog(LLV_DEBUG, LOCATION, NULL,
			     "Private PlainRSA keyfile parsed: %s\n", path);
			vfree((yyvsp[(2) - (2)].val));
		}
    break;

  case 354:
#line 2197 "cfparse.y"
    {
			(yyval.num) = algtype2doi(algclass_isakmp_dh, (yyvsp[(1) - (1)].num));
			if ((yyval.num) == -1) {
				yyerror("must be DH group");
				return -1;
			}
		}
    break;

  case 355:
#line 2205 "cfparse.y"
    {
			if (ARRAYLEN(num2dhgroup) > (yyvsp[(1) - (1)].num) && num2dhgroup[(yyvsp[(1) - (1)].num)] != 0) {
				(yyval.num) = num2dhgroup[(yyvsp[(1) - (1)].num)];
			} else {
				yyerror("must be DH group");
				(yyval.num) = 0;
				return -1;
			}
		}
    break;

  case 356:
#line 2216 "cfparse.y"
    { (yyval.val) = NULL; }
    break;

  case 357:
#line 2217 "cfparse.y"
    { (yyval.val) = (yyvsp[(1) - (1)].val); }
    break;

  case 358:
#line 2218 "cfparse.y"
    { (yyval.val) = (yyvsp[(1) - (1)].val); }
    break;

  case 361:
#line 2226 "cfparse.y"
    {
			cur_rmconf->spspec->lifetime = (yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num);
		}
    break;

  case 363:
#line 2231 "cfparse.y"
    {
#if 1
			yyerror("byte lifetime support is deprecated");
			return -1;
#else
			cur_rmconf->spspec->lifebyte = fix_lifebyte((yyvsp[(3) - (4)].num) * (yyvsp[(4) - (4)].num));
			if (cur_rmconf->spspec->lifebyte == 0)
				return -1;
#endif
		}
    break;

  case 365:
#line 2243 "cfparse.y"
    {
			cur_rmconf->spspec->algclass[algclass_isakmp_dh] = (yyvsp[(2) - (2)].num);
		}
    break;

  case 367:
#line 2248 "cfparse.y"
    {
			if (cur_rmconf->spspec->vendorid != VENDORID_GSSAPI) {
				yyerror("wrong Vendor ID for gssapi_id");
				return -1;
			}
			if (cur_rmconf->spspec->gssid != NULL)
				racoon_free(cur_rmconf->spspec->gssid);
			cur_rmconf->spspec->gssid =
			    racoon_strdup((yyvsp[(2) - (2)].val)->v);
			STRDUP_FATAL(cur_rmconf->spspec->gssid);
		}
    break;

  case 369:
#line 2261 "cfparse.y"
    {
			int doi;
			int defklen;

			doi = algtype2doi((yyvsp[(1) - (3)].num), (yyvsp[(2) - (3)].num));
			if (doi == -1) {
				yyerror("algorithm mismatched 1");
				return -1;
			}

			switch ((yyvsp[(1) - (3)].num)) {
			case algclass_isakmp_enc:
			/* reject suppressed algorithms */
#ifndef HAVE_OPENSSL_RC5_H
				if ((yyvsp[(2) - (3)].num) == algtype_rc5) {
					yyerror("algorithm %s not supported",
					    s_attr_isakmp_enc(doi));
					return -1;
				}
#endif
#ifndef HAVE_OPENSSL_IDEA_H
				if ((yyvsp[(2) - (3)].num) == algtype_idea) {
					yyerror("algorithm %s not supported",
					    s_attr_isakmp_enc(doi));
					return -1;
				}
#endif

				cur_rmconf->spspec->algclass[algclass_isakmp_enc] = doi;
				defklen = default_keylen((yyvsp[(1) - (3)].num), (yyvsp[(2) - (3)].num));
				if (defklen == 0) {
					if ((yyvsp[(3) - (3)].num)) {
						yyerror("keylen not allowed");
						return -1;
					}
				} else {
					if ((yyvsp[(3) - (3)].num) && check_keylen((yyvsp[(1) - (3)].num), (yyvsp[(2) - (3)].num), (yyvsp[(3) - (3)].num)) < 0) {
						yyerror("invalid keylen %d", (yyvsp[(3) - (3)].num));
						return -1;
					}
				}
				if ((yyvsp[(3) - (3)].num))
					cur_rmconf->spspec->encklen = (yyvsp[(3) - (3)].num);
				else
					cur_rmconf->spspec->encklen = defklen;
				break;
			case algclass_isakmp_hash:
				cur_rmconf->spspec->algclass[algclass_isakmp_hash] = doi;
				break;
			case algclass_isakmp_ameth:
				cur_rmconf->spspec->algclass[algclass_isakmp_ameth] = doi;
				/*
				 * We may have to set the Vendor ID for the
				 * authentication method we're using.
				 */
				switch ((yyvsp[(2) - (3)].num)) {
				case algtype_gssapikrb:
					if (cur_rmconf->spspec->vendorid !=
					    VENDORID_UNKNOWN) {
						yyerror("Vendor ID mismatch "
						    "for auth method");
						return -1;
					}
					/*
					 * For interoperability with Win2k,
					 * we set the Vendor ID to "GSSAPI".
					 */
					cur_rmconf->spspec->vendorid =
					    VENDORID_GSSAPI;
					break;
				case algtype_rsasig:
					if (oakley_get_certtype(cur_rmconf->peerscert) == ISAKMP_CERT_PLAINRSA) {
						if (rsa_list_count(cur_rmconf->rsa_private) == 0) {
							yyerror ("Private PlainRSA key not set. "
								 "Use directive 'certificate_type plainrsa ...'\n");
							return -1;
						}
						if (rsa_list_count(cur_rmconf->rsa_public) == 0) {
							yyerror ("Public PlainRSA keys not set. "
								 "Use directive 'peers_certfile plainrsa ...'\n");
							return -1;
						}
					}
					break;
				default:
					break;
				}
				break;
			default:
				yyerror("algorithm mismatched 2");
				return -1;
			}
		}
    break;

  case 371:
#line 2358 "cfparse.y"
    { (yyval.num) = 1; }
    break;

  case 372:
#line 2359 "cfparse.y"
    { (yyval.num) = 60; }
    break;

  case 373:
#line 2360 "cfparse.y"
    { (yyval.num) = (60 * 60); }
    break;

  case 374:
#line 2363 "cfparse.y"
    { (yyval.num) = 1; }
    break;

  case 375:
#line 2364 "cfparse.y"
    { (yyval.num) = 1024; }
    break;

  case 376:
#line 2365 "cfparse.y"
    { (yyval.num) = (1024 * 1024); }
    break;

  case 377:
#line 2366 "cfparse.y"
    { (yyval.num) = (1024 * 1024 * 1024); }
    break;


/* Line 1267 of yacc.c.  */
#line 4911 "cfparse.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 2368 "cfparse.y"


static struct secprotospec *
newspspec()
{
	struct secprotospec *new;

	new = racoon_calloc(1, sizeof(*new));
	if (new == NULL) {
		yyerror("failed to allocate spproto");
		return NULL;
	}

	new->encklen = 0;	/*XXX*/

	/*
	 * Default to "uknown" vendor -- we will override this
	 * as necessary.  When we send a Vendor ID payload, an
	 * "unknown" will be translated to a KAME/racoon ID.
	 */
	new->vendorid = VENDORID_UNKNOWN;

	return new;
}

/*
 * insert into head of list.
 */
static void
insspspec(rmconf, spspec)
	struct remoteconf *rmconf;
	struct secprotospec *spspec;
{
	if (rmconf->spspec != NULL)
		rmconf->spspec->prev = spspec;
	spspec->next = rmconf->spspec;
	rmconf->spspec = spspec;
}

/* set final acceptable proposal */
static int
set_isakmp_proposal(rmconf)
	struct remoteconf *rmconf;
{
	struct secprotospec *s;
	int prop_no = 1; 
	int trns_no = 1;
	int32_t types[MAXALGCLASS];

	/* mandatory check */
	if (rmconf->spspec == NULL) {
		yyerror("no remote specification found: %s.\n",
			saddr2str(rmconf->remote));
		return -1;
	}
	for (s = rmconf->spspec; s != NULL; s = s->next) {
		/* XXX need more to check */
		if (s->algclass[algclass_isakmp_enc] == 0) {
			yyerror("encryption algorithm required.");
			return -1;
		}
		if (s->algclass[algclass_isakmp_hash] == 0) {
			yyerror("hash algorithm required.");
			return -1;
		}
		if (s->algclass[algclass_isakmp_dh] == 0) {
			yyerror("DH group required.");
			return -1;
		}
		if (s->algclass[algclass_isakmp_ameth] == 0) {
			yyerror("authentication method required.");
			return -1;
		}
	}

	/* skip to last part */
	for (s = rmconf->spspec; s->next != NULL; s = s->next)
		;

	while (s != NULL) {
		plog(LLV_DEBUG2, LOCATION, NULL,
			"lifetime = %ld\n", (long)
			(s->lifetime ? s->lifetime : rmconf->lifetime));
		plog(LLV_DEBUG2, LOCATION, NULL,
			"lifebyte = %d\n",
			s->lifebyte ? s->lifebyte : rmconf->lifebyte);
		plog(LLV_DEBUG2, LOCATION, NULL,
			"encklen=%d\n", s->encklen);

		memset(types, 0, ARRAYLEN(types));
		types[algclass_isakmp_enc] = s->algclass[algclass_isakmp_enc];
		types[algclass_isakmp_hash] = s->algclass[algclass_isakmp_hash];
		types[algclass_isakmp_dh] = s->algclass[algclass_isakmp_dh];
		types[algclass_isakmp_ameth] =
		    s->algclass[algclass_isakmp_ameth];

		/* expanding spspec */
		clean_tmpalgtype();
		trns_no = expand_isakmpspec(prop_no, trns_no, types,
				algclass_isakmp_enc, algclass_isakmp_ameth + 1,
				s->lifetime ? s->lifetime : rmconf->lifetime,
				s->lifebyte ? s->lifebyte : rmconf->lifebyte,
				s->encklen, s->vendorid, s->gssid,
				rmconf);
		if (trns_no == -1) {
			plog(LLV_ERROR, LOCATION, NULL,
				"failed to expand isakmp proposal.\n");
			return -1;
		}

		s = s->prev;
	}

	if (rmconf->proposal == NULL) {
		plog(LLV_ERROR, LOCATION, NULL,
			"no proposal found.\n");
		return -1;
	}

	return 0;
}

static void
clean_tmpalgtype()
{
	int i;
	for (i = 0; i < MAXALGCLASS; i++)
		tmpalgtype[i] = 0;	/* means algorithm undefined. */
}

static int
expand_isakmpspec(prop_no, trns_no, types,
		class, last, lifetime, lifebyte, encklen, vendorid, gssid,
		rmconf)
	int prop_no, trns_no;
	int *types, class, last;
	time_t lifetime;
	int lifebyte;
	int encklen;
	int vendorid;
	char *gssid;
	struct remoteconf *rmconf;
{
	struct isakmpsa *new;

	/* debugging */
    {
	int j;
	char tb[10];
	plog(LLV_DEBUG2, LOCATION, NULL,
		"p:%d t:%d\n", prop_no, trns_no);
	for (j = class; j < MAXALGCLASS; j++) {
		snprintf(tb, sizeof(tb), "%d", types[j]);
		plog(LLV_DEBUG2, LOCATION, NULL,
			"%s%s%s%s\n",
			s_algtype(j, types[j]),
			types[j] ? "(" : "",
			tb[0] == '0' ? "" : tb,
			types[j] ? ")" : "");
	}
	plog(LLV_DEBUG2, LOCATION, NULL, "\n");
    }

#define TMPALGTYPE2STR(n) \
	s_algtype(algclass_isakmp_##n, types[algclass_isakmp_##n])
		/* check mandatory values */
		if (types[algclass_isakmp_enc] == 0
		 || types[algclass_isakmp_ameth] == 0
		 || types[algclass_isakmp_hash] == 0
		 || types[algclass_isakmp_dh] == 0) {
			yyerror("few definition of algorithm "
				"enc=%s ameth=%s hash=%s dhgroup=%s.\n",
				TMPALGTYPE2STR(enc),
				TMPALGTYPE2STR(ameth),
				TMPALGTYPE2STR(hash),
				TMPALGTYPE2STR(dh));
			return -1;
		}
#undef TMPALGTYPE2STR

	/* set new sa */
	new = newisakmpsa();
	if (new == NULL) {
		yyerror("failed to allocate isakmp sa");
		return -1;
	}
	new->prop_no = prop_no;
	new->trns_no = trns_no++;
	new->lifetime = lifetime;
	new->lifebyte = lifebyte;
	new->enctype = types[algclass_isakmp_enc];
	new->encklen = encklen;
	new->authmethod = types[algclass_isakmp_ameth];
	new->hashtype = types[algclass_isakmp_hash];
	new->dh_group = types[algclass_isakmp_dh];
	new->vendorid = vendorid;
#ifdef HAVE_GSSAPI
	if (new->authmethod == OAKLEY_ATTR_AUTH_METHOD_GSSAPI_KRB) {
		if (gssid != NULL) {
			if ((new->gssid = vmalloc(strlen(gssid))) == NULL) {
				racoon_free(new);
				yyerror("failed to allocate gssid");
				return -1;
			}
			memcpy(new->gssid->v, gssid, new->gssid->l);
			racoon_free(gssid);
		} else {
			/*
			 * Allocate the default ID so that it gets put
			 * into a GSS ID attribute during the Phase 1
			 * exchange.
			 */
			new->gssid = gssapi_get_default_gss_id();
		}
	}
#endif
	insisakmpsa(new, rmconf);

	return trns_no;
}

#if 0
/*
 * fix lifebyte.
 * Must be more than 1024B because its unit is kilobytes.
 * That is defined RFC2407.
 */
static int
fix_lifebyte(t)
	unsigned long t;
{
	if (t < 1024) {
		yyerror("byte size should be more than 1024B.");
		return 0;
	}

	return(t / 1024);
}
#endif

int
cfparse()
{
	int error;

	yycf_init_buffer();

	if (yycf_switch_buffer(lcconf->racoon_conf) != 0) {
		plog(LLV_ERROR, LOCATION, NULL, 
		    "could not read configuration file \"%s\"\n", 
		    lcconf->racoon_conf);
		return -1;
	}

	error = yyparse();
	if (error != 0) {
		if (yyerrorcount) {
			plog(LLV_ERROR, LOCATION, NULL,
				"fatal parse failure (%d errors)\n",
				yyerrorcount);
		} else {
			plog(LLV_ERROR, LOCATION, NULL,
				"fatal parse failure.\n");
		}
		return -1;
	}

	if (error == 0 && yyerrorcount) {
		plog(LLV_ERROR, LOCATION, NULL,
			"parse error is nothing, but yyerrorcount is %d.\n",
				yyerrorcount);
		exit(1);
	}

	yycf_clean_buffer();

	plog(LLV_DEBUG2, LOCATION, NULL, "parse successed.\n");

	return 0;
}

int
cfreparse()
{
	flushph2();
	flushph1();
	flushrmconf();
	flushsainfo();
	clean_tmpalgtype();
	return(cfparse());
}

#ifdef ENABLE_ADMINPORT
static void
adminsock_conf(path, owner, group, mode_dec)
	vchar_t *path;
	vchar_t *owner;
	vchar_t *group;
	int mode_dec;
{
	struct passwd *pw = NULL;
	struct group *gr = NULL;
	mode_t mode = 0;
	uid_t uid;
	gid_t gid;
	int isnum;

	adminsock_path = path->v;

	if (owner == NULL)
		return;

	errno = 0;
	uid = atoi(owner->v);
	isnum = !errno;
	if (((pw = getpwnam(owner->v)) == NULL) && !isnum)
		yyerror("User \"%s\" does not exist", owner->v);

	if (pw)
		adminsock_owner = pw->pw_uid;
	else
		adminsock_owner = uid;

	if (group == NULL)
		return;

	errno = 0;
	gid = atoi(group->v);
	isnum = !errno;
	if (((gr = getgrnam(group->v)) == NULL) && !isnum)
		yyerror("Group \"%s\" does not exist", group->v);

	if (gr)
		adminsock_group = gr->gr_gid;
	else
		adminsock_group = gid;

	if (mode_dec == -1)
		return;

	if (mode_dec > 777)
		yyerror("Mode 0%03o is invalid", mode_dec);
	if (mode_dec >= 400) { mode += 0400; mode_dec -= 400; }
	if (mode_dec >= 200) { mode += 0200; mode_dec -= 200; }
	if (mode_dec >= 100) { mode += 0200; mode_dec -= 100; }

	if (mode_dec > 77)
		yyerror("Mode 0%03o is invalid", mode_dec);
	if (mode_dec >= 40) { mode += 040; mode_dec -= 40; }
	if (mode_dec >= 20) { mode += 020; mode_dec -= 20; }
	if (mode_dec >= 10) { mode += 020; mode_dec -= 10; }

	if (mode_dec > 7)
		yyerror("Mode 0%03o is invalid", mode_dec);
	if (mode_dec >= 4) { mode += 04; mode_dec -= 4; }
	if (mode_dec >= 2) { mode += 02; mode_dec -= 2; }
	if (mode_dec >= 1) { mode += 02; mode_dec -= 1; }
	
	adminsock_mode = mode;

	return;
}
#endif


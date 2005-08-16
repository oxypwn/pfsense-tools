#ifndef YYERRCODE
#define YYERRCODE 256
#endif

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
typedef union {
        char        *string;
        int         val;
} YYSTYPE;
extern YYSTYPE yylval;

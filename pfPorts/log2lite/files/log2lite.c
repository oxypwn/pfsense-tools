/* 
 * log2lite
 * Matthew Hall <matt@ecsc.co.uk> 2006-06-06
 *
 * Description: Takes sql commands from syslog-ng 
 * into stdin and writes them to an sqlite3 db
 *
 * Installation:
 * Create syslog table in sqlite3:
 *
 * sqlite3 /var/db/syslog.sdb
 *
 *	CREATE TABLE syslog (
 *		date date,
 *		"time" time without time zone,
 *		host character varying(30),
 *		facility character varying(15),
 *		priority character varying(15),
 *		program character varying(30),
 *		"level" character varying(10),
 *		msg text
 *	);
 *
 * Add into /etc/syslog-ng/syslog-ng.conf:
 *
 * 	destination d_sqlite {
 * 		program("/usr/bin/log2lite /var/db/syslog.sdb"
 *      	template("INSERT INTO syslog (date, time, host, facility, priority, program, level, msg) \
 *			VALUES ( '$YEAR/$MONTH/$DAY', '$HOUR:$MIN:$SEC', '$HOST', '$FACILITY', '$PRIORITY', '$PROGRAM', '$LEVEL', '$MSGONLY');\n")
 *      	template_escape(no)
 *      	);
 * 	};
 * 	log { source(s_sys); destination(d_sqlite); };
 *
 *
 * Compile with:
 * 		gcc -o /usr/bin/log2lite log2lite.c -I/usr/include/ -lsqlite3 
 * (requires sqlite-devel installed)
 * 
 * Restart syslog-ng
 *
 * You should then be able to query the sdb with normal sql commands, ie:
 * 	sqlite3 /var/db/syslog.sdb "select distinct(program) from syslog;"
 *
 * (Nb. sqlite3 has a global read/write lock, so you can't read and write to the
 * database at the same time, which means you can only have one syslog source write
 * to the database at any time. syslog-ng should queue and serialize the messages
 * for you, so in essence you should never lose any data, but I wouldn't trust it for 
 * forensic auditing purposes (see http://security.sdsc.edu/software/sdsc-syslog/) )
 */

#include <stdlib.h>
#include <stdio.h>
#include <sqlite3.h>

static int callback(void *NotUsed, int argc, char **argv, char **azColName){
  int i;
  for(i=0; i<argc; i++){
    printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
  }
  printf("\n");
  return 0;
}

int main(int argc, char **argv){
  sqlite3 *db;
  char *zErrMsg = 0;
  int rc;
  char *in;

  in = malloc(8192);
  if ( in == NULL ) {
	printf("OOM\n");
	exit(0);
  }

  if( argc!=2 ){
    fprintf(stderr, "Usage: echo SQL-STATEMENT | %s DATABASE\n", argv[0]);
    exit(1);
  }

  rc = sqlite3_open(argv[1], &db);

  if( rc ){
    fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    exit(1);
  }

  while ( fgets(in, 8192, stdin) != NULL ) {
	  rc = sqlite3_exec(db, in, callback, 0, &zErrMsg);
	  if( rc!=SQLITE_OK ){
	    fprintf(stderr, "SQL error: %s\n", zErrMsg);
	  }
  }

  sqlite3_close(db);
  return 0;
}

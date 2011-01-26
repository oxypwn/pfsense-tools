#ifndef _FILTER_DNS_H_
#define _FILTER_DNS_H_

#include <sys/types.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/refcount.h>
#include <sys/queue.h>

#include <pthread.h>

#define IPFW_TYPE	0
#define PF_TYPE		1
#define CMD_TYPE	2

struct table {
        struct sockaddr_in      addr;
        u_int refcnt;
        TAILQ_ENTRY(table) entry;
};
TAILQ_HEAD(table_entry, table);

struct thread_data {
        struct table_entry *rnh;
	int type;
        char *tablename;
        char *hostname;
	int tablenr;
        int pipe;
        int mask;
	char *cmd;
        TAILQ_ENTRY(thread_data) next;
	pthread_t thr_pid;
};
TAILQ_HEAD(thread_list, thread_data) thread_list;

int parse_config(char *);

#endif /* _FILTER_DNS_H_ */

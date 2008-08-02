# $Id$

PROG=ipfw-classifyd
PREFIX?=	/usr/local
BINDIR?=	${PREFIX}/sbin
CONFDIR?=	${PREFIX}/etc/ipfw-classifyd
PROTOCOLDIR?=	${CONFDIR}/protocols
RCDIR?=		${PREFIX}/etc/rc.d
DATAMODE=	0444
INSTALL?=	/usr/bin/install

OBJS=	classifyd.o hashtable.o protocols.o

DEBUG_FLAGS=	-g
WARNS=		-Wsystem-headers -Werror -Wall -Wno-format-y2k -W \
		-Wno-unused-parameter -Wstrict-prototypes \
		-Wmissing-prototypes -Wpointer-arith -Wreturn-type \
		-Wcast-qual -Wwrite-strings -Wswitch -Wshadow -Wcast-align \
		-Wunused-parameter -Wchar-subscripts -Winline \
		-Wnested-externs -Wredundant-decls -Wno-pointer-sign	
LDD=		-lpthread_p -lm_p -lutil_p
CFLAGS+= -O2 -pipe ${DEBUG_FLAGS} ${WARNS}

all: ${PROG}

${PROG}: ${OBJS}
	cc ${CFLAGS} -o ${PROG} ${OBJS} ${LDD}

install: all
	${INSTALL} -d ${CONFDIR}
	${INSTALL} -d ${PROTOCOLDIR}
	${INSTALL} ${PROG} ${BINDIR}/
	${INSTALL} ${PROG}.sh ${RCDIR}/${PROG}
	${INSTALL} -m ${DATAMODE} ipfw-classifyd.conf.sample ${CONFDIR}
	${INSTALL} -m ${DATAMODE} l7-protocols/protocols/* ${PROTOCOLDIR}

clean:
	rm -f ${PROG} *.o

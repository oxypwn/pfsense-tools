# $Id$

.SUFFIXES: .o .c .h

UNAME!=uname -sr | sed 's/[ \.]/_/g' | tr '[:lower:]' '[:upper:]'
OSTYPE=-D$(UNAME)
DEFINES=
#DEFINES=-DDEBUG
INCLUDES=-I.
#CC=gcc
#CFLAGS=-O -g -pthread -Wall $(OSTYPE) $(INCLUDES) $(DEFINES)
LD=gcc
LDFLAGS=-pthread -Wall -g
#SUBDIR=tests
PROG=slbd
MAN=
PREFIX=/usr/local
BINDIR=sbin
CONFDIR=etc

.if exists(${PREFIX}/${CONFDIR}/slbdcap)
CONFFILE=$(PREFIX)/$(CONFDIR)/slbdcap.new
.else
CONFFILE=$(PREFIX)/$(CONFDIR)/slbdcap
.endif


.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $*.c

all:	slbd

test:	tests

vsvc_rules:	vsvc_rules.o vsvc.o
	$(LD) $(LDFLAGS) -o vsvc_rules vsvc_rules.o vsvc.o

service-clean:
	rm -f service.o

slbd:	service.o vsvc.o config.o printers.o vsvc_rules.o slbd.o pollers.o
	$(LD) $(LDFLAGS) -o slbd slbd.o service.o vsvc.o config.o printers.o \
		vsvc_rules.o pollers.o

install:	install-slbd

install-slbd:
	$(INSTALL) $(PROG) $(PREFIX)/$(BINDIR)/
	mkdir -p $(PREFIX)/$(CONFDIR)
	cp conf/slbdcap $(CONFFILE)

config-clean:
	rm -f config.o config_test config

vsvc-clean:
	rm -f vsvc.o

clean:	vsvc-clean service-clean config-clean
	rm -f ktrace.out a.out *.core *.o
	rm -f slbd

sourceclean: clean
	rm -f *~

#.include <bsd.subdir.mk>
.include <bsd.prog.mk>

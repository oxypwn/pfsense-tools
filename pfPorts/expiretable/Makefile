# $Id$

PREFIX?=/usr/local
INSTALL_BIN?=${PREFIX}/sbin
INSTALL_MAN?=${PREFIX}/man/man1

INSTALL=/usr/bin/install

# Use these CFLAGS for debugging
#CFLAGS=-g -pipe -pedantic -Wall -ansi

CFLAGS+=-pedantic -Wall -ansi

.PHONY: all clean

TARGET=expiretable
OBJECTS=expiretable.o ioctl_helpers.o
MAN=expiretable.1

all: ${TARGET}

install: ${TARGET}
	${INSTALL} -g bin -o root -m 755 ${TARGET} ${INSTALL_BIN}
	${INSTALL} -g bin -o root -m 644 ${MAN} ${INSTALL_MAN}

clean:
	rm -f ${TARGET}
	rm -f ${OBJECTS}
	
obj: ${OBJECTS}

${TARGET}: ${OBJECTS}
	${CC} ${CFLAGS} $> -o $@

.c.o:
	${CC} ${CFLAGS} -c $< -o $@


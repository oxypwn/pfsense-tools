PROG=	ftpsesame
SRCS=	filter.c ftpsesame.c state.c
MAN=	ftpsesame.8

CFLAGS+=-I.
CFLAGS+=-Wall -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith \
	-Wno-uninitialized
LDADD+=	-lpcap

install:
	install -s -o root -g bin -m 555 ftpsesame /usr/local/bin
	install -o root -g bin -m 444 ftpsesame.cat8 /usr/local/man/cat8/ftpsesame.0

.include <bsd.prog.mk>

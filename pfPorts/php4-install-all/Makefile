# -- php-install-all/Makefile copies all of the related php files to their correct
# -- directories and gets the php environment ready.
# -- simple port file magic.

PORTNAME=		php4
PORTVERSION=	4.4.8
PORTREVISION?=	0
CATEGORIES?=	lang devel www
DISTNAME=		php-${PORTVERSION}

all:
	cp /usr/local/bin/php-cgi /usr/local/bin/php
	mkdir -p /usr/local/lib/php/20020429/
	mkdir -p /usr/local/lib/php/20060613/
	mkdir -p /usr/local/lib/php/extensions/no-debug-non-zts-20020429/
	cp /usr/local/lib/php/20020429/* \
		/usr/local/lib/php/extensions/no-debug-non-zts-20020429/
	chmod a+rx /usr/local/bin/php

install:
	cp /usr/local/bin/php-cgi /usr/local/bin/php
	mkdir -p /usr/local/lib/php/20020429/
	mkdir -p /usr/local/lib/php/20060613/
	mkdir -p /usr/local/lib/php/extensions/no-debug-non-zts-20020429/
	cp /usr/local/lib/php/20020429/* \
		/usr/local/lib/php/extensions/no-debug-non-zts-20020429/
	chmod a+rx /usr/local/bin/php

clean:

deinstall:

distclean:



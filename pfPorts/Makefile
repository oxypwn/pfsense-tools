#!/bin/sh

set -e 
set -v

REVERSE="pecl-APC \
php5-bz2 \
php5-ctype \
php5-curl \
php5-gettext \
php5-ldap \
php5-mbstring \
php5-pcntl \
php5-pcre \
php5-posix \
pecl-radius \
php5-readline \
php5-session \
php5-simplexml \
php5-shmop \
php5-sysvmsg \
php5-sysvsem \
php5-sysvshm \
php5-tokenizer \
php5-xml \
php5-zlib \
php4-bz2 \
php4-ctype \
php4-curl \
php4-gettext \
php4-ldap \
php4-mbstring \
php4-pcntl \
php4-pcre \
php4-posix \
pecl-radius \
php4-readline \
php4-session \
php4-simplexml \
php4-xml \
php4-zlib \
php4-tokenizer"

for PORT in $REVERSE; do
	echo "Finding $PORT..."
	DOESPORTEXIST=`find /usr/ports -name $PORT -type d | grep -v pfPorts | head -n 1`
	echo "cp $DOESPORTEXIST/Makefile ~sullrich/tools/pfPorts/$PORT/Makefile"
	if [ -f $DOESPORTEXIST/Makefile ]; then 
		cp $DOESPORTEXIST/Makefile ~sullrich/tools/pfPorts/$PORT/Makefile
	else 
		echo "Could not find $PORT"
	fi 

done

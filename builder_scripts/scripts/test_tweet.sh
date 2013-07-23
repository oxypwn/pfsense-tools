#!/bin/sh

# Suck in local vars
if [ -f ./pfsense_local.sh ]; then
        . ./pfsense_local.sh
elif [ -f ../pfsense_local.sh ]; then
        . ../pfsense_local.sh
else
        echo "You are calling this script from wrong location"
        exit 1
fi

# Suck in script helper functions
if [ -f ./builder_common.sh ]; then
        . ./builder_common.sh
elif [ -f ../builder_common.sh ]; then
        . ../builder_common.sh
else
        echo "You are calling this script from wrong location"
        exit 1
fi

post_tweet "Robots need loving too."


#!/bin/sh
#
#  gather_pfPorts_binaries_in_tgz.sh
#  Copyright (C) 2004-2009 Scott Ullrich
#  All rights reserved.
#  
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#  
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  
#  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#  AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
# Crank up error reporting, debugging.
#  set -e 
#  set -x

# Suck in local vars
. ./pfsense_local.sh

echo ">>> Warning this will rm -rf $PFSENSEBASEDIR"
echo ">>> And reassemble binaries!"
echo
echo -n "Press CTRL-C to abort now!"
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo "."

rm -rf $PFSENSEBASEDIR
mkdir -p $PFSENSEBASEDIR

cust_overlay_host_binaries

unset CROSS_COMPILE_PORTS_BINARIES

tar czpf ~/$ARCH.tgz $PFSENSEBASEDIR

echo ">>> Target .tgz is located in ~/$ARCH.tgz"

echo ">>> You may now cross build using this tgz by setting CROSS_COMPILE_PORTS_BINARIES"
echo "    in pfsense-build.conf pointing to this newly created .tgz file."
echo


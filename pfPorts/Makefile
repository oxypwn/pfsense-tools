#
#  pfSense pfPorts
#
#  This directory holds port structures for common pfSense items
#  such as add on programs and the base system itself.
#
#  To build pfSense simply type make in this directory.
#

SUBDIR += atareinit
# Not applicable to amd64
#SUBDIR += beep
SUBDIR += check_reload_status
SUBDIR += choparp
#SUBDIR += dmt-ux
# Does not build on amd64?
##SUBDIR += dnsmasq
SUBDIR += expiretable
SUBDIR += ifstated
SUBDIR += ipsec-tools
SUBDIR += isc-dhcp3-relay
SUBDIR += isc-dhcp3-server
SUBDIR += kbdcheck
# Does not build on amd64
#SUBDIR += libmrss
SUBDIR += lighttpd
SUBDIR += minicron
# File not found?
#SUBDIR += miniupnpd
SUBDIR += mpd
SUBDIR += olsrd
SUBDIR += pftop
#SUBDIR += libevent
SUBDIR += libevent13
SUBDIR += pftpx
SUBDIR += pftpx-routeto
#SUBDIR += php4-pfsense
#SUBDIR += php4-pfsense-allopt
SUBDIR += php5-pfsense
#SUBDIR += php5-pfsense-allopt
SUBDIR += rrdtool
SUBDIR += sasyncd
SUBDIR += slbd
SUBDIR += ssh_tunnel_shell
SUBDIR += sshlockout_pf
SUBDIR += sshtools
SUBDIR += stats
SUBDIR += vtsh
SUBDIR += xcache

PORTSTOP=       yes

.include <bsd.port.subdir.mk>


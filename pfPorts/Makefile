#
#  pfSense pfPorts
#
#  This directory holds port structures for common pfSense items
#  such as add on programs and the base system itself.
#
#  To build pfSense simply type make in this directory.
#

SUBDIR += atareinit
SUBDIR += check_reload_status
SUBDIR += choparp
SUBDIR += ifstats
SUBDIR += kbdcheck
SUBDIR += pftpx
SUBDIR += mini_httpd-pfsense
SUBDIR += minicron
SUBDIR += php4-pfsense
SUBDIR += sshlockout_pf
SUBDIR += stats
#SUBDIR += upload_progress_meter
SUBDIR += verifysig
SUBDIR += wol

# Finally build the base system
SUBDIR += pfsense-lite

PORTSTOP=       yes

.include <bsd.port.subdir.mk>


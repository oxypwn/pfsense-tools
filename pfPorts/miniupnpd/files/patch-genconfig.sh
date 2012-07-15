--- ../miniupnpd-1.7.old/genconfig.sh	2012-07-15 20:43:15.000000000 +0000
+++ ./genconfig.sh	2012-07-15 20:43:54.000000000 +0000
@@ -112,22 +112,26 @@
 		# new way to see which one to use PF or IPF.
 		# see http://miniupnp.tuxfamily.org/forum/viewtopic.php?p=957
 		# source file with handy subroutines like checkyesno
-		. /etc/rc.subr
-		# source config file so we can probe vars
-		. /etc/rc.conf
-		if checkyesno ipfilter_enable; then
-			echo "Using ipf"
-			FW=ipf
-		elif checkyesno pf_enable; then
-			echo "Using pf"
-			FW=pf
-		elif checkyesno firewall_enable; then
-			echo "Using ifpw"
-			FW=ipfw
+		if [ -f /etc/rc.subr ] && [ -f /etc/rc.conf ]; then
+			. /etc/rc.subr
+			# source config file so we can probe vars
+			. /etc/defaults/rc.conf
+			. /etc/rc.conf
+			if checkyesno ipfilter_enable; then
+				echo "Using ipf"
+				FW=ipf
+			elif checkyesno pf_enable; then
+				echo "Using pf"
+				FW=pf
+			elif checkyesno firewall_enable; then
+				echo "Using ifpw"
+				FW=ipfw
+			fi
 		else
 			echo "Could not detect usage of ipf, pf, ipfw. Compiling for pf by default"
 			FW=pf
 		fi
+		FW=pf
 		echo "#define USE_IFACEWATCHER 1" >> ${CONFIGFILE}
 		OS_URL=http://www.freebsd.org/
 		;;

-- $Id$

--
-- Default configuration file for names of system commands
-- used by the BSD Installer.
--
-- Note that some non-command files and directories are configurable
-- here too.
--
-- The main table lists commands apropos for for DragonFly BSD.
-- Conditional overrides for other BSD's are listed below it.
--

local cmd_names = {
	SH		= "bin/sh",
	MKDIR		= "bin/mkdir",
	CHMOD		= "bin/chmod",
	LN		= "bin/ln",
	RM		= "bin/rm",
	CP		= "bin/cp",
	DATE		= "bin/date",
	ECHO		= "bin/echo",
	DD		= "bin/dd",
	MV		= "bin/mv",
	CAT		= "bin/cat",
	TEST		= "bin/test",
	TEST_DEV	= "bin/test -c",
	CPDUP		= "bin/cpdup -vvv -I",

	ATACONTROL	= "sbin/atacontrol",
	MOUNT		= "sbin/mount",
	MOUNT_MFS	= "sbin/mount_mfs",
	UMOUNT		= "sbin/umount",
	SWAPON		= "sbin/swapon",
	DISKLABEL	= "sbin/disklabel",
	MBRLABEL	= "sbin/mbrlabel",
	NEWFS		= "sbin/newfs",
	NEWFS_MSDOS	= "sbin/newfs_msdos",
	FDISK		= "sbin/fdisk",
	DUMPON		= "sbin/dumpon",
	IFCONFIG	= "sbin/ifconfig",
	ROUTE		= "sbin/route",
	DHCLIENT	= "sbin/dhclient",
	SYSCTL		= "sbin/sysctl",
	MOUNTD		= "sbin/mountd",
	NFSD		= "sbin/nfsd",
	KLDLOAD		= "sbin/kldload",
	KLDUNLOAD	= "sbin/kldunload",
	KLDSTAT		= "sbin/kldstat",

	TOUCH		= "usr/bin/touch",
	YES		= "usr/bin/yes",
	BUNZIP2		= "usr/bin/bunzip2",
	GREP		= "usr/bin/grep",
	KILLALL		= "usr/bin/killall",
	BASENAME	= "usr/bin/basename",
	SORT		= "usr/bin/sort",
	COMM		= "usr/bin/comm",
	AWK		= "usr/bin/awk",
	SED		= "usr/bin/sed",
	BC		= "usr/bin/bc",
	TR		= "usr/bin/tr",
	FIND		= "usr/bin/find",
	CHFLAGS		= "usr/bin/chflags",
	XARGS		= "usr/bin/xargs",
	MAKE		= "usr/bin/make",
	TAR		= "usr/bin/tar",

	PWD_MKDB	= "usr/sbin/pwd_mkdb",
	CHROOT		= "usr/sbin/chroot",
	VIDCONTROL	= "usr/sbin/vidcontrol",
	KBDCONTROL	= "usr/sbin/kbdcontrol",
	PW		= "usr/sbin/pw",
	SWAPINFO	= "usr/sbin/pstat -s",
	BOOT0CFG	= "usr/sbin/boot0cfg",
	FDFORMAT	= "usr/sbin/fdformat",
	MTREE		= "usr/sbin/mtree",
	INETD		= "usr/sbin/inetd",
	DHCPD		= "usr/sbin/dhcpd",
	RPCBIND		= "usr/sbin/portmap",

	PKG_ADD		= "usr/sbin/pkg_add",
	PKG_DELETE	= "usr/sbin/pkg_delete",
	PKG_CREATE	= "usr/sbin/pkg_create",
	PKG_INFO	= "usr/sbin/pkg_info",

	TFTPD		= "usr/libexec/tftpd",

	CVSUP		= "usr/local/bin/cvsup",
	MEMTEST		= "usr/local/bin/memtest",

	-- These aren't commands, but they're configurable here nonetheless.

	DMESG_BOOT	= "/FreeSBIE/var/log/dmesg.boot",
	MODULES_DIR	= "modules"
}

if App.os.name == "OpenBSD" then
	cmd_names.TEST_DEV = "bin/test -b"
	-- ...
elseif App.os.name == "FreeBSD" then
	cmd_names.CPDUP = "usr/local/bin/cpdup -vvv -I"
	cmd_names.DHCPD = "usr/local/sbin/dhcpd"
	cmd_names.RPCBIND = "usr/sbin/rpcbind"
	cmd_names.MOUNTD = "usr/sbin/mountd"
	cmd_names.NFSD = "usr/sbin/nfsd"
	cmd_names.MODULES_DIR = "boot/kernel"
elseif App.os.name == "NetBSD" then
	cmd_names.CPDUP = "usr/pkg/bin/cpdup -vvv -I"
	-- ...
end

return cmd_names

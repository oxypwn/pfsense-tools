--- acinclude.m4	Sat Apr 14 14:39:28 2007
+++ acinclude.m4.new	Sun Jun  3 17:55:41 2007
@@ -187,7 +187,7 @@
 		hd44780)
 			HD44780_DRIVERS="hd44780-hd44780-serial.o hd44780-hd44780-lis2.o"
 			if test "$ac_cv_port_have_lpt" = yes ; then
-				HD44780_DRIVERS="$HD44780_DRIVERS hd44780-hd44780-4bit.o hd44780-hd44780-ext8bit.o hd44780-lcd_sem.o hd44780-hd44780-winamp.o hd44780-hd44780-serialLpt.o"
+				HD44780_DRIVERS="$HD44780_DRIVERS hd44780-hd44780-4bit.o hd44780-hd44780-ext8bit.o hd44780-lcd_sem.o hd44780-hd44780-winamp.o hd44780-hd44780-ipc2u.o hd44780-hd44780-serialLpt.o"
 			fi
 			if test "$enable_libusb" = yes ; then
 				HD44780_DRIVERS="$HD44780_DRIVERS hd44780-hd44780-bwct-usb.o hd44780-hd44780-lcd2usb.o"

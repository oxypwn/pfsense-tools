/*
 * User-space reset-button support for PC Engines ALIX boards.
 * 
 * Written by Sylwester Sosnowski fpm@no-route.org
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@FreeBSD.ORG> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 */

 * Usage:
 * Use from rc(8).
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/cdefs.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <machine/cpufunc.h>
#include <unistd.h>
#include <signal.h>
#include <sys/time.h>
#include <paths.h>
#include <syslog.h>

// MY_NAME is the process name used in syslog.
#define MY_NAME "resetguard"

// GPIO_RESET
u_int32_t switchAddr = 0x61b0;
int switchBit = 8;

// GPIO_LED3
u_int32_t ledAddr = 0x6180;
int ledBit = 11;


// Blink GPIO_LED3.
void blinkLed(int times)
{
       int i;

       for (i=0; i<times; i++)
       {
               outl(ledAddr, 1 << (ledBit + 16));
               usleep(80000);
               outl(ledAddr, 1 << ledBit);
               usleep(80000);
       }
}

// Return GPIO_RESET state.
char isResetPressed() {
   return ((inl(switchAddr) & (1 << switchBit)) == 0);
}

int main() {
   int fd;                             // Define our file descriptor
   char *empty_environ[] = { NULL };   // Environment for halt(8)

   if(geteuid())
   {
       errx(1, "You're not super-user.");  // Show error and exit.
   }


   fd = open("/dev/io", O_RDONLY);     // Read-only file descriptor for /dev/io

   if (fd == -1) {                     // On error (e.g. wrong permissions)
       perror("Cannot open /dev/io."); // Print error message
       exit(1);                        // and exit with status 1
   }

   /*
    *  At this point we'll be polling the GPIO-Pin of the Reset-button
    *  at the front of the PC Engines Alix board every 450ms.
    *  If the pin is HIGH, resetBoard() will be called.
    */

   while(1)                    // Infinite loop
   {
       usleep(4000000);        // Wait ca. 450ms before probing again
       if(isResetPressed()) {  // If resetPressed() returns 1..
               blinkLed(4);            // Blink GPIO_LED3 4 times

               setlogmask(LOG_UPTO (LOG_NOTICE)); // LOG_NOTICE

               // We'll be logging to LOG_LOCAL1
               openlog(MY_NAME, LOG_CONS | LOG_NDELAY, LOG_LOCAL1);

               // Write message to syslog
               syslog(LOG_NOTICE, "Event detected on GPIO_RESET (UID %d)", getuid());

               // Close Log
               closelog();

               // Halt system (like "shutdown -h now" does)
               execle(_PATH_HALT, "halt", "-l", sync, (char *)NULL, empty_environ);

               // Exit with status 0
               exit(0);
       }
   }

   exit(0);                    // This should never be reached (exit 0)
}
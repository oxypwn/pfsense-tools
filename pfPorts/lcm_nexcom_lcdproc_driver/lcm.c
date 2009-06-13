/*************************************************************************
This program demostrates how the LCD module and keypad work. 
It will print out designated strings on the LCD module and get in a loop 
of echoing values back from Keypad
when you press/release any buttom in the keypad.

release:	Apr, 6, 2009
developer: 	ginlin@nexcom
		stevenwu@nexcom
***************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include "lcm.h"

#define NEX_INVALID -1

#ifdef DEBUG
#define MYPRINT(msg...) printf(msg)
#else
#define MYPRINT(msg...) do { } while(0)
#endif

//mapping from offset value to Address Counter, for 2*16 display
static char offToDDr[32]={0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
                    0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
                    0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f};

static int f_pos = 0;

// user functions
void	lcm_init(void);				// init LCM controller
void	lcm_clear(void);	// clear display and reset cursor position
int	lcm_write(char *s);			// write message to LCM display
int	lcm_lseek(int offset, int whence);	// move cursor 
unsigned char	kpad_poll(); 			// check if key pressed

// internal functions
int	acquire_io_privilege();
void	release_io_privilege();
unsigned char 	inb(unsigned short port);
void 	outb(unsigned char data, unsigned short port);
void	lcm_write_control(unsigned char cmd);
void	lcm_write_data (unsigned char data);

int main(int argc, char *argv[] )
{
    	int 	i;
	int	access;

	char* string1 = "booting...";
	char* string2 = "shutting down...";

	// do this once at the beginning of program
	if ((access = acquire_io_privilege()) < 0)
	{
		fprintf(stderr, "Couldn't get io privilege\n");
		exit(1);
	}

	// demo how to init LCM
	lcm_init();

	// demo how to clear LCM display
	lcm_clear();

	sleep(2);

	// demo how to move cursor to second line
	if (lcm_lseek(16, 0) < 0) {
		fprintf(stderr,"lseek() failed\n");
		exit(-1);
	 }
	// demo how to write the desired string
	lcm_write(string1);

	sleep(1);

	// demo how to move cursor to first line
	if (lcm_lseek(0, 0) < 0) {
		fprintf(stderr,"lseek() failed\n");
		exit(-1);
	 }
	// demo how to write the desired string
	lcm_write(string2);

	// demo how to check keypad
	while (1) 
	{
		switch (kpad_poll()) {
			case ENTER_KEY:
				printf("Enter_key\n");
				break;

			case ENTER_ROKEY:
				printf("Enter_ROkey\n");
				break;

			case ESC_KEY:
				printf("ESC_key\n");
				break;

			case ESC_ROKEY:
				printf("ESC_ROkey\n");
				break;

			case UP_KEY:
				printf("UP_key\n");
				break;

			case UP_ROKEY:
				printf("UP_ROkey\n");
				break;

			case DOWN_KEY:
				printf("DOWN_key\n");
				break;

			case DOWN_ROKEY:
				printf("DOWN_ROkey\n");
				break;

			default:
				printf("The value you got is %x\n", i);
				break;

		}
		sleep(1);
	}

	// do this once at end of program
	release_io_privilege(access);
	exit(0);
}

void lcm_clear()
{
	//clear display - write 0x20 to DDRAM and set its address to AC
	lcm_write_control(0x01);
	//move current position to the head
	f_pos = 0;
}

unsigned char kpad_poll()
{
	return(inb(LCD_STATUS_ADDRESS));
}

int lcm_lseek(int offset, int whence)
{
	int newpos;
	int ddram_addr;

	if ((f_pos < 0) || (f_pos > LCD_SIZE))
	{
		MYPRINT("LCM: device llseek: file position out of range (0x%x)\n", f_pos);
		return (-1);
	}

	switch(whence)
	{
	   case 0: /* SEEK_SET */
		newpos = offset;
		break;
	   case 1: /* SEEK_CUR */
		newpos = f_pos + offset;
		break;
	   case 2: /* SEEK_END */
		newpos = LCD_SIZE - offset;  // max size - offset
		break;
	   default: /* can't happen */
		return (NEX_INVALID);
	}

	if ((newpos < 0) || (newpos > LCD_SIZE))
	{
		MYPRINT("LCM: device llseek: new position out of range (0x%x)\n", (int)newpos);
		return (NEX_INVALID);
	}

	f_pos = newpos;

	//map the corresponding Address Counter
	ddram_addr = offToDDr[newpos];

	lcm_write_control(0x80 | ddram_addr);   // 0x80 - set ddram address cmd

	MYPRINT("LCM: device llseek: new position (0x%x)\n", f_pos);

	return (newpos);
}

int lcm_write(char *s)
{
	int length = strlen(s);
	char c = 0;
	int cur = f_pos;

	/* debug: Determine if position is at or past end of LCD. shouldn't be
	*/
	if ( (cur > (LCD_SIZE-1)) || (cur < 0) ){
		MYPRINT("LCM: device write: file position out of range (0x%x)\n", (int)cur);
		return (-1);
	}

	/* Determine if write will go past end. If so, modify length.
	*/
	if ((cur + length) > LCD_SIZE)
		length = LCD_SIZE - cur;

	/* Start writing (length) bytes at current location, length now won't be out of range
	*/
	for (; length > 0; length--)
	{
        	/*Set real Address Counter to the current file position before write data */
		lcm_write_control(0x80 | offToDDr[f_pos]);
		c = *s;
		s++;
		//MYPRINT("LCM: device write: get_user (%c)\n", c);
		lcm_write_data(c);
		(f_pos)++;
	}
	MYPRINT("LCM: device write: current file position (0x%x)\n", f_pos);
	MYPRINT("LCM: device write: current file position address (0x%x)\n",  offToDDr[f_pos]);
	return (length);        // return number of bytes written
}
/* End of lcm_write() */


/*
** lcm_init: Initialize the display.
*/
void lcm_init(void)
{
	lcm_write_control(0x30);
	// delay >4.1ms
	usleep(5000);
	lcm_write_control(0x30);
	// delay >100us
	usleep(200);
	lcm_write_control(0x30);
	lcm_write_control(0x3e); // 0x1110, 8 bits xfer, 2 lines and 5x10 dots
	//lcm_write_control(0x08); // display off
	lcm_write_control(0x01); // clear display
	lcm_write_control(0x06); // entry mode - increment on, no display shift
	lcm_write_control(0x0e); // display on, cursor on, blanking off
	lcm_write_control(0x02); // return cursor home (from sample code)
}

/*
** lcm_write_control: Write one byte control instruction to the LCD
*/
void lcm_write_control(unsigned char cmd)
{
	outb(0x08, LCD_CONTROL_ADDRESS); //command mode, RS = 1
  	usleep(600);

	outb(cmd, LCD_DATA_ADDRESS);
	usleep(600);

	outb(0x08, LCD_CONTROL_ADDRESS); //cmmand mode plus the E -> 0 (hi)
 	usleep(600);

	outb(0x0A, LCD_CONTROL_ADDRESS); //command mode but E -> 1 (lo)
}


/*
** lcm_write_data: Write one byte of data to the LCD
*/
void lcm_write_data (unsigned char data)
{
	outb(0x02, LCD_CONTROL_ADDRESS); //data mode, E -> 1 (lo)
	usleep(100);
	outb(data, LCD_DATA_ADDRESS);
	usleep(100);
	outb(0x00, LCD_CONTROL_ADDRESS); //cmmand mode plus the E -> 0 (hi)
	usleep(100);
	outb(0x02, LCD_CONTROL_ADDRESS); //command mode but E -> 1 (lo)
}

int acquire_io_privilege()
{
	int	io;

	if ((io = open("/dev/io", O_RDONLY)) == -1)
	{
		printf("fail to get i/o privilege\n");
		return -1;
	}
	else
		return io;
}

void release_io_privilege(int access)
{
	close(access);
}

unsigned char
inb(unsigned short port)
{
	unsigned char data;

	__asm __volatile("inb %1,%0" : "=a" (data) : "id" ((unsigned short)(port)));
	return (data);
}

void
outb(unsigned char data, unsigned short port)
{
	__asm __volatile("outb %0,%1" : : "a" (data), "id" ((unsigned short)(port)));
}

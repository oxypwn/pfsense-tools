#include <sys/stat.h>
#include <unistd.h>

/* Check if file exists */
int fexist(char * filename)
{
  struct stat buf;

  if (( stat (filename, &buf)) < 0)
    return (0);

  if (! S_ISREG(buf.st_mode)) {
    return (0);
  }

  return(1);

} 

int main(void) {
	while(1) {
		if(fexist("/tmp/filter_dirty") == 1) {
			printf("%s","Reloading filter settings...");
			system("/usr/local/bin/php /etc/rc.filter_configure >/dev/null");
		}
	sleep(5);
	}
	return 0;
}

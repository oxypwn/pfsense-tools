

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include "php.h"
#include "php_ini.h"
#include "ext/standard/info.h"
#include "SAPI.h"

#include <time.h>
#include <string.h>
#include <errno.h>


#define UPC_MAGIC  0x00D0D000

typedef struct _UPC_data {
   unsigned int __magic;
   unsigned int __struct_lg;
   void * (*callback)( void*, int, int, int);
   char * identifier;		/* full filename, or just the identifier, depending on method */

   time_t time_start;
   time_t time_last;
   unsigned int  speed_average;
   unsigned int  speed_last;
   unsigned long bytes_uploaded;
   unsigned long bytes_total;
   unsigned int  files_uploaded;
   int  est_sec;
} UPCdata;

static int mmcache_loaded(void);
static int select_method(void);
static char * mk_filename(char * identifier);
static void update_file(UPCdata *X);
static void * callback_file( void *pointer, int read_bytes, int total_bytes, int what_happened );
static void * callback_mmcache( void *pointer, int read_bytes, int total_bytes, int what_happened );

static void file_php_get_info(char *, zval * );
static void mmcache_php_get_info(char *, zval * );

PHP_INI_BEGIN()
PHP_INI_ENTRY("upload_progress_meter.store_method",  "file", PHP_INI_ALL, NULL)
PHP_INI_ENTRY("upload_progress_meter.mmcache",  "0", PHP_INI_ALL, NULL)
PHP_INI_ENTRY("upload_progress_meter.file",  "1", PHP_INI_ALL, NULL)
PHP_INI_ENTRY("upload_progress_meter.file.filename_template",  "/tmp/upt_%s.txt", PHP_INI_ALL, NULL)
PHP_INI_END()

/* declaration of functions to be exported */
ZEND_FUNCTION(upload_progress_meter_get_info);

/* compiled function list so Zend knows what's in this module */
zend_function_entry upload_progress_meter_functions[] =
{
    ZEND_FE(upload_progress_meter_get_info, NULL)
    {NULL, NULL, NULL}
};
PHP_MINFO_FUNCTION(upload_progress_meter);
PHP_MINIT_FUNCTION(upload_progress_meter);
PHP_MSHUTDOWN_FUNCTION(upload_progress_meter);

/* compiled module information */
zend_module_entry upload_progress_meter_module_entry =
{
    STANDARD_MODULE_HEADER,
    "Upload Progress Meter",
    upload_progress_meter_functions,
    PHP_MINIT(upload_progress_meter),
    PHP_MSHUTDOWN(upload_progress_meter),
    NULL,
    NULL,
    PHP_MINFO(upload_progress_meter),
    NO_VERSION_YET,
    STANDARD_MODULE_PROPERTIES
};



/* implement standard "stub" routine to introduce ourselves to Zend */
#if COMPILE_DL_UPLOAD_PROGRESS_METER
ZEND_GET_MODULE(upload_progress_meter)
#endif



PHP_MINFO_FUNCTION(upload_progress_meter)
{
   php_info_print_table_start();
   php_info_print_table_row(2, "upload_progress_meter support", "enabled");
   php_info_print_table_row(2, "available backend modules", "file");
   php_info_print_table_end();
}

extern int upload_progress_register_callback( void* );
static void * upload_progress_callback( void *, int, int, int );
PHP_MINIT_FUNCTION(upload_progress_meter)
{
   REGISTER_INI_ENTRIES();

   upload_progress_register_callback( &upload_progress_callback );
   return SUCCESS;
}
PHP_MSHUTDOWN_FUNCTION(upload_progress_meter)
{
   upload_progress_register_callback( NULL );

   UNREGISTER_INI_ENTRIES();
   return SUCCESS;
}

ZEND_FUNCTION(upload_progress_meter_is_loaded)
{
   RETURN_LONG(1);
}
ZEND_FUNCTION(upload_progress_meter_get_info)
{
   char * id;
   int id_lg;
   char method;

   if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "s", &id, &id_lg) == FAILURE) {
      return;
   }

   if (!check_identifier(id))
      return;	/* invalid identifier, may be a security risk */

   method = select_method();

   if (method == 'm')
      return mmcache_php_get_info( id, return_value );
   if (method == 'f')
      return file_php_get_info( id, return_value );

   RETURN_FALSE;
}
static void mmcache_php_get_info(char * id, zval * return_value) {}
static void file_php_get_info(char * id, zval * return_value)
{
   char s[1024];
   char * filename;
   FILE *F;
   TSRMLS_FETCH();

   filename = mk_filename( id );
   if (!filename) return;

   F = VCWD_FOPEN(filename, "rb");

   if (F) {
      array_init(return_value);

      while ( fgets(s, 1000, F) ) {
	 char *k, *v, *e;
	 e = strchr(s,'=');
	 if (!e) continue;

	 *e = 0; /* break the line into 2 parts */
	 v = e+1;
	 k = s;

	 /* trim spaces in front and after the name/value */
	 while (*k && *k <= 32) v++;
	 while (*v && *v <= 32) v++;
	 for (e=k; *e; e++) if (*e <= 32) { *e = 0; break; }
	 for (e=v; *e; e++) if (*e <= 32) { *e = 0; break; }

	 add_assoc_string( return_value, k, v, 1 );
      }
      fclose(F);
   }

   if (filename) efree(filename);
   return;
}




static void * upload_progress_callback( void *pointer, int read_bytes, int total_bytes, int what_happened )
{
//   sapi_module.sapi_error(E_NOTICE, "meter: callback called: read %d of %d reason=%d", read_bytes, total_bytes, what_happened );

   if (pointer == NULL) /* invalid call. ignoring... */
      return NULL;


   if (read_bytes == 0) { 	/* INIT time */
      char  method;

      if (!check_identifier(pointer))
	 return NULL;		/* invalid identifier, possibly a security risk */

      method = select_method();
      if (method == 'm')
	 return callback_mmcache( pointer, read_bytes, total_bytes, what_happened );

      if (method == 'f')
	 return callback_file( pointer, read_bytes, total_bytes, what_happened );

      return NULL;
   }

   if ( ((UPCdata*)pointer)->__magic  != UPC_MAGIC) return NULL;
   if ( ((UPCdata*)pointer)->__struct_lg != sizeof(UPCdata)) return NULL;
   if ( ((UPCdata*)pointer)->callback == NULL) return NULL;

   return ((UPCdata*)pointer)->callback( pointer, read_bytes, total_bytes, what_happened );
}

static void * callback_file( void *pointer, int read_bytes, int total_bytes, int what_happened )
{
//   sapi_module.sapi_error(E_NOTICE, "meter: callback file: read %d of %d reason=%d", read_bytes, total_bytes, what_happened );

   if (pointer == NULL) /* invalid call. ignoring... */
      return NULL;

   if (read_bytes == 0) { 	/* INIT time */
      UPCdata * progress = emalloc( sizeof(UPCdata) ); /* alocate internal structure */

      progress->__magic = UPC_MAGIC;
      progress->__struct_lg = sizeof(UPCdata);

      progress->callback = &callback_file;
      progress->identifier = mk_filename( (char*) pointer );

sapi_module.sapi_error(E_NOTICE, "meter: callback file: identifier=%s", progress->identifier );

      progress->time_start =
      progress->time_last  = time(NULL);
      progress->speed_average  = 0;
      progress->speed_last     = 0;
      progress->bytes_uploaded = 0;
      progress->bytes_total    = total_bytes;
      progress->files_uploaded = 0;
      progress->est_sec        = 0;

      update_file(progress);

      return progress;
   }



   {  /* compute upload speed and update file if necessary */
      UPCdata * progress = pointer;
      time_t crtime = time(NULL);
      int d,dt,ds;


      if (what_happened > 0)
	 progress->files_uploaded++;

      if (progress->time_last > crtime)  /* just in case we encounter a fracture in time */
	 progress->time_start = progress->time_last = crtime;


      dt = crtime - progress->time_last;
      ds = crtime - progress->time_start;
      d = read_bytes - progress->bytes_uploaded;

      if (dt) {
	 progress->speed_last = d/dt;

	 progress->time_last = crtime;
	 progress->bytes_uploaded = read_bytes;

	 progress->speed_average = ds ? read_bytes / ds : 0;
         progress->est_sec = progress->speed_average ?
		 		(progress->bytes_total - read_bytes) / progress->speed_average
				:
				-1;

	 update_file(progress);
      }

   }

   if (what_happened < 0) {	/* FINAL call, free resources */
      VCWD_UNLINK( ((UPCdata*)pointer)->identifier );
      efree( ((UPCdata*)pointer)->identifier );
      efree( pointer );
      return NULL;
   }

   return pointer;
}

static int select_method(void)
{
   int   index    = 0;
   char *methods  = estrdup( INI_STR("upload_progress_meter.store_method") );
   int   Nlg      = methods ? strlen(methods) : -1;
   char  selected = 0;

   while (index < Nlg) {
      int x = index + 1;

      if (methods[index] <= 32 || methods[index] == ',') {
	 index++;
	 continue;
      }

      while (x < Nlg) {
	 if (methods[x] <= 32 || methods[x] == ',')
	    break;
	 else x++;
      }

      methods[x] = 0;

      //sapi_module.sapi_error(E_NOTICE, "meter: index=%d x=%d Nlg=%d crM=%s", index,x,Nlg,methods+index);

      if (!strcasecmp( methods+index, "mmcache" ) && INI_INT("upload_progress_meter.mmcache") && mmcache_loaded() ) {
	 selected = 'm';
	 break;
      }
      if (!strcasecmp( methods+index, "file"    ) && INI_INT("upload_progress_meter.file") ) {
	 selected = 'f';
	 break;
      }

      index = x;
   }

   efree(methods);
   return selected;
}

static int check_identifier(char * identifier)
{
   char *c;

   if (!identifier) return 0;
   if (!*identifier) return 0;
   if (strlen(identifier) > 64) return 0; /* tooooo long */

   /* make sure the identifier does not contain strange things */
   for (c=identifier;*c;c++) {
      if ( (*c >= '0' && *c <= '9') || (*c == '.') || (*c == '_') || (*c == '-') || (*c == '=')
	      ||
	      (*c >= 'a' && *c <= 'z') || (*c >= 'A' && *c <= 'Z')   ) {
      }else{
	 return 0; /* reject strange looking identifiers */
      }
   }

   return 1;
}
static char * mk_filename(char * identifier)
{
   char * template = INI_STR("upload_progress_meter.file.filename_template");
   char * x;
   char * filename;

   filename = emalloc( strlen(template) + strlen(identifier) + 3 );

   x = strstr( template, "%s" );
   if (x==NULL) {
      sprintf( filename, "%s/%s", template, identifier );
   }else{
      strcpy( filename, template );
      strcpy( filename + (x - template), identifier );
      strcat( filename, x+2 );
   }

   return filename;
}
static void update_file(UPCdata *X)
{
   FILE *F;
   TSRMLS_FETCH();

   F = VCWD_FOPEN(X->identifier, "wb");
   if (F) {
      fprintf(F, "time_start=%d\ntime_last=%d\nspeed_average=%d\nspeed_last=%d\nbytes_uploaded=%d\nbytes_total=%d\nfiles_uploaded=%d\nest_sec=%d\n",
		      X->time_start, X->time_last,
		      X->speed_average, X->speed_last,
		      X->bytes_uploaded, X->bytes_total,
		      X->files_uploaded,
		      X->est_sec );
      fclose(F);
   }else{
      sapi_module.sapi_error(E_NOTICE, "meter: file create/open error: filename=(%s) error: %s", X->identifier, strerror(errno) );
   }
}




static int mmcache_loaded(void) { return 0; }
static void * callback_mmcache( void *pointer, int read_bytes, int total_bytes, int what_happened )
{
   return NULL;
}

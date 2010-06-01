#ifndef PHP_PFSENSE_H
#define PHP_PFSENSE_H 1

#ifdef ZTS
#include "TSRM.h"
#endif

ZEND_BEGIN_MODULE_GLOBALS(pfSense)
    int s;
ZEND_END_MODULE_GLOBALS(pfSense)

#ifdef ZTS
#define PFSENSE_G(v) TSRMG(pfSense_globals_id, zend_pfSense_globals *, v)
#else
#define PFSENSE_G(v) (pfSense_globals.v)
#endif

#define PHP_PFSENSE_WORLD_VERSION "1.0"
#define PHP_PFSENSE_WORLD_EXTNAME "pfSense"

PHP_MINIT_FUNCTION(pfSense_socket);
PHP_MSHUTDOWN_FUNCTION(pfSense_socket_close);

PHP_FUNCTION(pfSense_get_interface_info);
PHP_FUNCTION(pfSense_get_interface_stats);
PHP_FUNCTION(pfSense_get_pf_stats);
PHP_FUNCTION(pfSense_get_os_hw_data);
PHP_FUNCTION(pfSense_get_os_kern_data);
PHP_FUNCTION(pfSense_get_interface_addresses);
PHP_FUNCTION(pfSense_vlan_create);
PHP_FUNCTION(pfSense_interface_rename);
PHP_FUNCTION(pfSense_interface_mtu);
PHP_FUNCTION(pfSense_interface_create);
PHP_FUNCTION(pfSense_interface_destroy);
PHP_FUNCTION(pfSense_interface_flags);

extern zend_module_entry pfSense_module_entry;
#define phpext_pfSense_ptr &pfSense_module_entry

#endif

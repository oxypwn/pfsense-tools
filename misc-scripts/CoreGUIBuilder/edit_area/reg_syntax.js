	EditArea.prototype.getRegExp= function(tab_text){
		res="( |=|\\n|\\r)(";
		for( i=0; i<tab_text.length; i++){
			if(i>0)
				res+="|";
			res+="("+ tab_text[i] +")";
		}
		res+=")( |\\(|\'|\")";
		reg= new RegExp(res);
		return res;
	}
	
	EditArea.prototype.initRegExp= function(){
		this.php_keywords = ['break', 'case', 'continue', 'default', 'do', 'else', 
					   'elseif', 'endif', 'for',
					   'foreach', 'function', 'if', 'include', 'return', 'require',
					   'switch', 'while', 'var', 'new'];	// "this" does'nt work as other keyword
		this.php_keywords_reg= 	new RegExp(this.getRegExp( this.php_keywords ),"g");		   
		
		//var php_functions=new Array("function", "echo");
		this.php_functions_simple = ['echo','printf', 'sprintf', 'print_r', 'split', 'join', 'isset'];
		
		this.php_functions_middle = ['abs', 'acos', 'addcslashes', 'addslashes', 'apache_lookup_uri',
				   'apache_note', 'array', 'array_count_values', 'array_flip', 
				   'array_keys', 'array_merge', 'array_pad', 'array_pop', 
				   'array_push', 'array_reverse', 'array_shift', 'array_shift', 
				   'array_slice', 'array_slice', 'array_splice', 'array_unshift', 
				   'array_values', 'array_walk', 'arsort', 'asin', 'asort', 
				   'crypt', 'current', 'date', 'decbin', 'dechex', 'decoct', 
				   'delete', 'dir', 'dirname', 'diskfreespace', 'dl', 'doubleval', 
				   'each', 'easter_days', 'echo', 'empty', 'end', 'ereg', 
				   'ereg_replace', 'eregi', 'eregi_replace', 'error_log', 
				   'error_reporting', 'escapeshellcmd', 'exec', 'exp', 'explode', 
				   'extension_loaded', 'extract', 'fclose', 'fdf_close', 
				   'fdf_create', 'fdf_get_file', 'fdf_get_status', 'fdf_get_value',
				   'fdf_next_field_name', 'fdf_open', 'fdf_save', 'fdf_set_ap', 
				   'fdf_set_file', 'fdf_set_status', 'fdf_set_value', 'feof', 
				   'fgetc', 'fgetcsv', 'fgets', 'fgetss', 'file', 'file_exists', 
				   'fileatime', 'filectime', 'filegroup', 'fileinode', 'filemtime',
				   'fileowner', 'fileperms', 'filepro', 'filepro_fieldcount', 
				   'filepro_fieldname', 'filepro_fieldtype', 'filepro_fieldwidth', 
				   'filepro_retrieve', 'filepro_rowcount', 'filesize', 'filetype', 
				   'flock', 'floor', 'flush', 'fopen', 'fpassthru', 'fputs', 
				   'fread', 'frenchtojd', 'fseek', 'fsockopen', 'ftell', 
				   'func_get_arg', 
				   'func_get_args', 'func_num_args', 'fwrite', 'get_cfg_var', 
				   'get_current_user', 'get_html_translation_table', 
				   'get_magic_quotes_gpc', 'get_magic_quotes_runtime', 
				   'get_meta_tags', 'getallheaders', 'getdate', 'getenv', 
				   'gethostbyaddr', 'gethostbyname', 'gethostbynamel', 
				   'getimagesize', 'getlastmod', 'getmxrr', 'getmyinode', 
				   'getmypid', 'getmyuid', 'getprotobyname', 'getprotobynumber', 
				   'getrandmax', 'getrusage', 'getservbyname', 'getservbyport', 
				   'gettimeofday', 'gettype', 'gmdate', 'gmmktime', 'gmstrftime', 
					'header', 
				   'hexdec', 'htmlentities', 'htmlspecialchars','implode', 'in_array', 
				   'intval', 'is_array', 'is_dir', 'is_double', 'is_executable', 
				   'is_file', 'is_float', 'is_int', 'is_link', 'is_integer', 
				   'is_long', 'is_object', 'is_readable', 'is_real', 'is_string', 
				   'is_writeable', 'isset', 'join', 'key', 'krsort', 'ksort', 
				   'link', 'linkinfo', 
				   'list', 'log', 'log10', 'lstat', 'ltrim', 'mail', 'max', 
				   'md5', 'metaphone', 
				   'microtime', 'min', 'mkdir', 'mktime', 
				   'mysql_affected_rows', 'mysql_change_user', 
				   'mysql_close', 'mysql_connect', 'mysql_create_db', 
				   'mysql_data_seek', 'mysql_db_query', 'mysql_drop_db', 
				   'mysql_errno', 'mysql_error', 'mysql_fetch_array', 'mysql_fetch_assoc',
				   'mysql_fetch_field', 'mysql_fetch_lengths', 
				   'mysql_fetch_object', 'mysql_fetch_row', 'mysql_field_flags', 
				   'mysql_field_len', 'mysql_field_name', 'mysql_field_seek', 
				   'mysql_field_table', 'mysql_field_type', 'mysql_free_result', 
				   'mysql_insert_id', 'mysql_list_dbs', 'mysql_list_fields', 
				   'mysql_list_tables', 'mysql_num_fields', 'mysql_num_rows', 
				   'mysql_pconnect', 'mysql_query', 'mysql_result', 
				   'mysql_select_db', 'mysql_tablename', 'next', 'nl2br', 
				   'number_format', 'octdec',
				   'opendir', 'openlog',
				   'ord', 'parse_str', 'parse_url', 'passthru', 
				   'pclose', 'phpinfo', 'phpversion', 'pi', 'popen', 'pos', 
				   'pow', 'preg_grep', 
				   'preg_match', 'preg_match_all', 'preg_quote', 'preg_replace', 
				   'preg_split', 'prev', 'print', 'print_r', 'printf', 'putenv', 
				   'quoted_printable_decode', 'quotemeta', 'rand', 'range', 
				   'rawurldecode', 'rawurlencode', 'readdir', 'readfile', 
				   'readgzfile', 'readlink', 'recode_file', 'recode_string', 
				   'reset', 'rename', 'rewind', 'rewinddir', 'rmdir', 'round', 
				   'rsort', 'sem_acquire', 'sem_get', 'sem_release', 
				   'session_decode', 'session_destroy', 'session_encode', 
				   'session_id', 'session_is_registered', 'session_module_name', 
				   'session_module_name', 'session_name', 'session_register', 
				   'session_save_path', 'session_start', 'session_unregister', 
				   'set_file_buffer', 'set_magic_quotes_runtime', 
				   'set_socket_blocking', 'set_time_limit', 'setcookie', 
				   'setlocale', 'settype', 
				   'shuffle', 'similar_text', 'sin', 'sizeof', 
				   'sort', 'soundex', 
				   'split', 'sprintf', 'sql_regcase', 'sqrt', 'srand', 'stat', 
				   'str_repeat', 'str_replace', 'strcasecmp', 'strchr', 'strcmp', 
				   'strcspn', 'strftime', 'strip_tags', 'stripcslashes', 
				   'stripslashes', 'stristr', 'strlen', 'strpos', 'strrchr', 
				   'strrev', 'strrpos', 'strspn', 'strstr', 'strtok', 'strtolower',
				   'strtoupper', 'strtr', 'strval', 'substr', 'substr_replace', 
				   'symlink', 'syslog', 'system', 'tan', 
				   'tempnam', 'time', 'touch', 'trim', 'uasort', 'ucfirst', 
				   'ucwords', 'uksort', 'umask', 'unlink', 'unset', 'urldecode', 
				   'urlencode', 'usort', 'utf8_decode', 'utf8_encode', 'var_dump',
				   ];
				   
		this.php_functions_reg= new RegExp(this.getRegExp( this.php_functions_simple ),"g");
	};
	
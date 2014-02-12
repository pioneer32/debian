	location /zabbix {
    			access_log off;
    			root /var/wwws/;
    			index index.php;
    		}

	location ~* ^/zabbix.+\.(php|phtml)$ {
			access_log off;
			root /var/wwws;
			fastcgi_index index.php;
			include fastcgi_params;
			fastcgi_pass php_factory;
			fastcgi_param DOCUMENT_ROOT /var/wwws/zabbix;
			fastcgi_param SCRIPT_FILENAME /var/wwws$fastcgi_script_name;
		}
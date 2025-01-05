```nginx
user www-data;

events {}

http {

    # Load the types (e.g., css)
    include mime.types;

    server {
        listen 80;
        server_name 206.189.100.37;

        # Will look for files at the defined root
        root /var/www/demo;

        # PHP PROCESSING
        # Will load index.php if it exists in the directory
        index index.php index.html;

        # Try the requested URI, then the requested URI with a trailing slash (in case it maps to a directory),
        # and finally fall back to the default Nginx 404. 
        # This location will take care of any requests for static content.
        location / {
            try_files $uri $uri/ =404;
        }

        # Match anything ending in .php
        # This location will take precedence over the previous one
        location ~\.php$ {
            # Pass php requests to the php-fpm service (fastcgi protocol)
            include fastcgi.conf;
            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        }
    }
}
```

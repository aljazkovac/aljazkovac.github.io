```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

include mime.types;

# Buffer size for POST submissions
# Choose a size that is large enough to handle the largest POST request
# but not so large that it will waste memory.
client_body_buffer_size 10K;
# Don't allow more than 8MB of data to be sent to the server => 413 Request Entity Too Large
client_max_body_size 8m;

# Buffer size for Headers
# The amount of memory that the server can use for processing headers
client_header_buffer_size 1k;

# Max time to receive client headers/body
# If the client doesn't send the headers/body within this time, the connection is closed
client_body_timeout 12;
client_header_timeout 12;

# Max time to keep a connection open for
keepalive_timeout 15;

# Max time for the client accept/receive a response
send_timeout 10;

# sendfile and tcp_nopush help optimize sites with a lot of static files
# Skip buffering for static files
# When sending a client data from disk, don't use the buffer
sendfile on;

# Optimise sendfile packets
# Optimise the size of the packets sent to the client
tcp_nopush on;

server {

    listen 80;
    server_name 167.99.93.26;

    root /sites/demo;

    index index.php index.html;

    location / {
      try_files $uri $uri/ =404;
    }

    location ~\.php$ {
      # Pass php requests to the php-fpm service (fastcgi)
      include fastcgi.conf;
      fastcgi_pass unix:/run/php/php7.1-fpm.sock;
    }

}
}
```

# The course Nginx Fundamentals: High performance servers from scratch

[Nginx](https://github.com/nginx/nginx) is a high performance web server that is responsible for handling the load of some of the largest sites on the internet. 
It is a very flexible web server that can be configured to serve a variety of purposes, from simple sites to complex applications.
At its core, Nginx is a web server that can serve static and dynamic content using a variety of protocols, including HTTP, HTTPS, and SPDY.
Nginx is also a reverse proxy server that can be used to load balance traffic between multiple servers, and a caching server that can cache content to improve performance.

This Udemy course covers the following topics:
  * Learn to customise the NGINX installation
  * Configure NGINX
  * Learn to tweak NGINX for optimal performance 
  * Secure NGINX with some security best practises
  * Learn about NGINX load balancing and reverse proxying

## Overview of Nginx

Nginx is a high performance web server that is responsible for handling the load of some of the largest sites on the internet.

The benefits of Nginx:
1. High performance
2. Low resource usage

Nginx vs. Apache:
1. Nginx can serve static resources much faster
2. Nginx can dandle a much larger amount of concurrent requests
3. In Nginx requests are interpreted as URI locations first whereas Apache defaults to and favours file-system locations 
   => Nginx can easily function as not only a web server but anything from a load balancer to a mail server

## Installing Nginx

### With a package manager

1. Install with `apt-get install nginx`
2. Run `ps aux | grep nginx` to get the list of nginx processes
3. Run `ifconfig` to see the network interfaces on your system. Grab the IP address from there and go to it.

The downside of installing with a package manager is that we cannot install any additional modules. 
Therefore, we will install Nginx from source.

### From source

### Preamble: Setting up ssh keys



The authorized_keys in the droplet server contains my public ssh key!

	1. apt-get update
	2. Nginx.org (the majority of the docs) vs. Nginx.com (the flashier product website)
	3. Wget <link to mainstream version of nginx> (find here: https://nginx.org/en/download.html)
	4. tar -zxvf <file>
	5.  Enter extracted directory
	6. Run the configure script => we don't have a C compiler!
	7. Apt-get install build-essential && run configure script again
	8. Install some additional libraries, e.g., libpcre3, libpcre3-dev, etc.
	9. Customise install with:
		./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
	10. Run make
	11. Run make install
	




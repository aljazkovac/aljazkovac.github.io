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

## Overview

### Introduction

Nginx is a high performance web server that is responsible for handling the load of some of the largest sites on the internet.

The benefits of Nginx:
1. High performance
2. Low resource usage

### About Nginx


### Nginx vs. Apache

There are some key differences between Nginx and Apache:

1. Nginx can serve static resources much faster
2. Nginx can dandle a much larger amount of concurrent requests
3. In Nginx requests are interpreted as URI locations first whereas Apache defaults to and favours file-system locations 
   => Nginx can easily function as not only a web server but anything from a load balancer to a mail server

### Quiz 1



## Installation

### Server overview

I have set up a Digital Ocean droplet with the following specs:
  * 512 MB RAM
  * 1 vCPU
  * 10 GB SSD
  * Ubuntu 24.04 (LTS) x64

I have also set up [SSH key-based authentication](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server) to access the droplet.

### Installing with a package manager

1. Install with `apt-get install nginx`
2. Run `ps aux | grep nginx` to get the list of nginx processes
3. Run `ifconfig` to see the network interfaces on your system. Grab the IP address from there and go to it.

The downside of installing with a package manager is that we cannot install any additional modules. 
Therefore, we will install Nginx from source.

### Building Nginx from source & adding modules

### Adding an Nginx service

### Nginx for Windows

### Quiz 2

## Configuration

### Understanding configuration terms

### Creating a virtual host

### Location blocks

### Variables

### Rewrites & redirects

### Try files & named locations

### Logging

### Inheritance & directive types

### PHP processing

### Workers processes

### Buffers & timeouts

### Adding dynamic modules

### Quiz 3

## Performance

### Headers & expires

### Compressed responses with gzip

### FastCGI_cache

### HTTP2

### Server push

## Security

### HTTPS(SSL)

### Rate limiting

### Basic authentication

### Hardening Nginx

### Quiz 4

### Let's Encrypt - SSL certificates

## Reverse proxy & load balancing

### Prerequisites

### Reverse proxy

### Load balancer

### Load balancer options

### Documentations & resources

## Outro

### Bonus lecture: feedback & Stackacademy.tv courses

## Archive

### Adding an Nginx Init service

### GeoIP

### Video streaming





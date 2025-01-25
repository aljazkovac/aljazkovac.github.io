---
title: "Nginx Fundamentals: High performance servers from scratch"
date: 2025-01-19 14:38:23 +0200
categories: [devops, courses] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [devops, courses, certificates] # TAG names should always be lowercase.
description: An Udemy course on Nginx fundamentals.
---

# Introduction

I have decided to take [this Udemy course](https://www.udemy.com/course/nginx-fundamentals/) because I have been working on a 
custom reverse proxy at my current job at [Caspeco](https://caspeco.com/), and I wanted to see if we could perhaps 
replace it with Nginx. Our custom reverse proxy is built with [ProxyKit](https://github.com/ProxyKit/ProxyKit), 
which has been obsolete for a couple of years already, meaning that we will have to either rewrite it, or replace it with 
something else in the future. Nginx is a reverse proxy at its core, so I wanted to learn more about its capabilities, to see
if it could cover all our needs.

Let's dive into the course, and I hope you will enjoy my notes and thoughts on it.

# The course Nginx Fundamentals: High performance servers from scratch

[Nginx](https://github.com/nginx/nginx) is a high-performance, open-source web server and reverse proxy designed for 
speed, scalability, and efficient resource use. Its core functionality includes serving static content, load balancing, 
and acting as a reverse proxy to forward client requests to backend servers. Nginx excels at handling large numbers of 
concurrent connections, making it ideal for high-traffic websites and applications. Additionally, it supports features like 
caching, SSL termination, and URL rewriting, which enhance performance, security, and flexibility in modern web architectures.

[This Udemy course](https://www.udemy.com/course/nginx-fundamentals/) covers the following topics:
  * Learn to customise the NGINX installation
  * Configure NGINX
  * Learn to tweak NGINX for optimal performance 
  * Secure NGINX with some security best practises
  * Learn about NGINX load balancing and reverse proxying

## Overview

### About Nginx

Nginx was built in 2004 by [Igor Sysoev](https://en.wikipedia.org/wiki/Igor_Sysoev) as he was looking for an alternative to Apache, 
and wanted to build a replacement capable of handling [10000 concurrent connections](https://en.wikipedia.org/wiki/C10k_problem),
with a focus on:

  * High performance
  * High concurrency
  * Low memory usage

Today, Nginx serves the majority of the world's websites, not only because of its performance but also because of its relative ease of use.
At its core, Nginx is a reverse proxy server.

### Nginx vs. Apache

There are some key differences between Nginx and Apache:

1. Nginx can serve static resources much faster
2. Nginx can handle a much larger amount of concurrent requests
3. In Nginx requests are interpreted as URI locations first whereas Apache defaults to and favours file-system locations 
   => Nginx can easily function as not only a web server but anything from a load balancer to a mail server

Apache spawns a certain number of processes, each of which can serve a single request at a time. Nginx deals with requests
asynchronously, meaning that a single Nginx process can serve multiple requests concurrently. Because of this, Nginx cannot
embed PHP or other languages directly into the server like Apache can. Instead, all requests for dynamic content are dealt with
by a separate process, such as PHP-FPM, and then reverse proxied back to the client via Nginx.

In terms of performance, Nginx can do the following better than Apache:
1. Serve static content much faster
2. Handle a much larger number of concurrent requests (Apache will accept requests up to the pre-configured limit, then reject the rest)

Nginx and Apache also differ in terms of configuration. Nginx interprets requests as URI locations first, whereas Apache 
defaults to and favours file-system locations. Because of this very design, Nginx can easily function as not only a web server
but anything from a load balancer to a mail server.

## Installation

### Server overview

I have set up a [Digital Ocean](https://www.digitalocean.com/) droplet with the following specs:

  * 512 MB RAM
  * 1 vCPU
  * 10 GB SSD
  * Ubuntu 24.04 (LTS) x64

I have also set up SSH key-based authentication by following [this guide on Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server).
To summarize, I followed the following steps:

1. Generate a new SSH key pair with `ssh-keygen`
2. Access the server via the console in the Digital Ocean dashboard
3. Disable password authentication by editing the `/etc/ssh/sshd_config` file and setting `PasswordAuthentication no`
4. Copy the public key to the server manually (copy to the `~/.ssh/authorized_keys` file) 
5. For a smoother login experience, I added an entry in the `~/.ssh/config` file:

    ```bash
    Host digitalocean
        HostName <my-droplet-ip>
        User root
        IdentityFile ~/.ssh/<my-private-key>
    ```

This allows me to log in with `ssh digitalocean`.

### Installing with a package manager

Installing with a package manager is a quick and easy, albeit limited, way to get Nginx up and running.

I followed these steps:

1. Update the package list with `apt-get update`
2. Install with `apt-get install nginx`
3. Run `ps aux | grep nginx` to get the list of nginx processes 
    (the command `ps` lists the processes, `aux` lists all processes
    (a = show processes for all users
    u = display the process's user/owner
    x = also show processes not attached to a terminal), and `grep` filters the output):
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:~# ps aux | grep nginx
    root       49899  0.0  0.3  11156  1716 ?        Ss   12:50   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
    www-data   49900  0.0  0.9  12880  4404 ?        S    12:50   0:00 nginx: worker process
    root       49962  0.0  0.4   7076  2048 pts/0    S+   12:53   0:00 grep --color=auto nginx
    ```
4. Run `ifconfig` to see the network interfaces on your system. Grab the IP address from there and go to it.
   (needed to install the command with `apt-get install net-tools` first, and then the IP address I found under `inet` in the `eth0` section)
5. Open a browser and navigate to the IP address. There I could see the default Nginx page.

The downside of installing with a package manager is that we cannot install any additional modules. 
Therefore, I installed Nginx from source in the next section.

### Building Nginx from source & adding modules

Building Nginx from source allows us to customise the installation and add additional modules. Before starting, I rebuilt 
the droplet to start from scratch. Then I followed these steps:

1. Update the package list with `apt-get update`
2. Download the source code with `wget https://nginx.org/download/nginx-1.27.3.tar.gz`
3. Extract the source code with `tar -zxvf nginx-1.27.3.tar.gz`
4. Try and run `./configure` to see if there are any missing dependencies => get the error: 
    ```bash
    checking for OS
      + Linux 6.8.0-51-generic x86_64
    checking for C compiler ... not found

    ./configure: error: C compiler cc is not found
    ```
5. Install the build-essential package with `apt-get install build-essential`
6. Run `./configure` again => get the error:
    ```bash
    ./configure: error: the HTTP rewrite module requires the PCRE library.
    You can either disable the module by using --without-http_rewrite_module
    option, or install the PCRE library into the system, or build the PCRE library
    statically from the source with nginx by using --with-pcre=<path> option.
    ```
7. Install the PCRE, the zlib and the libssl libraries with `apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev`
8. Running ´./configure´now works, but we also want to add custom configuration flags. To see all possible flags, run `./configure --help`
9. Navigate to [Building Nginx from source](https://nginx.org/en/docs/configure.html) to see more information about the available configuration flags
10. Set a few common flags and the http_ssl module with: 
    `./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module`
11. Compile the source code with `make`
12. Install the compiled code with `make install`
13. Check that the configuration files exist with `ls /etc/nginx`
14. Check the Nginx version with `nginx -V`:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:~/nginx-1.27.3# nginx -V
    nginx version: nginx/1.27.3
    built by gcc 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
    built with OpenSSL 3.0.13 30 Jan 2024
    TLS SNI support enabled
    configure arguments: --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
    ```
15. Start Nginx with `nginx` and check that process is running with `ps aux | grep nginx`, and also check the default page in the browser

### Adding a Nginx service

The next step is to add a [systemd service](https://systemd.io/) for Nginx. This allows us to start, stop, and restart Nginx with a single command.

I followed these steps:

1. Run `nginx -h` to see the available commands
2. Run `nginx -s stop` to stop the Nginx process
3. Create a new file in `/lib/systemd/system/nginx.service` with the following content:
    ```nginx
    [Unit]
    Description=The NGINX HTTP and reverse proxy server
    After=syslog.target network.target remote-fs.target nss-lookup.target

    [Service]
    Type=forking
    PIDFile=/var/run/nginx.pid
    ExecStartPre=/usr/bin/nginx -t
    ExecStart=/usr/bin/nginx
    ExecReload=/bin/kill -s HUP $MAINPID
    ExecStop=/bin/kill -s QUIT $MAINPID
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    ``` 
4. Run `systemctl start nginx` to start Nginx and check that it is running with `systemctl status nginx`
5. Stop Nginx with `systemctl stop nginx` and check that it is stopped with `systemctl status nginx`
6. Enable Nginx to start on boot with `systemctl enable nginx`
7. Reboot the server with `reboot` and check that Nginx is running with `systemctl status nginx`

### Nginx for Windows

Nginx was originally designed for Unix-based systems, but it is also available for Windows. However, the Windows version
has some limitations compared to the Unix version, such as:

  * Poor performance 
  * Single worker process
  * Unsupported modules

I wasn't interested in installing Nginx on Windows, so I skipped this section.

## Configuration

### Understanding configuration terms

There are two main configuration terms in Nginx:

1. Context: A block of configuration directives (sections within a configuration) that apply to a specific part of the server. 
   For example, the `http` context contains directives that apply to the entire server, while the `server` context contains 
   directives that apply to a specific server block. Contexts are enclosed in curly braces `{}`, and can be nested within each other.
   Nested contexts inherit directives from their parent contexts. The top-most context is the configuration file itself (the main context),
   which is where we define the global directives that apply to the master process. Other important contexts include `events`, `http`,
   the `server`, and `location` contexts.
2. Directive: specific configuration options that control how Nginx behaves. Directives are placed inside contexts and are
   followed by a value or a block of values. For example, the `server_name` directive specifies the domain name that the server
   block should respond to.

### Creating a virtual host

We will create a virtual host to serve a simple HTML page. To do this, I followed these steps:

1. Asked ChatGTP to create a simple webpage consisting of three files: `index.html`, `style.css`, and `image.png`
2. Went to the root directory with `cd /` (your home directory you can reach with `cd ~` or just `cd`)
3. Created a new directory with `mkdir sites` and then `cd sites` and `mkdir demo`
4. Copied the files `index.html`and `style.css` from ChatGTP to the `demo` directory manually
5. Copied the image `image.png` to the `demo` directory with this command: `scp /Users/aljazkovac/Desktop/courses/nginx-fundamentals/image.png digitalocean:/sites/demo/`
   (the `scp` command copies files between hosts on a network, and the syntax is `scp <source> <destination>`, `digitalocean` is the alias I set up in the `~/.ssh/config` file)
6. Edit the file `/etc/nginx/nginx.conf` and add the following configuration:
    ```nginx
    events {
    }

    http {
        server {
          listen 80;
          server_name 206.189.100.37;
          root /sites/demo;
        }
    }
    ```
7. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`
8. Open a browser and navigate to the IP address. There I could see the simple webpage but without the CSS styling.
9. In the browser's developer tools, I could see that the CSS file was being loaded. However, Nginx was sending the wrong MIME type for the CSS file
   You can check the MIME type with `curl -i http://<IP>/<file>` and see the `Content-Type` header (I got `text/plain` instead of `text/css`)
10. To fix this, one can add a `types` block to the `http` context in the configuration file:
    ```nginx
    http {
        types {
            text/css css;
        }
    ```
    However, this is not the best solution because it requires manually adding MIME types for each file type. A better solution 
    is to use the `include` directive to include the `mime.types` file:
    ```nginx
    http {
        include mime.types;
    ```
11. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`
12. Open a browser and navigate to the IP address. There I could see the simple webpage with the CSS styling.
13. Check the stylesheet header with curl to see that the `Content-Type` header is now `text/css`

### Location blocks

Location blocks are used to define how Nginx should handle requests for specific URIs. They are defined within the `server` context

There are different types of location blocks (listed in order of priority):

1. Exact match (= <uri>) : The URI must match the location exactly
2. Preferential prefix match (^~ <uri>) : The URI must start with the specified prefix, and no other location block can match the URI
3. Regular expression match (~ <uri> => case-sensitive) or (~* <uri> => case-insensitive) : The URI must match the specified regular expression
4. Prefix match (<uri>) : The URI must start with the specified prefix

Here is the priority order for location blocks:

Each of the location modifiers below is assigned a priority in the following order:

1. Exact match (=)
2. Preferential prefix match (^~)
3. REGEX match (~*)
4. Prefix match ()

Here are some examples of location blocks:

```nginx
events {
}


http {

	include mime.types;

	server {
		listen 80;
		server_name 206.189.100.37;

		root /sites/demo;

		# PREFIX MATCH
		# This matches any location that start with "greet", e.g., greet, greeting, etc.
		location /greet {
			return 200 "Hello from Nginx greet location! => PREFIX MATCH!";

		}

		# PREFIX MATCH
		# This shows that the REGEX match takes priority over this match.
		location /Greet2 {
			return 200 "Hello from Nginx Greet2 location! => PREFIX MATCH PRIORITY PROOF!";

		}

		# PREFERENTIAL PREFIX MATCH
		# The same as a PREFIX MATCH, but takes precedence over REGEX matches.
		location ^~ Greet2 {
			return 200 "Hello from Nginx Greet2 location! => PREFERENTIAL PREFIX MATCH!";

		}

		# EXACT MATCH
		# This matches the exact location.
		location = /greet {
			return 200 "Hello from Nginx greet location => EXACT MATCH!";

		}

		# REGEX MATCH - CASE-SENSITIVE
		# This matches the REGEX expression, but is sensitive to lower vs. uppercase.
		location ~ /greet[0-8] {
			return 200 "Hello from Nginx greet location => REGEX MATCH - CASE SENSITIVE!";

		}

		# REGEX MATCH - CASE-INSENSITIVE
		# This matches the REGEX expression (lower or uppercase).
		location ~* /greet[0-8] {
			return 200 "Hello from Nginx greet location => REGEX MATCH - CASE INSENSITIVE!";

		}

	    }
}
```

### Variables

There are two types of variables in Nginx:

1. Configuration variables (variables we define in the configuration file), e.g., `set $var "value";`
2. [Nginx module variables](https://nginx.org/en/docs/varindex.html) (variables provided by Nginx modules), e.g., `$uri`, `$args`, `$request_uri`

**NOTE** The use of conditionals inside location blocks is [discouraged because it can lead to unexpected behaviour](https://github.com/nginxinc/nginx-wiki/blob/master/source/start/topics/depth/ifisevil.rst).

Here is a simple example of using Nginx built-in variables:

```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                location /inspect {

                        return 200 "$host\n$uri\n$args";
                }

                location /inspectarg {

                        return 200 "Name: $arg_name";
                }
        }
}
```

Here is an example of using a configuration variable and a conditional in Nginx:

```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                set $weekend 'No';

                # Check if day is weekend
                if ($date_local ~ 'Saturday|Sunday' ) {
                        set $weekend 'Yes';
                }

                location /isweekend {
                        return 200 $weekend;
                }
        }
}
```

### Rewrites & redirects

There are two rewrite directives in Nginx:

1. The rewrite directive: `rewrite pattern URI`
    ```nginx
    events {}

    http {

            include mime.types;

            server {

                    listen 80;
                    server_name 206.189.100.37;

                    root /sites/demo;

                    # Starting with user and more than one-word character
                    rewrite ^/user/\w+ /greet;

                    location /greet{
                            return 200 "Hello User";
                    }
            }
    }
    ```
   The URI here does not change in the browser, although the request is rewritten to the `/greet` location.
2. The return directive: `return status URI` => if the status is a 3xx, the return directive behaviour becomes 
   a redirect, and it accepts a URI as the second argument:
   ```nginx
    events {}
    http {

            include mime.types;

            server {

                    listen 80;
                    server_name 206.189.100.37;

                    root /sites/demo;
                    
                    location /logo {
                            return 307 /image.png;
                    }
            }
    }
    ```
    The URI changes in the browser with the redirect, and points to the `/image.png` location.

**NOTE** With the redirect, the URI changes in the browser, while with the rewrite, the URI stays the same.

**PERFORMANCE REWRITES vs. REDIRECTS** The rewrite directive is used to rewrite the URI before it is processed by Nginx. When a URI is rewritten, it gets reevaluated.
The return directive, on the other hand, does not reevaluate the URI but instead sends a redirect to the client.
Therefore, a rewrite directive is more resource-intensive than a return directive.

With rewrites, we can capture parts of the original URI. For example, if we have a URI `/user/john`, 
we can capture the username `john` with a regex pattern and rewrite it to `/greet`:
  
```nginx
events {}

http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                # Starting with user and more than one-word character
                rewrite ^/user/(\w+) /greet/$1;

                location /greet {

                        return 200 "Hello User";
                }

                location = /greet/john {
                        return 200 "Hello John";
                }
        }
}
```
What happens here is the following:
1. We go to the URI `/user/john`
2. The URI gets rewritten to `/greet/john` and reevaluated
3. The new URI skips the `/greet` location block and goes directly to the `/greet/john` location block because the exact match has priority

**OPTIONAL FLAGS** The rewrite directive can take optional flags, such as `last`, `break`, `redirect`, and `permanent`.
The `last` flag makes sure that the location cannot be rewritten again after the current rewrite and reevaluation. 
In the example below, without the `last` flag, the URI would be reevaluated after the rewrite, and would then be rewritten again to `/image.png`.
With the `last` flag set, the URI is rewritten to `/greet/john`, reevaluated, and is then not rewritten again, which 
means that we get the response "Hello John" instead of the image.
  
```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                # Starting with user and more than one-word character
                rewrite ^/user/(\w+) /greet/$1 last;
                rewrite ^/greet/john /image.png;

                location /greet {

                        return 200 "Hello User";
                }

                location = /greet/john {
                        return 200 "Hello John";
                }
        }
}
```

### Try files & named locations

The `try_files` directive can be used within a server context, or inside a location block. 
It is used to try different files or URIs in a specific order until one is found.

`try_files path1 path2 ... final`

In the example below, since the resource image.png exists, the server will return the image regardless of the URI (even if
we go to the /greet location).

```nginx
events {}

http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                try_files /image.png /greet;

                location /greet {

                        return 200 "Hello User";
                }
        }
}
```

If we, however, change the resource to something that does not exist, the server will return the response "Hello User".
To try the current URI first, add the `$uri` variable to the `try_files` directive:

```bash
try_files $uri /notexist.png /greet;
```

The last argument in the `try_files` directive is the final URI to try, and should ideally be something that won't ever fail,
e.g., a 404 page:

```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                try_files $uri /image2.png /friendly_404;

                location /friendly_404 {
                        return 404 "Sorry, that file could not be found.";
                }

                location /greet {

                        return 200 "Hello User";
                }
        }
}
```

Named locations simply means assigning a name to a location context:

```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                try_files $uri /image2.png @friendly_404;

                location @friendly_404 {
                        return 404 "Sorry, that file could not be found.";
                }

                location /greet {

                        return 200 "Hello User";
                }
        }
}
```

Here are some key differences between regular and named locations:

Key Differences Between Regular and Named Locations:

| Aspect          | Named Location (@friendly_404)           | Regular Location (/friendly_404)            |
|-----------------|------------------------------------------|---------------------------------------------|
| Access          | Internal only                            | Publicly accessible                         |
| Visibility      | Hidden from clients                      | Visible and addressable by clients          |
| Routing         | Handled entirely within Nginx            | Can be requested directly by users          |
| URI Redirection | No change to client-visible URI          | URI changes to /friendly_404                |
| Use Case        | Internal error handling or routing logic | Publicly exposed endpoints for custom logic |

Here is an example showcasing the difference:

```nginx
events {}

http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                try_files $uri /image2.png @friendly_404;

                location /friendly_404 {
                        return 200 "Hello from friendly_404 location";
                }

                location @friendly_404 {
                        return 404 "Sorry, that file could not be found.";
                }

                location /greet {

                        return 200 "Hello User";
                }
        }
}
```

If I go to the URI /friendly_404, I will get the response "Hello from friendly_404 location". If I go to the URI /notexist.png,
I will get the response "Sorry, that file could not be found." A named location is not directly accessible.

### Logging

Nginx provides two types of logs:

1. Access logs: Log all requests made to the server, including the client's IP address, the request method, the requested URI, 
   the response status code, and the size of the response.
2. Error logs: Record anything that failed or didn't work as expected, such as a 404 error or a misconfigured directive.

Logging is enabled by default, but understanding how to configure and customise logs is essential for troubleshooting and monitoring.
We might also want to disable logging for certain requests to improve performance, or create resource-specific logs to track specific requests.

Run `nginx -V` to see what log paths you set during the installation of Nginx. 

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/var/log/nginx# nginx -V
nginx version: nginx/1.27.3
built by gcc 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
built with OpenSSL 3.0.13 30 Jan 2024
TLS SNI support enabled
configure arguments: --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
```

To observer and learn about the logging process, I followed these steps:

1. Clear both logs by running:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/var/log/nginx# echo '' > access.log
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/var/log/nginx# echo '' > error.log
    ```
2. Go to the browser and request `<IP>/image.png`
3. Check the access log with `cat access.log` and the error log with `cat error.log`
4. The access log will show the request, the response code, and the size of the response:
    ```bash
   root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/var/log/nginx# cat access.log
   176.10.144.208 - - [19/Jan/2025:14:40:23 +0000] "GET /image.png HTTP/1.1" 200 1438718 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) 
   AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    ```
5. A common misconception is that 404s get logged in the error log. However, properly handled 404s are not errors. If they 
   are not properly handled, then they get logged to error.log.

To customise or disabling logging for a given context, we can use the `access_log` and `error_log` directives:

```nginx
events {}


http {

        include mime.types;

        server {

                listen 80;
                server_name 206.189.100.37;

                root /sites/demo;

                location /secure {
                        access_log /var/log/nginx/secure.access.log;
                        # By adding this, we log to both the access.log and the secure.access.log
                        access_log /var/log/nginx/access.log;
                        return 200 "Welcome to secure area.";
                }
        }
}
```

As soon as we reload the above configuration, a custom log file will be created in the `/var/log/nginx` directory:
  
  ```bash
  root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/var/log/nginx# ls -l
  total 8
  -rw-r--r-- 1 root root 1253 Jan 19 14:50 access.log
  -rw-r--r-- 1 root root  895 Jan 19 14:54 error.log
  -rw-r--r-- 1 root root    0 Jan 19 14:55 secure.access.log
  ```

To disable logging for a specific context, we can set the `access_log off` directive:

```bash
location /secure {
        access_log off;
        return 200 "Welcome to secure area.";
}
```

Read more about [configuring logging in the Nginx documentation](https://docs.nginx.com/nginx/admin-guide/monitoring/logging/).

### Inheritance & directive types

As with scope in a typical programming language, a Nginx context inherits configurations from its parent context.
For example, if we set a directive in the `http` context, it will apply to all server blocks within that context.
However, inheritance will vary depending on the directive type:

1. Array directive
2. Standard directive
3. Action directive

```nginx
events {}

######################
# (1) Array Directive
######################
# Can be specified multiple times without overriding a previous setting
# Gets inherited by all child contexts
# Child context can override inheritance by re-declaring directive
# In this case, the access_log directive is an array directive
access_log /var/log/nginx/access.log;
access_log /var/log/nginx/custom.log.gz custom_format;

http {

  # Include statement - non directive
  include mime.types;

  server {
    listen 80;
    server_name site1.com;

    # Inherits access_log from parent context (1)
  }

  server {
    listen 80;
    server_name site2.com;

    #########################
    # (2) Standard Directive
    #########################
    # Can only be declared once. A second declaration overrides the first
    # Gets inherited by all child contexts
    # Child context can override inheritance by re-declaring directive
    # In this case, the root directive is a standard directive
    root /sites/site2;

    # Completely overrides inheritance from (1)
    # This entire context (site2.com server) and all its child contexts will have logs disabled
    # (unless one of them declares a new access_log directive)
    access_log off;

    location /images {

      # Uses root directive inherited from (2)
      try_files $uri /stock.png;
    }

    location /secret {
      #######################
      # (3) Action Directive
      #######################
      # Invokes an action such as a rewrite or redirect
      # Inheritance does not apply as the request is either stopped (redirect/response) or re-evaluated (rewrite)
      # In this case, the return directive is an action directive
      return 403 "You do not have permission to view this.";
    }
  }
}
```

### PHP processing

Up to now we have configured Nginx to serve static files, leaving the rendering of that file to be handled by the client,
based on its content type or MIME type. However, a cricial part of a web server is to be able to serve dynamic content, 
that has been generated on the server side (by a server-side language such as PHP). Nginx does not have the capability to
embed PHP or other languages directly into the server like Apache can. Instead, all requests for dynamic content are dealt with
by a separate process, such as [PHP-FPM](https://www.php.net/manual/en/install.fpm.php), and then reverse proxied back to the client via Nginx.
Nginx will therefore pass the request for processing to php-fpm, and then return the response (typically as HTML) to the client.

I followed these steps to set up PHP processing:

1. Update the package list with `apt-get update`
2. Install PHP-FPM with `apt-get install php-fpm`
3. Check that the service exists with `systemctl list-units | grep php` => my version is `php8.3-fpm`
4. Check the status of the service with `systemctl status php8.3-fpm`
5. Create the following nginx configuration:
    ```nginx
    events {}

    http {

            include mime.types;

            server {

                    listen 80;
                    server_name 206.189.100.37;

                    root /sites/demo;

                    # Load index.php first if it exists
                    index index.php index.html;

                    # Take care of any request with static content
                    location / {
                            try_files $uri $uri/ =404;
                    }

                    location ~\.php$ {
                            # Pass php-requests to the php-fpm service (fastcgi)
                            include fastcgi.conf;
                            # Pass to a UNIX socket which we can find like this:
                            # find / -name *fpm.sock
                            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
                    }
            }
    }
    ```
6. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`
7. Create a new file `index.php` in the `/sites/demo` directory like this:
    ```bash
    echo '<?php phpinfo(); ?>' > /sites/demo/info.php
    ```
8. Open a browser and navigate to the IP address followed by `/info.php`. There I got a 502 Bad Gateway error.
9. Check the last entry of the error log:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# tail -n 1 /var/log/nginx/error.log
    2025/01/19 19:58:16 [crit] 94182#0: *1547 connect() to unix:/run/php/php8.3-fpm.sock failed (13: Permission denied) while connecting to upstream, client: 176.10.144.208, server: 206.189.100.37, request: "GET /index.php HTTP/1.1", upstream: "fastcgi://unix:/run/php/php8.3-fpm.sock:", host: "206.189.100.37"
    ```
10. The error message indicates that the Nginx process does not have permission to access the PHP-FPM socket => check the user
    that Nginx is running as:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# ps aux | grep nginx
    root         766  0.0  0.6  10808  3204 ?        Ss   Jan12   0:00 nginx: master process /usr/bin/nginx
    nobody     94182  0.0  0.9  12160  4612 ?        S    19:54   0:00 nginx: worker process
    root       94213  0.0  0.4   7076  2048 pts/0    S+   20:01   0:00 grep --color=auto nginx
    ```
11. The Nginx worker process is running as the `nobody` user, which does not have permission to access the PHP-FPM socket.
12. Check the php process permissions:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# ps aux | grep php
    root       93854  0.0  4.4 206824 20736 ?        Ss   19:37   0:00 php-fpm: master process (/etc/php/8.3/fpm/php-fpm.conf)
    www-data   93855  0.0  1.7 207332  8072 ?        S    19:37   0:00 php-fpm: pool www
    www-data   93856  0.0  1.7 207332  8072 ?        S    19:37   0:00 php-fpm: pool www
    root       94226  0.0  0.4   7076  2048 pts/0    S+   20:05   0:00 grep --color=auto php
    ```
13. The PHP-FPM process is running as the `www-data` user, which has permission to access the PHP-FPM socket => configure
    Nginx to run as the same user: add `user www-data;` in the `http` context in Nginx configuration
14. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`
15. Open a browser and navigate to the IP address followed by `/info.php`. There I could see the PHP info page.
    What happened is the following: Nginx received the request, matched it on the location block with the PHP extension,
    and passed it to the PHP-FPM service. PHP-FPM processed the request and returned the response to Nginx, which then 
    served it to the client.
16. Now let's create an `index.php` file that will display the current date and time:
    ```bash
    echo '<h1>Date: <?php echo date("l js F"); ?><h1>' > /sites/demo/index.php
    ```
17. Open a browser and navigate to the IP address. There I could see the current date and time displayed => the index directive
    is set to `index index.php index.html`, so Nginx will look for the `index.php` file first, and if it exists, it will be served.

To learn more about PHP processing in Nginx, read this DigitalOcean article, [Understanding and Implementing FastCGI Proxying in Nginx](https://www.digitalocean.com/community/tutorials/understanding-and-implementing-fastcgi-proxying-in-nginx).

### Worker processes

If I check the status of the Nginx service with `systemctl status nginx`, I see the following:

```bash
nginx.service - The NGINX HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: enabled)
     Active: active (running) since Sun 2025-01-12 19:24:02 UTC; 1 week 1 day ago
    Process: 94234 ExecReload=/bin/kill -s HUP $MAINPID (code=exited, status=0/SUCCESS)
   Main PID: 766 (nginx)
      Tasks: 2 (limit: 509)
     Memory: 2.7M (peak: 5.5M)
        CPU: 1.728s
     CGroup: /system.slice/nginx.service
             ├─  766 "nginx: master process /usr/bin/nginx"
             └─94236 "nginx: worker process"
```

The `nginx: master process` is the the actual Nginx service or software instance. The master process then spawns
`nginx: worker process` instances, which are responsible for handling client requests. The number of worker processes is
by default set to one. To change the number of processes, we can set the `worker_processes` directive:

```nginx
user www-data;

worker_processes 2;

events {}

http {}
```

The worker processes are asynchronous, meaning they will handle incoming requests as fast as the hardware allows. Since CPU
cores cannot share processes, the number of worker processes should be equal to the number of CPU cores. To check the number
of CPU cores, run `nproc` or `lscpu`. The best practice is to set the number of worker processes to `auto`, which will
automatically set the number of worker processes to the number of CPU cores.

Then we can also set the number of connections each worker process can accept. Your server has a limit on the number of
files that can be open at once for each CPU core. Check the open-file limit by running `ulimit -n`. To set the number of
connections, use the `worker_connections` directive:

```nginx
events {
    worker_connections 1024;
}
```

The maximum number of concurrent requests our server should be able to accept is calculated as 
`max_nr_concurrent requests = worker_processes * worker_connections`.

---
**A note on the PID directive**

Recall that we set the PID path in the `nginx.conf` file during the installation of Nginx:
  
```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# nginx -V
nginx version: nginx/1.27.3
built by gcc 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
built with OpenSSL 3.0.13 30 Jan 2024
TLS SNI support enabled
configure arguments: --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
```

We can reconfigure the process ID location by changing the `pid` directive in the `nginx.conf` file.
At the moment, our PID file is located at `/var/run/nginx.pid`. If we want to change the location without rebuilding Nginx, 
we can do so like this:
  
```bash
pid /var/run/new_nginx.pid;
```
---

### Buffers & timeouts

We can optimize performance by configuring buffers and timeouts. 

A buffer is when a process reads data into memory or RAM before writing it to its next destination. If the buffer is too small,
the process will write some of the data to disk.

Timeouts specify a cut-off time for a given event. If the event does not complete within the specified time, the connection
is closed.

```nginx
user www-data;

worker_processes auto;

load_module /etc/nginx/modules/ngx_http_image_filter_module.so;

events {
worker_connections 1024;
}

http {

include mime.types;

# Buffer size for POST submissions
client_body_buffer_size 10K;
client_max_body_size 8m;

# Buffer size for Headers
client_header_buffer_size 1k;

# Max time to receive client headers/body
client_body_timeout 12;
client_header_timeout 12;

# Max time to keep a connection open for
keepalive_timeout 15;

# Max time for the client accept/receive a response
send_timeout 10;

# Skip buffering for static files
sendfile on;

# Optimise sendfile packets
tcp_nopush on;

  server {

      listen 80;
      server_name 206.189.100.37;

      root /sites/demo;

      index index.php index.html;

      location / {
        try_files $uri $uri/ =404;
      }

      location ~\.php$ {
        # Pass php requests to the php-fpm service (fastcgi)
        include fastcgi.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
      }

      location = /image.png {
        image_filter rotate 180;
      }
  }
}
```

### Adding dynamic modules
TODO: Change all Nginx code snippets to Nginx!
TODO: Change all Hack code snippets to Hack in FromNand2Tetris!
https://github.com/rouge-ruby/rouge/wiki/list-of-supported-languages-and-lexers

In order to add dynamic modules to Nginx, we need to recompile Nginx from source. I followed these steps:

1. Go to the directory where the Nginx source code is located. In my case, it is `/root/nginx-1.27.3`
2. Make sure we don't change the existing configuration, so let's run ´nginx -V´ to see the current configuration:
    ```bash
    nginx version: nginx/1.27.3
    built by gcc 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
    built with OpenSSL 3.0.13 30 Jan 2024
    TLS SNI support enabled
    configure arguments: --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log 
                         --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:~/nginx-1.27.3#
    ```
3. See the list of available dynamic modules with `./configure --help | grep dynamic`
4. Use the same configure arguments as before and add the chose dynamic module:
   ```bash
   ./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log 
               --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module 
               --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules # Add the modules path in the same directory as the configuration files
   ```
5. We get the following error:
   ```bash
   ./configure: error: the HTTP image filter module requires the GD library.
   You can either do not enable the module or install the libraries.
   ```
6. Run `apt-get install libgd-dev` to install the GD library
7. Run `./configure` again with the same arguments
8. Run `make` to compile the source code
9. Run `make install` to install the compiled source code
10. Check the current build's configuration with `nginx -V`
11. Reload the Nginx service with `systemctl reload nginx`
12. Check the Nginx status with `systemctl status nginx`
13. Use the new dynamic module in the Nginx configuration:
    ```nginx
    user www-data;

    worker_processes auto;

    load_module /etc/nginx/modules/ngx_http_image_filter_module.so;

    events {
    worker_connections 1024;
    }

    http {

    include mime.types;

    # Buffer size for POST submissions
    client_body_buffer_size 10K;
    client_max_body_size 8m;

    # Buffer size for Headers
    client_header_buffer_size 1k;

    # Max time to receive client headers/body
    client_body_timeout 12;
    client_header_timeout 12;

    # Max time to keep a connection open for
    keepalive_timeout 15;

    # Max time for the client accept/receive a response
    send_timeout 10;

    # Skip buffering for static files
    sendfile on;

    # Optimise sendfile packets
    tcp_nopush on;

      server {

          listen 80;
          server_name 206.189.100.37;

          root /sites/demo;

          index index.php index.html;

          location / {
            try_files $uri $uri/ =404;
          }

          location ~\.php$ {
            # Pass php requests to the php-fpm service (fastcgi)
            include fastcgi.conf;
            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
          }

          location = /image.png {
            image_filter_buffer 2M; 
            image_filter rotate 180;
          }
      }
    }
    ```
14. Reload the Nginx service with `systemctl reload nginx`
15. Check the browser to see if the image is rotated by 180 degrees

Here I encountered an issue: I was getting a 415 (Unsupported Media Type) error. I checked the error log with `tail -n 1 /var/log/nginx/error.log` and saw the following:
  
```bash
2025/01/25 19:50:28 [error] 200345#0: *3719 image filter: too big response: 1438718 while sending response to client, 
client: 176.10.144.208, server: 206.189.100.37, request: "GET /image.png HTTP/1.1", host: "206.189.100.37"
```

I asked [DeepSeek](https://www.deepseek.com/) - a really cool alternative to [ChatGPT](https://chatgpt.com/) - for help. 
It said that the error message image filter: too big response: 1438718 indicates that the image_filter module is rejecting the image
because it exceeds the default size limit for image processing. By default, the image_filter module has a size limit for the images it processes, 
and my image.png file (1.4 MB) is too large for the default settings. It suggested to increase the buffer size for the image_filter module 
using the image_filter_buffer directive.


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

---
title: "Nginx Fundamentals: High performance servers from scratch"
date: 2025-01-19 14:38:23 +0200
categories: [devops, courses] # TOP_CATEGORY, SUB_CATEGORY, MAX 2.
tags: [devops, courses, certificates] # TAG names should always be lowercase.
description: An Udemy course on Nginx fundamentals.
---

## Introduction

I have decided to take [this Udemy course](https://www.udemy.com/course/nginx-fundamentals/) because I have been rewriting a 
custom reverse proxy at my current job at [Caspeco](https://caspeco.com/), and I wanted to see if we could perhaps 
replace it with Nginx in the future. Nginx is a reverse proxy at its core, so I wanted to learn more about its capabilities, to see
if it could cover all our needs.

Let's dive into the course, and I hope you will enjoy my notes and thoughts on it.

## Overview

The course covers the following topics:

* Learn to customise the NGINX installation
* Configure NGINX
* Learn to tweak NGINX for optimal performance
* Secure NGINX with some security best practises
* Learn about NGINX load balancing and reverse proxying

### About Nginx

[Nginx](https://github.com/nginx/nginx) is a high-performance, open-source web server and reverse proxy designed for
speed, scalability, and efficient resource use. Its core functionality includes serving static content, load balancing,
and acting as a reverse proxy to forward client requests to backend servers. Nginx excels at handling large numbers of
concurrent connections, making it ideal for high-traffic websites and applications. Additionally, it supports features like
caching, SSL termination, and URL rewriting, which enhance performance, security, and flexibility in modern web architectures.

Nginx was built in 2004 by [Igor Sysoev](https://en.wikipedia.org/wiki/Igor_Sysoev) as he was looking for an alternative to Apache, 
and wanted to build a replacement capable of handling [10000 concurrent connections](https://en.wikipedia.org/wiki/C10k_problem),
with a focus on:

  * High performance
  * High concurrency
  * Low memory usage

Today, Nginx serves the [majority of the world's websites](https://w3techs.com/technologies/details/ws-nginx), not only because of its performance but also because of its relative ease of use.
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

## Installation

### Server overview

I have set up a [Digital Ocean](https://www.digitalocean.com/) droplet with the following specs:

  * 512 MB RAM
  * 1 vCPU
  * 10 GB SSD
  * Ubuntu 24.04 (LTS) x64

I have also set up SSH key-based authentication by following [this guide on Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server).
To summarize, I followed these steps:

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
    (`a` = show processes for all users,
    `u` = display the process's user/owner,
    `x` = also show processes not attached to a terminal), and `grep` filters the output):
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

1. **Context**: A block of configuration directives (sections within a configuration) that apply to a specific part of the server. 
   For example, the `http` context contains directives that apply to the entire server, while the `server` context contains 
   directives that apply to a specific server block. Contexts are enclosed in curly braces `{}`, and can be nested within each other.
   Nested contexts inherit directives from their parent contexts. The top-most context is the configuration file itself (the main context),
   which is where we define the global directives that apply to the master process. Other important contexts include `events`, `http`,
   the `server`, and `location` contexts.
2. **Directive**: specific configuration options that control how Nginx behaves. Directives are placed inside contexts and are
   followed by a value or a block of values. For example, the `server_name` directive specifies the domain name that the server
   block should respond to.

### Creating a virtual host

We will create a virtual host to serve a simple HTML page. To do this, I followed these steps:

1. Asked [ChatGPT](https://chatgpt.com/) to create a simple webpage consisting of three files: `index.html`, `style.css`, and `image.png`.
2. Went to the root directory with `cd /` (your home directory you can reach with `cd ~` or just `cd`).
3. Created a new directory with `mkdir sites` and then `cd sites` and `mkdir demo`.
4. Copied the files `index.html`and `style.css` from ChatGTP to the `demo` directory manually.
5. Copied the image `image.png` to the `demo` directory with this command: `scp /Users/aljazkovac/Desktop/courses/nginx-fundamentals/image.png digitalocean:/sites/demo/`
   (the [SCP command](https://go.lightnode.com/tech/scp-linux?ref=b7022283&id=58&gad_source=1&gclid=Cj0KCQiA19e8BhCVARIsALpFMgFWgB53pwnAgSFmIOTh_rxr4hYy4J7fW1XxKsTVOLkK6koCZAQxRWgaAlwkEALw_wcB) 
    copies files between hosts on a network, and the syntax is `scp <source> <destination>`, `digitalocean` is the alias I set up in the `~/.ssh/config` file).
6. Edit the file `/etc/nginx/nginx.conf` and add the following configuration:
    ```nginx
    events {
    }

    http {
        server {
          listen 80;
          server_name <IP>;
          root /sites/demo;
        }
    }
    ```
7. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`.
8. Open a browser and navigate to the IP address. There I could see the simple webpage but without the CSS styling.
9. In the browser's developer tools, I could see that the CSS file was being loaded. However, Nginx was sending the wrong [MIME type](https://developer.mozilla.org/en-US/docs/Web/HTTP/MIME_types) 
    for the CSS file. You can check the MIME type with `curl -i http://<IP>/<file>` and see the `Content-Type` header (I got `text/plain` instead of `text/css`).
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
11. Check the configuration with `nginx -t` and reload the configuration with `systemctl reload nginx`.
12. Open a browser and navigate to the IP address. There I could see the simple webpage with the CSS styling.
13. Check the stylesheet header with curl to see that the `Content-Type` header is now `text/css`.

### Location blocks

Location blocks are used to define how Nginx should handle requests for specific URIs. They are defined within the `server` context.

There are different types of location blocks (listed in order of priority):

1. **Exact match (= <uri>)** : The URI must match the location exactly.
2. **Preferential prefix match (^~ <uri>)** : The URI must start with the specified prefix, and no other location block can match the URI.
3. **Regular expression match (~ <uri> => case-sensitive)** or **(~* <uri> => case-insensitive)** : The URI must match the specified regular expression.
4. **Prefix match (<uri>)** : The URI must start with the specified prefix.

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

1. **Configuration variables** (variables we define in the configuration file), e.g., `set $var "value";`
2. **[Nginx module variables]**(https://nginx.org/en/docs/varindex.html) (variables provided by Nginx modules), e.g., `$uri`, `$args`, `$request_uri`

**NOTE**: The use of conditionals inside location blocks is [discouraged because it can lead to unexpected behaviour](https://github.com/nginxinc/nginx-wiki/blob/master/source/start/topics/depth/ifisevil.rst).

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
                if ($date_local ~ 'Saturday|Sunday') {
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

1. The **rewrite** directive: `rewrite pattern URI`
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
2. The **return** directive: `return status URI` => if the status is a 3xx, the return directive behaviour becomes 
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

**NOTE**: With the redirect, the URI changes in the browser, while with the rewrite, the URI stays the same.

---

**Rewrites vs. redirects**

The rewrite directive is used to rewrite the URI before it is processed by Nginx. 
When a URI is rewritten, it gets reevaluated. The return directive, on the other hand, does not reevaluate the URI but instead 
sends a redirect to the client. *Therefore, a rewrite directive is more resource-intensive than a return directive.*

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

1. We go to the URI `/user/john`.
2. The URI gets rewritten to `/greet/john` and reevaluated.
3. The new URI skips the `/greet` location block and goes directly to the `/greet/john` location block because the exact match has priority.

---

**OPTIONAL FLAGS** 

The rewrite directive can take optional flags, such as `last`, `break`, `redirect`, and `permanent`.
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

In the example below, since the resource `image.png` exists, the server will return the image regardless of the URI (even if
we go to the `/greet` location).

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

```nginx
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

**Named locations** simply means assigning a name to a location context:

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

The difference between a named location and a regular location is that a named location is not directly accessible.

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

                location @friendlier_404 {
                        return 404 "Sorry, that file could not be found.";
                }

                location /greet {

                        return 200 "Hello User";
                }
        }
}
```

If I go to the URI `/friendly_404`, I will get the response "Hello from friendly_404 location". If I go to the URI `/friendlier_404`,
I will get the response "Sorry, that file could not be found." A named location is not directly accessible.

### Logging

Nginx provides two types of logs:

1. **Access logs**: Log all requests made to the server, including the client's IP address, the request method, the requested URI, 
   the response status code, and the size of the response.
2. **Error logs**: Record anything that failed or didn't work as expected, such as a 404 error or a misconfigured directive.

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

To observe and learn about the logging process, I followed these steps:

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
   are not properly handled, then they get logged to `error.log`.

To customise or disable logging for a given context, we can use the `access_log` and `error_log` directives:

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
based on its content type or MIME type. However, a critical part of a web server is to be able to serve dynamic content, 
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
8. Open a browser and navigate to the IP address followed by `/info.php`. There I got a `502 Bad Gateway error`.
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

The `nginx: master process` is the actual Nginx service or software instance. The master process then spawns
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
  
```nginx
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

In order to add dynamic modules to Nginx, we need to recompile Nginx from source. I followed these steps:

1. Go to the directory where the Nginx source code is located. In my case, it is `/root/nginx-1.27.3`
2. Make sure we don't change the existing configuration, so let's run `nginx -V` to see the current configuration:
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
4. Use the same configure arguments as before and add the chosen dynamic module:
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

**PROBLEM ALERT**: Instead of a rotated image I got a `415 (Unsupported Media Type)` error. 
I checked the error log with `tail -n 1 /var/log/nginx/error.log` and saw the following:
  
```bash
2025/01/25 19:50:28 [error] 200345#0: *3719 image filter: too big response: 1438718 while sending response to client, 
client: 176.10.144.208, server: 206.189.100.37, request: "GET /image.png HTTP/1.1", host: "206.189.100.37"
```

I asked [DeepSeek](https://www.deepseek.com/) - a really cool alternative to [ChatGPT](https://chatgpt.com/) - for help. 
It said that the error message indicates that the `image_filter` module is rejecting the image because it exceeds the default size limit 
for image processing. By default, the `image_filter` module has a size limit for the images it processes (according to [the documentation](https://nginx.org/en/docs/http/ngx_http_image_filter_module.html#image_filter_buffer),
the default is 1M), and my `image.png` file (1.4 MB) is too large for the default settings. I therefore increased the buffer size to 2M.

## Performance

### Headers & expires

Let's look at some useful modules and directives outside the fundamental Nginx configuration that can help improve performance.

A good starting point is configuring [`expires` headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Expires). 
These headers contain the date/time after which the response is considered expired in the client's cache.

```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

  include mime.types;

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
        add_header my_header "Hello World!";
      }
  }
}
```

We have added a custom header to the image file using the [`add_header`directive](https://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header). To check the headers, we can use the `curl` command:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/image.png
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 26 Jan 2025 20:04:27 GMT
Content-Type: image/png
Content-Length: 1438718
Last-Modified: Tue, 14 Jan 2025 04:53:52 GMT
Connection: keep-alive
ETag: "6785ede0-15f3fe"
my_header: Hello World!
Accept-Ranges: bytes
```

And we see the custom header `my_header: Hello World!` in the response.

Now that we know how to set headers, let's set a few of them:

```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

  include mime.types;

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
        add_header Cache-Control public;
        add_header Pragma public;
        add_header Vary Accept-Encoding;
        expires 1M;
      }
  }
}
```

Let's curl again to see the headers:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/image.png
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 26 Jan 2025 20:08:37 GMT
Content-Type: image/png
Content-Length: 1438718
Last-Modified: Tue, 14 Jan 2025 04:53:52 GMT
Connection: keep-alive
ETag: "6785ede0-15f3fe"
Expires: Tue, 25 Feb 2025 20:08:37 GMT
Cache-Control: max-age=2592000
Cache-Control: public
Pragma: public
Vary: Accept-Encoding
Accept-Ranges: bytes
```

Let's see how a typical location for static files might look like:

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
  access_log off;
  add_header Cache-Control public;
  add_header Pragma public;
  add_header Vary Accept-Encoding;
  expires 1M;
}
```

Curl again, this time for a CSS file:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx#  curl -I http://206.189.100.37/style.css
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Sun, 26 Jan 2025 20:17:17 GMT
Content-Type: text/css
Content-Length: 519
Last-Modified: Tue, 14 Jan 2025 04:46:34 GMT
Connection: keep-alive
ETag: "6785ec2a-207"
Expires: Tue, 25 Feb 2025 20:17:17 GMT
Cache-Control: max-age=2592000
Cache-Control: public
Pragma: public
Vary: Accept-Encoding
Accept-Ranges: bytes
```

### Compressed responses with gzip

When a client requests a resource, e.g., a static file, that client can indicate its ability to accept compressed data.
We can compress a response on the server, typically using `gzip`, which greatly reduces its size and the time it takes to transfer it.

Following are the steps to enable gzip compression:

1. Add `gzip on;` to the `http` context in the Nginx configuration file.
2. Add `gzip_comp_level` to set the compression level (lower number means larger files but requiring less resources) => *3 or 4 is a good value*.
3. Add `gzip_types` to specify the MIME types that should be compressed.
4. Add header `Vary Accept-Encoding` to the location block to indicate that the response [varies based on the `Accept-Encoding` header](https://stackoverflow.com/questions/7848796/what-does-varyaccept-encoding-mean).
5. Reload the Nginx service and check the headers with `curl -I http://206.189.100.37/style.css`.
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/style.css
    HTTP/1.1 200 OK
    Server: nginx/1.27.3
    Date: Mon, 27 Jan 2025 20:12:54 GMT
    Content-Type: text/css
    Content-Length: 519
    Last-Modified: Tue, 14 Jan 2025 04:46:34 GMT
    Connection: keep-alive
    ETag: "6785ec2a-207"
    Expires: Wed, 26 Feb 2025 20:12:54 GMT
    Cache-Control: max-age=2592000
    Cache-Control: public
    Pragma: public
    Vary: Accept-Encoding
    Accept-Ranges: bytes
    ```
6. Now set the header `Accept-Encoding` to `gzip` and curl again:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I -H "Accept-Encoding: gzip" http://206.189.100.37/style.css
    HTTP/1.1 200 OK
    Server: nginx/1.27.3
    Date: Mon, 27 Jan 2025 20:14:14 GMT
    Content-Type: text/css
    Last-Modified: Tue, 14 Jan 2025 04:46:34 GMT
    Connection: keep-alive
    ETag: W/"6785ec2a-207"
    Expires: Wed, 26 Feb 2025 20:14:14 GMT
    Cache-Control: max-age=2592000
    Cache-Control: public
    Pragma: public
    Vary: Accept-Encoding
    Content-Encoding: gzip
    ```
    We see that the response is now compressed with gzip.
7. We can see the difference if we download the file with `curl http://206.189.100.37/style.css` =>
   we get the stylesheet in plain text. If we download the file with `curl -H "Accept-Encoding: gzip" http://206.189.100.37/style.css`
   then we get this:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -H "Accept-Encoding: gzip" http://206.189.100.37/style.css
    Warning: Binary output can mess up your terminal. Use "--output -" to tell
    Warning: curl to output it to your terminal anyway, or consider "--output
    Warning: <FILE>" to save to a file.
    ```
8. Compare how much data we saved:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl http://206.189.100.37/style.css > style.css
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    Dload  Upload   Total   Spent    Left  Speed
    100   519  100   519    0     0   516k      0 --:--:-- --:--:-- --:--:--  506k
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -H "Accept-Encoding: gzip" http://206.189.100.37/style.css > style.min.css
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
    Dload  Upload   Total   Spent    Left  Speed
    100   273    0   273    0     0   224k      0 --:--:-- --:--:-- --:--:--  266k
    ```
   **We compressed the file to approximately half its size.**

### FastCGI_cache

An Nginx micro cache is a small cache that stores responses for a short period of time. It is useful for caching dynamic content. 
This cache can provide great performance benefits for websites that rely heavily on server side languages and database access.

To set up a micro cache, we need to set a few directives, something like this:

```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

  include mime.types;

  # Configure microcache (fastcgi)
  # This configures the depth of directories to split the cache entries into
  fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=MYCACHE:100m inactive=60m; # 100 MB, 60 minutes
  # Adding the scheme will create one entry for https, and another for http
  fastcgi_cache_key "$scheme$request_method$host$request_uri";

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

      # Enable cache
      fastcgi_cache MYCACHE;
      fastcgi_cache_valid 200 60m;
  }
}
```

Let's compare the performance with and without the cache:

1. Install [Apache Benchmark](https://httpd.apache.org/docs/2.4/programs/ab.html) with `apt-get install apache2-utils`
2. Let's create 100 requests in 10 concurrent connections with `ab -n 100 -c 10 http://206.189.100.37/`:
    ```bash
    Benchmarking 206.189.100.37 (be patient).....done
    Server Software:        nginx/1.27.3
    Server Hostname:        206.189.100.37
    Server Port:            80

    Document Path:          /
    Document Length:        35 bytes

    Concurrency Level:      10
    Time taken for tests:   0.054 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      17200 bytes
    HTML transferred:       3500 bytes
    Requests per second:    1842.43 [#/sec] (mean)
    Time per request:       5.428 [ms] (mean)
    Time per request:       0.543 [ms] (mean, across all concurrent requests)
    Transfer rate:          309.47 [Kbytes/sec] received

    Connection Times (ms)
    min  mean[+/-sd] median   max
    Connect:        0    0   0.1      0       0
    Processing:     2    4   1.1      4      14
    Waiting:        2    4   1.0      4      12
    Total:          3    4   1.1      4      14

    Percentage of the requests served within a certain time (ms)
    50%      4
    66%      4
    75%      4
    80%      4
    90%      5
    95%      5
    98%      6
    99%     14
    100%     14 (longest request)
    ```
   The two most important metrics are `Requests per second` and `Time per request`.
3. Let us simulate a longer response time with `sleep(1)` in the PHP file:
    ```bash
    echo '<?php sleep(1); ?>' > /sites/demo/index.php
    ```
   This simulates a slow response time from the server, such as a database query or a slow API call.
4. Run the test again, and now the results are very much different:
    ```bash
    Benchmarking 206.189.100.37 (be patient)... ..done
    Server Software:        nginx/1.27.3
    Server Hostname:        206.189.100.37
    Server Port:            80

    Document Path:          /
    Document Length:        35 bytes

    Concurrency Level:      10
    Time taken for tests:   22.022 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      17200 bytes
    HTML transferred:       3500 bytes
    Requests per second:    4.54 [#/sec] (mean)
    Time per request:       2202.179 [ms] (mean)
    Time per request:       220.218 [ms] (mean, across all concurrent requests)
    Transfer rate:          0.76 [Kbytes/sec] received

    Connection Times (ms)
    min  mean[+/-sd] median   max
    Connect:        0    0   0.3      0       1
    Processing:  1001 2017 283.4   2002    3235
    Waiting:     1001 2016 283.4   2001    3235
    Total:       1002 2017 283.4   2002    3236

    Percentage of the requests served within a certain time (ms)
    50%   2002
    66%   2002
    75%   2002
    80%   2003
    90%   2019
    95%   2251
    98%   3004
    99%   3236
    100%   3236 (longest request)
    ```
5. Now let's enable the cache and run the test again:
    ```bash
    Benchmarking 206.189.100.37 (be patient).....done
    Server Software:        nginx/1.27.3
    Server Hostname:        206.189.100.37
    Server Port:            80

    Document Path:          /
    Document Length:        35 bytes

    Concurrency Level:      10
    Time taken for tests:   0.014 seconds
    Complete requests:      100
    Failed requests:        0
    Total transferred:      17200 bytes
    HTML transferred:       3500 bytes
    Requests per second:    7048.21 [#/sec] (mean)
    Time per request:       1.419 [ms] (mean)
    Time per request:       0.142 [ms] (mean, across all concurrent requests)
    Transfer rate:          1183.88 [Kbytes/sec] received

    Connection Times (ms)
    min  mean[+/-sd] median   max
    Connect:        0    0   0.2      0       1
    Processing:     0    1   0.3      1       2
    Waiting:        0    1   0.3      1       2
    Total:          1    1   0.3      1       3

    Percentage of the requests served within a certain time (ms)
    50%      1
    66%      2
    75%      2
    80%      2
    90%      2
    95%      2
    98%      2
    99%      3
    100%      3 (longest request)
   ```
    The performance is much better now. Requests per second increased from 4.54 to 7048, and the time per request decreased from 2202.179 ms to 1.419 ms.
6. But how to know if a response was served from the cache? We can add the following header:
    ```nginx
    # Configure microcache (fastcgi)
    # This configures the depth of directories to split the cache entries into
    fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=MYCACHE:100m inactive=60m; # 100 MB, 60 minutes
    # Adding the scheme will create one entry for https, and another for http
    fastcgi_cache_key "$scheme$request_method$host$request_uri";
    # Add a header to indicate if the response was served from the cache
    add_header X-Cache $upstream_cache_status;
    ```
7. Test with curl:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/
    HTTP/1.1 200 OK
    Server: nginx/1.27.3
    Date: Fri, 31 Jan 2025 19:38:06 GMT
    Content-Type: text/html; charset=UTF-8
    Connection: keep-alive
    X-Cache: HIT
    ```
8. Since we included the `request_uri` in the cache key, the cache will be unique for each request URI. 
    Therefore, to see a cache miss we can curl with a different URI:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/index.php
    HTTP/1.1 200 OK
    Server: nginx/1.27.3
    Date: Fri, 31 Jan 2025 19:39:10 GMT
    Content-Type: text/html; charset=UTF-8
    Connection: keep-alive
    X-Cache: MISS
    ```
9. To add cache exceptions, set up something like this:
    ```nginx
    user www-data;

    worker_processes auto;

    events {
    worker_connections 1024;
    }

    http {

    include mime.types;

    # Configure microcache (fastcgi)
    # This configures the depth of directories to split the cache entries into
    fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=MYCACHE:100m inactive=60m; # 100 MB, 60 minutes
    # Adding the scheme will create one entry for https, and another for http
    fastcgi_cache_key "$scheme$request_method$host$request_uri";
    add_header X-Cache $upstream_cache_status;

      server {

            listen 80;
            server_name 206.189.100.37;

            root /sites/demo;

            index index.php index.html;

            # Cache by default
            set $no_cache 0;

            # Check for cache bypass
            if ($arg_skipcache = 1) {
              set $no_cache 1;
            }

            location / {
              try_files $uri $uri/ =404;
            }

            location ~\.php$ {
              # Pass php requests to the php-fpm service (fastcgi)
              include fastcgi.conf;
              fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        # If no_cache is 1, bypass serving from the cache, and don't write the response to the cache either.
        fastcgi_cache_bypass $no_cache;
        fastcgi_no_cache $no_cache;
            }

            # Enable cache
            fastcgi_cache MYCACHE;
            fastcgi_cache_valid 200 60m;
      }
    }
    ```
10. Now we can curl like this:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -I http://206.189.100.37/?skipcache=1
    HTTP/1.1 200 OK
    Server: nginx/1.27.3
    Date: Fri, 31 Jan 2025 19:44:06 GMT
    Content-Type: text/html; charset=UTF-8
    Connection: keep-alive
    X-Cache: BYPASS
    ```

### HTTP2

HTTP/2 is a major revision of the HTTP network protocol used by the World Wide Web. It is based on the [SPDY](https://en.wikipedia.org/wiki/SPDY) protocol developed by Google.

| HTTP2 vs HTTP1.1 | Advantages of HTTP2                                                  |
|------------------|----------------------------------------------------------------------|
| Binary protocol  | HTTP1 is a text-based protocol                                       |
| Compression      | Compression of headers                                               |
| Persistent       | Persistent connections                                               |
| Multiplex        | Multiple assets can be combined into a single stream of binary data  |
| Server push      | Server can push assets to the client before the client requests them |

To load a simple website with HTTP1, we need to establish at least 3 connections: 1 for the HTML file, 1 for the CSS file, and 1 for the JavaScript file.
With HTTP2, we can load all these assets with a single connection (after receiving the HTML file, the connection persists and the server pushes the CSS and JavaScript files).

To configure HTTP2 in Nginx, we need to first enable SSL, but that has already been done before (`with-http_ssl_module`).
To add the HTTP2 module, we need to recompile Nginx from source:

1. Check the build arguments with `nginx -V`.
2. Copy the build arguments and add `--with-http_v2_module` to the `./configure` command and run it.
3. Run `make` and `make install`.
4. Restart Nginx and check its status.
5. Add a self-signed SSL certificate and private key:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# openssl req -x509 -days 30 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/self.key -out /etc/nginx/ssl/self.crt
    ```
6. Add the SSL configuration to the server block:
    ```nginx
    user www-data;
    worker_processes auto;
    events {
    worker_connections 1024;
    }

    http {

    include mime.types;

      server {

            listen 443 ssl; # This is the standard SSL port.
            server_name 206.189.100.37;

            root /sites/demo;

            index index.php index.html;

            ssl_certificate /etc/nginx/ssl/self.crt;
            ssl_certificate_key /etc/nginx/ssl/self.key;

            location / {
              try_files $uri $uri/ =404;
            }

            location ~\.php$ {
              # Pass php requests to the php-fpm service (fastcgi)
              include fastcgi.conf;
              fastcgi_pass unix:/run/php/php8.3-fpm.sock;
            }
      }
    }
    ```
7. In the browser, change to `https://...` and check the SSL certificate.
8. Enable HTTP2 in the server block:
    ```nginx
      server {

            listen 443 ssl http2; # Enable HTTP2
            server_name <IP_ADDRESS>;
            ...
     }
   ```
9. Reload Nginx and curl:
    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -Ik https://206.189.100.37/index.html
    HTTP/2 200
    server: nginx/1.27.3
    date: Fri, 31 Jan 2025 20:52:55 GMT
    content-type: text/html
    content-length: 571
    last-modified: Tue, 14 Jan 2025 05:19:56 GMT
    etag: "6785f3fc-23b"
    accept-ranges: bytes
    ```

**NOTE**: The course here is a bit outdated, as the most modern version of the HTTP protocol is [HTTP3](https://en.wikipedia.org/wiki/HTTP/3).

### Server push

Server push is a feature of HTTP/2 that allows the server to push resources to the client before the client requests them.
This is an extensive subject, which you can read more about [here](https://www.f5.com/company/blog/nginx/nginx-1-13-9-http2-server-push).

Since browser tools aren't good at displaying how pushed files are delivered, let's install the [`nghttp2` module](https://nghttp2.org/) with `apt-get install nghttp2-client`.
Then run `nghttp -nys https://206.189.100.37/index.html` (`n` to discard responses, `y`to ignore the self-signed certificate, and `s` to print the response statistics).

We get this:

```bash
***** Statistics *****
Request timing:
  responseEnd: the  time  when  last  byte of  response  was  received
               relative to connectEnd
 requestStart: the time  just before  first byte  of request  was sent
               relative  to connectEnd.   If  '*' is  shown, this  was
               pushed by server.
      process: responseEnd - requestStart
         code: HTTP status code
         size: number  of  bytes  received as  response  body  without
               inflation.
          URI: request URI

see http://www.w3.org/TR/resource-timing/#processing-model

sorted by 'complete'

id  responseEnd requestStart  process code size request path
 13      +605us       +247us    358us  200  571 /index.html
```

Then run this again but add also an `a` flag to request the linked resources (assets) in the request, and we get this:

```bash
***** Statistics *****
Request timing:
  responseEnd: the  time  when  last  byte of  response  was  received
               relative to connectEnd
 requestStart: the time  just before  first byte  of request  was sent
               relative  to connectEnd.   If  '*' is  shown, this  was
               pushed by server.
      process: responseEnd - requestStart
         code: HTTP status code
         size: number  of  bytes  received as  response  body  without
               inflation.
          URI: request URI

see http://www.w3.org/TR/resource-timing/#processing-model

sorted by 'complete'

id  responseEnd requestStart  process code size request path
 13     +6.80ms       +128us   6.67ms  200  571 /index.html
 15     +7.55ms      +7.29ms    251us  200  519 /style.css
 17    +15.97ms      +7.30ms   8.67ms  200   1M /image.png
```

**NOTE**: The course here is a bit outdated, as it wants you to add the following to your Nginx configuration:

```nginx
location = /index.html {
              http2_push /style.css;
              http2_push /image.png;
      }
```

However, if you run `nginx -t` you will get an error that `http2_push` is obsolete. Instead, you should use `add_header Link` like this:

```nginx
location = /index.html {
    add_header Link "</style.css>; as=style; rel=preload";
    add_header Link "</image.png>; as=image; rel=preload";
}
```

If we run `nghttp -nysa https://206.189.100.37/index.html` again, we can see that the response time for loading the assets is much faster now:

```bash
***** Statistics *****

Request timing:
  responseEnd: the  time  when  last  byte of  response  was  received
               relative to connectEnd
 requestStart: the time  just before  first byte  of request  was sent
               relative  to connectEnd.   If  '*' is  shown, this  was
               pushed by server.
      process: responseEnd - requestStart
         code: HTTP status code
         size: number  of  bytes  received as  response  body  without
               inflation.
          URI: request URI

see http://www.w3.org/TR/resource-timing/#processing-model

sorted by 'complete'

id  responseEnd requestStart  process code size request path
 13      +624us       +106us    518us  200  571 /index.html
 15      +894us       +722us    172us  200  519 /style.css
 17     +7.07ms       +723us   6.34ms  200   1M /image.png
```

## Security

### HTTPS (SSL)

We will continue to work on our SSL configuration and see how to optimize our HTTPS connections. 

First off, if we go to our landing page at `http://206.189.100.37/` then we get an error because we have set up the server to only listen on port 443 (SSL).
To redirect all HTTP traffic to HTTPS, we can add a new server block that listens on port 80 and redirects to port 443:

```nginx
# Redirect all traffic to HTTPS.
server {
        listen 80;
        server_name 206.189.100.37;
        return 301 https://$host$request_uri;
}
```
Test with curl:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -Ik http://206.189.100.37
HTTP/1.1 301 Moved Permanently
Server: nginx/1.27.3
Date: Sun, 02 Feb 2025 17:33:15 GMT
Content-Type: text/html
Content-Length: 169
Connection: keep-alive
Location: https://206.189.100.37/
```

Now we can see that the server redirects all HTTP traffic to HTTPS.

We will continue by disabling SSL in favor of [TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0,_2.0,_and_3.0), 
optimising our [cipher suites](https://en.wikipedia.org/wiki/Cipher_suite), and enabling [Diffie-Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange).

```nginx
# Disable SSL
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

# Optimise cipher suits
ssl_prefer_server_ciphers on;
ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

# Enable DH Params
ssl_dhparam /etc/nginx/ssl/dhparam.pem;
```

Now let's generate the DH params:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
```

Now let's enable HSTS (HTTP Strict Transport Security) to force the browser to use HTTPS:

```nginx
# Enable HSTS
add_header Strict-Transport-Security "max-age=31536000" always;

# SSL sessions
ssl_session_cache shared:SSL:40m;
ssl_session_timeout 4h;
ssl_session_tickets on;
```

In summary, we have done the following:

1. Disabled SSL in favor of TLS.
2. Optimised the cipher suites.
3. Enabled DH params.
4. Enabled HSTS.
5. Cached SSL sessions.

Our final configuration looks like this:

```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

  include mime.types;

  # Redirect all traffic to HTTPS.
  server {
	  listen 80;
	  server_name 206.189.100.37;
	  return 301 https://$host$request_uri;
  }

  server {

      listen 443 ssl; # This is the standard SSL port.
      http2 on;
      server_name 206.189.100.37;

      root /sites/demo;

      index index.html;

      ssl_certificate /etc/nginx/ssl/self.crt;
      ssl_certificate_key /etc/nginx/ssl/self.key;

      # Disable SSL
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

      # Optimise cipher suits
      ssl_prefer_server_ciphers on;
      ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

      # Enable DH Params
      ssl_dhparam /etc/nginx/ssl/dhparam.pem;

      # Enable HSTS
      add_header Strict-Transport-Security "max-age=31536000" always;

      # SSL sessions
      ssl_session_cache shared:SSL:40m;
      ssl_session_timeout 4h;
      ssl_session_tickets on;

      location / {
        try_files $uri $uri/ =404;
      }

      location ~\.php$ {
        # Pass php requests to the php-fpm service (fastcgi)
        include fastcgi.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
      }
  }
}
```

And if we test with curl we get this:

```bash
root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -Ik https://206.189.100.37
HTTP/2 200
server: nginx/1.27.3
date: Sun, 02 Feb 2025 20:33:38 GMT
content-type: text/html
content-length: 571
last-modified: Tue, 14 Jan 2025 05:19:56 GMT
etag: "6785f3fc-23b"
strict-transport-security: max-age=31536000
accept-ranges: bytes
```

**NOTE**: The course is a bit outdated in this section:

1. TLSv1 and TLSv1.1: These protocols are deprecated and vulnerable to attacks like [POODLE](https://en.wikipedia.org/wiki/POODLE) and [BEAST](https://www.invicti.com/blog/web-security/how-the-beast-attack-works/).
2. Weak Ciphers: The inclusion of DH+3DES and the lack of modern ciphers like AES-GCM and ChaCha20 make the configuration less secure.
3. No TLSv1.3: TLSv1.3 is the most modern and secure version of TLS, offering faster handshakes and improved security.

### Rate limiting

Rate limiting is a technique used to control the rate of traffic sent or received by a network interface controller and is used 
for the following reasons:

1. Security against brute force attacks.
2. Reliability by preventing server overload.
3. Shaping traffic, e.g., restrict users to a service tier.

To test the rate limiting, we will use a tool called [Siege](https://www.joedog.org/siege-home/), which can be installed with `apt-get install siege`.

Let's run a basic test to check that the tool is working:

```bash
siege -v -r 2 -c 5 https://206.189.100.37/image.png
```

This will run two tests of five concurrent connections to the image file, with verbose output.

We get this:

```bash
{
    "transactions":              10,
    "availability":              100.00,
    "elapsed_time":              0.11,
    "data_transferred":          13.72,
    "response_time":             0.05,
    "transaction_rate":          90.91,
    "throughput":                124.73,
    "concurrency":               4.64,
    "successful_transactions":   10,
    "failed_transactions":       0,
    "longest_transaction":       0.08,
    "shortest_transaction":      0.03
}
```

Now let's add rate limiting to our Nginx configuration:

```nginx
# Rate limiting
limit_req_zone $request_uri zone=MYZONE:10m rate=60r/m;
```

What this does is it limits the number of requests to 60 per minute for each unique request URI. This sets a frequency, meaning
that `60r/m` is the same as `1r/s`. In other words, this doesn't mean that the server can accept 60 requests at once, and then
no more for the rest of the minute. Instead, it means that the server can accept 1 request per second.

Now let's add the rate limiting to the location block, so our final configuration would look like this:

```nginx
user www-data;

worker_processes auto;

events {
worker_connections 1024;
}

http {

  include mime.types;

  # Define limit zone
  limit_req_zone $request_uri zone=MYZONE:10m rate=60r/m;

  # Redirect all traffic to HTTPS.
  server {
	  listen 80;
	  server_name 206.189.100.37;
	  return 301 https://$host$request_uri;
  }

  server {

      listen 443 ssl; # This is the standard SSL port.
      http2 on;
      server_name 206.189.100.37;

      root /sites/demo;

      index index.html;

      ssl_certificate /etc/nginx/ssl/self.crt;
      ssl_certificate_key /etc/nginx/ssl/self.key;

      # Disable SSL
      ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

      # Optimise cipher suits
      ssl_prefer_server_ciphers on;
      ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

      # Enable DH Params
      ssl_dhparam /etc/nginx/ssl/dhparam.pem;

      # Enable HSTS
      add_header Strict-Transport-Security "max-age=31536000" always;

      # SSL sessions
      ssl_session_cache shared:SSL:40m;
      ssl_session_timeout 4h;
      ssl_session_tickets on;

      location / {
	      limit_req zone=MYZONE;
        try_files $uri $uri/ =404;
      }

      location ~\.php$ {
        # Pass php requests to the php-fpm service (fastcgi)
        include fastcgi.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
      }
  }
}
```

If we now run the same test again we get this:

```bash
{
    "transactions":              1,
    "availability":              10.00,
    "elapsed_time":              0.04,
    "data_transferred":          1.37,
    "response_time":             0.20,
    "transaction_rate":          25.00,
    "throughput":                34.34,
    "concurrency":               5.00,
    "successful_transactions":   1,
    "failed_transactions":       9,
    "longest_transaction":       0.03,
    "shortest_transaction":      0.01
}
```

We see that there were 9 failed transactions, which means that the rate limiting is working.

Now let's also set a burst limit, which is the maximum number of requests that can be made in a single burst. We achieve this
by adding a `burst` parameter to the `limit_req` directive:

```nginx
limit_req zone=MYZONE burst=5;
```

Run the test again and you get:

```bash
{
    "transactions":              10,
    "availability":              100.00,
    "elapsed_time":              9.03,
    "data_transferred":          13.72,
    "response_time":             3.51,
    "transaction_rate":          1.11,
    "throughput":                1.52,
    "concurrency":               3.89,
    "successful_transactions":   10,
    "failed_transactions":       0,
    "longest_transaction":       5.00,
    "shortest_transaction":      0.03
}
```

We see that all transactions were successful, and the traffic shaping is working as expected.

If we now change the test and run it with 15 concurrent connections in one batch, we get this:

```bash
{
    "transactions":              6,
    "availability":              40.00,
    "elapsed_time":              5.04,
    "data_transferred":          8.23,
    "response_time":             2.64,
    "transaction_rate":          1.19,
    "throughput":                1.63,
    "concurrency":               3.14,
    "successful_transactions":   6,
    "failed_transactions":       9,
    "longest_transaction":       5.04,
    "shortest_transaction":      0.05
}
```

We see that there were just 6 successful transactions. Why six and not five? This is because the burst limit allows for 
the original request plus five extra requests to be made in a single burst.

We can also add the `nodelay` parameter to the `limit_req` directive, which means that the rate limit is applied immediately
and not after the burst limit is reached.

```nginx
limit_req zone=MYZONE burst=5 nodelay;
```

Here are two articles that you can read to learn more about rate limiting:

1. [Rate Limiting with Nginx](https://www.nginx.com/blog/rate-limiting-nginx/)
2. [Nginx Rate-Limiting in a Nutshell](https://www.freecodecamp.org/news/nginx-rate-limiting-in-a-nutshell-128fe9e0126c)

### Basic authentication

What if you have an area of your site that is not intended for the public? You can use basic authentication to protect it.
It provides a simple username-password layer of security.

To set up basic authentication, we need to create a password file in the `htpasswd` format.
We begin by installing the same suite of tools that we used for Apache Bench tools: `apt-get install apache2-utils`.

Now we can create a password file with the `htpasswd` command:

```bash
htpasswd -c /etc/nginx/.htpasswd user1
```

The `-c` flag creates a new file, and the `user1` is the username. You will be prompted to enter a password for the user.
If we now look at the file with `cat /etc/nginx/.htpasswd` we see the username and the hashed password.

### Hardening Nginx

Before we start to further secure our Nginx server, let's update the system with `apt-get update` and `apt-get upgrade`.
Then check your version of Nginx and the [Nginx changelog](https://nginx.org/en/CHANGES) to see if there are any security vulnerabilities that need to be addressed.

Now to further secure your Nginx server:

1. Hide the version number in the server header by adding `server_tokens off;` to the `http` block. 
   The reason is that if an attacker knows the version number, they can look up known vulnerabilities for that version. 

    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -Ik https://206.189.100.37/
    HTTP/2 200
    server: nginx/1.27.3
    date: Tue, 04 Feb 2025 20:32:05 GMT
    content-type: text/html
    content-length: 571
    last-modified: Tue, 14 Jan 2025 05:19:56 GMT
    etag: "6785f3fc-23b"
    strict-transport-security: max-age=31536000
    accept-ranges: bytes
    ```

    If we turn off the server tokens then we get this:

    ```bash
    root@ubuntu-s-1vcpu-512mb-10gb-ams3-01:/etc/nginx# curl -Ik https://206.189.100.37/
    HTTP/2 200
    server: nginx
    date: Tue, 04 Feb 2025 20:32:05 GMT
    content-type: text/html
    content-length: 571
    last-modified: Tue, 14 Jan 2025 05:19:56 GMT
    etag: "6785f3fc-23b"
    strict-transport-security: max-age=31536000
    accept-ranges: bytes
    ```

    Voilà! The version number is gone.
2. `X-Frame-Options`: This header is used to protect against [clickjacking](https://en.wikipedia.org/wiki/Clickjacking) attacks. 
   It tells the browser whether to allow a page to be displayed in an iframe. Add this to the `server` block:

    ```nginx
    add_header X-Frame-Options "SAMEORIGIN";
    ```

   What this does is it tells the browser that the page can only be displayed in a frame on the same origin as the page itself.
   Test by creating a simple website:

    ```html
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>Origin</title>
      </head>
      <body>
        <iframe src="https://206.189.100.37/" width="800" height="400"></iframe>
      </body>
    </html>
    ```

    If you add the `X-Frame-Options` header, then the page will not be displayed in the iframe.
3. Add the `X-XSS-Protection` header to protect against [cross-site scripting](https://en.wikipedia.org/wiki/Cross-site_scripting) attacks:

    ```nginx
    add_header X-XSS-Protection "1; mode=block";
    ```

    This header tells the browser to block the page if an XSS attack is detected. `1`means `on`, and `mode=block` means that the browser should block the page.
4. Rebuild Nginx with the `--without-http_autoindex_module` flag to disable the `autoindex` module. 
   This module generates directory listings if there is no index file in a directory. This is a security risk because it can 
   expose sensitive information. f an index file (such as `index.html`) isn’t present, the module creates a directory listing that 
   might expose sensitive files or internal organization details. Disabling autoindex minimizes the risk of accidental exposure of 
   file system information that could help an attacker plan further exploits. 
   To rebuild, do the following:
   * Run `nginx -V` to see the build arguments, then copy them and add `--without-http_autoindex_module` to the `./configure` command.
   * Run `make` and `make install`.

### Let's Encrypt - SSL certificates

[Let's Encrypt](https://letsencrypt.org/) is a free, automated, and open certificate authority that provides free SSL certificates.
Plain, insecure http connections are a thing of the past, and it is now expected that all websites use `https`.

Before setting up an SSL certificate I had to set up a custom domain, which I did with [Namecheap](https://www.namecheap.com/).
I also had to connect the Digital Ocean's name servers to the custom domain.

In order to generate certificates and automate their renewal, I used the [Certbot](https://certbot.eff.org/) tool.
To install certbot on Ubuntu, I followed the instructions on the [Certbot website](https://certbot.eff.org/instructions?ws=nginx&os=snap).
I installed Certbot with [snap](https://en.wikipedia.org/wiki/Snap_(software)), a package manager for Linux. Snaps are self-contained applications with mediated access 
to the host system.

Because I ran the `sudo certbot --nginx` command, Certbot edited my Nginx configuration automatically, and I ended up with this:

```nginx
events {
}

http {

  server {
	  server_name reddsmart.org;

	  location / {
		  return 200 "Hello from Nginx";
	  }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/reddsmart.org/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/reddsmart.org/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

  server {
    if ($host = reddsmart.org) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

	  listen 80;
	  server_name reddsmart.org;
    return 404; # managed by Certbot
}}
```

As I went to the browser, I could see that the website was now secure and I could inspect the certificate there. 

The last part was making sure that the certificate will be renewed. It is possible to renew the certificate manually by running
`sudo certbot renew`. But there is no need to automate the renewal of the certificate, as that is the default behaviour, as stated
in the [Certbot documentation](https://certbot.eff.org/instructions?ws=nginx&os=snap): *"The Certbot packages on your system come with a cron job or systemd timer that will renew 
your certificates automatically before they expire. You will not need to run Certbot again, unless you change your configuration."*

We could also add a `cronjob` manually with the `crontab -e` command, and by adding the following line there `@daily certbot renew`.
Then we could list all our cronjobs with the `crontab -l` command.

## Reverse proxy & load balancing

### Prerequisites

We will be using our local Nginx server here, along with a few simple php servers. I installed my Nginx with homebrew,
so the Nginx configuration was placed in the `/opt/homebrew/etc/nginx` folder. There was already a nice setup there, but to test a very 
simple version, I changed the `location` block to this:

```nginx
    server {
        listen       8080;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
#             root   html;
#             index  index.html index.htm;
              return 200 "Hello from Nginx";
        }
    }
```

Running `curl` to `http://localhost:8080/` returns the greeting.

Now we can also fire up a simple php server (I had to install php first with `brew install php`). Then I could fire up
a php server with `php -S localhost:9090`. I also copied an image from the internet into my nginx folder with 
`sudo curl -o /opt/homebrew/etc/nginx/logo.png <URL>`, so if I go to `locahost:9090/logo.png` I can see the image there.

I then created a `resp.txt` file in the nginx folder, and in the file I simply said **"Hello from PHP!"**. Then I started the 
PHP server again with `php -S localhost:9090 resp.txt`, and now I am served the greeting from the file at `localhost:9090`.

### Reverse proxy

A reverse proxy acts as an intermediary between the client (e.g., a browser), and the resource itself. 

I have the following running:

1. Nginx server at `localhost:8080`
2. PHP server at `localhost:9090`

I have then added the following location block to `nginx.conf`:

```bash
location /php {
      proxy_pass http://localhost:9090/;
}
```

This means that I can proxy from the Nginx server to the PHP server. So, if I curl to `http://localhost:8080/php` I get the
**"Hello from PHP"** message from the PHP server. If I curl without the `php` part I get the greeting from Nginx.

We can also pass custom headers to either the proxied server or to the client.

Let's pass headers to the client first:

```nginx
location /php {
      add_header proxied nginx;
      proxy_pass http://localhost:9090/;
}
```

If we `curl` now we get this: 

```bash
HTTP/1.1 200 OK
Server: nginx/1.27.3
Date: Mon, 10 Feb 2025 20:42:33 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
Host: localhost:9090
X-Powered-By: PHP/8.4.3
proxied: nginx
```

Now we can add headers to the proxied server. First, let's create a file called `show_request.php`:

```php
<?php

var_dump(getallheaders());
```

Then let's start the server with: `php -S localhost:9090 show_request.php`. If we now `curl`to `http://localhost:8080/php` then we get:

```bash
array(4) {
  ["Host"]=>
  string(14) "localhost:9090"
  ["Connection"]=>
  string(5) "close"
  ["User-Agent"]=>
  string(11) "curl/7.80.0"
  ["Accept"]=>
  string(3) "*/*"
}
```

All we need to do to add the headers to the proxied server instead is change the `add_header` directive to `proxy_set_header`.
Then a `curl` returns this:

```bash
curl http://localhost:8080/php
array(5) {
  ["proxied"]=>
  string(5) "nginx"
  ["Host"]=>
  string(14) "localhost:9090"
  ["Connection"]=>
  string(5) "close"
  ["User-Agent"]=>
  string(11) "curl/7.80.0"
  ["Accept"]=>
  string(3) "*/*"
}
```

### Load balancer

Nginx makes it easy to configure a [simple and robust load balancer](https://nginx.org/en/docs/http/load_balancing.html). 
A load balancer should perform two main tasks:

1. Distribute requests to multiple servers, thus reducing the load on those individual servers
2. Provide redundancy, meaning that if one of the servers fails, the load balancer should recognize that and redirect/proxy requests

Let us begin by firing up three PHP servers. We simply create three different files like this:

```bash
echo "PHP server 1" > s1
echo "PHP server 2" > s2
echo "PHP server 3" > s3
```

And then we run them with `php -S localhost:<port> <file>`.

Once we have that running we create another Nginx configuration file, e.g., `load-balancer.conf`:

```nginx
events {}

http {

  server {

    listen 8888;

    location / {
      proxy_pass "http://localhost:10001/";
      }
  }
}
```

We can then run that file (instead of the default `nginx.conf`) by using the `-c` flag, like this: `nginx -c <file-path>`.
We can also test this configuration by running `nginx -t -c <file-path>`.

Since we are proxying to the first PHP server, if we curl our nginx server, we get a response from the first server.

To create the load balancer functionality, we need to create an `upstream`, a block that groups servers and enables us to set 
options on the block. We will be using the [`http_ustream_module`](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)
for this purpose.

Add and `upstream` block to the `http` context and proxy to it like so:

```nginx
events {}

http {

	upstream php_servers {
		server localhost:10001;
		server localhost:10002;
		server localhost:10003;
	}

  server {
  
    listen 8888;
    
    location / {
      proxy_pass http://php_servers;
      }
  }
} 
```

Remember to reload the configuration file like so: `nginx -s reload`. Then run a simple while loop that curls to the Nginx server,
and you should see something like this:

```bash
(base) aljazkovac@Aljazs-MBP nginx % while sleep 0.5; do curl http://localhost:8888; done
PHP Server 1
PHP Server 2
PHP Server 3
PHP Server 3
PHP Server 2
PHP Server 1
PHP Server 3
PHP Server 2
PHP Server 1
PHP Server 3
PHP Server 2
PHP Server 1
PHP Server 3
PHP Server 2
PHP Server 1
PHP Server 3
PHP Server 2
etc.
```

We see that the requests are nicely balanced ([round-robin](https://en.wikipedia.org/wiki/Round-robin_scheduling, as per default).
We can also test that the load balancer works by running the loop again, perhaps with a slightly larger delay, and killing
the servers one-by-one. We see that the server balances the requests to the remaining servers.

### Load balancer options

Let's look at a few load balancer options:

_Sticky sessions_: the request is bound to a user's IP request and always, when possible, proxied to the same server. 
This allows us to maintain user sessions for things like login state, etc. 

Add `ip_hash` directive to the `upstream php_servers` block: 

```nginx
upstream php_servers {
  ip_hash;
  server localhost:10001;
  server localhost:10002;
  server localhost:10003;
}
```

If we run our three PHP servers again and `curl` the nginx server with the `while` loop, as we did before, we will now get 
proxied to only one server. If that server goes down, nginx will start proxying to the next available server, etc. In the 
terminal output below you can see where I killed `PHP Server 2`:

```bash
(base) aljazkovac@Aljazs-MBP nginx % while sleep 1; do curl http://localhost:8888; done
PHP Server 2
PHP Server 2
PHP Server 2
PHP Server 2
PHP Server 2
PHP Server 2
PHP Server 2
PHP Server 1
PHP Server 1
PHP Server 1
PHP Server 1
PHP Server 1
PHP Server 1
```

_Active connections / load_: Instead of picking the next server in the queue, nginx will proxy to the server with the least
active connections.

We can simulate an overloaded server by creating a PHP server that has a delay of 20 seconds:

```php
<?php

sleep(20);

echo "Sleepy server finally done!";
```

Then we can start one of the servers with that file, while the other two can be run as before. If we now curl in a loop again,
then we might get stuck on that delayed server. However, if we add the `least_conn` directive to the `upstream php_servers` block,
then nginx will proxy to the two servers that are not as busy.

```nginx
events {}

http {

	upstream php_servers {
    least_conn;
		server localhost:10001;
		server localhost:10002;
		server localhost:10003;
	}

server {

    listen 8888;
    
    location / {
      proxy_pass http://php_servers;
      }
}
}
```

### Documentation & resources

Here are two interesting resources worth looking at:

1. [Nginx documentation](https://docs.nginx.com/)
2. [Nginx resources](https://github.com/fcambus/nginx-resources): a great list of various resources, including an [interview with the creator of Nginx](https://web.archive.org/web/20180614224054/http://mindend.com/interview-with-the-creator-of-nginx/), and much more.

## Final thoughts and certificate

I really enjoyed this course. I learned a lot about Nginx and its powerful capabilities. The course is a bit outdated in
some sections, e.g., Security, but that is to be expected. The initial motivation was to take the course to learn more 
about reverse proxying, and I would have liked for that section to be longer and more in-depth, but I certainly feel I have
enough knowledge now to set things up myself and start experimenting. And that is really the best way to learn anything. 

And I even got a nice little certificate from Udemy!

![Udemy Certificate](../assets/images/nginx/udemy-nginx-certificate.jpg){: w="700" h="400" }
_Figure 1: Certificate after the completion of the course_



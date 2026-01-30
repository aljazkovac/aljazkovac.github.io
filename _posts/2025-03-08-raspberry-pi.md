---
title: Adventures with Raspberry Pi - Running a Nginx Server
date: 2025-03-08 09:30:00 +0100
categories: [notes, raspberry pi]
tags: [devops, raspberry pi, nginx, linux] # TAG names should always be lowercase.
description: Home Lab - How to Set Up a Nginx Server On a Raspberry Pi
---

## What and Why

I bought a Raspberry Pi quite a few years ago - I am guessing it must have been around 2019 when I decided I wanted to retrain
and study Computer Science. I guess I thought it could be a cool little thing to experiment with. But then my studies took
over completely and my little Pi has been laying in his box for the past six years or so. I did bring it out when I first
bought it - I got one of those full kits that comes with a keyboard, a mouse, and a lovely little book with instructions and
project ideas - but I didn't do much more than fire it up once or twice just to see what it looked like.

Now, in 2025, I finally decided it would be cool to bring it out for a little home lab session. I recently took [a course
on how to set up a Nginx server from scratch](https://aljazkovac.github.io/posts/Udemy-Nginx-Fundamentals/), so I thought
it would be cool to do something super simple: run a basic Nginx server on my Pi which would simply redirect a visitor from
https://reddsmart.org to my [GitHub Pages](https://aljazkovac.github.io/) (which is where you, dear reader, find yourself now).

Simple enough, one would think, right? Stick around to find out!

## How

Let's break down the steps I was going to take:

1. Run a Nginx server on my Pi
2. Buy and set up the custom domain _reddsmart.org_
3. Make the Nginx server do a redirect from https://reddsmart.org to https://aljazkovac.github.io
4. Set up SSH from my MacBook to the Pi

### Set up the Pi and install Nginx from source

I first needed to fire up my dusty Pi (only a figure of speech, the Pi was actually in mint condition since it has been living
in a cozy box all its life). Once I got the Pi fired up I ran `sudo apt update` to update the packages. I immediately ran into
an error which I at first disregarded:

```
The repository http.//mirrordirector.raspbian.org/raspbian stretch Release does
no longer have a Release file. Updating from such a repository cant be done securely, and is therefore disabled by default.
See apt-secure manpage for repository creation and user configuration details.
```

I don't know why I disregarded the error, but that's what I did. I then ran `sudo apt upgrade` and then I followed [the
instructions from my notes on the Nginx course I took recently](https://aljazkovac.github.io/posts/Udemy-Nginx-Fundamentals/#building-nginx-from-source--adding-modules)
to build Nginx from source (I downloaded the latest stable version of Nginx, 1.26). I then ran into an issue installing the PCRE library:

```
"Err: 1 http://mirrordirector.raspbian.org/raspbian stretch/main armhf libpcre2-32-0 armhf 10.22-3 404 Not Found
E: Failed to fetch ..."
```

At which point I understood I would have to address the issue I got when I ran `sudo apt update`.

I followed [the instructions I found in Raspberry Pi's docs](https://www.raspberrypi.com/documentation/computers/os.html)
to first perform a firmware upgrade but I ran into problems after `sudo reboot`: the network interface and the wireless adapter were gone.
The firmware update must have broken the drivers!

After consulting with ChatGPT I ran `sudo apt install --reinstall raspberrypi-bootloader raspberrypi-kernel -y`: this should
check what version of firmware will work with my hardware and rebuild the kernel accordingly. After `sudo reboot` the issues
were thankfully solved (I was worried there for a second that I had managed to destroy my Pi with my first project).

Then I got curious what version of firmware and OS I am running. So I ran `cat /sys/firmware/devicetree/base/model` to see my hardware:
_Raspberry Pi 3 Model B Rev 1.2_

I also ran `cat /etc/os-release` for OS: _Raspbian GNU/Linux 9 (stretch)_

I installed the Raspberry Pi Imager on my Mac as recommended on the [RaspberryPi.com website](https://www.raspberrypi.com/software/).
I chose the recommended image from there: _Bookworm 64-bit with desktop_. I also added some custom settings, e.g., SSH with private keys.
But it turned out to be incredibly slow. So I checked with ChatGPT and got this recommendation:

```
__Best OS for Raspberry Pi 3 Model B (Rev 1.2)__

✅ Recommended: Raspberry Pi OS Bookworm (Debian 12)
•	Latest release (October 2023)
•	64-bit version available, but Pi 3 officially runs better on 32-bit.
•	Uses Kernel 6.1 for better performance and security.
•	Supports Pi 3 Model B, but it might be slightly slower than on a Pi 4/5.

🟡 Alternative: Raspberry Pi OS Bullseye (Debian 11)
•	Older (2021 release), but still stable and supported.
•	Works better on older Raspberry Pis than Bookworm.
•	Kernel 5.15 (older but stable).

❌ Avoid: Staying on Stretch (Debian 9)
•	End of Life (EOL)
•	No security updates.
•	Many modern packages and software will not work.
```

I decided to go for the 32-bit Bullseye. This turned out to work much better.

I then repeated the process of installing Nginx from source:

1. Installed the necessary libraries: the PCRE, the zlib and the libssl libraries with `sudo apt install libpcre2-8-0 libpcre2-dev zlib1g zlib1g-dev libssl-dev`
2. Ran configure with `./configure --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module`
3. Ran `sudo make` and `sudo make install`
4. Checked the Nginx version with `nginx -V`
5. Started Nginx with `nginx` and checked if it's running with `ps aux | grep nginx`

### Set up a custom domain

Well, to be able to have a redirect from https://reddsmart.org to https://aljazkovac.github.io I needed to actually own
the _reddsmart.org_ custom domain. So I went to [Namecheap](https://www.namecheap.com/) and purchased it. Then I added the following to it:

- _A record_ to it: _@ -> <Pi's public IP>_
- _CNAME record_: _www -> reddsmart.org_

An _A record_ (short for _Address Record_) maps a domain name to an IPv4 address. In other words, when someone browses the
Internet and goes to _reddsmart.org_, the DNS (Domain Name Service) resolves it to my Pi's public IP, and the browser connects
to that IP address.

The _CNAME record_ (short for _Canonical Name Record_) is simply an alias for another domain. It doesn't point to an IP, instead
it points to another custom domain. In my case, if someone goes to _www.reddsmart.org_ it points them to _reddsmart.org_ which
in turn points to my Pi's public IP.

| Record Type | Host | Value            | Why?                                                                     |
| ----------- | ---- | ---------------- | ------------------------------------------------------------------------ |
| A           | @    | <Pi’s Public IP> | Because the root domain (reddsmart.org) needs a direct IP address.       |
| CNAME       | www  | reddsmart.org    | Because _www.reddsmart.org_ should follow _reddsmart.org_ automatically. |

Now you might be wondering how I knew what my Pi's public IP is. It is essentially the same as my router's IP. You can check
that by logging into your router (different routers have different IPs to log into, you can Google for this information).

You can also run two commands on your Pi to get the public and the private IP of your Pi:

- `hostname -I` for the private IP
- `curl ifconfig.me` for the public IP

Once you have updated an A-record it is a good idea to check if the changes have been propagated (it might take a while,
even a few days). I ran `nslookup reddsmart.org` and got this:

```
Server:		192.168.50.1
Address:	192.168.50.1#53

Non-authoritative answer:
Name:	reddsmart.org
Address: 192.64.119.248
```

Ran `whois 192.63.119.248` and saw that it was Namecheap's server. Hm! I then asked Google's DNS server directly:
`nslookup reddsmart.org 8.8.8.8` and got my Pi's public IP!

The difference between the two commands is that the first one asks my default DNS resolver (my router or ISP's DNS server),
whereas the second command queries Google's public DNS server. Google's DNS server is usually quicker to update, whereas your
ISP's DNS server might have cached an older result and takes a longer time to update.

---

**TROUBLE ALERT!**

Here comes a little sidetrack (as usual). When I was first setting this up I didn't quite realize that the IP address
that I got by running `curl ifconfig.me` or logging into my router wasn't really a public IP. I only realized this after
setting up everything (continue to read below for the full setup), and scratching my head as to why the redirect didn't work.

After some digging around I realized that my router is behind a [CGNAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT), meaning
that my internet provider does network address translation on their side before my home router even sees the traffic.
In other words, my router is not truly on the public internet—it’s behind the ISP’s large-scale NAT device.

**CGNAT (Carrier-grade NAT)** is often used for mitigating the lack of IPv4 addresses. My router is assigned a private or
“non-routable” IP on its WAN interface (often in the 100.64.x.x range), rather than a unique public IP. Any inbound connection
from the internet (like someone trying to reach my web server) stops at the ISP’s NAT. I have no control over it.
Because of this, port forwarding at my home router didn't work for external traffic. The ISP’s NAT discards incoming traffic before it even reaches my router.

However, I got lucky (for once in my life), and was able to order a public IP from my ISP at no extra cost. I only needed to
reboot the router and a few minutes later I could see the new IP in my router website or with `curl ifconfig.me`.

---

### Set up an Nginx redirect

In order to be able to have my Pi redirect from my [custom domain](https://reddsmart.org) to my [GitHub Pages](https://aljazkovac.github.io,
I needed to enable port forwarding on my router so that when a client requests my custom domain Namecheap's DNS servers forward the request to my Raspberry Pi.

---

**TROUBLE ALERT!**

Kids, always remember to use a password manager if you don't have the brains to memorize a password you set up five years ago
and have never used since. Unfortunately, I am not as smart as those smart kids, and wasn't able to remember my password for the router.
I tried some of the standard admin passwords (Google is your friend) but none of them worked. So I was forced to do a reset, and then set up the Wifi networks again.
(This time I did save the password in my password manager). Then I upgraded the firmware on the router also!

---

Port forwarding is quite simple and straightforward to do. This is how I set it up.

---

**Port forwarding**

Namecheap domain has my router's (or Pi's) public IP (they are the same since the router hides everything behind its public IP).
Then I set up port forwarding from External port 80 -> Pi's private IP. I have also set the internal port to 80, which basically
means: _"If someone from the internet tries to access port 80 on my public IP, forward that request to port 80 on my Raspberry Pi."_

| Field               | HTTP Rule (Port 80)  | HTTPS Rule (Port 443) |
| ------------------- | -------------------- | --------------------- |
| Service Name        | HTTP to Raspberry Pi | HTTPS to Raspberry Pi |
| Protocol            | TCP                  | TCP                   |
| External Port       | 80                   | 443                   |
| Internal Port       | 80                   | 443                   |
| Internal IP Address | Pi’s private IP      | Pi's private IP       |
| Source IP           | (leave empty)        | (leave empty)         |

For HTTPS I followed these steps:

1. Set up port forwarding in the router (443)
2. Install certbot by following [instructions on their website](https://certbot.eff.org/instructions?ws=other&os=snap)
   - Needed to also install [snapd](https://snapcraft.io/docs/installing-snap-on-raspbian) (snaps are Linux self-contained app packages for desktop, cloud and IoT)

---

**TROUBLE ALERT!**

As I was following the setup instructions, I got an error: the domain _reddsmart.org_ and www.reddsmart.org could not be fetched!
I realized that my Pi's private IP had changed! But why? The reason is the router's **DHCP (Dynamic Host Configuration Protocol)**,
which automatically reassigns IP addresses to devices on the local network. I logged into my router and manually assigned an IP
address (basically a static IP address) to the Raspberry Pi. This should prevent the router from changing it. And voilà!
https://reddsmart.org and https://www.reddsmart.org are now up and running and both redirect to my GitHub Pages https://aljazkovac.github.io.

---

But it isn't only the router at home that can dynamically change an IP address. Your ISP's servers can (and will) do that as well!
So, my public IP (which I was lucky enough to be able to get since I was behind CGNAT at first) might change at some point. Obviously,
I could also ask my ISP provider for a static IP, but I simply couldn't be bothered, it might cost me something extra,
and I also thought it would be fun to learn how to set up dynamic DNS handling.

---

**Dynamic DNS handling**

To set up dynamic DNS handling, I went to Namecheap and turned on the Dynamic DNS feature. As I did that I was given a
password or token. I then used [ddclient](https://ddclient.net/) to update dynamic DNS entry in Namecheap. I installed
it with `sudo apt update` and then `sudo apt install ddclient` where I then had to input the username (name of my custom domain),
the password (the one that was generated in Namecheap before), and various other things (method to update the DNS record, etc.).

Then I got the following `ddclient.conf` file:

```
protocol=namecheap
use=web, web=https://api.ipify.org
login=reddsmart.org
password=<passwd>
reddsmart.org
```

But it didn't work out of the box, I was getting an error that a "record was not found". I investigated what gets sent to the server:

`https://dynamicdns.park-your-domain.com/update?host=reddsmart.org&domain=reddsmart.org&password=<passwd>&ip=<current_ip>`

(This was when I used dynamicdns werver instead of ipify), I could see that the host was incorrect. So my final config was this:

```
protocol=namecheap
use_web, web=https://api.ipify.org
login=reddsmart.org
password=<passwd>
@
```

I tested with `sudo service ddclient restart` and `sudo ddclient -force`, and got `SUCCESS: updating @: good: IP address
set to <ip-addr>`. Sweet!

---

### Set up SSH to the Pi

The last thing I wanted to do for this little project was to set up an SSH connection to my Raspberry Pi, so I could
access it from my MacBook.

First, run `sudo raspi-config`. This opens a GUI menu where you can navigate to Interface -> SSH -> Enable. Then it is a good
idea to reboot the Pi with `sudo reboot`.

Then, for extra security, use some other port instead of the standard 22. To be able to connect from outside your network, enable port forwarding
on your router (similar to what I did for `http` and `https`, see above).

Then follow these steps:

1. Generate SSH keys (Google is your friend)
2. Copy public key to Pi
3. Disable password authentication for extra security

Actually, I realized that my public key was already in my Pi. Why? Because I used the Pi Imager when setting up my Pi, and there
I chose the SSH keys to be enabled.

On my Pi in `/etc/ssh/sshd_config` I changed some SSH settings: port 22 to something else (I'm not telling you) and `PasswordAuthentication No`.
Then I restarted ssh with `sudo systemctl restart ssh`.

I also added an entry to my ssh config file (located in `/.ssh/config`) on my MacBook:

```bash
Host pi
HostName <pi-public-ip>
User aljazkovac
Port <secret-port>
IdentityFile ~/.ssh/id_rsa
```

And voilà! Now I can ssh into my Pi by running `ssh pi`.

## Summary

I loved this little project. Such a simple and easy thing I set out to do, but it sure threw a couple of challenges my way!
Here is a little overview of what I did and learned:

1. How to set up Pi with a fresh OS from scratch
2. How to set up a custom domain
3. The difference between a private IP and a public IP
4. The difference between having a shared public IP (if you are behind CGNAT) and your own public IP
5. How to set up port forwarding and assign a certain client a static IP in my router (the latter is needed due to the router's DHCP or Dynamic Host Configuration Protocol)
6. How to set up dynamic DNS handling
7. How to set up an SSH connection to my Pi

That is a full bag of tricks! With such a simple, little project. The benefit of doing projects (as opposed to taking courses, for example),
is that in projects your learn the stuff that you really need for your specific goals, instead of learning stuff in a very
generalized way. It is a very practical, straight-forward way of gaining new information and solving problems.

Update with sudo apt update
Had an error here which I at first disregarded: "The repository http.//mirrordirector.raspbian.org/raspbian stretch Release does no longer have a Release file. Updating from such a repository cant be done securely, 
and is therefore disabled by default. See apt-secure manpage for repository creation and user configuration details."
Upgrade with sudo apt upgrade
Followed instructions from here: https://aljazkovac.github.io/posts/Udemy-Nginx-Fundamentals/#building-nginx-from-source--adding-modules 
to build Nginx from source (I downloaded the latest stable version, 1.26)
Ran into an issue installing the PCRE library: 
"Err: 1 http://mirrordirector.raspbian.org/raspbian stretch/main armhf libpcre2-32-0 armhf 10.22-3 404 Not Found
E: Failed to fetch ..."
At which point I understood I would have to address the issue I got with sudo apt update.
Followed the instructions here to first perform a firmware upgrade: https://www.raspberrypi.com/documentation/computers/os.html
Ran into problems after sudo reboot => the network interface and the wireless adapter were gone. The firmware update must have
broken the drivers. 
After consulting with ChatGPT I ran sudo apt install --reinstall raspberrypi-bootloader raspberrypi-kernel -y => this should
check what version of firmware will work with my hardware and rebuild the kernel accordingly. After sudo reboot the issues were solved.
Got curious what version of firmware and OS I am running. Ran cat /sys/firmware/devicetree/base/model to see my hardware:
Raspberry Pi 3 Model B Rev 1.2
Ran cat /etc/os-release for OS: Raspbian GNU/Linux 9 (stretch)

I installed the Raspberry Pi Imager on my Mac as recommended on the RaspberryPi.com website: https://www.raspberrypi.com/software/.
I chose the recommended image from there: Bookworm 64-bit with desktop. I also added some custom settings, e.g., SSH with private keys. 
But it turned out to be incredibly slow. So I checked with ChatGPT and got this recommendation:

Best OS for Raspberry Pi 3 Model B (Rev 1.2)

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

I decided to go for the 32-bit Bullseye. This turned out to work much better.

I then repeated the process of installing Nginx from source:

1. 






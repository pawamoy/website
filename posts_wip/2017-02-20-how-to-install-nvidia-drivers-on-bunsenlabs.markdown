---
layout: post
title: "How to install NVidia drivers on BunsenLabs (Debian)"
date: 2017-02-20 16:18:01
tags: nvidia driver install bunsenlabs debian dual screen
comments: true
---

Today I encountered a problem with `pip` on my Ubuntu 16.04. It didn't want to
work anymore. It was saying `"The folder you are executing pip from can no longer be found."`.
Maybe I was still in a directory I previously deleted from another shell,
or maybe I had broken my system again. Anyway, the best solution I found
(read: the solution I wanted to use without considering other, simpler ones)
was to switch from Ubuntu to BunsenLabs, a Debian-based distro, to have a clean,
fresh installation.

Except the fact that I had to boot live on BunsenLabs to manually delete the
previous partitions so the installer could create an ext4 on my disk,
everything went fine. The next step was to enable dual-screen, and therefore
install Nvidia drivers. I eventually succeeded and it was a great adventure!<!--more-->

# Don't use the installer
My first attempt was to get the drivers from the Nvidia website.
I set my GPU's reference on the download page, download the .run file,
then `chmod +x` it and run it:

![me-no-run-under-x](/images/me-no-run-under-x.png)

Really? Going into a TTY with `CTRL-ALT-F1` to kill lightdm and retry does not work.
Lightdm is relaunched automatically everytime. There must be another way.

# Don't install the wrong version
There is an installable package, `nvidia-driver`, but you have to install it
from the good repositories. `nvidia-detect` can help you to determine this.

```
Detected NVIDIA GPUs:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:1402] (rev a1)
Your card is only supported by a newer driver that is available in jessie-backports.
See http://backports.debian.org for instructions how to use backports.
You may also find newer driver packages in experimental.
It is recommended to install the
    nvidia-driver/jessie-backports
package.
```

So, jessie-backports right. Add these lines in `/etc/apt/sources.list`:

```
deb http://httpredir.debian.org/debian jessie main non-free contrib
deb-src http://httpredir.debian.org/debian jessie main non-free contrib

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
```

Now, update and install these packages:
```bash
sudo apt update
sudo apt install -t jessie-backports nvidia-driver nvidia-xconfig
sudo apt install xserver-xorg xserver-xorg-core xserver-xorg-dev
sudo apt install -t jessie-backports xserver-xorg-video-nvidia
```

# Have faith
I personally encountered configuration errors from dpkg, for the
*xserver-xorg-video-nvidia* package. I wanted to configure it manually but dpkg
was getting stuck when running `sudo dpkg --configure xserver-xorg-video-nvidia`
(no CPU usage through htop). After some time, I saw that the postinst script
was getting locked by another program, *xserver-x*,
with `sudo lsof +D /var/lib/dpkg`.

To fix this, I had to run a loop, quickly killing instances of xserver-x:

```bash
while true; do
  sleep 0.1
  sudo pkill xserver-x
done
```

And in another shell:

```bash
sudo dpkg --configure xserver-xorg-video-nvidia
# or sudo dpkg --configure -a
```

Finally! I could then run `sudo nvidia-xconfig` to create a **valid**
*/etc/X11/xorg.conf* to be used by `sudo nvidia-settings`.

# Finish it
After multiple reboots, my second screen was getting used. But the resolution
was stuck to 640x480. To increase it, I had to open *nvidia-settings* (with sudo),
and set the second screen to "Xscreen 0", then restart lightdm with
`sudo service lightdm restart`.

![nvidia-settings](/images/nvidia-settings.png)

If it doesn't work, try to play a bit with *nvidia-settings* and restart *lightdm*
each time you change the settings, until you get something correct!

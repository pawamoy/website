---
layout: post
title: "How to install NVidia drivers on BunsenLabs (Debian 8)"
date: 2017-02-20 16:18:01
tags: nvidia driver install bunsenlabs debian dual screen jessie xorg
comments: true
---

First, to save your time and mind, install the Linux headers!

```
sudo apt install linux-headers-$(uname -r)
```

I spent two painful hours this afternoon trying to figure out why it wouldn't
work. It happens that I didn't install these headers!

Also install these requirements:

```
sudo apt install xserver-xorg xserver-xorg-core xserver-xorg-dev
```

Now, install the Nvidia Detect program. It will tell you where to get the driver
from:

```
sudo apt install nvidia-detect
```

Run it:

```shell-session
$ nvidia-detect
Detected NVIDIA GPUs:
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:1402] (rev a1)
Your card is only supported by a newer driver that is available in jessie-backports.
See http://backports.debian.org for instructions how to use backports.
You may also find newer driver packages in experimental.
It is recommended to install the
    nvidia-driver/jessie-backports
package.
```

So, in my case, I have to install the driver from Jessie backports.

**Beware!!** It might not be your case! Pay attention to what `nvidia-detect`
says, and do what it says :D!

So, for Jessie backports, you would install the driver like this:

```
sudo apt install -t jessie-backports nvidia-driver
```

<!--
If somehow the `-t jessie-backports` is not working, you might need to add
these lines to `/etc/apt/sources.list`:

```
deb http://httpredir.debian.org/debian jessie main non-free contrib
deb-src http://httpredir.debian.org/debian jessie main non-free contrib

deb http://security.debian.org/ jessie/updates main contrib non-free
deb-src http://security.debian.org/ jessie/updates main contrib non-free
```
-->

But the driver is not the only thing you need to install. I'm gonna install
the rest from Jessie backports as well, **adapt to your needs!**

```
sudo apt install -t jessie-backports nvidia-xconfig nvidia-settings xserver-xorg-video-nvidia
```

Reboot! At this point, it won't hurt your OS (it will actually help).

*Rebooting...*

Alright, you should now be able to run `nvidia-xconfig` without trouble:

```
sudo nvidia-xconfig
```

This command will create or update the file `/etc/X11/xorg.conf`.

You can now restart your X server and send me a not-positive comment below
if nothing work and your system is broken.

```
sudo systemctl restart lightdm.service
```

Login, then finalize with:

```
sudo nvidia-settings
```

Set your screen(s) resolutions and everything, save the configuration
into `/etc/X11/xorg.conf`, maybe reboot one last time, and you should be
good to go!

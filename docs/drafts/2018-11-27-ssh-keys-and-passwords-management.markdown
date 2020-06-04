---
layout: post
title: "Managing SSH keys for remote servers and services: a solution with tomb and pass"
date: 2018-11-27 16:00:00
tags: password manager local ssh key tomb pass server web service
excerpt_separator: <!--more-->
---

When you are given access to a lot of remote servers,
it's getting more and more complicated
to remember the passwords for every SSH key and server account.
In this post I will show you a method
to organize your SSH keys and passwords
in a secure manner.

<!--more-->

The goal of this method is to deal with:

1. [SSH keys](#ssh-keys)
2. [their associated passwords](#ssh-keys-passwords)
3. [remote server accounts login and passwords](#remote-server-accounts)

## SSH keys
I will distinguish the different usages we make of SSH keys.

1. *Personal machine to remote server SSH key:*
  let's call it a **P-R key**, like `Personal-to-Remote`.
  It's a key you use to connect to a server from your laptop
  or from your work machine.
2. *Remote server to remote server SSH key:* a **R-R key**, like `Remote-to-Remote`. It's a key present on a remote server,
  used to connect to another remote server.
3. *Remote server to remote server SSH key:* a **R-R key**, like `Remote-to-Remote`. It's a key present on a remote server,
  used to connect to another remote server.


[tomb]: https://github.com/dyne/Tomb
[pass]: https://www.passwordstore.org/

---
layout: post
title: "Managing SSH keys for remote servers and services: a solution with tomb and pass"
date: 2018-11-27 16:00:00
tags: password manager local ssh key tomb pass server web service
excerpt_separator: <!--more-->
---

During the last four years I worked in a lab and collaborated with
engineers and researchers from another team. We worked on a few different projects,
and each project had its own dedicated online server to run tests.

Before that I had access to only two machines. My computer and my laptop.
Then I had access to (and was responsible for) a bit more: computer at work,
production and staging servers for the main project, staging servers for three
other projects, and a GitLab instance.

My SSH keys started to pile up, and I started to forget passwords.

So I gave it a bit of thought and came up with an in-house solution
using tomb and pass.

<!--more-->

The goal was to deal with:

1. SSH keys, some of them shared across several physical-access machines,
   others being present only on one specific remote server
2. their associated passwords
3. remote server accounts login and passwords

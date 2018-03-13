---
layout: post
title: "Django application as an authentication / authorization server for Shiny"
date: 2018-03-18 12:24:01
tags: django shiny server nginx auth request security reverse proxy app
---

As you may know, [Shiny Server][] comes in two versions: open-source and
professional. The professional adds security and authentication features
like *password protected applications*, and *controlled access via SSL and LDAP,
Active Directory, Google OAuth, PAM, proxied authentication, or passwords*.

If you need these authentication features but don't want or can't spend
[$9,995 per year][] for the professional edition, then I got a solution for you!

In this post, I will show how to wrap one or several Shiny applications into
a Django application to add authentication and access control to your Shiny
apps. The shining star here will not be Django, as you could replace it by
any other web application you want, but the famous NginX reverse proxy,
accompanied by its devoted [auth-request][] module.

The code used in this post is also available as a [repository on GitHub][].
It contains a Docker configuration so you can try it easily.

[Shiny Server]: https://www.rstudio.com/products/shiny/shiny-server/
[$9,995 per year]: https://www.rstudio.com/pricing/#ShinyProPricing
[auth-request]: https://nginx.org/en/docs/http/ngx_http_auth_request_module.html
[repository on GitHub]: https://github.com/Pawamoy/docker-nginx-auth-request-django-shiny-example

#### On the menu
1. [Overview](#overview)
1. [The Shiny app](#the-shiny-app)
1. [The Django app](#the-django-app)
1. [Wrapping the Shiny app into a Django-powered page](#wrapping-the-shiny-app-into-a-django-powered-page)
1. [Proxying Shiny requests to the Shiny app](#proxying-shiny-requests-to-the-shiny-app)
1. [Adding an authentication step for every Shiny request](#adding-an-authentication-step-for-every-shiny-request)

## Overview
Let's look at some pictures to see what we want to accomplish. The first picture
shows our client-server architecture. The client can communicate with the server
on the port 80 or 443 (HTTP or HTTPs), but not on the ports 8000 or 8100, which
are used internally by Django and Shiny. This can be configured through the
firewall.

![client-server-architecture]({{ "/assets/client-server-architecture.png" | absolute_url }})

The second picture shows what happens when the client requests the URL
that the Shiny app is served on. As we wrap the Shiny app into a Django-powered
page, the request is proxied directly to Django by NginX. Django then gets the
initial Shiny page HTML contents with an internal HTTP Get request, and renders
it in a `iframe` (we will see the details later). It then returns this rendered
page to NginX, which returns it to the client.

![client-requests-shiny]({{ "/assets/client-requests-shiny.png" | absolute_url }})

The third picture shows each subsequent requests from the client to the server
through a WebSocket, and how NginX is asking authorization to Django. When NginX
receives the reques, it sends a sub-request to Django, asking for permission
to proxy the request to Shiny and return the response to the client. If Django
says yes (HTTP 200), NginX proxies the request to Shiny. If Django says no
(HTTP 403 or any other error code), NginX rejects the request by returning
HTTP 403 as a response to the client.

![client-shiny-subrequests]({{ "/assets/client-shiny-subrequests.png" | absolute_url }})

OK, let's try it! To begin, create a directory that we will use for this
tutorial:

```
mkdir django-shiny
cd django-shiny
```

## The Shiny app
Let's get a Shiny app example from [RStudio's gallery][]: the [Movie Explorer][].
The code is available on GitHub in [this repository][].

[RStudio's gallery]: https://shiny.rstudio.com/gallery/
[Movie Explorer]: https://shiny.rstudio.com/gallery/movie-explorer.html
[this repository]: https://github.com/rstudio/shiny-examples/tree/master/051-movie-explorer

Clone it in a sub-directory called `shinyapp`:

```
git clone --depth=1 https://github.com/rstudio/shiny-examples
mv shiny-examples/051-movie-explorer shinyapp
rm -rf shiny-examples
```

We also need to install its dependencies. If you don't already have R installed,
you can install it with `sudo apt-get install r-base`.

Run this command to install the dependencies:

```
sudo R -e "install.packages(c('shiny', 'ggvis', 'dplyr', 'RSQLite'))"
```

To run the Shiny application on port 8100, use the following command:

```
sudo R -e "shiny::runApp(appDir='shinyapp', port=8100)"
```

Try to go to http://localhost:8100 to see if the app is running.

## The Django app
We will create a new Django project called `djangoapp`. If you don't already have
Django installed on your system, install it in a virtualenv with
`pip install Django`, or system-wide with `sudo pip install Django`.

To create the project, run the following command:

```
django-admin startproject djangoapp
```

## Wrapping the Shiny app into a Django-powered page

## Proxying Shiny requests to the Shiny app

## Adding an authentication step for every Shiny request

---
template: post.html
title: "Unify Python logging for a Gunicorn/Uvicorn/FastAPI application"
date: 2020-06-02
authors:
  - Timothée Mazzucotelli
tags: gunicorn uvicorn fastapi loguru logs logging unified unify httpx kibana
image: /assets/gunicorn_logs.png
disqus: pawamoy
---

I recently started playing with [FastAPI](https://fastapi.tiangolo.com/)
and [HTTPX](https://www.python-httpx.org/),
and I am deploying my app with [Gunicorn](https://gunicorn.org/) and
[Uvicorn](https://www.uvicorn.org/) workers.

But when serving, the logs from each component looks quite different
from the others. I want them to all look the same, so I can easily read them
or exploit them in something like [Kibana](https://www.elastic.co/kibana).

After a lot of hours trying to understand
how [Python logging](https://docs.python.org/3/library/logging.html) works,
and how to override libraries' logging settings,
here is what I have...

<!--more-->

A single `run.py` file!
I didn't want to split logging configuration, Gunicorn configuration,
and the rest of the code into multiple files, as it was harder to wrap
my head around it.

Everything is contained in this single file:

```python
import os
import logging
import sys

from gunicorn.app.base import BaseApplication
from gunicorn.glogging import Logger
from loguru import logger

from my_app.app import app


LOG_LEVEL = logging.getLevelName(os.environ.get("LOG_LEVEL", "DEBUG"))
JSON_LOGS = True if os.environ.get("JSON_LOGS", "0") == "1" else False
WORKERS = int(os.environ.get("GUNICORN_WORKERS", "5"))


class InterceptHandler(logging.Handler):
    def emit(self, record):
        # Get corresponding Loguru level if it exists
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find caller from where originated the logged message
        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


class StubbedGunicornLogger(Logger):
    def setup(self, cfg):
        handler = logging.NullHandler()
        self.error_logger = logging.getLogger("gunicorn.error")
        self.error_logger.addHandler(handler)
        self.access_logger = logging.getLogger("gunicorn.access")
        self.access_logger.addHandler(handler)
        self.error_log.setLevel(LOG_LEVEL)
        self.access_log.setLevel(LOG_LEVEL)


class StandaloneApplication(BaseApplication):
    """Our Gunicorn application."""

    def __init__(self, app, options=None):
        self.options = options or {}
        self.application = app
        super().__init__()

    def load_config(self):
        config = {
            key: value for key, value in self.options.items()
            if key in self.cfg.settings and value is not None
        }
        for key, value in config.items():
            self.cfg.set(key.lower(), value)

    def load(self):
        return self.application


if __name__ == '__main__':
    intercept_handler = InterceptHandler()
    # logging.basicConfig(handlers=[intercept_handler], level=LOG_LEVEL)
    # logging.root.handlers = [intercept_handler]
    logging.root.setLevel(LOG_LEVEL)

    seen = set()
    for name in [
        *logging.root.manager.loggerDict.keys(),
        "gunicorn",
        "gunicorn.access",
        "gunicorn.error",
        "uvicorn",
        "uvicorn.access",
        "uvicorn.error",
    ]:
        if name not in seen:
            seen.add(name.split(".")[0])
            logging.getLogger(name).handlers = [intercept_handler]

    logger.configure(handlers=[{"sink": sys.stdout, "serialize": JSON_LOGS}])

    options = {
        "bind": "0.0.0.0",
        "workers": WORKERS,
        "accesslog": "-",
        "errorlog": "-",
        "worker_class": "uvicorn.workers.UvicornWorker",
        "logger_class": StubbedGunicornLogger
    }

    StandaloneApplication(app, options).run()
```

If you are in a hurry, copy-paste it, change the Gunicorn options at the end,
and try it!

If you're not, I will explain each part below.

---

```python
import os
import logging
import sys

from gunicorn.app.base import BaseApplication
from gunicorn.glogging import Logger
from loguru import logger
```

This part is easy, we simply import the things we need.
The Gunicorn `BaseApplication` so we can run Gunicorn directly from this script,
and its `Logger` that we will override a bit.
We are using [Loguru](https://github.com/Delgan/loguru) later in the code,
to have a pretty log format, or to serialize them.

---

```python
from my_app.app import app
```

In my project, I have a `my_app` package with an `app` module.
My FastAPI application is declared in this module, something like
`app = FastAPI()`.

---

```python
LOG_LEVEL = logging.getLevelName(os.environ.get("LOG_LEVEL", "DEBUG"))
JSON_LOGS = True if os.environ.get("JSON_LOGS", "0") == "1" else False
WORKERS = int(os.environ.get("GUNICORN_WORKERS", "5"))
```

We setup some values from environment variables, useful for development vs.
production setups. `JSON_LOGS` tells if we should serialize the logs to JSON,
and `WORKERS` tells how many workers we want to have.

---

```python
class InterceptHandler(logging.Handler):
    def emit(self, record):
        # Get corresponding Loguru level if it exists
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        # Find caller from where originated the logged message
        frame, depth = logging.currentframe(), 2
        while frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())
```

This code is copy-pasted from Loguru's documentation!
This handler will be used to intercept the logs emitted by libraries
and re-emit them through Loguru.

---

```python
class StubbedGunicornLogger(Logger):
    def setup(self, cfg):
        handler = logging.NullHandler()
        self.error_logger = logging.getLogger("gunicorn.error")
        self.error_logger.addHandler(handler)
        self.access_logger = logging.getLogger("gunicorn.access")
        self.access_logger.addHandler(handler)
        self.error_log.setLevel(LOG_LEVEL)
        self.access_log.setLevel(LOG_LEVEL)
```

This code was copied from this
[GitHub comment](https://github.com/benoitc/gunicorn/issues/1572#issuecomment-430747811)
by [@dcosson](https://github.com/dcosson). Thanks!
It will allow us to override Gunicorn's own logging configuration
so its logs can be formatted like the rest.

I'm not sure about the last two lines, as removing them doesn't change anything.
There are still mysteries about Python logging that I couldn't resolve...

---

```python
class StandaloneApplication(BaseApplication):
    """Our Gunicorn application."""

    def __init__(self, app, options=None):
        self.options = options or {}
        self.application = app
        super().__init__()

    def load_config(self):
        config = {
            key: value for key, value in self.options.items()
            if key in self.cfg.settings and value is not None
        }
        for key, value in config.items():
            self.cfg.set(key.lower(), value)

    def load(self):
        return self.application
```

This code is taken from
[Gunicorn's documentation](https://docs.gunicorn.org/en/stable/custom.html).
We declare a simple Gunicorn application that we will be able to run.
It accepts all Gunicorn's options.

---

```python
if __name__ == '__main__':
    intercept_handler = InterceptHandler()
    # logging.basicConfig(handlers=[intercept_handler], level=LOG_LEVEL)
    # logging.root.handlers = [intercept_handler]
    logging.root.setLevel(LOG_LEVEL)
```

We simply instantiate our interception handler,
and set the log level on the root logger.

Once again, I fail to understand how this works exactly, as the two commented
lines have no impact on the result. I did a lot of trial and error and ended
up with something working, but I cannot entirely explain why.
The idea here was to set the handler on the root logger so it intercepts
everything, but it was not enough (logs were not all intercepted).

---

```python
    seen = set()
    for name in [
        *logging.root.manager.loggerDict.keys(),
        "gunicorn",
        "gunicorn.access",
        "gunicorn.error",
        "uvicorn",
        "uvicorn.access",
        "uvicorn.error",
    ]:
        if name not in seen:
            seen.add(name.split(".")[0])
            logging.getLogger(name).handlers = [intercept_handler]
```

Here we iterate on all the possible loggers declared by libraries
to override their handlers with our interception handler.
This is where we actually configure every logger to behave the same.

For a reason that I fail to understand, Gunicorn and Uvicorn do not appear
in the root logger manager, so we have to hardcode them in the list.

We also use a set to avoid setting the interception handler on the parent
of a logger that is already configured, because otherwise logs would be
emitted twice or more. I'm not sure this code can handle levels of
nested loggers deeper than two.

---

```python
    logger.configure(handlers=[{"sink": sys.stdout, "serialize": JSON_LOGS}])
```

Here we configure Loguru to write on the standard output,
and to serialize logs if needed.

At some point I was also using `activation=[("", True)]`
([see Loguru's docs](https://loguru.readthedocs.io/en/stable/api/logger.html#loguru._logger.Logger.configure)),
but it seems it's not required either.

---

```python
    options = {
        "bind": "0.0.0.0",
        "workers": WORKERS,
        "accesslog": "-",
        "errorlog": "-",
        "worker_class": "uvicorn.workers.UvicornWorker",
        "logger_class": StubbedGunicornLogger
    }

    StandaloneApplication(app, options).run()
```

Finally, we set our Gunicorn options, wiring things up,
and run our application!

---

Well, I'm not really proud of this code, but it works!

![logs](/assets/gunicorn_logs.png)

![logs_json](/assets/gunicorn_logs_json.png)

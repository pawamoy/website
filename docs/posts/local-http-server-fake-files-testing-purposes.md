---
template: post.html
title: "Local HTTP server sending fake files for testing purposes"
date: 2020-11-15
authors:
  - Timothée Mazzucotelli
tags: localhost local http server fake virtual files testing python
image:
  src: /assets/local-http-server.png
  class: crop-excerpt
---

I have developed a Python client/library
for [`aria2`](https://aria2.github.io/)
called [`aria2p`](https://github.com/pawamoy/aria2p).

To test my code, I spawn `aria2c` processes
to interact with them and see if everything works correctly.
I know I could mock the calls, but I feel like actually
testing the interaction between my client and `aria2c`
is a better way to ensure my code does its best.

Until recently the test suite fed actual downloads to `aria2c`
(like Linux distributions ISOs, metalinks, magnets, or torrents),
but of course the inevitable happened: some URLs broke.

So I decided to go full local.
This post describes my attempt at spawning local HTTP servers
to serve fake/virtual files efficiently,
files that are then fed to `aria2c`.

<!--more-->

## The basics: `http.server`

As you may already know, Python's standard library provides
a ready-to-go HTTP server that can serve files from a folder.
It lives in the `http.server` module, and you can run it in
a single command:

```bash
python -m http.server
```

This will serve the contents of your current working directory
on `http://0.0.0.0:8000`.

I was already using it in some tests when I needed to feed
very small files to `aria2c`. I was serving `aria2p`'s code folder
to use the LICENSE file: 759 bytes.

So, the simplest solution that immediately came to mind was:
dump text into files with predefined sizes,
like 1B, 100B, 1KiB, 100KiB, 1MiB, 10MiB, 100MiB, etc.
And do this each time you run the test suite,
in a temporary directory that you will serve using
Python's built-in HTTP server.

But that sounds a bit wasteful, right? Wasting disk cycles on
expensive SSDs is not really attractive.
So it led me to the next solution.

### Serving files from memory

Instead of creating files on the disk,
why not just create them in memory?

So I looked at the sources in `http.server`,
particularly how `SimpleHTTPRequestHandler`
sends the files contents to the client,
and eventually ended up with this code:

```python
# http_server.py
import shutil
import socketserver
import sys
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler
from io import BytesIO


class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        size = self.path.lstrip("/")
        self.send_response(HTTPStatus.OK)
        self.send_header("Content-type", "application/octet-stream")
        self.send_header("Content-Length", size)
        self.end_headers()
        shutil.copyfileobj(BytesIO(b"1" * int(size)), self.wfile)


def run_http_server(port):
    with socketserver.TCPServer(("", port), RequestHandler) as httpd:
        try:
            httpd.serve_forever()
        finally:
            httpd.server_close()


if __name__ == "__main__":
    print("Running HTTP server on port 8000")
    run_http_server(8000)
```

This snippet can be run directly with `python http_server.py`.
The `run_http_server` can also be imported somewhere else.

This server accepts GET requests on the path `/{size}`,
which allows us to choose the size of the file we want to download.
For example: `GET http://localhost:8000/1024` for 1Kib.
The files are then only composed of ones.

There is a problem however:
this server will not support a heavy load
(lots of tests running in parallel),
because it can handle only one request at a time.

### Multi-threading

Thankfully, `socketserver` also provides a `ThreadingTCPServer`
we can use. It's as simple as:

```python
def run_http_server(port=PORT):
    with socketserver.ThreadingTCPServer(("", port), RequestHandler) as httpd:
        try:
            httpd.serve_forever()
        finally:
            httpd.server_close()
```

### Reusable address

Even with the `finally` clause,
I noticed that the address kept being "in use"
for up to a minute sometimes, after the server was killed.

This can be alleviated with the `allow_reuse_address` attribute
of the socket server:

```python
class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True


def run_http_server(port=PORT):
    with Server(("", port), RequestHandler) as httpd:
        try:
            httpd.serve_forever()
        finally:
            httpd.server_close()
```

### Still not enough

But even with all this, many tests were still failing,
and the standard error captured by `pytest` showed
a lot of `BrokenPipe` errors coming from the server.

I think it's because this server is way too simple,
and handles only GET requests. Maybe `aria2c` is using
HEAD as well? What about its "pausing" feature,
allowing to pause downloads and resume them?
Will the server handle it correctly?

So, instead of digging more into this,
I decided to try running a *proper* server.

## With FastAPI

I've been using [FastAPI](https://fastapi.tiangolo.com/) recently,
so I gave it a try. A very small amount of code was needed:

```python
# http_server.py
from io import BytesIO

from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()


@app.get("/{size}")
async def get(size):
    return StreamingResponse(BytesIO(b"1" * size), media_type="application/octet-stream")
```

I went with a `StreamingResponse`
because the `FileResponse` only accepts paths to actual files.

To run the server, I run this command: `uvicorn http_server:app`.
And it seems to work great!
All the tests that were previously failing now pass.

### Trying to be clever

I'm still not really satisfied with this solution.
It feels wasteful to allocate memory for each handled request.
I tried storing the `BytesIO` object into a dictionary,
with sizes as keys, but I guess their buffer get consumed
when sending the response, so this doesn't work
on subsequent requests using the same size.
Instead of storing the `BytesIO` objects,
we can store the strings themselves!

```python
from io import BytesIO

from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()
allocated = {}

@app.get("/{size}")
async def get(size: int):
    if size not in allocated:
        allocated[size] = b"1" * size
    return StreamingResponse(BytesIO(allocated[size]), media_type="application/octet-stream")
```

But even then, why allocating memory at all?
Couldn't we have a really "virtual" file,
some kind of generator that generates chunks of data,
sent as a streaming response, and that stops at the desired size?

Well the `StreamingResponse`
[accepts async generators](https://fastapi.tiangolo.com/advanced/custom-response/#streamingresponse),
so here's what I tried:

```python
async def virtual_file(size, chunks=4096):
    while size > 0:
        yield b"1" * min(size, chunks)
        size -= chunks


@app.get("/{size}")
async def get(size: int):
    return StreamingResponse(virtual_file(size), media_type="application/octet-stream")
```

It seems to work, and the memory footprint is much, much lower,
but I get a lot of `socket.send() raised exception.` messages from FastAPI,
and a test occasionally fails. Anyway, I think it's good enough.

### Additional niceties

To make it easier to choose a medium-to-big file size,
we can accept a unit suffix:

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse

app = FastAPI()


def translate_size(size):
    try:
        return int(size)
    except ValueError:
        pass
    size = size.lower()
    if size.endswith("k"):
        multiplier = 2 ** 10
    elif size.endswith("m"):
        multiplier = 2 ** 20
    elif size.endswith("g"):
        multiplier = 2 ** 30
    else:
        raise ValueError("size unit not supported:", size)
    return int(size.rstrip("kmg")) * multiplier


async def virtual_file(size, chunks=4096):
    while size > 0:
        yield b"1" * min(size, chunks)
        size -= chunks


@app.get("/{size}")
async def get(size: str):
    return StreamingResponse(
        virtual_file(translate_size(size)),
        media_type="application/octet-stream",
    )
```

Note that the route `size` argument is not an integer anymore but a string.
It allows us to send GET requests like `/4k` or `/100m`,
values that are then translated to bytes.

## Pytest fixture

Since I run tests in parallel thanks to the `pytest-xdist` plugin,
I must make sure I run only one instance of the HTTP server.

We can accomplish this by checking the worker ID
(to handle both parallel and non-parallel cases)
and by using a lock.

The worker ID will be `master` for non-parallel runs.
It can be obtained with the `worker_id` fixture.

For the lock, I chose to use `mkdir` as it's an atomic operation.
If the directory already exists, the operation fails
(someone else already got the lock).

Once the server is running, we must make sure it's ready,
so we send GET requests until it responds.

We put all this in a function and declare it a "fixture"
with "session" scope and "automatic use":

```python
# tests/conftest.py
import subprocess
import sys
import time

import pytest
import requests  # or httpx


def spawn_and_wait_server(port=8000):
    process = subprocess.Popen([
        sys.executable,
        "-m",
        "uvicorn",
        "tests.http_server:app",
        "--port",
        str(port),
    ])
    while True:
        try:
            requests.get(f"http://localhost:{port}/1")
        except:
            time.sleep(0.1)
        else:
            break
    return process


# credits to pytest-xdist's README
@pytest.fixture(scope="session", autouse=True)
def http_server(tmp_path_factory, worker_id):
    if worker_id == "master":
        # single worker: just run the HTTP server
        process = spawn_and_wait_server()
        yield process
        process.kill()
        process.wait()
        return

    # get the temp directory shared by all workers
    root_tmp_dir = tmp_path_factory.getbasetemp().parent

    # try to get a lock
    lock = root_tmp_dir / "lock"
    try:
        lock.mkdir(exist_ok=False)
    except FileExistsError:
        yield  # failed, don't run the HTTP server
        return

    # got the lock, run the HTTP server
    process = spawn_and_wait_server()
    yield process
    process.kill()
    process.wait()
```

With this, each time you run your test suite,
exactly one instance of the HTTP server will run.

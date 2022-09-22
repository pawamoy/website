---
template: post.html
title: "Testing a FastAPI application using Ormar models and Alembic migrations"
date: 2022-08-28
authors:
  - Timothée Mazzucotelli
tags: python alembic database migration fastapi ormar testing pytest factory-boy
image:
  src: /assets/alembic_post.png
  add_to_post: yes
  class: crop-excerpt
---

In the [previous post](../add-alembic-migrations-to-existing-fastapi-ormar-project/)
I showed how to add Alembic migrations to an existing FastAPI + Ormar project.
In this post we will see how to write unit tests for such applications.

<!--more-->

We start with the following project layout:

```tree
./
    src/
        project/
            __init__.py
            app.py
            models.py
    tests/
```

## Database models

Let say we have three models: Artist, Album and Track.
To keep things simple, we just add a `name` field on each. 

```python title="src/project/models.py"
"""Database models."""

import os
import databases
import ormar
import sqlalchemy

SQLITE_DB = os.getenv("SQLITE_DB", "sqlite:///db.sqlite")
DB_PATH = SQLITE_DB.replace("sqlite:///", "")


class BaseMeta(ormar.ModelMeta):
    database = databases.Database(SQLITE_DB)
    metadata = sqlalchemy.MetaData()


class Artist(ormar.Model):
    class Meta(BaseMeta): ...

    id: int = ormar.Integer(primary_key=True)
    name: str = ormar.String(max_length=100)


class Album(ormar.Model):
    class Meta(BaseMeta): ...

    id: int = ormar.Integer(primary_key=True)
    name: str = ormar.String(max_length=100)
    artist: Artist = ormar.ForeignKey(Artist, nullable=False)


class Track(ormar.Model):
    class Meta(BaseMeta): ...

    id: int = ormar.Integer(primary_key=True)
    name: str = ormar.String(max_length=100)
    album: Album = ormar.ForeignKey(Album, nullable=False)
```

## Database and migrations helpers

Now lets create helpers to easily (re)create, update (migrate) or stamp the database.
We will put everything that is related to migrations in a migrations subpackage:

```tree hl_lines="4 5"
./
    src/
        project/
            migrations/
                __init__.py
            __init__.py
            app.py
            models.py
    tests/
```

We will define helpers in the `__init__` module.
[Loguru](https://pypi.org/project/loguru/) will be used to log things,
but that's optional and you can remove logging lines or use another logging framework.

```python title="src/project/migrations/__init__.py"
"""Database migrations modules."""

from functools import wraps
from pathlib import Path

import sqlalchemy
from alembic import command as alembic
from alembic.config import Config
from loguru import logger

from project.models import DB_PATH, SQLITE_DB, BaseMeta


def get_alembic_config(db_url: str = SQLITE_DB) -> Config:
    alembic_cfg = Config()
    alembic_cfg.set_main_option("script_location", "project:migrations")
    alembic_cfg.set_main_option("sqlalchemy.url", str(db_url))
    return alembic_cfg


def upgrade_database(revision: str = "head", db_url: str = SQLITE_DB) -> None:
    alembic_cfg = get_alembic_config(db_url)
    alembic.upgrade(alembic_cfg, revision)


def stamp_database(revision: str = "head", db_url: str = SQLITE_DB) -> None:
    alembic_cfg = get_alembic_config(db_url)
    alembic.stamp(alembic_cfg, revision)


def create_database(db_url: str = SQLITE_DB) -> None:
    engine = sqlalchemy.create_engine(db_url, connect_args={"timeout": 30})
    BaseMeta.metadata.create_all(engine)


def db_lock(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        lock = Path(DB_PATH).parent / ".dblock"
        try:
            lock.mkdir(parents=True, exist_ok=False)
        except FileExistsError:
            logger.debug("Migrations are already being applied")
            return
        logger.debug("Applying migrations")
        try:
            func(*args, **kwargs)
        finally:
            lock.rmdir()

    return wrapper


@db_lock
def apply_migrations(db_url: str = SQLITE_DB) -> None:
    if Path(DB_PATH).exists():
        upgrade_database(db_url=db_url)
    else:
        create_database(db_url=db_url)
        stamp_database(db_url=db_url)
```

Note how each function accepts a `db_url` parameter:
this will be very useful to support different environments,
such as development, production and testing.

We still need the Alembic configuration module:

```tree hl_lines="6"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
```

```python title="src/project/migrations/env.py"
import os

from alembic import context
from sqlalchemy import engine_from_config, pool

from project.models import BaseMeta

config = context.config
target_metadata = BaseMeta.metadata


def get_url():
    # allow configuring the database URL / filepath using an env var, useful for production
    return os.getenv("SQLITE_DB", config.get_main_option("sqlalchemy.url"))


def run_migrations_offline():
    url = get_url()
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        render_as_batch=True,  # needed for sqlite backend
    )
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online():
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = get_url()
    connectable = engine_from_config(
        configuration,
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            render_as_batch=True,  # needed for sqlite backend
        )
        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

## Automatic database creation/update

Now, lets configure our FastAPI app so that the database is automatically
created or updated every time we run our app (using [uvicorn](https://www.uvicorn.org/) for example):

```tree hl_lines="8"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
```

```python title="src/project/app.py"
"""FastAPI application."""

from fastapi import FastAPI

from project.migrations import apply_migrations
from project.models import BaseMeta

app = FastAPI()


@app.on_event("startup")
async def startup() -> None:
    apply_migrations(str(BaseMeta.database.url))
    if not BaseMeta.database.is_connected:
        await BaseMeta.database.connect()


@app.on_event("shutdown")
async def shutdown() -> None:
    if BaseMeta.database.is_connected:
        await BaseMeta.database.disconnect()
```

Creating or updating the database in the `startup` event allows several things:

- in a development environment, developers can simply run the server,
    and the database is automatically created. They don't have to worry
    about running a database creation command. Similarly, they can
    simply delete the `db.sqlite` file and restart the server to empty
    their local database, or copy a pre-populated SQlite file to reset
    their local database to a particular state.
- in a production environment, in which you have no control (no possibility
    to run custom shell commands), migrations are applied automatically
    upon starting the server. If there are no (new) migrations,
    the startup event is a no-op: nothing happens and the server starts
    normally, with the current database untouched.
    Note that we ensure only one instance of the server will apply the migrations,
    as to prevent multiple parallel/concurrent accesses to a potentially
    shared storage space (for example multiple pods accessing the same persistent volume
    on a Kubernetes infrastructure).
- in a testing environment, tests will be able to provide a unique database URL
    (a local file path) so that they each have their own temporary database.
    It means tests will be able to run in parallel,
    for example using [pytest-xdist](https://pypi.org/project/pytest-xdist/).

## Pytest fixture

Now lets create a Pytest fixture that will allow each test
to get access to its own unique, temporary database:

```tree hl_lines="12"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
        __init__.py
        conftest.py
```

```python title="tests/conftest.py"
"""Configuration for the pytest test suite."""

import os
from pathlib import Path

import databases
import pytest
from asgi_lifespan import LifespanManager
from httpx import AsyncClient

from project.app import app
from project.migrations import create_database, stamp_database
from project.models import BaseMeta


@pytest.fixture()
async def async_client(tmp_path: Path, monkeypatch):
    """
    Provide an HTTPX asynchronous HTTP client, bound to an app using a unique, temporary database.

    Arguments:
        tmp_path: Pytest fixture: points to a temporary directory.
        monkeypatch: Pytest fixture: allows to monkeypatch objects.

    Yields:
        An instance of AsyncClient using the FastAPI ASGI application.
    """
    db_url = f"sqlite:///{tmp_path}/db.sqlite"
    create_database(db_url=db_url)
    stamp_database(db_url=db_url)
    database = databases.Database(db_url)
    monkeypatch.setattr(BaseMeta, "database", database)

    lifespan = LifespanManager(app)
    httpx_client = AsyncClient(app=app, base_url="http://testserver")

    async with httpx_client as client, lifespan:
        yield client
```

You'll notice that we use [asgi-lifespan](https://pypi.org/project/asgi-lifespan/).
Without it, the startup and shutdown ASGI events would not be triggered.

In the startup event, we apply migrations using the URL in `BaseMeta.database.url`.
This allows us to monkeypatch the `database` attribute in our fixture to change
the database URL for each test.

## Model instances factories

In our tests, we'll want to insert some rows in the database to test our API.
Doing so manually can be cumbersome, as you have to define each instance
one after the other, linking them together.
To ease the process, we use [factory-boy](https://pypi.org/project/factory-boy/),
with which we'll be able to define model factories. With these factories,
it will be very easy to create instances of models in our tests.

```tree hl_lines="13"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
        __init__.py
        conftest.py
        factories.py
```

```python title="tests/factories.py"
"""Factory classes to build models instances easily."""

import factory

from project import models


class ArtistFactory(factory.Factory):
    class Meta:
        model = models.Artist

    id = 1
    name = "artist name"


class AlbumFactory(factory.Factory):
    class Meta:
        model = models.Album

    id = 1
    name = "album name"
    artist = factory.SubFactory(ArtistFactory)


class TrackFactory(factory.Factory):
    class Meta:
        model = models.Track

    id = 1
    name = "track name"
    album = factory.SubFactory(AlbumFactory)
```

With these factories you can now create an artist, album and track,
all linked together, using a single line of code:

```python
from tests import factories

track = factories.TrackFactory()
```

You can change arbitrary attributes when creating instances:

```python
track = factories.TrackFactory(
    name="other track name",
    album__name="other album name",
    album__artist__name="other artist name",
)
```

Refer to [factory-boy's documentation](https://factoryboy.readthedocs.io/en/stable/) for more examples.
You could also use [Faker](https://pypi.org/project/Faker/)
to set more relevant default values to your instances attributes.

## Populating the database with data

Creating instances is nice, but they are not magically inserted in the database for us.
Since instances are Ormar model instances, we could technically use the `save()` method
on the instances we create to save them in the database, however I did not try that
and cannot guarantee it will work for multiple instances linked together at once.

Instead, and only if you have added
[CRUD operations](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete)
to your API, you can call your API routes to create the instances in the database.

For this, I chose to create a new helper module,
but that's probably not the best design you can come up with,
so feel free to discard the next suggestions and follow your instincts.

```tree hl_lines="14"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
        __init__.py
        conftest.py
        factories.py
        helpers.py
```

```python title="tests/helpers.py"
"""Helpers for tests."""

from project.models import Artist, Album, Track
from tests import factories


async def create_artist(client) -> Artist:
    artist = factories.ArtistFactory()

    payload = artist.dict()
    response = await client.post("/artists", json=payload)
    response.raise_for_status()

    return artist


async def create_album(client) -> Album:
    album = factories.AlbumFactory()

    # create artist first
    payload = album.artist.dict()
    response = await client.post("/artists", json=payload)
    response.raise_for_status()

    # then create album
    payload = album.dict()
    response = await client.post("/albums", json=payload)
    response.raise_for_status()

    return album


async def create_track(client) -> Track:
    track = factories.TrackFactory()

    # create artist first
    payload = track.album.artist.dict()
    response = await client.post("/artists", json=payload)
    response.raise_for_status()

    # then create album
    payload = track.album.dict()
    response = await client.post("/albums", json=payload)
    response.raise_for_status()

    # finally create track
    payload = track.dict()
    response = await client.post("/tracks", json=payload)
    response.raise_for_status()

    return track
```

## Example tests

Now you can easily populate the database in tests,
and call other API routes to test their behavior and output.

```.tree hl_lines="15"
./
    src/
        project/
            migrations/
                __init__.py
                env.py
            __init__.py
            app.py
            models.py
    tests/
        __init__.py
        conftest.py
        factories.py
        helpers.py
        test_tracks.py
```

```python title="tests/test_tracks.py"
"""Tests for the `tracks` routes."""

import pytest

from tests import factories, helpers


@pytest.mark.asyncio()
async def test_tracks_create(async_client):
    track = await helpers.create_track(async_client)
    # ...then test other API routes
```

Note how we use the previously defined fixture `async_client`.
Just adding that fixture as a parameter to our test function
ensures we have a temporary, dedicated database for this test.

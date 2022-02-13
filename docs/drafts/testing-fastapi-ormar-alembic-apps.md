---
template: post.html
title: "How to add Alembic migrations to an existing FastAPI + Ormar project"
date: 2022-02-13
authors:
  - Timothée Mazzucotelli
tags: python alembic database migration fastapi ormar
image:
  src: /assets/alembic_post.png
  add_to_post: yes
---

In the previous post I showed how to add Alembic migrations to an existing FastAPI + Ormar project.
In this post we will see how to write unit tests for such applications.

<!--more-->

Tree

Fixtures

```python title="tests/conftest.py"
"""Configuration for the pytest test suite."""

import databases
import pytest
from httpx import AsyncClient
from asgi_lifespan import LifespanManager

from package.app import app
from package.models import BaseMeta
from package.migrations import create_database, stamp_database


@pytest.fixture()
async def async_client(tmp_path, monkeypatch):
    """
    Provide an HTTPX asynchronous HTTP client.

    Yields:
        An instance of AsyncClient using the FastAPI ASGI application.
    """
    db_url = f"sqlite:///{tmp_path}/db.sqlite"
    create_database(db_url=db_url)
    stamp_database(db_url=db_url)
    database = databases.Database(db_url)
    monkeypatch.setattr(BaseMeta, "database", database)

    async with AsyncClient(app=app, base_url="http://testserver") as client, LifespanManager(app):
        yield client
```

Migrations

```python title="src/project/migrations/__init__.py"
"""Database migrations modules."""

from functools import wraps
from pathlib import Path

import sqlalchemy
from alembic import command as alembic
from alembic.config import Config
from loguru import logger

from package.models import DB_PATH, SQLITE_DB, BaseMeta


def get_alembic_config(db_url=SQLITE_DB):
    alembic_cfg = Config()
    alembic_cfg.set_main_option("script_location", "package:migrations")
    alembic_cfg.set_main_option("sqlalchemy.url", str(db_url))
    return alembic_cfg


def upgrade_database(revision="head", db_url=SQLITE_DB):
    alembic_cfg = get_alembic_config(db_url)
    alembic.upgrade(alembic_cfg, revision)


def stamp_database(revision="head", db_url=SQLITE_DB):
    alembic_cfg = get_alembic_config(db_url)
    alembic.stamp(alembic_cfg, revision)


def create_database(db_url=SQLITE_DB):
    engine = sqlalchemy.create_engine(db_url)
    BaseMeta.metadata.create_all(engine)


def db_lock(func):
    """
    Decorate a function to run it in a thread-safe way.

    Arguments:
        func: The function to decorate.

    Returns:
        A wrapper.
    """

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
def apply_migrations(db_url=SQLITE_DB):
    """Apply all migrations to the database."""
    if Path(DB_PATH).exists():
        upgrade_database(db_url=db_url)
    else:
        create_database(db_url=db_url)
        stamp_database(db_url=db_url)
```

App

```python title="src/project/app.py"
from package.migrations import apply_migrations
from package.models import BaseMeta

@app.on_event("startup")
async def startup() -> None:
    """Startup application."""
    apply_migrations(str(BaseMeta.database.url))
    if not BaseMeta.database.is_connected:
        await BaseMeta.database.connect()
```

Models

```python title="src/project/models.py"
import os
import databases
import ormar
import sqlalchemy

SQLITE_DB = os.getenv("SQLITE_DB", "sqlite:///db.sqlite")
DB_PATH = SQLITE_DB.replace("sqlite:///", "")

class BaseMeta(ormar.ModelMeta):
    database = databases.Database(SQLITE_DB)
    metadata = sqlalchemy.MetaData()
```

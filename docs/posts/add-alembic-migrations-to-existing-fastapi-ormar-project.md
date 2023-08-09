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
  class: crop-excerpt
hide: [toc]
---

I had trouble adding an `ON DELETE CASCADE` constraint to foreign keys *after* they were already created, so here's a small post explaning how I did it. This specific constraint, `ON DELETE CASCADE`, is not relevant here. This post will help you for any kind of change you want to apply on database already used in production.

<!--more-->

First, I knew I was going to need "migrations", because my database was already used in production. I didn't previously add any migration. so I had to create the initial one, reflecting the current state of the database, and a second one to add the cascade delete constraints.

As documented in Ormar's pages themselves, the tool to write migrations is Alembic. Alembic has an "autogenerate" feature that can compare the "metadata" of the database (an SQLAlchemy object in memory) against the actual database to generate a migration file.

I'm using PDM to manage my dependencies, so I added Alembic to them with:

```bash
pdm add alembic
```

I did not add it to development dependencies because I can't SSH into the production machine to run a one-off command. It has to be a production dependency so I can run migrations (upgrade the state of the database) every time the app is deployed and started.

Next, following the [Alembic tutorial](https://alembic.sqlalchemy.org/en/latest/tutorial.html), I initialized it with:

```bash
pdm run alembic init alembic
```

I then had to modify a bit the `alembic.ini` and `alembic/env.py` files it created, to set the URL of the database and to import the right metadata object:

```ini
# works locally only, see later how to deal with multiple environments
sqlalchemy.url = sqlite:///db.sqlite
```

```python
from my_app.db import metadata
target_metadata = metadata
```

I was now able to generate the initial migration with the following command, making sure I removed the `ondelete="CASCADE"` arguments from my models' foreign keys:

```bash
pdm run alembic revision --autogenerate -m "Initial migration."
```

The first issue I had was that Alembic was generating a migration that would *drop* tables instead of creating them. After some investigation, I realized that it was because the `metadata` object I imported was *empty*. With Ormar, the metadata object is populated only when loading the models definitions. So instead of importing it from my `db` module which only instantiated it, I imported it from my `models` module which uses it to declare my models classes:

```python
from my_app.models import metadata
target_metadata = metadata
```

I deleted the broken migration, and recreated a correct one:

```bash
pdm run alembic revision --autogenerate -m "Initial migration."
```

To mark this migration as "applied", I ran the Alembic upgrade command:

```bash
pdm run alembic upgrade head
```

Now it was time to add the second migration, the one that adds the "on delete cascade" constraint. I added the `ondelete="CASCADE"` arguments to my models' foreign keys, add created the second migration:

```bash
pdm run alembic revision --autogenerate -m 'Add `ondelete="CASCADE"` to foreign keys.'
```

But then I got this error:

```
NotImplementedError: No support for ALTER of constraints in SQLite dialect.
Please refer to the batch mode feature which allows for SQLite migrations using a copy-and-move strategy.
```

Oh no. Thankfully, a quick search on the internet got me to this [SO post and answer](https://stackoverflow.com/questions/30378233): you have to use `render_as_batch=True` to be able to alter constraint when using an SQLite database. In `alembic/env.py`:

```python
context.configure(
    connection=connection,
    target_metadata=target_metadata,
    render_as_batch=True
)

# in both run_migrations_offline() and run_migrations_online()!
```

I ran the previous command again, and it worked. I applied the migration with `pdm run alembic upgrade head` again.

At this point, I have migrations that I will be able to apply on the production database. But how do I do that?

First, I need to support local *and* production environments. The way to do it is with an environment variable. The SQLite database URL will be stored in the `SQLITE_DB` environment variable. All I have to do now is to modify `alembic/env.py` to use this variable first, and fallback to the value configured in `alembic.ini`:

```python
def get_url():
    return os.getenv("SQLITE_DB", config.get_main_option("sqlalchemy.url"))

# in run_migrations_offline:
    url = get_url()

# in run_migrations_online:
    configuration = config.get_section(config.config_ini_section)
    configuration["sqlalchemy.url"] = get_url()
    connectable = engine_from_config(
        configuration, prefix="sqlalchemy.", poolclass=pool.NullPool,
    )
```

I was inspired by [this FastAPI example](https://github.com/tiangolo/full-stack-fastapi-postgresql/blob/master/%7B%7Bcookiecutter.project_slug%7D%7D/backend/app/alembic/env.py).

Now I need to set this variable for production, for example in an `.env` file. For me it was in a Helm chart:

```yaml
...
env:
- name: SQLITE_DB
  value: "sqlite:///different/path/to/db.sqlite"
```

Finally, I have to call the `alembic upgrade head` command each time I start the application. This can be done in FastAPI's "startup" event:

```python
import os
from pathlib import Path

import sqlalchemy
from alembic.config import Config
from alembic.commad import upgrade
from fastapi import FastAPI

from my_app.db import metadata, database

app = FastAPI()
app.state.database = database

@app.on_event("startup")
async def startup() -> None:
    """Startup application."""
    db_url = os.getenv(SQLITE_DB)
    db_path = db_url.replace("sqlite://", "")
    if not Path(db_path).exists():
        engine = sqlalchemy.create_engine(db_url)
        metadata.drop_all(engine)
        metadata.create_all(engine)

    upgrade(Config(), "head")

    database = app.state.database
    if not database.is_connected:
        await database.connect()
```

In my [next post](add-alembic-migrations-to-existing-fastapi-ormar-project.md),
you will see how to write tests for such setups,
but also how to configure all this in a more robust and elegant way.

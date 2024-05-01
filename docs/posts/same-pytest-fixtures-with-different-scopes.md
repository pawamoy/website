---
template: post.html
title: "Same Pytest fixtures with different scopes"
date: 2023-03-19
authors:
  - Timothée Mazzucotelli
tags: python pytest tests fixtures scope
image:
  src: /assets/pytest-fixtures.png
  class: crop-excerpt
---

How to use the same Pytest fixtures with different scopes, to prevent slowing down your test suite?

<!--more-->

I've recently started experimenting with mutiple [parametrizations](https://docs.pytest.org/en/6.2.x/parametrize.html) above tests, to run tests on every combination of possible values of different options. Concretely, I'm testing the output of a function that generates HTML. Since this function can potentially generate lots of HTML, I also use [inline-snapshot](https://pypi.org/project/inline-snapshot/) to automatically store the output in external files and update my test code to reference them for the next runs. I then just have to check the generated HTML to assert it matches my expectations, and fix it if it doesn't.

```python
import pytest
from inline_snapshot import snapshot

@pytest.mark.parametrize("option1", [True, False, None])
@pytest.mark.parametrize("option2", ["value1", "value2"])
@pytest.mark.parametrize("option3", [(), ("a", "b")])
def test_options_combinations(option1, option2, option3):
    assert generate_html(option1, option2, option3) == snapshot()
```

With such parametrization, I easily end up with hundreds of tests (they grow exponentially with each additional parametrization or option value). When the parametrized tests use function-scoped fixtures, they slow down the tests a lot, even if the fixtures are not very expensive. They're just executed over and over hundreds of time, so it starts being noticeable (one second, five seconds, fifteen seconds, etc.). These fixtures are function-scoped because they can be customized through Pytest's `request` fixture. But for the parametrized tests, they don't need customization. So I tried to duplicate the fixtures and make them session-scoped, but Pytest complains that they use function-scoped fixtures. After a bit of tinkering, here is what I ended up with:

- move fixtures' actual code into external helpers
- use these helpers in fixtures
- fixtures are now short and can easily be duplicated with different scopes

## Move fixtures' actual code into external helpers

Let's illustrate with code.

Initially, I had my Pytest fixture declared like this:

```tree
project/
    tests/
        conftest.py
```

```python title="tests/conftest.py"
from collections import ChainMap
from pathlib import Path
from typing import Iterator

import pytest
from mkdocs.config.defaults import MkDocsConfig

@pytest.fixture(name="mkdocs_conf")
def fixture_mkdocs_conf(request: pytest.FixtureRequest, tmp_path: Path) -> Iterator[MkDocsConfig]:
    conf = MkDocsConfig()
    while hasattr(request, "_parent_request") and hasattr(request._parent_request, "_parent_request"):
        request = request._parent_request

    conf_dict = {
        "site_name": "foo",
        "site_url": "https://example.org/",
        "site_dir": str(tmp_path),
        "plugins": [{"mkdocstrings": {"default_handler": "python"}}],
        **getattr(request, "param", {}),
    }

    mdx_configs: dict[str, Any] = dict(ChainMap(*conf_dict.get("markdown_extensions", [])))

    conf.load_dict(conf_dict)
    assert conf.validate() == ([], [])

    conf["mdx_configs"] = mdx_configs
    conf["markdown_extensions"].insert(0, "toc")  # Guaranteed to be added by MkDocs.

    conf = conf["plugins"]["mkdocstrings"].on_config(conf)
    conf = conf["plugins"]["autorefs"].on_config(conf)
    yield conf
    conf["plugins"]["mkdocstrings"].on_post_build(conf)
```

The code is not very important. We just see here that the fixture is quite long. If I wanted to duplicate it and make it session-scoped (instead of function-scoped by default), I'd have to copy-paste all this code and the only thing that would change is the `tmp_path` dependency (function-scoped), which would become `tmp_path_factory` (session-scoped). That would be wasteful.

Instead, I moved this code into a `tests/helpers.py` module:

```tree
project/
    tests/
        __init__.py
        conftest.py
        helpers.py
```

```python title="tests/helpers.py"
from collections import ChainMap
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

import pytest
from mkdocs.config.defaults import MkDocsConfig

@contextmanager
def mkdocs_conf(request: pytest.FixtureRequest, tmp_path: Path) -> Iterator[MkDocsConfig]:
    conf = MkDocsConfig()
    while hasattr(request, "_parent_request") and hasattr(request._parent_request, "_parent_request"):
        request = request._parent_request

    conf_dict = {
        "site_name": "foo",
        "site_url": "https://example.org/",
        "site_dir": str(tmp_path),
        "plugins": [{"mkdocstrings": {"default_handler": "python"}}],
        **getattr(request, "param", {}),
    }

    mdx_configs: dict[str, Any] = dict(ChainMap(*conf_dict.get("markdown_extensions", [])))

    conf.load_dict(conf_dict)
    assert conf.validate() == ([], [])

    conf["mdx_configs"] = mdx_configs
    conf["markdown_extensions"].insert(0, "toc")  # Guaranteed to be added by MkDocs.

    conf = conf["plugins"]["mkdocstrings"].on_config(conf)
    conf = conf["plugins"]["autorefs"].on_config(conf)
    yield conf
    conf["plugins"]["mkdocstrings"].on_post_build(conf)
```

You'll notice that it's the exact same code, except it's now wrapped as a `@contextmanager` and the `fixture_` prefix is removed from its name. Why a context manager? We could let it be a generator, but that would mean we have to yield from it to make sure it tears down at the end:

```python
yield from helpers.mkdocs_conf(...)
```

And we might not want to yield from it but rather just use it as argument to another function. The context manager allows us to do that:

```python
with helpers.mkdocs_confg(...) as mkdocs_conf:
    yield other_function(mkdocs_conf)
```

## Use these helpers in fixtures

Now let's rebuild our initial function-scoped fixture with this helper:

```python title="tests/conftest.py"
from collections import ChainMap
from contextlib import contextmanager
from pathlib import Path
from typing import Iterator

import pytest
from mkdocs.config.defaults import MkDocsConfig

# The following import requires that you create a `tests/__init__.py` module.
from tests import helpers


@pytest.fixture(name="mkdocs_conf")
def fixture_mkdocs_conf(request: pytest.FixtureRequest, tmp_path: Path) -> Iterator[MkDocsConfig]:
    with helpers.mkdocs_conf(request, tmp_path) as mkdocs_conf:
        yield mkdocs_conf
```

Nice and short.

## Duplicate fixtures with different scopes

It is now extremely easy to duplicate the fixture as session-scoped:

```python
@pytest.fixture(name="session_mkdocs_conf", scope="session")
def fixture_session_mkdocs_conf(request: pytest.FixtureRequest, tmp_path_factory: pytest.TempPathFactory) -> Iterator[MkDocsConfig]:
    with helpers.mkdocs_conf(request, tmp_path_factory.mktemp("project")) as mkdocs_conf:
        yield mkdocs_conf
```

We could imagine duplicating the fixture for each possible scope, which are function, class, module, package and session.

Now it happens that I have other fixtures that depend on this `mkdocs_conf` fixture. They'll be just as easy to duplicate as session-scoped fixtures. Here is the complete code of my conftest module with both function and session-scoped fixtures. The code of the helpers is not important, so isn't shown here.

```python title="tests/conftest.py"
from __future__ import annotations

from typing import TYPE_CHECKING, Iterator

import pytest

from tests import helpers

if TYPE_CHECKING:
    from pathlib import Path

    from markdown.core import Markdown
    from mkdocs.config.defaults import MkDocsConfig
    from mkdocstrings.plugin import MkdocstringsPlugin

    from mkdocstrings_handlers.python.handler import PythonHandler


# --------------------------------------------
# Function-scoped fixtures.
# --------------------------------------------
@pytest.fixture(name="mkdocs_conf")
def fixture_mkdocs_conf(request: pytest.FixtureRequest, tmp_path: Path) -> Iterator[MkDocsConfig]:
    with helpers.mkdocs_conf(request, tmp_path) as mkdocs_conf:
        yield mkdocs_conf


@pytest.fixture(name="plugin")
def fixture_plugin(mkdocs_conf: MkDocsConfig) -> MkdocstringsPlugin:
    return helpers.plugin(mkdocs_conf)


@pytest.fixture(name="ext_markdown")
def fixture_ext_markdown(mkdocs_conf: MkDocsConfig) -> Markdown:
    return helpers.ext_markdown(mkdocs_conf)


@pytest.fixture(name="handler")
def fixture_handler(plugin: MkdocstringsPlugin, ext_markdown: Markdown) -> PythonHandler:
    return helpers.handler(plugin, ext_markdown)


# --------------------------------------------
# Session-scoped fixtures.
# --------------------------------------------
@pytest.fixture(name="session_mkdocs_conf", scope="session")
def fixture_session_mkdocs_conf(request: pytest.FixtureRequest, tmp_path_factory: pytest.TempPathFactory) -> Iterator[MkDocsConfig]:
    with helpers.mkdocs_conf(request, tmp_path_factory.mktemp("project")) as mkdocs_conf:
        yield mkdocs_conf


@pytest.fixture(name="session_plugin", scope="session")
def fixture_session_plugin(session_mkdocs_conf: MkDocsConfig) -> MkdocstringsPlugin:
    return helpers.plugin(session_mkdocs_conf)


@pytest.fixture(name="session_ext_markdown", scope="session")
def fixture_session_ext_markdown(session_mkdocs_conf: MkDocsConfig) -> Markdown:
    return helpers.ext_markdown(session_mkdocs_conf)


@pytest.fixture(name="session_handler", scope="session")
def fixture_session_handler(session_plugin: MkdocstringsPlugin, session_ext_markdown: Markdown) -> PythonHandler:
    return helpers.handler(session_plugin, session_ext_markdown)
```

Now in my tests I can either use `handler` or `session_handler`, to pick the right scope depending on the test's needs and how many times it runs through parametrizations.

```python
# This test customizes the MkDocs configuration,
# and runs only 3 x 7 = 21 times,
# so I use the function-scoped handler fixture.
@pytest.mark.parametrize(
    "plugin",
    [
        {"theme": "mkdocs"},
        {"theme": "readthedocs"},
        {"theme": {"name": "material"}},
    ],
    indirect=["plugin"],
)
@pytest.mark.parametrize(
    "identifier",
    [
        "mkdocstrings.extension",
        "mkdocstrings.inventory",
        "mkdocstrings.loggers",
        "mkdocstrings.plugin",
        "mkdocstrings.handlers.base",
        "mkdocstrings.handlers.rendering",
        "mkdocstrings_handlers.python",
    ],
)
def test_render_themes_templates_python(identifier: str, handler: PythonHandler) -> None:
    data = handler.collect(identifier, {})
    handler.render(data, {})
```

```python
...

# This test runs about 400 times with different options,
# and doesn't need any customization of the MkDocs configuration,
# so I use the session-scoped handler fixture.
@pytest.mark.parametrize("inherited_members", options["inherited_members"])
@pytest.mark.parametrize("members", options["members"])
@pytest.mark.parametrize("members_order", options["members_order"])
@pytest.mark.parametrize("filters", options["filters"])
@pytest.mark.parametrize("summary", options["summary"])
def test_end_to_end_for_members(
    session_handler: PythonHandler,
    inherited_members: list[str] | bool | None,
    members: list[str] | bool | None,
    members_order: str,
    filters: list[str] | None,
    summary: bool | dict[str, bool] | None,
) -> None:
    final_options = {**locals()}
    html = _render(session_handler, final_options)
    snapshot_key = tuple(sorted(final_options.items()))
    assert outsource(html, suffix=".html") == snapshots_members[snapshot_key]
```

Do you have similar use-cases? How did you handle them? Maybe there's something obvious I missed about fixtures? Maybe there are Pytest plugins that make this easier?

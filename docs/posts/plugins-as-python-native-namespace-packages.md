---
template: post.html
title: "Python packages and plugins as namespace packages"
date: 2020-10-11
authors:
  - Timothée Mazzucotelli
tags: python plugin package native namespace pkgutil
---

A user of [`mkdocstrings`](https://github.com/pawamoy/mkdocstrings)
wrote a Crystal handler for their own use-case.
They asked on [the Gitter channel](https://gitter.im/mkdocstrings/community)
if we could allow to load external handlers, so they don't have to fork
the project and install the fork, but rather just install their
lightweight package containing just the handler.

We both saw Python namespace packages as good candidates,
so I experimented a bit, and here are my conclusions.

<!--more-->

Based on the documentation, there are
[3 ways of creating a Python namespace package](https://packaging.python.org/guides/packaging-namespace-packages/#creating-a-namespace-package):

- native namespace packages
- pkgutil-style namespace packages
- pkg-resources-style namespace packages

I only considered the first two options (I'll let you read the docs to see why).

## Native namespace packages

Native namespace packages are Python 3 compatible only.
Good, I don't support Python 2 in my projects.

To write a native namespace package, you just have to do one thing:
drop the `__init__.py`!

```
my_namespace_package/
    my_module_a.py

my_namespace_package/
    my_module_b.py
```

Install both packages and you will be able to import
both `my_module_a` and `my_module_b` from `my_namespace_package`.

If you want to provide deeper modules, you will have to drop
all `__init__.py` files along the way:

```
# main package
package/
    level1/
        level2/
            builtin_module.py
    subpackage/
        __init__.py
        sub.py
    a.py

# plugin
package/
    level1/
        level2/
            plugin_module.py
```

Notice how we don't have any `__init__.py` in `package`, `level1` and `level2`.
This is required for the plugin package to add modules there.

In this example, `subpackage` has an `__init__.py` file,
it means that our plugin package could not add a module into it.

## `pkgutil`-style namespace packages

The `pkgutil` way is compatible with Python 2 and Python 3.
It allows to keep `__init__.py` modules.

```
# main package
package/
    __init__.py
    level1/
        __init__.py
        level2/
            __init__.py
            builtin_module.py

# plugin
package/
    __init__.py
    level1/
        __init__.py
        level2/
            __init__.py
            plugin_module.py
```

Each `__init__.py` must contain this code:

```python
from pkgutil import extend_path
__path__ = extend_path(__path__, __name__)
```

Basically, it's a bit like the native way,
except that you keep your `__init__.py` modules,
**but they must be identical across all packages!**

The `__init__.py` modules of the plugin will overwrite the
`__init__.py` modules of the main package. If they are not
identical, things will break (mostly imports).

So, with the native way, you cannot write code in `__init__.py`
because those modules must not exist,
and with the `pkgutil` way you must not write code in `__init__.py`
because you don't want to have users duplicate it in their own.

At this state, I prefer the native way, as it's less files to write.

## What I would have liked

Maybe namespace packages are not the best option for plugins.

But I would have loved being able to write my main package normally,
with `__init__.py`, and as much code in those as I want,
and write the plugin package *without any* `__init__.py`, so as to
"plug" (i.e. merge) additional modules into the main package:

```
# main package
package/
    __init__.py
    level1/
        __init__.py
        level2/
            __init__.py
            builtin_module.py

# plugin
package/
    level1/
        level2/
            plugin_module.py
```

The order of installation would not matter of course,
as merging the main package into the plugin one, or the opposite,
would result in the same final package on the disk:

```
# main package
package/
    __init__.py
    level1/
        __init__.py
        level2/
            __init__.py
            builtin_module.py
            plugin_module.py
```

The main package author doesn't even have to think about plugins
and prepare the field by removing `__init__.py` where it is needed.
Instead, they just write their package normally.

Then users can write a namespace package, mimicking the main package
structure, but without `__init__.py` files, and BOOM, they
successfully wrote a plugin!

Native namespace packages look like they are trying to be implicit,
but in my taste they are still not implicit enough.

Also, merging namespace packages into packages of the same name
would allow easy patching of projects! Something not quite working
like you want to? Quickly create a namespace package with just the
patched module, and list it as a dependency.

What do you use to allow plugins in your Python projects :slightly_smiling_face:?
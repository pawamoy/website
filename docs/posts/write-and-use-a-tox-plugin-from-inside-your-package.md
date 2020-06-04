---
template: post.html
title: "Write and use a tox plugin from inside your package"
date: 2016-12-07
authors:
  - Timothée Mazzucotelli
tags: python package tox plugin
disqus: pawamoy
---

So let's say you wrote a program that is using tox and you want to add
some options to tox's command-line. Reading at [tox's documentation][]
about plugins, you see that you have to make a pip installable plugin
and setup some entry point. In fact, you can skip the pip installable
side and integrate the plugin directly within your code.

<!--more-->

It can be done in three very simple steps.

- [Add a tox_module in your package](#add-a-tox-module-in-your-package)
- [Setup the entry points](#setup-the-entry-points)
- [Update your code](#update-your-code)

## Add a tox_module in your package
Create a new module somewhere. Its name should begin with `tox_`.

```python
# tox_your_module.py
from tox import hookimpl


@hookimpl
def tox_addoption(parser):
    parser.add_argument('my_new_option')
    # read argparse's doc online to see more complex examples
```

## Setup the entry points
Tox has an automagic system that will see installed plugins and load them when you call it.
Just set the new `tox` entry point:

```python
# setup.py
setup(
    ...
    entry_points={
        'console_scripts': 'your_program = your_program.main:main',  # to be adapted
        'tox': ['your_module = your_program.tox_your_module']
    },
    ...
)
```

Installing your package will make it visible to tox.

## Update your code
In your code you will now be able to use the `my_new_option` option in tox's config object, and do whatever you want with it!

```python
from tox.session import prepare

config = prepare(args)

print(config.option.my_new_option)
```

Voilà.

Of course your plugin could be much more complex, but this is another story.

[tox's documentation]: http://tox.readthedocs.io/en/latest/plugins.html

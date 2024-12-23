---
template: post.html
title: "Tips for writing good Python CLI/libraries"
date: 2023-03-19
authors:
  - Timothée Mazzucotelli
tags: python tips cli library api
# image:
  # src: /assets/client-server-architecture.png
  # class: crop-excerpt
---

This post shows a few things that I consider best-practices,
and a few other things that you should avoid when writing
a Python command-line tool and/or library.

<!--more-->

## Motivation

Stems from duty, task runner that can run Python callables.
Toot on Mastodon, quote from docs "call to developers".

<iframe src="https://fosstodon.org/@pawamoy/109891647598910409/embed" class="mastodon-embed" style="max-width: 100%; border: 0" width="400" allowfullscreen="allowfullscreen"></iframe><script src="https://fosstodon.org/embed.js" async="async"></script>


- people *will* want to use your tool programatically,
    whether you provide a public interface or not
- it is just easier to write, maintain and test

## Kindness disclaimer

- it's fine not to care about programatic use (though it makes things easier)
- no judgments on the projects I mention as examples of what to do or not:
    written by people when they didn't have experience,
    or didn't think/care about programatic use

## Do's and don'ts

- don't tie logic to your CLI (BE: black, coverage)
- think "library first" (BE: pydeps)
- decide what you expose in the CLI, write a function for each
- accept only built-in types in these functions
- the CLI just translates CLI arguments to Python arguments
- capture stdout/stderr of subprocess and re-print it
- don't exit the process in functions
- avoid fancy IO management
- avoid fancy decorators
- use `main.py` and `cli.py`
- @ionelmc's wisdom `__main__.py`
- accepts args in your CLI entrypoints
- (unsure) if you operate on files, accepts directories and implement discovery/recursion
- (tyro) https://brentyi.github.io/tyro/examples/01_basics/01_functions/ not good,
  hides actual CLI args

## splitting projects

- `project-lib`
- `project-cli`, depends on lib
- `project`, depends on cli + interactive deps (auto-completion, shell detection)
- `project-gui`, depends on project
- `project-tui`, depends on project
- `project` declares following extras: `gui`, `tui`, `all`

## Benefits

- providing a callable means it will work for every version of your project
    (impossible otherwise)



## Bad examples

- Twine adds logic to its `__main__.main` function which does not accept arguments.
- pyproject-build defines its main method in `__main__`.
- iterate on all duty tools to see which ones are painful to deal with (mypy? black?)
- safety, debugging the issue I had between v2 and v3


# Cappa

- declare the final state of data (dataclasses)
- annotate how Cappa transforms command line args into it

- tempted for maximizing reusability: don't, it's rare that options keep same help/desc across different commands, or commands across CLIs
- if you have to, you can use composition, by destructuring args, instead of using inheritance (better?)
- in the end, your dataclasses are still for a CLI, not for programmatic usage

- global arguments: propagate=True
- setup: global dependency

- no subcommand default: each command *requires* the subcommand, otherwise why even provide it? and you'd need to propagate args downwards (`prog command --opt` -> `prog command --opt subcommand` not working)

# final data from CLI, env, config

---
template: post.html
title: "Somewhat-modern Python"
date: 2022-02-01
authors:
  - Timothée Mazzucotelli
tags: dev development python modern project template
---

In this post I present my latest project template for Python projects,
[copier-pdm](https://github.com/pawamoy/copier-pdm),
based on the great [Copier](https://github.com/copier-org/copier).

This parodic title was inspired by the
["Hypermodern Python"](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/)
article series by [Claudio Jolowicz](https://github.com/cjolowicz).
Indeed, my Python development setup has parts that could considered
modern by some, and old-school by others, so I found it funny
to call it "more-or-less modern".

<!--more-->

---

As Claudio points it out in his article series,
the Python landscape has changed considerably this
last decade, and even more so these last few years.
Python is now one of the most used languages in the world,
and we see a plethora of new projects coming up to life.
Code formatters, linters, test runners, task runners,
documentation generators, project managers, wheel builders
and installers, dependency resolvers, CLI/TUI/API frameworks,
static/runtime type checkers. It can be hard
for new-comers to choose their tools and libraries,
or even learn about their existence. Seasoned developers
might see a lot of these new projects as new "toys"
that will just be unmaintained one year from now.
Sometimes, they are right. But I think it's important
to keep an open-mind and try new fancy projects,
even if they're not widely accepted/used by
the community of Python developers (experts and beginners),
or even create your own tools and libraries. Sometimes, it pays.
Sometimes, you fill a niche and get progressive adoption.

That's what I've been doing for a few years now.
I'm far from being the most experienced Python developer,
but I've grown to know the ecosytem quite well.
I have my opinions, which not everybody will share.
And I know (almost) exactly what I need as a Python developer.
This is why I have created my own template for Python projects.
It is very opinionated, and makes use of some of my own tools
which are probably completely unknown to the community at large.

This post presents all the tools
and libraries used in my template, categorized and ordered
from general aspects of project templating and Python projects,
to very specific things like "what do I want to see in the
standard output of my task runner":

- [Project templating](#project-templating-copier): creating a template, generating projects, updating generated projects.
- [Project management](#project-management-pdm): metadata, dependencies, building and publishing wheels.
- [Running tasks](#task-runner-duty): setting the project up, running quality checks or tests suites, etc.
- [Workflow](#workflow): git commit messages, automatic changelog generation, new releases.
- [Generating documentation](#documentation-mkdocs): writing docs/docstrings, automatic code reference, publishing.
- [Continuous Integration](#continuous-integration-github-actions): DRY configuration between local and CI

## Project templating: Copier

![copier logo](../assets/copier-logo.png)

Copier is a project templating tool.
It is able to generate a project from a given template,
prompting the user for some information, and injecting
this information into the generated files.
A template is basically a git repository with
templated files and folders,
as well as a configuration file for Copier.
Files ending with a `.jinja` extension will be rendered
using [Jinja](https://palletsprojects.com/p/jinja/).
The Jinja context will be populated with the user's answers.

```console
% copier gh:pawamoy/copier-pdm test-project
🎤 Your project name
   Test Project
🎤 Your project description
   This is just a test.
🎤 Your full name
   Timothée Mazzucotelli
🎤 Your email
   pawamoy@pm.me
🎤 Your username (e.g. on GitHub)
   pawamoy
...
```

A template is very helpful when you create lots of new project:
you avoid writing boilerplate code again and again.

Now, Copier does not just allow to generate projects.
**It is also able to *update* generated projects
when newer versions of templates are released.**

??? info "Story time: from Cookiecutter to Copier"
    Most of Python developers probably know about [CookieCutter](https://github.com/cookiecutter/cookiecutter).
    It's a project templating tool that allows to write language-and-technology-agnostic templates.
    Templates are basically a folder, with files and other folders in it,
    whose names and contents can be "templated", i.e. use variables, conditions and loops.
    The templating language used is [Jinja2](https://jinja2docs.readthedocs.io/en/stable/),
    another well known project.

    Despite its popularity, CookieCutter lacks a crucial feature: upstream-to-downstream updates.
    Let say you create your perfect Python project template with CookieCutter.
    You use it to generate 5 or 6 projects with it. With time, these 5 or 6 projects will start
    to diverge, and there's no integrated way into CookieCutter to prevent it.
    You will apply clever things from project N back into the template itself,
    but there's no way to apply these same modifications onto the other projects.
    It effectively makes your template "single-use" or "one-time" only,
    because once a project is generated, there's no way to keep it in sync with the template
    evolutions themselves. And this is something users are trying to achieve,
    see [cookiecutter#784](https://github.com/cookiecutter/cookiecutter/issues/784) and
    [cookiecutter#1004](https://github.com/cookiecutter/cookiecutter/issues/1004).

    In fact, there is a way, and it's called [Cruft](https://github.com/cruft/cruft)
    (other alternatives exist but I feel like Cruft is the most popular).
    But Cruft is a wrapper around CookieCutter so it can only do so much to improve it.
    It does not have access to CookieCutter's internals, and therefore cannot provide
    a completely integrated, native project-updating experience (at least in my opinion,
    I will let you try it out if you are using CookieCutter, and let me know if I'm wrong :smile:).

    This is where [Copier](https://github.com/copier-org/copier) shines:
    that feature is built-in, by design. One of Copier's main goals
    is to make it easy to update your already-generated projects
    when your template evolves. It means that, even when you manage dozens of projects
    that were generated using a single template, you can easily, almost automatically
    keep them in sync, while still allowing small differences here and there.
    I won't go into the details of how the update mechanism works (git operations, basically),
    but you can see a [diagram and explanation here](https://copier.readthedocs.io/en/latest/updating/#how-the-update-works). 

    !!! quote "To quote Copier's docs:"
        *Although Copier was born as a code scaffolding tool,
        it is today a code lifecycle management tool. This makes it somehow unique.*

### Creating a template

To create a template using Copier, you have to know
[the basics of Jinja](https://jinja.palletsprojects.com/en/3.1.x/api/#basics).
Then you can simply read the [Quickstart section](https://copier.readthedocs.io/en/latest/#quick-start) of Copier's docs.
This will give you an idea of what is possible. If you already know and use CookieCutter, you'll see that it's similar:
you can put the templated stuff into a subdirectory of your git repository.
One small difference is that the context is available globally rather than under the `cookiecutter` key.

A minimal Copier template could look like this:

```tree
template/
  project/
    README.md.jinja
  copier.yml
```

```yaml title="template/copier.yml"
_subdirectory: project

project_name:
  help: What is your project name?
```

```md title="template/project/README.md.jinja"
# {{ project_name }}
```

### Generating a project

To get a feel of what it's like to generate a project from a real-life template,
you can try to generate a project using my `copier-pdm` template.
Just run this in a terminal:

```bash
pip install --user pipx
pipx run copier gh:pawamoy/copier-pdm newproject
cd newproject
```

The template at [`gh:pawamoy/copier-pdm`](https://github.com/pawamoy/copier-pdm)
is the actual template containing all the tools and configuration I'm writing about in this post.
I'll present it in more details in the [last chapter](#integrating-everything-together) of this post.

An important thing to know is that you should immediately stage and commit
every generated file and folder, even if you want to delete some of them,
because this will help later during updates.

```bash
git add -A
git commit -m "feat: Generate initial project"
# now modify and commit as much as you want!
```

### Updating generated projects

Let say you just changed something in your template.
All you need to be able to update your projects generated from this template,
is to push a new tag, then go into your generated project(s) and run `copier -f update`.
Copier will automatically apply the modifications to your project,
while keeping the project's own changes intact.
You can review the changes in your favorite tool (VSCode "Source Control" tab, `git add -p`, etc.),
stage and commit. That's it!

You can see all my "template upgrade" commits on GitHub with this search:
["chore: Template upgrade user:pawamoy"](https://github.com/search?q=chore%3A+Template+upgrade+user%3Apawamoy&type=commits).

For more information on the update process,
see [how the update works](https://copier.readthedocs.io/en/stable/updating/#how-the-update-works).

## Project management: PDM

<img src="../../assets/pdm-logo.png" style="max-width: 300px;" />

Now that we have templates and can generate projects, we must choose a project management tool.
Traditional setups include `setuptools`' `setup.py` file, with some `MANIFEST.in` and `requirements.txt` files.
We can spice things up with [pip-tools](https://github.com/jazzband/pip-tools/) or other alternatives.
We can use modern, minimalist tools like [Flit](https://github.com/pypa/flit).
Or we can use full-fledge, all-in-one managers like [Hatch](https://github.com/pypa/hatch),
[Poetry](https://python-poetry.org/), or [PDM](https://pdm.fming.dev/).

??? info "Story time: from Poetry to PDM"
    When the community came to learn about Poetry, it was a revolution: finally a tool
    that removed all the boilerplate and complexity around packaging and publishing Python projects.
    Everything was declared in `pyproject.toml`, and nothing else.
    You could manage your dependencies, virtualenvs being handled for you (great for beginners),
    you could build wheels and source distributions and publish them to PyPI with simple commands
    like `poetry build` and `poetry publish`. Poetry seriously improved the UX around project management
    and packaging in the Python ecosystem. I'll forever be thankful for that.

    But Poetry also took some annoying design decisions. They looked good at first,
    but were a huge hindrance for projects, depending on their environment.
    To make it short, I'm referring to this,
    ["Allow user to override PyPI URL without modifying pyproject.toml"](https://github.com/python-poetry/poetry/issues/1632),
    and other things like the inconsistencies in how to configure things / how the configuration is used,
    and the lack of option to disable SSL verification.
    I was maybe a bit thown-off by the complete absence of answer to my request for guidance in the PR I sent
    (working change, just hard to test),
    but I really can't blame them for this because they were literally assaulted with issues and PRs.

    Then I learned about PDM. It had all the good things Poetry had, and it removed
    the previously mentioned pain points, namely: it was able to read `pip`'s configuration.
    It made using private indexes *so easy*: setup `pip`'s index-url and trusted-host and you're done.
    Your own configuration does not contaminate other users through `pyproject.toml`
    (note: PDM 2.0 doesn't read `pip`'s configuration anymore, but you can still configure
    your index outside of `pyproject.toml`).

    Even more interesting, it offered support for the (draft) [PEP 582](https://peps.python.org/pep-0582/).
    Since then, it gained several other outstanding features, like a [pnpm](https://pnpm.io/)-like cache,
    a powerful plugin system, development dependencies groups, etc.
    [@noirbizarre](https://github.com/noirbizarre) posted a
    [very nice comment](https://github.com/pdm-project/pdm/discussions/1162#discussioncomment-3041456)
    about PDM, summarizing all these wonderful features.
    [@frostming](https://github.com/frostming) is doing a fantastic job at maintaining PDM.

One of the main interests in using PDM is its ability to use
[PEP 582](https://peps.python.org/pep-0582/)'s `__pypackages__` installation folders.
No more virtualenvs! Combined with its package cache, dependencies are installed
insanely fast, and your environment won't break when you update your Python versions.
Obviously, it also drastically reduces the disk-space taken by your dependencies.

![pdm install](../assets/pdm-install.svg)

If you still want to use virtualenvs, PDM natively supports them as well,
and can manage them for you, just like Poetry.

### Installing and using PDM

My recommandation to install PDM is to use [pipx](https://pypa.github.io/pipx/):

```bash
python -m pip install --user pipx
pipx install pdm
```

I also like to enable PEP 582 support globally ([docs](https://pdm.fming.dev/latest/usage/pep582/#enable-pep-582-globally)),
so that `python` is always aware of packages installed in a `__pypackages__` folder:

```bash
pdm --pep582 >> ~/.bash_profile
```

The commands written to `.bash_profile` simply add a subfolder of PDM to the `PYTHONPATH`
environment variable. This folder contains a `sitecustomize.py` module,
which Python executes upon starting. The module in turn will add subfolders
of `__pypackages__` (when it exists) to `sys.path`. The end result is
that you can run `python` and import dependencies normally,
or even call modules with `python -m thing`,
without having to use `pdm run python ...`. One limitation
is that you still won't be able to call installed script directly,
for example `pytest`, like in an activated virtual environment.
For this, you'll have to run `pdm run pytest` (but remember that
if packages support it, you can run `python -m pytest` instead).

### Declaring your project metadata

PEP 517
PEP 621

### Declaring your dependencies

Groups.

### Building and publishing wheels

pdm build, pdm publish

## Task runner: duty

Own tool, run str/list/callable, Invoke, failprint, output, makefile, no tox/nox, no venvs, multirun script.

### Project setup

setup script.

### Quality analysis

flake8 and plugins, mypy and stubs.

### Code formatters

isort, ssort, black, autoflake.

### Security analysis

safety, dependency confusion.

### Test suite

pytest, coverage, pytest-plugin, hypothesis.

## Workflow

git commit messages, automatic changelog generation, new releases.

## Documentation: MkDocs

Writing docs/docstrings, automatic code reference, site generation, publishing.

## Continuous Integration: GitHub Actions

Linux/MacOS/Windows. DRY configuration between local and CI.

## Integrating everything together

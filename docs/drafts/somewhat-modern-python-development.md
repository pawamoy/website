---
template: post.html
title: "Somewhat-modern Python"
date: 2022-02-01
authors:
  - Timothée Mazzucotelli
tags: dev development python modern project template
---

In this post I present my latest project template for Python projects,
[copier-pdm](https://github.com/pawamoy/copier-pdmpoetry),
based on the great [Copier](https://github.com/copier-org/copier) tool.

This parodic title was inspired by the
["Hypermodern Python"](https://cjolowicz.github.io/posts/hypermodern-python-01-setup/)
article series by [Claudio Jolowicz](https://github.com/cjolowicz).
Indeed, my Python development setup has parts that could considered
modern by some, and old-school by others, so I found it funny
to call it "more-or-less modern" (is it? is it not? does it matter? I don't know!).

<!--more-->

---

As Claudio points it out in his article series,
the Python landscape has changed considerably this
last decade, and even more so these last few years.
Python is now one of the most used language in the world,
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
which are probably completely unknown by the community at large.

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

Copier, reasoning, updates, Cookiecutter+Cruft, multi-projects, no divergence.

### Creating a template

Basics, Jinja, Copier docs.

### Generating a project

Try copier-pdm.

### Updating generated projects

Updates again, multi-projects, no divergence.

## Project management: PDM

PEP 582, PEP 621, PEP 517, PDM vs. Poetry, shell integration, pdm run vs. python -m.

### Metadata

### Dependencies

Groups.

### Building and publishing wheels

pdm build, pdm-publish plugin, twine.

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

---
layout: post
title: "Testing Python and Django in pydjama"
date: 2016-12-07 17:27:40
tags: python package django app testing maintaining cookiecutter pydjama
comments: true
---

# /!\ Work in progress /!\
This post is about testing and maintaining Python packages and Django apps.

If you are inteterested in the testing and maintaining flow it talks about, please check
the [pydjama][] cookiecutter (yes, that explains this post's title). See here what is
[cookiecutter][].<!--more-->

#### Contents

- [Introduction](#introduction)
- [Project structure](#project-structure)
  - [General files](#general-files)
  - [Configuration files](#configuration-files)
  - [Sources directory]
  - [Tests directory]
  - [Requirements]
  - [Scripts](#scripts)
- [Testing](#testing)
  - [Tools](#testing-tools)
    - [tox]
    - [detox]
    - [check-manifest]
    - [coverage]
    - [prospector]
    - [flake8]
    - [isort]
    - [py.test]
  - [Services]
    - [Travis]
    - [Landscape]
    - [Codecov]
  - [Scripts]
    - [Running Django tests]
- [Maintaining]
  - [Tools]
    - [bumpversion]
    - [sphinx]
  - [Services]
    - [PyPI]
    - [PyUp]
    - [Gitter]
    - [ReadTheDocs]
  - [Scripts]
    - [Releasing]
    - [Updating template]


# Introduction
Python community is great because of the vast multitude of tools and services
you can use in your projects. This post is a big summary of the tools and
services I use to develop Python packages and Django apps.

At the time of writing, I work on about 10 different packages/apps. I need them
in a bigger project's development for which I'm paid. These packages and apps
are not used so much by other developers, but maybe they will in the future ;)

If I want other people to contribute, I have to set a good structure for each
of these apps. Testing, CI, releasing, documenting... all these tasks should
be easy to achieve. To avoid a maintaining hell, I use the same project
template for each one of them, using a cookiecutter.

# Project structure
General files and configuration files are at the root of the repository.
Actual source code (the python package) is in a `src` directory.

```
.
├── AUTHORS.rst
├── CHANGELOG.rst
├── CONTRIBUTING.rst
├── LICENSE
├── MANIFEST.in
├── README.rst
|
├── .bumpversion.cfg
├── .cookiecutterrc
├── .coverage
├── .coveragerc
├── .editorconfig
├── .gitignore
├── .landscape.yml
├── .style.yapf
├── .travis.yml
├── setup.cfg
├── setup.py
├── tox.ini
|
├── update.sh
├── release.sh
├── [runtests.py]
|
├── requirements
│   ├── base.txt
│   ├── ci.txt
│   ├── local.txt
│   └── test.txt
|
├── src
│   └── package
│       └── __init__.py
|
└── tests
    └── test_package.py

```

## General files
- **AUTHORS.rst**: The list of authors who contributed to the project.
- **CHANGELOG.rst**: The list of modifications over time, ordered by release date.
- **CONTRIBUTING.rst**: Guide lines for whoever wants to contribute.
- **LICENSE**: The project's license.
- **README.rst**: The important thing everyone should read.

## Configuration files
- **.bumpversion.cfg**: Configuration for bumpversion tool
  (see [bumpversion section](#bumpversion)).
- **.cookiecutterrc**: Cookiecutter values used to generate this project.
- **.coveragerc**: Configuration for coverage tool
  (see [coverage section](#coverage)).
- **.editorconfig**: Consistent coding style between
  different editors and IDEs. See http://editorconfig.org/.
- **.gitignore**: Files and directories ignored by git.
- **.landscape.yml**: Configuration for prospector tool and Landscape service
  (see [prospector section](#prospector) and [Landscape section](#landscape)).
- **.style.yapf**: Configuration for yapf tool (see [yapf section](#yapf)).
- **.travis.yml**: Configuration for Travis service
  (see [Travis section](#travis)).
- **setup.cfg**: Installation instructions, but also contains configuration
  for some tools like py.test, flake8 or isort
  (see [py.test section](#pytest), [flake8 section](#flake8)
  and [isort section](#isort)).
- **setup.py**: Python installation script.
- **tox.ini**: Configuration for tox (see [tox section](#tox)).

## Sources directory

## Tests directory

## Requirements

## Scripts
- **update.sh**: A script to get last updates
  from the cookiecutter used to generate the project
  (see [updating section](#updating-template)).
- **release.sh**: A script to release a new version of the project in one
  command (see [releasing section](#releasing)).
- **runtests.py**: Only for Django apps. Will load the needed Django setup
  before actually running the tests
  (see [running django tests section](#running-django-tests)).

# Testing
When the ground is well prepared, tests are really fun to write!

## Testing tools

### tox

### detox

### check-manifest

### coverage

### prospector

### flake8

### isort

### py.test

## Testing services

### Travis

### Landscape

### Codecov

## Testing scripts

### Running Django tests

# Maintaining

## Maintaining tools

### bumpversion

### sphinx

## Maintaining services

### PyPI

### PyUp

### Gitter

### ReadTheDocs

## Maintaining scripts

### Releasing

### Updating template



[pydjama]: https://github.com/Pawamoy/cookiecutter-pydjama
[cookiecutter]: https://github.com/audreyr/cookiecutter

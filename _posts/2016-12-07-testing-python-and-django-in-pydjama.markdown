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

- [Introduction]()
- [Project structure]()
  - [General files]()
  - [Configuration files]()
  - [Sources directory]()
  - [Tests directory]()
  - [Requirements]()
  - [Scripts]()
- [Testing]()
  - [Tools]()
    - [tox]()
    - [detox]()
    - [check-manifest]()
    - [coverage]()
    - [prospector]()
    - [flake8]()
    - [isort]()
    - [py.test]()
  - [Services]()
    - [Travis]()
    - [Landscape]()
    - [Codecov]()
  - [Scripts]()
    - [Running Django tests]()
- [Maintaining]()
  - [Tools]()
    - [bumpversion]()
    - [sphinx]()
  - [Services]()
    - [PyPI]()
    - [PyUp]()
    - [Gitter]()
    - [ReadTheDocs]()
  - [Scripts]()
    - [Releasing]()
    - [Updating template]()


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
General files and confiration files are at the root of the repository.
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
  (see bumpversion section).
- **.cookiecutterrc**: Cookiecutter values used to generate this project.
- **.coveragerc**: Configuration for coverage tool (see coverage section).
- **.editorconfig**: Consistent coding style between
  different editors and IDEs. See http://editorconfig.org/.
- **.gitignore**: Files and directories ignored by git.
- **.landscape.yml**: Configuration for prospector tool and Landscape service
  (see prospector section and Landscape section).
- **.style.yapf**: Configuration for yapf tool (see yapf section).
- **.travis.yml**: Configuration for Travis service (see Travis section).
- **setup.cfg**: Installation instructions, but also contains configuration
  for some tools like pytest, flake8 or isort.
- **setup.py**: Python installation script.
- **tox.ini**: Configuration for tox (see [tox section](#tox)).

## Sources directory

## Tests directory

## Requirements

## Scripts
- **update.sh**: A script to get last updates
  from the cookiecutter used to generate the project.
- **release.sh**: A script to release a new version of the project in one command.
- **runtests.py**: Only for Django apps. Will load the needed Django setup
  before actually running the tests.

# Testing
When the ground is well prepared, tests are really fun to write!

## Tools
### tox
### detox
### check-manifest
### coverage
### prospector
### flake8
### isort
### py.test
## Services
### Travis
### Landscape
### Codecov
## Scripts
### Running Django tests
# Maintaining
## Tools
### bumpversion
### sphinx
## Services
### PyPI
### PyUp
### Gitter
### ReadTheDocs
## Scripts
### Releasing
### Updating template



[pydjama]: https://github.com/Pawamoy/cookiecutter-pydjama
[cookiecutter]: https://github.com/audreyr/cookiecutter

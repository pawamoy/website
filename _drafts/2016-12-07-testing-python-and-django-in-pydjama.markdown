---
layout: post
title: "Testing Python and Django in pydjama"
date: 2016-12-07 17:27:40
tags: python package django app testing maintaining cookiecutter pydjama
comments: true
---

### /!\ Work in progress /!\
This post is about testing and maintaining Python packages and Django apps.

If you are inteterested in the testing and maintaining flow it talks about, please check
the [pydjama][] (yes, that explains this post's title) and [pylibrary][] cookiecutters.
See here what is [cookiecutter][].<!--more-->


- [Introduction](#introduction)
- [Project structure](#project-structure)
  - [General files](#general-files)
  - [Configuration files](#configuration-files)
  - [Sources directory](#sources-directory)
  - [Tests directory](#tests-directory)
  - [Requirements](#requirements)
  - [Scripts](#scripts)
- [Testing](#testing)
  - [Tools](#testing-tools)
    - [tox](#tox)
    - [detox](#detox)
    - [check-manifest](#check-manifest)
    - [coverage](#coverage)
    - [prospector](#prospector)
    - [flake8](#flake8)
    - [isort](#isort)
    - [pytest](#pytest)
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
    - [yapf]
  - [Services]
    - [PyPI]
    - [PyUp]
    - [Gitter]
    - [ReadTheDocs]
  - [Scripts]
    - [Releasing]
    - [Updating template]


## Introduction
I find Python community great because of the vast multitude of tools and services
you can use in your projects. This post is a big summary of the tools and
services I use to develop Python packages and Django apps.

At the time of writing, I work on about 10 different packages/apps. I need them
in a bigger project's development for which I'm paid. These packages and apps
are not used so much by other developers, but maybe they will in the future ;)

If I want other people to contribute, I have to set a good structure for each
of these apps. Testing, CI, releasing, documenting... all these tasks should
be easy to achieve. To avoid a maintaining hell, I use the same project
template for each one of them, using a cookiecutter.

## Project structure
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
│   └── <PACKAGE>
│       └── __init__.py
|
└── tests
    └── test_<PACKAGE>.py

```

### General files
- **AUTHORS.rst**: The list of authors who contributed to the project.
- **CHANGELOG.rst**: The list of modifications over time, ordered by release date.
- **CONTRIBUTING.rst**: Guide lines for whoever wants to contribute.
- **LICENSE**: The project's license.
- **README.rst**: The important thing everyone should read.

### Configuration files
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
  for some tools like pytest, flake8 or isort
  (see [pytest section](#pytest), [flake8 section](#flake8)
  and [isort section](#isort)).
- **setup.py**: Python installation script.
- **tox.ini**: Configuration for tox (see [tox section](#tox)).

### Sources directory
The actual Python code.

### Tests directory
The tests directory, with Python files beginning with `test_`.

### Requirements
Text files with requirements for the different environment if relevant:
- base requirements (for every environment)
- requirements for tests
- requirements for continuous integration
- requirements for local environment (development)
- ...

### Scripts
- **update.sh**: A script to get last updates
  from the cookiecutter used to generate the project
  (see [updating section](#updating-template)).
- **release.sh**: A script to release a new version of the project in one
  command (see [releasing section](#releasing)).
- **runtests.py**: Only for Django apps. Will load the needed Django setup
  before actually running the tests
  (see [running django tests section](#running-django-tests)).

## Testing
When the ground is well prepared, tests are really fun to write!

### Testing tools

#### tox
[tox][] is the main tool here. It can be used to define many testing environments, or many
different "tasks", like checkint and linting the code, actually run the tests and then report the
coverage.

Tox configuration file, `tox.ini`, defines the following sections:
- tox
- testenv
- your envs

In **tox** section, you specify the list of envs or tasks that will be run when calling `tox`:

```ini
[tox]
envlist =
    clean,
    check,
    {py27,py33,py34,py35,pypy},
    report
skip_missing_interpreters = true
```

For a Django app, you would also add envs to test with different versions of Django:

```ini
[tox]
envlist =
    clean,
    check,
    {py27,py34,py35}-django-18,
    {py27,py34,py35}-django-19,
    {py27,py34,py35}-django-110,
    report
skip_missing_interpreters = true
```

Here, clean will clean the directory, check will run different checking or linting tools on
your code and setup, and report will report the coverage data collected while running tests.

In **testenv** section, you specify the base configuration for one of your custom env:

```ini
[testenv]
setenv = PYTHONPATH={toxinidir}/tests
commands = {posargs:pytest --cov --cov-report=term-missing -vv tests/test_<PACKAGE>.py}
deps = -r{toxinidir}/requirements/test.txt
passenv = *
usedevelop = false
basepython =
    pypy: {env:TOXPYTHON:pypy}
    py27: {env:TOXPYTHON:python2.7}
    py33: {env:TOXPYTHON:python3.3}
    py34: {env:TOXPYTHON:python3.4}
    py35: {env:TOXPYTHON:python3.5}
    detox: python2.7
    {clean,check,report,coveralls,codecov}: python3.5
```


Then, you can specify the dependencies or commands to run for each one of your env. Here is the
`check` env:

```ini
[testenv:check]
deps =
    docutils
    check-manifest
    flake8
    readme-renderer
    pygments
    isort
    prospector[with_pyroma]
skip_install = true
commands =
    python setup.py check --strict --metadata --restructuredtext
    check-manifest {toxinidir}
    flake8 src tests setup.py
    isort --check-only --diff --recursive src tests setup.py
    prospector -0 {toxinidir}
```

This env will check that your setup.py and manifest are correct, and run flake8, isort and
prospector on your code.

On the command line, you can tell tox to run only of subset of envs with the `-e` option and
a comma-separated list of envs: `tox -e check`.

Tox's output will be in bold white on the command line.

#### detox
[detox][] will allow you to run tox's tests in parallel. It is really useful on a local machine
when you don't want to wait too much for tests to finish.

I like to define an additional env for detox like this:

```ini
[testenv:detox]
deps = detox
commands =
    detox -e clean,check,py27,py33,py34,py35,pypy
    tox -e report
```

You can then run detox with `tox -e detox`.

Indeed, running `detox` directly will try to run the `report` env in parallel with the other tests
(since it's listed in `[tox] envlist`), and it will fail. The detox env will run all the envs
except the report, and when they are all finish, run the report. Note that you must not add this
detox env into `[tox] envlist`, so you can still call `tox` normally.

#### check-manifest
[check-manifest][] will basically check that the files tracked by your CVS match the rules define
in MANIFEST.in.

#### flake8
[flake8][] will check that imports in your code are correctly used, and that your code respects
PEP8 standard, like line-length. flake8 is configurable through the `[flake8]` section in
the `setup.cfg` file. You can for example specify max line lenght, or exclude paths.

```ini
  [flake8]
  max-line-length = 79
  exclude = tests/*,*/migrations/*,*/south_migrations/*
```

#### isort
[isort][] will check that your imports are correctly ordered. It can even sort your imports
in-place, but here the tox check env just print the diff. isort is also configurable through the
`[isort]` section of `setup.cfg`. isort can understand different levels of import: future imports,
standard library, frameworks, third-party packages or libraries, dependencies, local modules, ...

```ini
[isort]
line_length=79
not_skip=__init__.py
skip=migrations,south_migrations
# django coding style would be 3 or 5
multi_line_output=4
force_single_line=False
balanced_wrapping=True
default_section=THIRDPARTY
forced_separate=test_<PACKAGE>
known_django=django
known_pandas=pandas,numpy
known_first_party=<PACKAGE>
sections=FUTURE,STDLIB,PANDAS,DJANGO,THIRDPARTY,FIRSTPARTY,LOCALFOLDER
```

#### prospector
[prospector][] is a combination of tools like [flake8][], [pylint][], [mccabe][], [pep257][],
[pyroma][], ...
Il will run all of these tools against your code and output a list of messages. The goal of
prospector here is only to display warnings, not block the tests from passing. The `-0` option
tells it to always return 0. The purpose is purely informational here. It is meant to be a list
of advices and warnings that you can fix to improve your code healt on Landscape.

prospector's configuration is located in `.landscape.yml` file. I like to set its strictness to
very high, and also warn for missing documentation. Here is an example of configuration:

```yaml
ignore-patterns:
  - (^|/)\..+
  - build/

strictness: veryhigh
autodetect: true
doc-warnings: true
test-warnings: true
member-warnings: false

# pylint:
#   disable:
#     - fixme
#     - bad-continuation
#     - invalid-name

#   options:
#     max-locals: 15
#     max-returns: 6
#     max-branches: 12
#     max-statements: 50
#     max-parents: 7
#     max-attributes: 7
#     min-public-methods: 2
#     max-public-methods: 20
#     max-module-lines: 1000
#     max-line-length: 79

# mccabe:
#   options:
#     max-complexity: 10

pep8:
  full: true
#   disable:
#     - E226
#     - E402
  options:
    max-line-length: 79
    single-line-if-stmt: n

# pyroma:
#   run: true
#   disable:
#     - PYR19
#     - PYR16

pep257:
  disable:
    - D203
```

#### pytest
pytest is a framework for testing Python code. You should take a look at the documentation:
<http://doc.pytest.org/en/latest/>.

#### coverage

### Testing services

#### Travis

#### Landscape

#### Codecov

### Testing scripts

#### Running Django tests

## Maintaining

### Maintaining tools

#### bumpversion

#### sphinx

### Maintaining services

#### PyPI

#### PyUp

#### Gitter

#### ReadTheDocs

### Maintaining scripts

#### Releasing

#### Updating template


[tox]:
[detox]:
[check-manifest]:
[coverage]:
[prospector]:
[flake8]:
[isort]:
[pytest]:

[pydjama]: https://github.com/Pawamoy/cookiecutter-pydjama
[pylibrary]: https://github.com/ionelmc/cookiecutter-pylibrary
[cookiecutter]: https://github.com/audreyr/cookiecutter

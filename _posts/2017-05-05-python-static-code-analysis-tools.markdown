---
layout: post
title: "Python static code analysis tools"
date: 2017-05-31 19:30:01
tags: python static code analysis tools
permalink: /:categories/:year/:month/:day/:title:output_ext
image: /assets/python-static-code-analysis-tools.png
---

Python static code analysis is often used in Continuous Integration.
I use it in every Python or Django package I develop,
into a [Tox][] configuration. The difficult part is to choose the right tools,
because there are many, and to configure them correctly.

Thankfully, there also are tools using other tools to reduce the amount
of configuration we have to do. This ends up in a big mix of tools, which
is represented in the following chart.

![Chart]({{ "/assets/python-static-code-analysis-tools.png" | absolute_url }})

In this post, we will see the advantages and disadvantages of these tools,
and compare them a bit.

<!--more-->
*Chart realized with Draw.io.*

## The "aggregator" tools
Some tools have a unique purpose, while others aim at doing more.
This is the case of [Prospector][], [Pylama][], [Pylint][] and [Flake8][].

I see two types of aggregators here:

1. the ones that do everything themselves (mostly): [Pylint][],
2. and the ones that combine the result of many smaller tools:
   [Prospector][], [Pylama][] and [Flake8][].

What is funny here is that both [Prospector][] and [Pylama][] use not only tools used
by [Pylint][], but [Pylint][] as well! There is a bit of overlap here.

### Pylint
What I like in [Pylint][] is its ability to rate your code, and keep a record
of its evolution, telling you if it has improved or regressed between
each run. I also love it's **Similar** tool, a one of its
kind, used to output the similarities in your code. You can run it with
`python -m pylint.checkers.similar FILES`.
It's very fast, but will start to take some time with a lot of files.

### Pylama
[Pylama][] seems not to have much activity since last year and has unresolved issues
and open pull requests. At the time of writing, it's [Pydocstyle][] integration
is broken. I also tried using it from Python because I wanted to count
the number of issues in some code, and was unsuccessful to do so.
Still, I used [Pylama][] for some time because I liked a lot how it can be
configured, directly in `setup.cfg`. Its options are simple to use
and simple to configure. I find ignoring warnings in [Pylama][] much more easier
than in [Prospector][], as they are all ignored on the same line, and are consistent
between them (only names composed of a letter and a code). [Pylama][] can also be
deactivated in specific locations of your code with comments like
`# pylama:ignore=D105,D106`, and recognizes `# noqa` comments.

### Prospector
[Prospector][] is my favorite here: I used it for quite some time before switching
to [Pylama][], and I'm back with it now. I was afraid that it was deperishing,
because maintainers did not seem to answer pull requests and fix broken
integration, but many fixes have been pushed now. I think it's a great project
and it deserves more activity!

What I like about [Prospector][] is that it uses many tools to check many things,
and it does it well: as I said earlier, there is some overlap between tools;
[Prospector][] handles that by keeping a record of similar warnings and only keep
one of each to avoid redundancy in its reports! This is not done by default
in [Pylama][], so you have to manually ignore redundant warnings in its
configuration.

[Prospector][] also helped me discover tools I never heard of before, like [Dodgy][],
[Vulture][], [Pyroma][] and [Frosted][]. I would like to see integrations for [Radon][]
(used by [Pylama][]) as it offers the same thing as [McCabe][] plus other stuff,
as well as for [Bandit][] which is a Python code security checker.

What I miss in [Prospector][] is the ability to configure it directly in
`setup.cfg`, which I enjoyed a lot with [Pylama][].

*This is another story but I am trying hard to reduce the number of configuration
files in my projects. I think tools should be able to find their configuration
files into a specific location of your project, not only in the root directory,
where configuration files pile up. I would be very happy to see some sort of
standard for configuration files location rising, just as what EditorConfig is
doing. Maybe a ConfigConfig standard? With a .configconfig file at the root of
the repository telling where to find the configuraton files, and tools being
able to read it, or by default search at the root or in the `config` folder?*

### Flake8
I don't have much to say about [Flake8][] here. I did try it some time ago,
but since [Prospector][] does what it does, I won't use it. But it's only my
personal choice and it can be a really good choice for others if they don't
need to run all the possible code analysis tools in the world (unlike me :D).

## The "do-one-thing-but-do-it-well" tools
Work in progress, coming soon!

Meanwhile, please share your thoughts! Did I say something wrong? Did I forget
great tools? Did I write *"tools"* to much?
I will gladly update the post with your sharings!

## Also worth noticing
Go check [Safety][] from [PyUp.io][], which check your requirements (dependencies)
for known-vulnerabilities! Also [Pyt][] for which I didn't take enough time
to understand what it does and how it works,
and great *Code Quality* web-services like [Landscape.io][] and [Codacy][]!

---

#### Links:

- Bandit: [https://github.com/openstack/bandit]()
- Codacy: [https://www.codacy.com/]()
- Dodgy: [https://github.com/landscapeio/dodgy]()
- Draw.io: [https://www.draw.io/]()
- Flake8: [https://github.com/PyCQA/flake8]()
- Frosted: [https://github.com/timothycrosley/frosted]()
- Landscape.io: [https://landscape.io/]()
- McCabe: [https://github.com/PyCQA/mccabe]()
- Prospector: [https://github.com/landscapeio/prospector]()
- Pydocstyle: [https://github.com/PyCQA/pydocstyle]()
- Pylama: [https://github.com/klen/pylama]()
- Pylint: [https://github.com/PyCQA/pylint]()
- Pyroma: [https://github.com/regebro/pyroma]()
- Pyt: [https://github.com/python-security/pyt]()
- PyUp.io: [https://pyup.io/]()
- Radon: [https://github.com/rubik/radon]()
- Safety: [https://github.com/pyupio/safety]()
- Tox: [https://github.com/tox-dev/tox]()
- Vulture: [https://github.com/jendrikseipp/vulture]()

[Bandit]: https://github.com/openstack/bandit
[Codacy]: https://www.codacy.com/
[Dodgy]: https://github.com/landscapeio/dodgy
[Draw.io]: https://www.draw.io/
[Flake8]: https://github.com/PyCQA/flake8
[Frosted]: https://github.com/timothycrosley/frosted
[Landscape.io]: https://landscape.io/
[McCabe]: https://github.com/PyCQA/mccabe
[Prospector]: https://github.com/landscapeio/prospector
[Pydocstyle]: https://github.com/PyCQA/pydocstyle
[Pylama]: https://github.com/klen/pylama
[Pylint]: https://github.com/PyCQA/pylint
[Pyroma]: https://github.com/regebro/pyroma
[Pyt]: https://github.com/python-security/pyt
[PyUp.io]: https://pyup.io/
[Radon]: https://github.com/rubik/radon
[Safety]: https://github.com/pyupio/safety
[Tox]: https://github.com/tox-dev/tox
[Vulture]: https://github.com/jendrikseipp/vulture

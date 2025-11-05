---
template: post.html
title: Sunsetting the Insiders program
date: 2025-10-24
authors:
  - Timothée Mazzucotelli
tags: funding sponsors sponsorships sponsorware strategy
---

In April 2023 I announced the launch of a sponsorware program called Insiders, for mkdocstrings and other projects of mine. After two years and a half, I reached a bit more than a thousand dollar in monthly sponsorships, meaning two goals were completed, the $500 and $1000 goals, and their 20 associated features and projects released to the public. Today I'm sunsetting the Insiders program, for a few reasons listed below.

<!--more-->

---

## What is the Insiders program?

The "Insiders" sponsorware strategy is an interesting approach to open-source projects funding, allowing authors/maintainers to work full-time on these projects, given enough monthly sponsorships. Sponsors fund new features, get immediate access when they are implemented, and the features eventually become available to everyone. Everybody wins: the software is maintained and grows, sponsors get something in return for their funding, all users eventually benefit from the exchange.

## Why do I sunset it?

This sponsorware strategy has a few drawbacks. First, it's quite a setup: twice as much repositories (public and private versions), which is OK when you maintain only one, but not when you maintain 10 or more. You must be careful with versioning (keeping private versions up-to-date with public ones), with CI (private repositories on GitHub don't have the same CI-minutes allowance), with compatibility (a configured Insiders feature must not crash a public version of the project and instead be a no-op), with documentation, etc.. Merging back private features into public projects is not trivial either. Using Git is almost impossible, unless you have the most disciplined Git history ever (which I don't). The best way to merge back features is basically to `cp -r private-project/* public-project/` and then stage the relevant features and associated tests, documentation, and other changes. It takes time and is error-prone.

Second, because it doesn't scale well. The more popular your projects get, the more user-support you have to do, like answering questions, triaging issues, updating documentation, etc.. And with this funding model, user-support stays free. Maybe a better approach would be to let users pay for support instead of funding features?

The complexity of the setup and the fact that it doesn't scale well is one reason I'm sunsetting the Insiders program. The other reason is that, even though some users and companies will start sponsoring you, you still have to promote yourself, reach out to companies, and do a bit of marketing if you want to get sponsorships, depending on the success/popularity of your project, and... that's not my cup of tea. I've always loved the programming side of things, and less the marketing one.

Another reason is that my most popular project, the one for which I get most of the sponsorships, is mkdocstrings (and its ecosystem). But mkdocstrings entirely relies on MkDocs, and MkDocs is unmaintained. This won't come as a surprise for some of you, who raised questions about its maintenance in the MkDocs discussions board. MkDocs hasn't seen a new release in more than a year now. Some critical issues remain unaddressed. I don't feel like MkDocs has a bright future anymore, and relying on it (both technically and financially) seems brittle.

## New endeavour

There's a new project that might have a brighter future though! It's called Zensical, led by the creator of Material for MkDocs together with his team. And I'm now part of Zensical's core team! My initial focus is bringing first-class API documentation functionality to Zensical, just like I did for MkDocs with mkdocstrings, and we plan to do much more together over time. I've been in touch with Martin for a long time and have followed Zensical's progress closely: I am amazed by the quality of his work and absolutely convinced Zensical is an S-tier project that will make you forget the alternatives. I won't say much more: go check [the announcement](https://squidfunk.github.io/mkdocs-material/blog/2025/11/05/zensical/) 🙂!

Another factor in sunsetting Insiders is a deliberate reallocation of my time: I believe my energy is better spent working as a team with Zensical's core contributors than continuing to invest in a stack that shows signs of stagnation. This isn't about a lack of time, it's about choosing the highest-impact work.

## What happens to mkdocstrings?

I'll be working at Zensical but I'll continue maintaining my open-source projects. Specifically, I'll keep maintaining mkdocstrings for something like a year at least, giving you time to try and switch to Zensical.

If you like my work regardless of mkdocstrings, you can of course continue to sponsor me and fund my open-source work.

---

**Thank you to all my current and past sponsors, especially Material for MkDocs, FastAPI, Pydantic Logfire and Quansight Labs!** All the features and projects listed below came to life thanks to you, as well as the countless bug fixes, documentation updates and all the maintenance of all my open-source projects. Thank you ❤️

## What we achieved

Two funding goals were reached, the $500 and $1000 per month goals. All the associated features and projects are already available to the public. The next two goals weren't reached. As I'm sunsetting the Insiders program, I will start releasing all their associated features and projects too. They should all be available to everyone in something like a week.

- [x] **$ 500 per month**
  - [mkdocstrings/griffe2md](https://mkdocstrings.github.io/griffe2md/) — [[Project] Output API docs to Markdown using Griffe](https://mkdocstrings.github.io/griffe2md/)
  - [mkdocstrings/griffe-inherited-docstrings](https://mkdocstrings.github.io/griffe-inherited-docstrings/) — [[Project] Griffe extension for inheriting docstrings](https://mkdocstrings.github.io/griffe-inherited-docstrings/)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Cross-references for type annotations in signatures](https://mkdocstrings.github.io/python/usage/configuration/signatures/#signature_crossrefs)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Symbol types in headings and table of contents](https://mkdocstrings.github.io/python/usage/configuration/headings/#show_symbol_type_toc)
  - [pawamoy/markdown-exec](https://pawamoy.github.io/markdown-exec/) — [Pyodide fence](https://pawamoy.github.io/markdown-exec/usage/pyodide/)
  - [pawamoy/mkdocs-manpage](https://pawamoy.github.io/mkdocs-manpage/) — [[Project] MkDocs plugin to generate a manpage from the documentation site](https://pawamoy.github.io/mkdocs-manpage/)
- [x] **$ 1,000 per month**
  - [mkdocstrings/griffe](https://mkdocstrings.github.io/griffe/) — [Markdown output format for the `griffe check` command](https://mkdocstrings.github.io/griffe/guide/users/checking/#markdown)
  - [mkdocstrings/griffe](https://mkdocstrings.github.io/griffe/) — [GitHub output format for the `griffe check` command](https://mkdocstrings.github.io/griffe/guide/users/checking/#github)
  - [mkdocstrings/griffe-pydantic](https://mkdocstrings.github.io/griffe-pydantic/) — [[Project] Griffe extension for Pydantic](https://mkdocstrings.github.io/griffe-pydantic/)
  - [mkdocstrings/griffe-tui](https://mkdocstrings.github.io/griffe-tui/) — [[Project] A textual user interface for Griffe](https://mkdocstrings.github.io/griffe-tui/)
  - [mkdocstrings/griffe-warnings-deprecated](https://mkdocstrings.github.io/griffe-warnings-deprecated/) — [[Project] Griffe extension for `@warnings.deprecated` (PEP 702)](https://mkdocstrings.github.io/griffe-warnings-deprecated/)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Auto-summary of object members](https://mkdocstrings.github.io/python/usage/configuration/members/#summary)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — Automatic rendering of function signature overloads
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Parameter headings](https://mkdocstrings.github.io/python/usage/configuration/headings/#parameter_headings)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Automatic cross-references to parameters](https://mkdocstrings.github.io/python/usage/configuration/headings/#parameter_headings)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — Automatic cross-references for default parameter values in signatures
  - [mkdocstrings/shell](https://mkdocstrings.github.io/shell/) — [[Project] Shell scripts/libraries handler for mkdocstrings](https://mkdocstrings.github.io/shell/)
  - [pawamoy/insiders-project](https://pawamoy.github.io/insiders-project/) — [[Project] Manage your Insiders projects](https://pawamoy.github.io/insiders-project/)
  - [pawamoy/markdown-pycon](https://pawamoy.github.io/markdown-pycon/) — [[Project] Markdown extension to parse `pycon` code blocks without indentation or fences](https://pawamoy.github.io/markdown-pycon/)
  - [pawamoy/pypi-insiders](https://pawamoy.github.io/pypi-insiders/) — [[Project] Self-hosted PyPI server with automatic updates for Insiders versions of projects](https://pawamoy.github.io/pypi-insiders/)
- [ ] **$ 1,500 per month**
  - [mkdocstrings/griffe](https://mkdocstrings.github.io/griffe/) — [Check API of Python packages from PyPI](https://mkdocstrings.github.io/griffe/guide/users/checking/#using-pypi)
  - [mkdocstrings/griffe](https://mkdocstrings.github.io/griffe/) — [Expressions modernization](https://mkdocstrings.github.io/griffe/guide/users/navigating/#modernization)
  - [mkdocstrings/griffe](https://mkdocstrings.github.io/griffe/) — [Automatic detection of docstring style](https://mkdocstrings.github.io/griffe/reference/docstrings/#auto-style)
  - [mkdocstrings/griffe-autodocstringstyle](https://mkdocstrings.github.io/griffe-autodocstringstyle/) — [[Project] Set docstring style to `auto` for external packages](https://mkdocstrings.github.io/griffe-autodocstringstyle/)
  - [mkdocstrings/griffe-public-redundant-aliases](https://mkdocstrings.github.io/griffe-public-redundant-aliases/) — [[Project] Mark objects imported with redundant aliases as public](https://mkdocstrings.github.io/griffe-public-redundant-aliases/)
  - [mkdocstrings/griffe-public-wildcard-imports](https://mkdocstrings.github.io/griffe-public-wildcard-imports/) — [[Project] Mark wildcard imported objects as public](https://mkdocstrings.github.io/griffe-public-wildcard-imports/)
  - [mkdocstrings/griffe-runtime-objects](https://mkdocstrings.github.io/griffe-runtime-objects/) — [[Project] Make runtime objects available through `extra`](https://mkdocstrings.github.io/griffe-runtime-objects/)
  - [mkdocstrings/griffe-sphinx](https://mkdocstrings.github.io/griffe-sphinx/) — [[Project] Parse Sphinx-comments above attributes as docstrings](https://mkdocstrings.github.io/griffe-sphinx/)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Class inheritance diagrams with Mermaid](https://mkdocstrings.github.io/python/usage/configuration/general/#show_inheritance_diagram)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Annotations modernization](https://mkdocstrings.github.io/python/usage/configuration/signatures/#modernize_annotations)
  - [pawamoy/devboard](https://pawamoy.github.io/devboard/) — [[Project] A development dashboard for your projects](https://pawamoy.github.io/devboard/)
  - [pawamoy/markdown-exec](https://pawamoy.github.io/markdown-exec/) — [Custom icons in tree fences](https://pawamoy.github.io/markdown-exec/usage/tree/#custom-icons)
  - [pawamoy/mkdocs-pygments](https://pawamoy.github.io/mkdocs-pygments/) — [[Project] Highlighting themes for code blocks](https://pawamoy.github.io/mkdocs-pygments/)
- [ ] **$ 2,000 per month**
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Relative cross-references](https://mkdocstrings.github.io/python/usage/configuration/docstrings/#relative_crossrefs)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Scoped cross-references](https://mkdocstrings.github.io/python/usage/configuration/docstrings/#scoped_crossrefs)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Backlinks](https://mkdocstrings.github.io/python/usage/configuration/general/#backlinks)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Filtering method: `public`](https://mkdocstrings.github.io/python/usage/configuration/members/#option-filters-public)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — [Ordering method: `__all__`](https://mkdocstrings.github.io/python/usage/configuration/members/#option-members_order)
  - [mkdocstrings/python](https://mkdocstrings.github.io/python/) — Visually-lighter source code blocks

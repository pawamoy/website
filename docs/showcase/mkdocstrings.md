# mkdocstrings

![mkdocstrings](../assets/mkdocstrings.gif)

- Repository: https://github.com/mkdocstrings/mkdocstrings
- Documentation: https://mkdocstrings.github.io/

---

A few years ago (around 2020), I bumped into the [Pydantic](https://docs.pydantic.dev/latest/) project (again). I had already seen it before, mainly interested in its settings configuration ability that could replace most of the logic in my Django app
[django-appsettings](https://github.com/pawamoy/django-appsettings). This time, when I landed on its docs pages, I thought: "wow, this looks nice". Then, a bit later, [FastAPI](https://fastapi.tiangolo.com/) exploded in our faces, and I thought again: "hey, looks familiar, and I love it!". So I looked around and saw that it used [MkDocs](https://www.mkdocs.org/) and a theme called "[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)".

I started migrating my projects to MkDocs and Material for MkDocs from [Sphinx](https://www.sphinx-doc.org/en/master/), because it looked nicer than the [ReadTheDocs](https://docs.readthedocs.io/en/stable/) theme, and was far easier to use. Indeed, for the six previous years I had been using Sphinx for my projects documentation, and I never quite enjoyed writing docs with it.
This was before the [MyST parser](https://myst-parser.readthedocs.io/en/latest/) or [recommonmark](https://github.com/readthedocs/recommonmark) (which I used a bit later), so I was writing my documentation in [reStructuredText](https://www.writethedocs.org/guide/writing/reStructuredText/).
I constantly had to check the syntax of rST and the Sphinx docs to achieve basic things. In particular, I wanted to have ToC (Table of Contents) entries in the sidebar for every documented module, class or function auto-generated with Sphinx's autodoc extension. I posted [a question on StackOverflow](https://github.com/sphinx-doc/sphinx/issues/6316) and then found a [feature request](https://github.com/sphinx-doc/sphinx/issues/6316) on Sphinx's bugtracker: the answer was "it's not possible (yet)".

So I thought, hey, why not bring that to MkDocs instead of Sphinx? At the time, the only viable option for autodoc in MkDocs was Tom Christie's [mkautodoc](https://github.com/tomchristie/mkautodoc).
Tom expressed his lack of capacity to work on the project, and I had an itch to scratch, so I decided to create my own MkDocs plugin for auto-documentation. This is how [mkdocstrings](https://mkdocstrings.github.io/) was born. Tom's code has been very helpful at the beginning of the project (mkdocstrings' `:::` syntax actually comes from mkautodoc), so thanks Tom!

Today mkdocstrings supports four languages (Crystal, Python, VBA and shell scripts) and will soon have support for more (TypeScript). In the future, with the help of my sponsors funding my work, I would like to support many more languages! Something I'm super proud of is that the two projects that initially made me want to create mkdocstrings, Pydantic and FastAPI, are now using it for their own docs 🎉

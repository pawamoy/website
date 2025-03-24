---
hide:
  - navigation
---

# Insiders

I develop open-source software, primarily Python tools and libraries. I do this full time: I earn my keep through sponsorship from individual users and companies, which is what makes these projects sustainable and gives you a chance to use them.

I follow a sponsorware release strategy: new features are at first exclusively available to sponsors. Read on to learn [what sponsorships achieve][sponsorship], how to [become a sponsor][sponsors] to get access to Insiders, and [what's in it for you][features]!

```python exec="1" session="insiders"
data_source = [
    (
        "mkdocstrings/griffe",
        "https://mkdocstrings.github.io/griffe/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe2md",
        "https://mkdocstrings.github.io/griffe2md/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-autodocstringstyle",
        "https://mkdocstrings.github.io/griffe-autodocstringstyle/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-inherited-docstrings",
        "https://mkdocstrings.github.io/griffe-inherited-docstrings/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-public-redundant-aliases",
        "https://mkdocstrings.github.io/griffe-public-redundant-aliases/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-public-wildcard-imports",
        "https://mkdocstrings.github.io/griffe-public-wildcard-imports/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-pydantic",
        "https://mkdocstrings.github.io/griffe-pydantic/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-runtime-objects",
        "https://mkdocstrings.github.io/griffe-runtime-objects/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-sphinx",
        "https://mkdocstrings.github.io/griffe-sphinx/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-tui",
        "https://mkdocstrings.github.io/griffe-tui/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-typedoc",
        "https://mkdocstrings.github.io/griffe-typedoc/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/griffe-warnings-deprecated",
        "https://mkdocstrings.github.io/griffe-warnings-deprecated/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/c",
        "https://mkdocstrings.github.io/c/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/python",
        "https://mkdocstrings.github.io/python/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/shell",
        "https://mkdocstrings.github.io/shell/",
        "insiders/goals.yml",
    ),
    (
        "mkdocstrings/typescript",
        "https://mkdocstrings.github.io/typescript/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/devboard",
        "https://pawamoy.github.io/devboard/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/insiders-project",
        "https://pawamoy.github.io/insiders-project/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/markdown-exec",
        "https://pawamoy.github.io/markdown-exec/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/markdown-pycon",
        "https://pawamoy.github.io/markdown-pycon/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/mkdocs-manpage",
        "https://pawamoy.github.io/mkdocs-manpage/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/mkdocs-pygments",
        "https://pawamoy.github.io/mkdocs-pygments/",
        "insiders/goals.yml",
    ),
    (
        "pawamoy/pypi-insiders",
        "https://pawamoy.github.io/pypi-insiders/",
        "insiders/goals.yml",
    ),
]
descriptions = {
    "mkdocstrings/griffe": "Signatures for entire Python programs. Generate API documentation or find breaking changes in your API.",
    "mkdocstrings/griffe2md": "Output API docs to Markdown using Griffe.",
    "mkdocstrings/griffe-autodocstringstyle": "Set docstring style to `auto` for external packages.",
    "mkdocstrings/griffe-inherited-docstrings": "Griffe extension for inheriting docstrings.",
    "mkdocstrings/griffe-public-redundant-aliases": "Mark objects imported with redundant aliases as public.",
    "mkdocstrings/griffe-public-wildcard-imports": "Mark wildcard imported objects as public.",
    "mkdocstrings/griffe-pydantic": "Griffe extension for Pydantic.",
    "mkdocstrings/griffe-runtime-objects": "Make runtime objects available through `extra`.",
    "mkdocstrings/griffe-sphinx": "Parse Sphinx-comments above attributes as docstrings.",
    "mkdocstrings/griffe-tui": "A textual user interface for Griffe.",
    "mkdocstrings/griffe-typedoc": "Signatures for entire TypeScript programs using TypeDoc.",
    "mkdocstrings/griffe-warnings-deprecated": "Griffe extension for `@warnings.deprecated` (PEP 702).",
    "mkdocstrings/c": "A C handler for mkdocstrings.",
    "mkdocstrings/python": "A Python handler for mkdocstrings.",
    "mkdocstrings/shell": "A shell scripts/libraries handler for mkdocstrings.",
    "mkdocstrings/typescript": "A TypeScript handler for mkdocstrings.",
    "pawamoy/devboard": "A development dashboard for your projects.",
    "pawamoy/insiders-project": "Manage your Insiders projects.",
    "pawamoy/markdown-exec": "Utilities to execute code blocks in Markdown files.",
    "pawamoy/markdown-pycon": "Markdown extension to parse `pycon` code blocks without indentation.",
    "pawamoy/mkdocs-manpage": "MkDocs plugin to generate a manpage from the documentation site.",
    "pawamoy/mkdocs-pygments": "Highlighting themes for code blocks.",
    "pawamoy/pypi-insiders": "Self-hosted PyPI server with automatic updates for Insiders versions.",
}
public = {
    "mkdocstrings/griffe": True,
    "mkdocstrings/griffe2md": True,
    "mkdocstrings/griffe-autodocstringstyle": False,
    "mkdocstrings/griffe-inherited-docstrings": True,
    "mkdocstrings/griffe-public-redundant-aliases": False,
    "mkdocstrings/griffe-public-wildcard-imports": False,
    "mkdocstrings/griffe-pydantic": True,
    "mkdocstrings/griffe-runtime-objects": False,
    "mkdocstrings/griffe-sphinx": False,
    "mkdocstrings/griffe-tui": True,
    "mkdocstrings/griffe-typedoc": True,
    "mkdocstrings/griffe-warnings-deprecated": True,
    "mkdocstrings/c": False,
    "mkdocstrings/python": True,
    "mkdocstrings/shell": True,
    "mkdocstrings/typescript": True,
    "pawamoy/devboard": False,
    "pawamoy/insiders-project": True,
    "pawamoy/markdown-exec": True,
    "pawamoy/markdown-pycon": True,
    "pawamoy/mkdocs-manpage": True,
    "pawamoy/mkdocs-pygments": False,
    "pawamoy/pypi-insiders": True,
}
```

```python exec="1" session="insiders"
--8<-- "scripts/insiders.py"
```

## What is Insiders?

Insiders are private forks of my projects, hosted as private GitHub repositories. Almost[^1] [all new features][features] are developed as part of these forks, which means that they are immediately available to all eligible sponsors, as they are made members of these repositories.

Every feature is tied to a [funding goal][funding] in monthly subscriptions. When a funding goal is hit, the features that are tied to it are merged back into the public projects and released for general availability, making them available to all users. Bugfixes are always released in tandem.

Sponsorships start as low as [**$10 a month**][sponsors].[^2]

## What sponsorships achieve

Sponsorships make these projects sustainable, as they buy the maintainers of these projects time – a very scarce resource – which is spent on the development of new features, bug fixing, stability improvement, issue triage and general support. The biggest bottleneck in Open Source is time.[^3]

If you're unsure if you should sponsor my projects, check out the list of [completed funding goals][goals completed] to learn whether you're already using features that were developed with the help of sponsorships. You're most likely using at least a handful of them, [thanks to our awesome sponsors][sponsors]!

## What's in it for me?

```python exec="1" session="insiders"
print(f"""The moment you <a href="#how-to-become-a-sponsor">become a sponsor</a>, you'll get **immediate
access to {len(unreleased_features)} additional features** that you can start using right away, and
which are currently exclusively available to sponsors:\n""")

for feature in unreleased_features:
    feature.render(badge=True)
```

---

### *mkdocstrings* projects

[*mkdocstrings*](https://mkdocstrings.github.io) is a plugin for [MkDocs](https://www.mkdocs.org/), a static site generator written in Python. It brings autodoc capabilities to MkDocs, to enable automatic and configurable documentation of Python APIs.

```python exec="1" session="insiders"
print(project_cards("mkdocstrings/"))
```

### Other tools/libraries

These tools are focused on documentation, developer-experience and productivity.

```python exec="1" session="insiders"
print(project_cards("pawamoy/"))
```

## How to become a sponsor

Thanks for your interest in sponsoring! In order to become an eligible sponsor with your GitHub account, visit [pawamoy's sponsor profile][github sponsor profile], and complete a sponsorship of **$10 a month or more**. You can use your individual or organization GitHub account for sponsoring.

Sponsorships lower than $10 a month are also very much appreciated! They won't grant you access to Insiders, but they will be counted towards reaching sponsorship goals. *Every* sponsor helps us implementing new features and releasing them to the public.

**Important**: If you're sponsoring **[@pawamoy][github sponsor profile]** through a GitHub organization, please send a short email to insiders@pawamoy.fr with the name of your organization and the GitHub account of the individual that should be added as a collaborator.[^4]

You can cancel your sponsorship anytime.[^5]

[:octicons-heart-fill-24:{ .pulse } &nbsp; Join our <span id="sponsors-count"></span> awesome sponsors](https://github.com/sponsors/pawamoy){ .md-button .md-button--primary }

<hr>
<div class="premium-sponsors">
  <div id="gold-sponsors"></div>
  <div id="silver-sponsors"></div>
  <div id="bronze-sponsors"></div>
</div>
<hr>

<div id="sponsors"></div>

<small>
  If you sponsor publicly, you're automatically added here with a link to
  your profile and avatar to show your support for my projects.
  Alternatively, if you wish to keep your sponsorship private, you'll be a
  silent +1. You can select visibility during checkout and change it
  afterwards.
</small>

## Funding <span class="sponsors-total"></span>

### Goals

The following section lists all funding goals. Each goal contains a list of features prefixed with a checkmark symbol, denoting whether a feature is :octicons-check-circle-fill-24:{ style="color: #00e676" } already available or :octicons-check-circle-fill-24:{ style="color: var(--md-default-fg-color--lightest)" } planned, but not yet implemented. When the funding goal is hit, the features are released for general availability.

```python exec="1" session="insiders" idprefix=""
for goal in goals.values():
    if not goal.complete:
        goal.render()
```

### Goals completed

This section lists all funding goals that were previously completed, which means that those features were part of Insiders, but are now generally available and can be used by all users.

```python exec="1" session="insiders" idprefix=""
for goal in goals.values():
    if goal.complete:
        goal.render()
```

## Frequently asked questions

### Payment

> We don't want to pay for sponsorship every month. Are there any other options?

Yes. You can sponsor on a yearly basis by [switching your GitHub account to a yearly billing cycle][billing cycle]. If for some reason you cannot do that, you could also create a dedicated GitHub account with a yearly billing cycle, which you only use for sponsoring (some sponsors already do that).

If you have any problems or further questions, please reach out to insiders@pawamoy.fr.

### Terms

> Are we allowed to use Insiders under the same terms and conditions as the public project?

Yes. Whether you're an individual or a company, you may use the Insiders versions precisely under the same terms as the public versions, which are generally given by the [ISC License][license]. However, we kindly ask you to respect our **fair use policy**:

- Please **don't distribute the source code** of Insiders. You may freely use it for public, private or commercial projects, privately fork or mirror it, but please don't make the source code public, as it would counteract the sponsorware strategy.

- If you cancel your subscription, you're automatically removed as a collaborator and will miss out on all future updates of Insiders. However, you may **use the latest version** that's available to you **as long as you like**. Just remember that [GitHub deletes private forks][private forks].

<script src="../js/insiders.js"></script>

<script>updateInsidersPage('pawamoy');</script>

[^1]: In general, every new feature is first exclusively released to sponsors, but sometimes upstream dependencies enhance existing features that must be supported.

[^2]: Note that $10 a month is the minimum amount to become eligible for Insiders. While GitHub Sponsors also allows to sponsor lower amounts or one-time amounts, those can't be granted access to Insiders due to technical reasons. Such contributions are still very much welcome as they help ensuring the project's sustainability.

[^3]: Making an Open Source project sustainable is exceptionally hard: maintainers burn out, projects are abandoned. That's not great and very unpredictable. The sponsorware model ensures that if you decide to use my Insiders projects, you can be sure that bugs are fixed quickly and new features are added regularly.

[^4]: It's currently not possible to grant access to each member of an organization, as GitHub only allows for adding users. Thus, after sponsoring, please send an email to insiders@pawamoy.fr, stating which account should become a collaborator of the Insiders repository. We're working on a solution which will make access to organizations much simpler. To ensure that access is not tied to a particular individual GitHub account, create a bot account (i.e. a GitHub account that is not tied to a specific individual), and use this account for the sponsoring. After being added to the list of collaborators, the bot account can create a private fork of the private Insiders GitHub repository, and grant access to all members of the organizations.

[^5]: If you cancel your sponsorship, GitHub schedules a cancellation request which will become effective at the end of the billing cycle. This means that even though you cancel your sponsorship, you will keep your access to Insiders as long as your cancellation isn't effective. All charges are processed by GitHub through Stripe. As we don't receive any information regarding your payment, and GitHub doesn't offer refunds, sponsorships are non-refundable.

[billing cycle]: https://docs.github.com/en/github/setting-up-and-managing-billing-and-payments-on-github/changing-the-duration-of-your-billing-cycle
[features]: #whats-in-it-for-me
[funding]: #funding
[github sponsor profile]: https://github.com/sponsors/pawamoy
[goals completed]: #goals-completed
[license]: https://spdx.org/licenses/ISC.html
[private forks]: https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/removing-a-collaborator-from-a-personal-repository
[sponsors]: #how-to-become-a-sponsor
[sponsorship]: #what-sponsorships-achieve

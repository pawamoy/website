---
template: post.html
title: A survey of deprecation-related Python libraries
date: 2026-02-15
authors:
  - Timothée Mazzucotelli
tags: deprecation python library survey
---

In this post I try to explain what is a code deprecation, why we deprecate code, and how we do it. Then I survey existing Python libraries that make it easer to deprecate code, make a comparative table of their features, and then expand on what I think we could do better. This post will touch to static analysis, runtime warnings, type-checkers, editors, public APIs, code maintenance and how deprecations fit into all that.

<!--more-->

## What are deprecations, and why are they used

NOTE: **TL;DR** Projects depend on libraries, libraries expose public APIs which eventually evolve in incompatible ways, authors create deprecation periods to inform users of upcoming incompatible changes. [Skip to next section ->](#)

Library authors expose programming interfaces to their users. That is what we generally call APIs (Application Programming Interfaces). That is what lets one programmer make use of what another programmer created. The different parts of an API can have different visibility kinds: private, internal, public... In this post we will focus on the public part of APIs or, in short, public APIs.

Each bit of a public API is exposed to its users with a specific intent by the library authors. Library users hook into these interfaces with specific expectations. Their understanding of the exposed interface might match the intent of the authors, or differ from it.

To make sure they are on the same page, authors provide their users with documentation and contracts. Documentation can be provided in many different forms:

- comments in the source code
- standardized comments or strings that tools can parse for display in other places (editors, HTML documentation)
- hand-written documentation (erm) available in the sources or published on the web

One form isn't better than the other: they complete each other.

Contracts are generally provided through the programming language itself. Depending on the language, library authors can annotate their code to give more information to users and tools. For example, function parameters can be annotated with the types they expect, or accept, so that users know what values they can, or should pass, and for compilers or interpreters to optimize byte-code, emit compilation or runtime warnings and errors, etc.. Contracts are, in a way, yet another form of documentation.

When the language itself is lacking in this regard, conventions emerge from ecosystems, in the form of popular third-party libraries, commonly accepted naming or architecture patterns, etc. Sometimes these conventions make their way back into the language, as new standards or features.

Most library authors use versioning strategies ([CalVer](https://calver.org/), [SemVer](https://semver.org/)) to be able to update their libraries while giving time to their users to catch up. Some users will upgrade quickly to the latest versions, while others will stay longer on older versions. One common expectation from library users is that public APIs should stay compatible (stable) between versions, meaning that they can continue using the library with the same interface, even when they upgrade to later versions.

Obviously, with organic development, a library is guaranteed to break its interface from time to time, just to adapt to the ever-evolving ecosystem around it. To reduce the occurrences of the interface changing in incompatible ways, library authors often choose to maintain several variations of their interface at once, and this across several versions of their library. Such temporization lets authors pack several incompatible changes at once, in major version updates. These major updates are described as "breaking".

Since maintenance of public API variations across many versions is costly (it slows down or even prevent development of new features, requires testing, documentation and user support), a common expectation from library authors is that their users must eventually upgrade (and the sooner the better) to newer versions, so that they (the authors) can get rid of old compatibility layers, maintaining their code base in good shape.

To facilitate the migration to newer versions by users of the library, and to ensure their use of the library stays correct and up-to-date, library authors can opt into **deprecating** (finally!) specific parts of their public API. **Deprecations** are pending revisions of the contract provided to users. They are (they must be) accompanied by relevant documentation updates, too.

Depending on the language or ecosystem, library authors have languages constructs, standards or third-party libraries at their disposal to mark parts of their public API as deprecated. These deprecated parts are later changed in incompatible ways, or simply removed. Authors can optionally inform their users of *when* this will happen (be it with a version number, a time estimation, a specific date, etc.).

## The Python case

When developing Python libraries, authors have a few tools on hand to deprecate parts of their APIs. But before diving into a review of these tools, let us ask ourselves: what *are* these API parts? And what is a *good* deprecation in a Python library? What purpose should it serve, apart from informing direct users of upcoming breaking changes?

Here is what I think. A good deprecation:

- [ ] tells users about the deprecated use
- [ ] tells users about the *new* use, if any
- [ ] tells users when to expect the breaking change (or removal) to happen
- [ ] tells users how to migrate
- [ ] allows tooling to apply that migration automatically in user code bases
- [ ] allows tooling to remove/update the deprecated code when ready
- [ ] can be logged at runtime
- [ ] can be displayed in editors
- [ ] can be reported by linters or test runners
- [ ] most essentially, can be easily surfaced back to the right person (more on that later)

Now, what parts of an API should we be able to deprecate? This is really specific to each project and what they consider part of their public API, but if we had to try and list every possible thing, this would be:

- [ ] symbol names
- [ ] symbol locations (from where we import/access them)
- [ ] modules, functions, classes, methods, attributes, type aliases
- [ ] function (method) parameters
    - [ ] their kind (positional-only, etc.)
    - [ ] their position if relevant
    - [ ] their accepted type (more on that below)
    - [ ] their default value, or the presence of a default value
- [ ] function returned values (their type)
- [ ] function/class type parameters? their names?
- [ ] attribute values?
- [ ] raised exceptions? their messages?
- [ ] class bases?
- [ ] any symbol's type?
- [ ] any symbol's kind (e.g. class vs. function)?
- [ ] emitted warnings? their messages?
- [ ] emitted logs? their messages? their logger name?
- [ ] can you think of anything else?

Now let's see what existing Python tooling can do with each of these items.

### Standard library

[Python's standard library](https://docs.python.org/3/library/index.html) provides a few things to help library authors deprecate code.

The first one is the [warning system](https://docs.python.org/3/library/warnings.html#module-warnings). This system allows library authors to issue warnings during the execution of the code. These warnings are printed in the console. Users (developers and end-users) can filter these warnings, to only print the ones they are interested in, or turn them into actual errors that stop execution.

The system provides a dozen warning "categories", in the form of classes, that library authors can subclass if they need to define new categories.

These warnings can be about many things (it's really up to the library authors how to use them and what to warn about), but here we are interested in the following categories:

- [`DeprecationWarning`](https://docs.python.org/3/library/exceptions.html#DeprecationWarning):

    > Base category for warnings about deprecated features when those warnings are intended for other Python developers (ignored by default, unless triggered by code in `__main__`).

    The category we are most interested in. It is used to communicate to users of your code (and by users of your code, I mean developers, not end-users) that a specific part of your public API they are using is actually deprecated and will either change in an incompatible manner or be removed in the future.

    We will see how the target here, developers, relates to our earlier mention of "surfacing deprecations to the right person", and how the standard library's warning system lacks in this regard.

- [`PendingDeprecationWarning`](https://docs.python.org/3/library/exceptions.html#PendingDeprecationWarning):

    > Base category for warnings about features that will be deprecated in the future (ignored by default).

    A more gentle warning, informing developers that the part of your public API they are using will become deprecated (but is not yet deprecated).

    >? NOTE: **Nerd-snipe** I often wonder about the utility of this category: if you are able to deprecate a specific part of your public API, in the sense that it still works, but the API provides a newer/better interface (or not), then why the need for a *pending* deprecation warning? Can't you just wait for the deprecation to be implemented, and then issue a regular deprecation warning? Maybe it's about giving library authors the possibility to warn their users about their plans of deprecating something, before actually deprecating it, because deprecating it requires some work (implementation of a newer API, initial decoupling for easier removal later, etc.)? My own projects are maybe not popular enough to warrant the use of pending deprecation warnings!
    >
    > Searching on GitHub, I found more occurrences of code filtering them out than using them to warn. The few occurrences that did issue pending deprecation warnings showed that the replacement was already present (in this case why not issue a deprecation warning directly?) or stated that the code was deprecated (so, why pending?).
    >
    > [From Antoine Pitrou on discuss.python.org](https://discuss.python.org/t/pendingdeprecationwarning-is-really-useful/1038/3):
    >
    > > [As far as I can understand] it was useful when DeprecatingWarning was visible by default. But at some point it was decided that DeprecatingWarning would be hidden by default (as PendingDeprecationWarning already was), and now it’s not clear anymore why we have two separate categories.
    >
    > Other comments in this thread seem to imply this was useful for features in Python's standard library itself (and so maybe only designed for it).
    >
    > By the way the [documentation](https://docs.python.org/3/library/exceptions.html#PendingDeprecationWarning) states:
    >
    > > Base class for warnings about features which are obsolete and expected to be deprecated in the future, but are not deprecated at the moment.
    >
    > ...which doesn't make sense for a french reader as myself since we translate "deprecated" with "obsolète", turning the sentence into:
    >
    > > ...features which are obsolete and expected to be obsolete in the future, but are not yet obsolete at the moment.
    >
    > [Some definitions on the web say](https://www.askdifference.com/deprecated-vs-obsolete/):
    >
    > > Deprecated involves discouraging use due to better alternatives or drawbacks, often remaining supported, while obsolete refers to being out of use, outdated, and unsupported.
    >
    > ...so IMO the definition for the category got it reversed. Code is deprecated before it is obsolete, not the other way around.

- [`FutureWarning`](https://docs.python.org/3/library/exceptions.html#FutureWarning):

    > Base category for warnings about deprecated features when those warnings are intended for end users of applications that are written in Python.

    As clearly explained, this warning is intended for end-users of a program. For example, when a *field in a configuration file* is deprecated, the library author should issue a `FutureWarning` instead of a `DeprecationWarning`, since end-users should know about it, and only them (not the possible intermediate libraries that make use of the configuration file loading code).

We see that `DeprecationWarning` is hidden by default, because it's targetted at developers, and `FutureWarning` is shown by default, because it's targetted at end-users. Developers can of course configure their project to show deprecation warnings too, in order to fix them while it's still time (before any breaking change / removal).

While this seems to cover all use-cases in theory, in practice the reality is more complex, and the hidden-by-default nature of deprecation warnings causes some friction in the Python ecosystem. I write about this in more details in the [Surfacing](#surfacing) section.

So, can we use the warning system to tick a few boxes in [our lists above](#the-python-case)?

For symbol names and locations, one can use another mechanism, the `__getattr__` module-level function:

```python
import warnings


class NewName:
    pass


def __getattr__(name: str):
    if name == "OldName":
        warnings.warn(
            "OldName was renamed NewName, please use the new name.",
            DeprecationWarning,
        )
        return NewName
```

- [x] symbol names

```python title="in <code>pkg/old_module.py</code>"
import warnings


def __getattr__(name: str):
    if name == "Location":
        warnings.warn(
            "pkg.old_module.Location was moved to pkg.new_module.Location, "
            "please use the new location to import it.",
            DeprecationWarning,
        )
        from pkg.new_module import Location
        return Location
```

- [x] symbol locations

---

Modules can emit a warning at import time:

```python
import warnings


warnings.warn(
    "Module pkg.module is deprecated, "
    "import from pkg directly instead.",
    DeprecationWarning,
)
```

- [x] modules

---

Classes can emit a warning at instantiation time, though that doesn't take into account class methods or static methods that don't also instantiate the class.

```python
import warnings


class Old:
    def __init__(self):
        warnings.warn(
            "Class Old is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )

    @classmethod
    def m1(cls):
        # no warning when we call this method

    @staticmethod
    def m2():
        # no warning when we call this method
```

To palliate to this, we could rename the class and rely on a module-level `__getattr__` again, so that merely importing the class emits a warning:

```python
import warnings


class _Old:
    pass


def __getattr__(name: str):
    if name == "Old"
        warnings.warn(
            "Class Old is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return _Old
```

- [x] classes

---

Functions, methods, and other things that eventually get called can emit a deprecation warning when they are called.

```python
import warnings


def old_function():
    warnings.warn(
        "Function old_function is deprecated, "
        "and will be removed in a future version.",
        DeprecationWarning,
    )


class Thing:
    @property
    def old_property(self):
        warnings.warn(
            "Property Thing.old_property is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return self._thing
```

- [x] functions, methods, properties

---

Module-level attributes (variables, constants) can be renamed and re-accessed through `__getattr__` again:

```python
import warnings


_old_variable = 0


def __getattr__(name: str):
    if name == "old_variable":
        warnings.warn(
            "Attribute old_variable is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return _old_variable
```

Instance-level attributes can be hidden behind properties:

```python
import warnings


class Thing:
    def __init__(self):
        self._old_field = 0

    @property
    def old_field(self) -> int:
        warnings.warn(
            "Attribute old_field is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return self._old_field
```

Class-level attributes are a bit more difficult to deprecate. We need to do it at the metaclass level:

```python
import warnings


class _ThingMetaclass(type):
    @property
    def bar(self):
        warnings.warn(
            "Attribute bar is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return self._bar


class Thing(metaclass=_ThingMetaclass):
    _bar = 0
```

When using [descriptors](https://docs.python.org/3/howto/descriptor.html), this becomes easier again:

```python
import warnings


class _Bar:
    def __get__(self, obj, objtype=None):
        warnings.warn(
            "Attribute bar is deprecated, "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
        return 10


class Thing:
    bar = _Bar()
```

- [x] attributes

---

Type aliases behave like any other attribute, so we got this covered.

- [x] type aliases

---

Next we have function parameters. Some cases can be straight-forward, while some others can be very convoluted, but all of them can be handled.

When the whole parameter is deprecated, one can use a sentinel to check if a value was passed.

```python
import warnings

_sentinel = object()


def function(param: int = _sentinel):
    if param is not _sentinel:
        warnings.warn(
            "Parameter `param` is deprecated "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
```

If the parameter already had a default value, one can still use it in place of the sentinel:

```python
import warnings

_sentinel = object()


def function(param: int = _sentinel):
    if param is not _sentinel:
        warnings.warn(
            "Parameter `param` is deprecated "
            "and will be removed in a future version.",
            DeprecationWarning,
        )
    else:
        param = 0  # previous default value
```

Things get a bit more complicated when the deprecated parameter is followed by other parameters without default values (as Python doesn't allow a parameter with a default value to be followed by a parameter without one). For these cases, it is always possible to swallow positional parameters with `*args` and keyword parameters with `**kwargs`. A few examples:

=== "positional-only"

    ```python title="before"
    # your parameters are positional-only parameters
    def greet(prefix: str, name: str, /):
        print(prefix, name)

    greet("hello", "world")
    ```

    ```python title="after"
    # swallow prefix using a variadic positional parameter
    def greet(*args):
        if len(args) == 2:
            prefix, name = args
        elif len(args) == 1:
            prefix = None
            name = args[0]
        else:
            raise TypeError("greet() missing 1 required positional parameter: 'name'")
        if prefix is not None:
            warnings.warn(
                "Parameter `prefix` is deprecated, "
                "and will be removed in a future version.",
                DeprecationWarning,
            )
        print(prefix or "hello", name)

    # still working as expected
    greet("hello", "world")
    ```

=== "keyword-only"

    ```python title="before"
    # your parameters are keyword-only parameters
    def greet(*, prefix: str, name: str):
        print(prefix, name)

    greet(prefix="hello", name="world")
    ```

    ```python title="after"
    # swallow prefix using a variadic keyword parameter
    def greet(name: str, **kwargs):
        prefix = kwargs.get("prefix", None)
        if prefix is not None:
            warnings.warn(
                "Parameter `prefix` is deprecated, "
                "and will be removed in a future version.",
                DeprecationWarning,
            )
        print(prefix or "hello", name)

    # still working as expected
    greet(prefix="hello", name="world")
    ```

=== "positional or keyword"

    ```python title="before"
    # your parameters are positional or keyword parameters
    def greet(prefix: str, name: str):
        print(prefix, name)

    greet("hello", name="world")
    ```

    ```python title="after"
    # no other choice than to swallow both forms
    def greet(*args, **kwargs):
        if len(args) == 2:
            prefix, name = args
        elif len(args) == 1:
            prefix = None
            name = args[0]
        elif "name" in kwargs:
            name = kwargs["name"]
            prefix = kwargs.get("prefix", None)
        else:
            raise TypeError("greet() missing 1 required positional parameter: 'name'")
        if prefix is not None:
            warnings.warn(
                "Parameter `prefix` is deprecated, "
                "and will be removed in a future version.",
                DeprecationWarning,
            )
        print(prefix or "hello", name)

    # still working as expected
    greet("hello", "world")
    greet("hello", name="world")
    greet(prefix="hello", name="world")
    ```

- [x] parameters

---

When transforming a parameter from positional-or-keyword to positional-only or keyword-only, one can use `*args` and `**kwargs` to allow both kinds during the deprecation period:

```python title="before"
def function(param1: str, /, param2: str, *, param3: str):
    ...
```

```python title="after"
import warnings


def function(param1: str, *args: str, param3: str, **kwargs: str):
    if args and kwargs:
        raise TypeError("function() got multiple values for argument 'param2'")
    elif args:
        param2 = args[0]
        # deprecate positional use
        warnings.warn(
            "Passing `param2` argument as positional is deprecated.",
            DeprecationWarning,
        )
    elif kwargs:
        param2 = kwargs["param2"]
        # or deprecate keyword use
        # warnings.warn(
        #     "Passing `param2` argument as keyword is deprecated",
        #     DeprecationWarning,
        # )
    ...
```

- [x] parameter kind

---

The position of a positional parameter can be deprecated if we can rely on the parameter's type (or other metadata) to identify it amongst other positional parameters. Since other parameters can shift too, we must also be able to identify these. Even then, signatures quickly stop making sense.

```python title="before"
def function(pos_x: bool, pos_y: int, pos_a: str, /):
    ...
```

```python title="after"
import warnings


# moving pos_a before pos_x
def function(pos_a: str | bool, pos_x: bool | int, pos_y: int | str, /):
    if isinstance(pos_a, bool) and isinstance(pos_x, int) and isinstance(pos_y, str):
        warnings.warn(
            "Parameter `pos_a` was moved to the first parameter.",
            DeprecationWarning,
        )
    # optionally type-check the rest, to avoid any invalid combination
    elif not (isinstance(pos_a, str) and isinstance(pos_x, bool) and isinstance(pos_y, int)):
        raise TypeError("function() requires 3 parameters of types str, bool and int, in this order")
    ...
```

Signatures can be improved with `typing.overload` to specify the valid combination of parameters:

```python title="after"
import warnings
from typing import overload


@overload
def function(pos_x: bool, pos_y: int, pos_a: str, /):
    ...


@overload
def function(pos_a: str, pos_x: bool, pos_y: int, /):
    ...


def function(*args):
    # variant implementation using a match statement
    match args:
        case (pos_x, pos_y, pos_a) if isinstance(pos_x, bool) and isinstance(pos_y, int) and isinstance(pos_a, str):
            ...
        case (pos_a, pos_x, pos_y) if isinstance(pos_a, str) and isinstance(pos_x, bool) and isinstance(pos_y, int):
            ...
        case _:
            raise TypeError("function() requires 3 parameters of types str, bool and int, in this order")
```

I am not sure how well type checkers support positional-only parameters moving around. We will get into the type-checking topic a bit later in this post.

As a general rule of thumb, my recommandation is to only make parameters positional-only when they are interchangeable with the other positional-only parameters. Another recommandation would be to use only one positional-or-keyword parameter, and make the rest keyword-only, early in the development of the library in order to minimize breaking changes later.

```python
def function(a: int, b: int, /, name: str, *, z: int = 0, show: bool = True):
    ...
```

We saw that deprecating the position of positional parameter is a bit contrived, but lets consider it possible.

- [x] parameter position

---

If a parameter accepts a union of types as values, it is straight-forward to deprecate one these type with `isinstance` checks:

```python
import warnings


def function(param: int | str):
    if isinstance(param, str):
        warnings.warn(
            "Passing a string as `param` value is deprecated, "
            "pass an integer directly instead.",
            DeprecationWarning,
        )
        param = int(param)
    ...
```

Similarly, if the accepted type changes to something else, we can accept both types temporarily and use an `isinstance` check again:

```python
import warnings


# old type
class A:
    ...


# new type
class B:
    ...


def function(param: A | B):
    if isinstance(param, A):
        warnings.warn(
            "Passing an instance of `A` as `param` value is deprecated, "
            "pass an instance of `B` instead.",
            DeprecationWarning,
        )
        # logic to transform param,
        # unless both types are compatible
    ...
```

- [x] parameter type

---

Deprecating parameter default values is also possible, whether we want to remove them later or change them to something else. For this we can use sentinels again:

```python
import warnings

_sentinel = object()


def function(param=_sentinel):  # previously =0
    if param is _sentinel:
        warnings.warn(
            "Parameter `param` will become required "
            "in a future version, please pass it explicitly.",
            DeprecationWarning,
        )
        param = 0
    ...
```

- [x] parameter default

```python
import warnings

_sentinel = object()


def function(param=_sentinel):  # previously =0
    if param is _sentinel:
        warnings.warn(
            "Parameter `param` default value will change "
            "from 0 to 1 in a future version, "
            "please pass 0 explicitly if you want to retain "
            "the current behavior.",
            DeprecationWarning,
        )
        param 0
    ...
```

- [x] parameter default value

---

Deprecating a function return type or value is not easy, if doable at all. To effectively deprecate it, the library authors would have to know *how* the return value is used. To know how it is used, they would have to somehow scan the surrounding code *within the user's code base*, which is definitely not trivial. Or they would have to wrap the returned value into a custom type of their own, where they would have control over attribute access, method execution, etc..

For example, if the function initially returns an `int`, but the library authors want to deprecate that in order to return an instance of a more complex class, they could try and wrap integers into a custom class, and find the right place where to emit a deprecation warning, for example in the `__eq__` method.

```python
import warnings


class _DeprInt(int):
    def __eq__(self, other):
        warnings.warn(
            "function() will start returning instances "
            "of DifferentInt instead of int in a future version, "
            "so you should stop comparing them directly with ==",
            DeprecationWarning,
        )
        return super().__eq__(other)


def function() -> int:
    return _DeprInt(0)
```

That is, assuming the `DifferentInt` class implements a different comparison method.

But this would be very brittle: what if the user code uses `>=` or any other operator? Library authors would have to re-implement all relevant methods (`__gt__`, etc.). What if the user only prints the returned value? Should the `__repr__` or `__str__` methods emit deprecation warnings? Mocking built-in classes is doable, but sometimes won't prevent breakages. For example there is no way of redefining what happens when the identity operator is used, so mocking/wrapping a boolean would fail when users of the library write `if result is True` or `if result is False`, since `result` will now never be `True` or `False`, but some mocked instance that only imitate their truthy/falsy value.

In the end, it might be easier to emit a deprecation warning from the function that returns the value, even if this value eventually isn't used by the user. This would generate "false-positive" deprecation warnings, that even users who upgraded their code to the new use would have to filter out, but at least library authors would be sure that every user is aware of the deprecation.

```python
import warnings


def function() -> int:
    warnings.warn(
        "function() will start returning instances "
        "of DifferentInt instead of int in a future version."
    )
    return 0
```

The other option, scanning the surrounding code, would need the help of type-checkers. We will see later how they come into play.

Because how brittle solutions suggested above look, I'm gonna leave the "function returned value/type" as unchecked.

- [ ] function returned value/type

---


- [ ] function/class type parameters? their names?
- [ ] attribute values?
- [ ] raised exceptions? their messages?
- [ ] class bases?
- [ ] any symbol's type?
- [ ] any symbol's kind (e.g. class vs. function)?
- [ ] emitted warnings? their messages?
- [ ] emitted logs? their messages? their logger name?
- [ ] can you think of anything else?





---

---

---

---

---

---

---

---

---

---

---


- deprecating a parameter value: seems trivial (just need to match param to `*args`, **kwargs` in wrapper)
- deprecating parameter type: less trivial. For example how do you deprecate integers in values of `dict[str, str | int]`? Best way I can see is annotating the type directly: `dict[str, str | Annotate[int, Deprecated("message")]]`. Can be unwrapped by Griffe/mkdocstrings-python, as well as stylized as deprecated (`deprecated` CSS class resulting in strike-through, probably).

What can we deprecate? Things that, when changed, might break downstream code. What are these things?

- raised exceptions
- base classes (isinstance)
- parameters (position, kind) and their values (default, accepted types)
- object names and locations
- object kinds (method -> property)

Deprecated use that can be detected at runtime:

- all parameter-related stuff ("easy" to inspect params and values in function body)
- object names and locations (module-level `__getattr__`)
- difficult: object kinds (must mock both kinds somehow, not always possible, works partially only)
- `isinstance(thing, DeprecatedBaseClass)` thanks to `__instancecheck__`
- `issubclass(Thing, DeprecatedBaseClass)` thanks to `__subclasscheck__`

Deprecated use that cannot be detected at runtime and needs static analysis:

- `except DeprecatedException`


```python
from __future__ import annotations

from typing import overload


def deprecated(
    message: str,
    *,
    base_class: type | None = None,
    kind: str | None = None,
    moved: tuple[str, str] | None = None,
    parameter: str | None = None,
    param_type: tuple[str, type] | None = None,
    param_default: str | None = None,
    param_kind: tuple[str, str] | None = None,
    param_name: tuple[str, str] | None = None,
    return_type: type | None = None,
    raising: tuple[type, type] | None = None,
    returning: object | None = None,
) -> callable:
    def decorator(obj: callable) -> callable:
        def wrapper(*args, **kwargs):
            return obj(*args, **kwargs)

        return wrapper

    return decorator


class Getting:
    ...


class Catching:
    ...


class Passing:
    ...


# Deprecating a class.
@deprecated("Use B instead.")
class A:
    pass


# NOTE: I'm inclined not to support this, and communicate that base classes are not part of the public API.
# Deprecating a base class.
# This implements `__instancecheck__` and `__subclasscheck__` to allow `issubclass` and `isinstance` to work.
@deprecated(base_class=A, message="Class A will be removed from the base classes of B.")
class B(A):
    pass


# Deprecating a function.
@deprecated("Use g instead.")
def f1():
    pass


# Deprecating a parameter.
# This wraps the function to check if the parameter was passed (using a sentinel).
@deprecated(parameter="x", message="Parameter `x` is deprecated.")
def f2(x: str = "hey") -> str:
    return x

@deprecate(Passing("x"), message="Parameter `x` is deprecated.")
def f2(x: str = "hey") -> str:
    return x

# Deprecating a parameter type.
@overload
@deprecated("Passing integers to `x` is deprecated.")
def f3(x: int) -> int: ...


@overload
def f3(x: str) -> int: ...


def f3(x: str | int) -> int:
    return 0


# Deprecating a parameter type (alternative).
# This wraps the function to check the argument type.
@deprecated(param_type=("x", int), message="Passing integers to `x` is deprecated.")
def f4(x: str | int) -> int:
    return 0


@deprecate(Passing("x", types=(int,)), message="Passing integers to `x` is deprecated.")
def f4(x: str | int) -> int:
    return 0


# Deprecating a parameter default.
# This wraps the function to check if a value was passed (using a sentinel).
@deprecated(param_default="x", message="Default value of `x` will be removed in the future.")
def f5(x: str = "hey") -> str:
    return x


@deprecate(NotPassing("x"), message="Default value of `x` will be removed in the future.")
def f5(x: str = "hey") -> str:
    return x


# Deprecating a parameter kind.
# This wraps the function to check if the parameter was passed as a positional or keyword argument.
@deprecated(param_kind=("x", "positional"), message="Passing `x` as a positional argument is deprecated.")
def f6a(x: str) -> str:
    return x


@deprecated(param_kind=("x", "keyword"), message="Passing `x` as a keyword argument is deprecated.")
def f6b(x: str) -> str:
    return x


@deprecate(Passing("x", kind="positional"), message="Passing `x` as a positional argument is deprecated.")
def f6a(x: str) -> str:
    return x


@deprecate(Passing("x", kind="keyword"), message="Passing `x` as a keyword argument is deprecated.")
def f6b(x: str) -> str:
    return x

# Deprecating a parameter name.
# This wraps the function to check which name was used (using sentinels).
@deprecated(param_name=("x", "y"), message="Parameter `x` was renamed `y`.")
def f7(y: str) -> str:
    return y


@deprecated(Passing("x", in_favor_of="y"), message="Parameter `x` was renamed `y`.")
def f7(y: str) -> str:
    return y

# Deprecating a return type.
# This wraps the function to check the return type.
@deprecated(
    return_type=str,
    message="This function will return an integer instead of a string in the future.",
)
def f8() -> str | int:
    return "0"


@deprecate(Getting(str, in_favor_of=int), message="This function will return an integer instead of a string in the future.")
def f8() -> str | int:
    return "0"

# Deprecating a raised exception.
# This wraps the function to catch the deprecated exception and raise a new custom one inheriting from both.
# Still misses an `__exceptcheck__` method.
@deprecated(raising=(RuntimeError, ValueError), message="Catching RuntimeError is deprecated in favor of ValueError.")
def f9():
    raise RuntimeError("hey")


@deprecate(Catching(RuntimeError, in_favor_of=ValueError), message="Catching RuntimeError is deprecated in favor of ValueError.")
def f9():
    raise RuntimeError("hey")

# Deprecating a return value in favor of newly raised exception.
# This wraps the function to catch the return value.
@deprecated(returning=None, raising=ValueError, message="This function will start raising ValueError instead of returning None.")
def f10():
    return None


@deprecate(Getting(None, in_favor_of=Catching(ValueError)), message="This function will start raising ValueError instead of returning None.")
def f10():
    return None


@deprecate(Getting(None, in_favor_of=Catching(ValueError)), message="This function will start raising ValueError instead of returning None.")
def f10():
    return None

# Deprecating an object name or location.
# This wraps the function to (import and) return `to` when `moved` is accessed.
@deprecated(moved=("g9", "f9"), message="Function g9 was moved to f9.")
@deprecated(moved=("g10", "package.module.f10"), message="Function g9 was moved to f9.")
def __getattr__(name: str):
    raise AttributeError(f"module '{__name__}' has no attribute '{name}'")


# Deprecating an object kind.
# This wraps the result in a container that can be called again.
class C:
    @deprecated(kind="", message="Method `m` is deprecated.")
    def m(self):
        pass
# method -> property?
# property -> method?
```


Aspects:

- goal: annotate code for static analysis, and emit deprecation warnings at runtime
- secondary goal: make it easy to deprecate code and support both old and new ways of using it
- general: keep the old code and support the new one, or update to the new code but support the old one
- return types: return the old type, document both types (->) (hack type checkers)
- raised exceptions: raise the old exception, document new exception


Deprecation libraries:

Library                                         | Function | Class | Method | Property | Attribute | Parameter | Return value | Raised exception | Object | Location | Kind | Message
----------------------------------------------- | -------- | ----- | ------ | -------- | --------- | --------- | ------------ | ---------------- | ------ | -------- | ---- | -------
https://pypi.org/project/deprecationlib/        | x        |       |        |          |           |           |              |                  |
https://pypi.org/project/deprecat/              | x | x | x | | | x
https://pypi.org/project/Deprecated/            | x | | x
https://pypi.org/project/zope.deprecation/      | x | x | x | x
https://pypi.org/project/Dandelyon/             |
https://pypi.org/project/pdeprecator/           |
https://pypi.org/project/libdeprecation/        |
https://pypi.org/project/deprecate/             |
https://pypi.org/project/deprecation/           |
https://pypi.org/project/deprecation-alias/     |
https://pypi.org/project/regret/                |
https://pypi.org/project/deprecator/            |
https://pypi.org/project/pvandyken-deprecated/  |
https://pypi.org/project/Python-Deprecated/     |
https://pypi.org/project/rosey-deprecated/      |

https://narwhals-dev.github.io/narwhals/backcompat/










```python
from __future__ import annotations

import inspect
import os
import warnings
from contextlib import contextmanager
from datetime import datetime
from functools import wraps
from typing import Any, Callable

from packaging.version import Version

from vectice.__version__ import __version__

CURRENT_VERSION = Version(Version(__version__).base_version)
_WARN_DEPR_REMOVAL = os.getenv("VECTICE_WARN_DEPR_REMOVAL", "0") == "1"


class DeprecationError(BaseException):
    """An exception raised when a deprecated object is used."""


def _exceeds(at: str | datetime | None) -> bool:
    if isinstance(at, str) and Version(at) <= CURRENT_VERSION:
        return True
    if isinstance(at, datetime) and at <= datetime.now():
        return True
    return False


def _deprecated_use(
    *,
    parameter: str | None,
    default: bool,
    args: tuple,
    kwargs: dict[str, Any],
    param_names: list[str],
) -> bool:
    # no parameter was specified for deprecation
    if parameter is None:
        return True
    # checking presence/absence of parameter in given arguments
    if default:
        # parameter must be present
        if parameter not in kwargs and len(args) <= param_names.index(parameter):
            return True
    else:
        # parameter must be absent
        if parameter in kwargs or len(args) > param_names.index(parameter):
            return True
    # no deprecated use detected
    return False


def deprecate(
    reason: str,
    *,
    parameter: str | None = None,
    default: bool = False,
    warn_at: str | datetime | None = None,
    fail_at: str | datetime | None = None,
    remove_at: str | datetime | None = None,
) -> Callable[[Callable], Callable]:
    """Deprecate a function. Internal-use only.

    This decorator can be used to deprecate a function or class method, or a parameter of this function/method.

    Parameters:
        reason: The reason why the function/method is deprecated. Useful information
            can be provided to the users, such as what to use instead of the deprecated function.
            Placeholders can be used in the reason string: `{name}`, `{parameter}`, `{warn_at}`, `{fail_at}` and `{remove_at}`:
            they will be replaced by their actual values, `name` being the name of the function.
        parameter: The name of the parameter to deprecate. If none,
            the whole function is deprecated.
        default: Whether to deprecate the default value of the given parameter (`True`),
            or the use of the parameter itself (`False`, default).
        warn_at: Version or date at which to start emitting a deprecation warning to the user.
            The user will see a deprecation warning when executing the function.
        fail_at: Version or date at which to start raising a deprecation error.
        remove_at: Internal-use only. Version or date at which to remove the deprecated code
            from the code base. It will start emitting a deprecation warning to the developers.
            The test suite will fail as long as the deprecated code is not removed.

    The `warn_at`, `fail_at` and `remove_at` values can be strings or instances of `datetime.datetime`.
    Strings are parsed as PEP 440 versions, see https://peps.python.org/pep-0440/.

    Although you don't have to always provide the three `warn_at`, `fail_at` and `remove_at` parameters,
    it is recommended to provide all three, to ensure the full life-cycle management of the deprecated function.

    IMPORTANT: Deprecation warnings are not enabled by default in Python,
    so users might need to enable them with `python -Walways`.
    More information on warnings control: https://docs.python.org/3/library/warnings.html.

    Examples:
        ```python
        # deprecating a function

        # --------------------------------------
        # vectice code in vectice/module.py
        from vectice.utils.deprecation import deprecate

        @deprecate(
            warn_at="2.1",
            fail_at="3.0",
            remove_at="4.0",
            reason="Function {name} is deprecated since version {warn_at}. "
            "Starting at version {fail_at}, it raises / will raise an exception. "
            "It will be removed at version {remove_at}. "
            "Please use 'other_function' instead.",
        )
        def my_deprecated_function(): ...
        # tests suite fails if version is >= 4.0


        # --------------------------------------
        # user code
        from vectice.module import my_deprecated_function

        my_deprecated_function()
        # exception raised if version is >= 3.0
        # warning emitted if version is >= 2.1
        # nothing happens if version is < 2.1
        ```

        ```python
        # deprecating a class method
        from vectice.utils.deprecation import deprecate


        class MyClass:
            @deprecate(warn_at="1", fail_at="2", remove_at="3", reason="This method is deprecated.")
            def my_deprecated_method(self): ...
        ```

        ```python
        # deprecating a module attribute
        from vectice.utils.deprecation import deprecate

        @deprecate(warn_at="1", fail_at="2", remove_at="3", reason="This attribute is deprecated.")
        def _get_my_deprecated_attribute():
            return "value'

        def __getattr__(name):
            if name == "my_deprecated_attribute":
                return _get_my_deprecated_attribute()
            raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
        ```

        ```python
        # deprecating a class attribute
        from vectice.utils.deprecation import deprecate


        class MyClass:
            _my_deprecated_attribute = "..."

            @deprecate(warn_at="1", fail_at="2", remove_at="3", reason="This attribute is deprecated.")
            def my_deprecated_attribute(self):
                return self._my_deprecated_attribute
        ```

        ```python
        # deprecating a function parameter
        from vectice.utils.deprecation import deprecate


        @deprecate(
            parameter="my_deprecated_parameter",
            warn_at="1",
            fail_at="2",
            remove_at="3",
            reason="This parameter is deprecated.",
        )
        def my_function(my_deprecated_parameter=None): ...
        ```

        ```python
        # deprecating a parameter default value
        from vectice.utils.deprecation import deprecate


        @deprecate(
            parameter="my_parameter",
            default=True,
            warn_at="1",
            fail_at="2",
            remove_at="3",
            reason="This default value is deprecated.",
        )
        def my_function(my_parameter="my_deprecated_default_value"): ...
        ```

    Returns:
        This function returns the actual decorator that must be called again
            with the function to decorate as argument.
    """

    def decorator(func: Callable) -> Callable:
        formatted_reason = reason.format(
            name=func.__name__,
            warn_at=warn_at,
            fail_at=fail_at,
            remove_at=remove_at,
            parameter=parameter,
        )
        if _WARN_DEPR_REMOVAL and _exceeds(remove_at):
            at = f"v{remove_at}" if isinstance(remove_at, str) else remove_at
            param = (f"({parameter})" + (" (default value)" if default else "")) if parameter else ""
            warnings.warn(
                f"Reminder: {func.__module__}.{func.__qualname__}{param} has reached its End-Of-Life, "
                f"planned at {at} - you should remove it from the code base. "
                f"Deprecation reason: {formatted_reason}",
                DeprecationWarning,
                stacklevel=2,
            )

        # we make sure the parameter exists and is not required,
        # and we don't guard behind _WARN_DEPR_REMOVAL
        # so that we never fail to detect such an error,
        # to protect users from getting an exception themselves
        params = inspect.signature(func).parameters
        if parameter:
            if parameter not in params:
                raise DeprecationError(
                    f"Cannot deprecate parameter '{parameter}' in callable {func}: no such parameter"
                )
            if params[parameter].default is inspect._empty:  # pyright: ignore[reportPrivateUsage]
                default_value = "default value " if default else ""
                raise DeprecationError(
                    f"Cannot deprecate parameter '{parameter}' {default_value}in callable {func}: parameter is required"
                )

        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any):
            if _deprecated_use(
                parameter=parameter,
                default=default,
                args=args,
                kwargs=kwargs,
                param_names=list(params),
            ):
                if _exceeds(fail_at):
                    raise DeprecationError(formatted_reason)
                if _exceeds(warn_at):
                    warnings.warn(formatted_reason, DeprecationWarning, stacklevel=2)
            return func(*args, **kwargs)

        return wrapper

    return decorator
```
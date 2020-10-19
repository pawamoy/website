---
template: post.html
title: "Passing Makefile arguments to a command, as they are typed in the command line."
date: 2020-10-17
authors:
  - Timothée Mazzucotelli
tags: make makefile args arguments command
#image: /assets/make-args.png
---

In my Python projects,
I use a combination of [Duty](https://github.com/pawamoy/duty)
(my task runner) and `make`.

My `Makefile` declares the same tasks as the ones written in `duties.py`,
but in a generic manner:

```Makefile
TASKS = check test release

.PHONY: $(TASKS)
$(TASKS):
	@poetry run duty $@
```

So, instead of running `poetry run duty check`, I can run `make check`.
Convenient, right?

Except that some duties (tasks) accept arguments. For example:

```bash
poetry run duty release version=0.1.2
```

So how do I allow the `make` equivalent?

```bash
make release version=0.1.2
```

<!--more-->

## Experiments

Do I write a specific rule in the Makefile for the `release` task?

```Makefile
TASKS = check test release

.PHONY: release
release:
	@poetry run duty release version=$(version)

.PHONY: $(TASKS)
$(TASKS):
	@poetry run duty $@
```

Meh. My Makefile rules are not generic anymore.
Besides, what if the argument is optional?
If I don't pass it when running `make`,
the command will end up being `poetry run duty release version=`,
which is just wrong.

Instead, I'd like to find a generic way to insert the arguments
in the command just as they are typed on the command line:

```bash
make release
# => poetry run duty release
```

```bash
make release version=0.1.2
# => poetry run duty release version=0.1.2
```

Well, after a few hours playing with Makefiles features,
I got a nice solution!

## Sorcery

Let me sprinkle this dark magic right here:

```Makefile
args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a=$($a)))

check_args = files
docs_serve_args = host port
release_args = version
test_args = match

TASKS = \
	check \
	docs-serve \
	release \
	test

.PHONY: $(TASKS)
$(TASKS):
	@poetry run duty $@ $(call args,$@)
```

What happens here?!

## Recipe

```Makefile
args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a=$($a)))
```

The heart of the magic. We declare a function called `args`.
We later call it with `$(call args,$@)`.

It could be described like this:

```
args reference := first parameter
replace - by _ in args reference
append "_args" to args reference
get argument names by dereferencing args reference
for each argument name
  get argument value by dereferencing argument name
  if argument value is not empty
    print "argument name = argument value"
```

This is why we declare our arguments like this:

```Makefile
check_args = files
docs_serve_args = host port
release_args = version
test_args = match
```

When running `make docs-serve host=0.0.0.0`,
the `args` function will do the following:

```
args_ref := "docs-serve"
args_ref becomes "docs_serve" (replace)
args_ref becomes "docs_serve_args"
args_names is value of "docs_serve_args" variable
args_names therefore is "host port"
arg "host":
  variable "host" is not empty
  print "host=0.0.0.0"
arg "port":
  variable "port" is empty
  print nothing
```

So when calling `$(call args,$@)`, `$@` is replaced
by the rule name, which is `docs-serve` in this example,
and `host=0.0.0.0` is added to the command.

We successfully re-built the arguments passed on the command line!

## Side-effects

Arguments can be passed to `make` in no particular order.
The following commands are all equivalent:

```bash
make hello world=earth foo bar=baz
make hello foo bar=baz world=earth
make bar=baz hello foo world=earth
```

It can be seen as an advantage but as an inconvenient as well,
because you cannot have arguments with the same name for different commands.
Or at least, you could not use these commands and arguments at the same time.

```Makefile
args = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a=$($a)))

rule1_args = version
rule2_args = version name

TASKS = rule1 rule2

.PHONY: $(TASKS)
$(TASKS):
	@poetry run duty $@ $(call args,$@)
```

Here `rule1` and `rule2` both accept a `version` argument.

```bash
make rule1 version=1  # OK

make rule1 version=1 rule2  # not OK
# it will result in "poetry run duty rule1 version=1"
# then "poetry run duty rule2 version=1"!

make rule1 version=1 rule2 version=2  # ???
# I couldn't get the courage to try more of these dark arts
# so I don't know what would happen here...
```

## Addendum

Not a real addendum.

Share your tricks!

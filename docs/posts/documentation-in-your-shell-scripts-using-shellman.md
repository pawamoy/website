---
template: post.html
title: "Documentation in your shell scripts using shellman"
date: 2016-12-07
authors:
  - Timothée Mazzucotelli
tags: shell doc documentation man page markdown text auto help script library shellman
---

When I write a script, I like to have a `-h, --help` option to help me remember what it does
and how it works. But I was never delighted to write this help text. Besides, when your script's
options change, you have to update the help text.

I also always liked man pages, their search feature and their ability to scroll up and down
and not leave any output in the console. But maintaining a man page is even more tedious than
maintaining a help text.

This is why I thought of using documentation in shell scripts. So I wrote [shellman][].

<!--more-->

- [Writing doc](#writing-doc)
- [Using shellman](#using-shellman)
- [An example](#an-example)
- [How it looks](#how-it-looks)
  - [Text](#text)
  - [Man](#man)
  - [Markdown](#markdown)
- [More](#more)

## Writing doc
Shellman can read special comments in your file. These special comments are the documentation
of your script or library. They simply begin with two sharps instead of one:

```bash
# A normal comment.
## A documentation comment.
```

Also, to give a special meaning to your documentation, each documentation line can be tagged,
just like you would do in doxygen documentation:

```bash
## \brief A brief description.
## \desc A long description.
## You can write many lines in this tag.
```

## Using shellman
After reading and loading all the documentation written in a file, shellman will then be able
to output it on stdout (on in another file) in different formats, such as text, man page
or markdown.

```bash
shellman my_script.sh  # text output by default
man <(shellman --format man my_script.sh)
# Available formats for -f, --format option: text, man, markdown
```

Shellman also has a `--check` option that will not output anything, but instead check for
written documentation in a file. A simple `--check` option will return 0 or 1, but display no
warnings. Add a `--warn` option to print warnings on stderr. It will help you fix your
documentation, or even do some linting and continuous integration on your scripts' documentation.

## An example
Here is an example of how I write documentation in my scripts now:

```bash
#!/bin/bash

## \brief shell script debugger

## \desc Run a script in path with the -x bash option (and more).
## You should set the PS4 variable for better output.

## \env PS4
## Debugger prompt. This is the prefix that bash prepends
## to the current instruction when using -x option.

main() {
  case "$1" in

    ## \option -t, --test
    ## Read the script and warn for encountered syntax errors.
    ## Do not actually run the script.
    -t|--test) FLAGS=-n; shift ;;

    ## \option -v, --verbose
    ## Run the script with verbose option.
    -v|--verbose) FLAGS=-xv; shift ;;

    ## \option -n, --dry-run
    ## Options test and verbose combined. Validate the syntax
    ## and print the script to stdout.
    -n|--dry-run) FLAGS=-xvn; shift ;;

    ## \option -h, --help
    ## Print this help and exit.
    -h|--help) shellman "$0"; exit 0 ;;  # Here is the black magic!

    *) FLAGS=-x ;;

  esac
  SCRIPT=$1
  shift

  /bin/bash "${FLAGS}" "${SCRIPT}" "$@"
}

## \usage dbg [-tvn] SCRIPT
main "$@"
```

## How it looks
The different outputs would be like the following.

#### Text

```
Usage: dbg [-tvn] SCRIPT

Run a script in path with the -x bash option (and more).
You should set the PS4 variable for better output.

Options:
  -t, --test
    Read the script and warn for encountered syntax errors.
    Do not actually run the script.

  -v, --verbose
    Run the script with verbose option.

  -n, --dry-run
    Options test and verbose combined. Validate the syntax
    and print the script to stdout.

  -h, --help
    Prints this help and exit.
```

#### Man
![man output](/assets/man-output.png)

#### Markdown
```markdown
**dbg** - shell script debugger
# Usage
`dbg [-tvn] SCRIPT`  

Run a script in path with the -x bash option (and more).
You should set the PS4 variable for better output.

# Options
- `-t, --test`:
  Read the script and warn for encountered syntax errors.
Do not actually run the script.
- `-v, --verbose`:
  Run the script with verbose option.
- `-n, --dry-run`:
  Options test and verbose combined. Validate the syntax
and print the script to stdout.
- `-h, --help`:
  Prints this help and exit.

# Environment variables
- `PS4`:
  Debugger prompt. This is the prefix that bash prepends to
the current instruction when using -x option.
```

... which would look like:

![markdown output](/assets/markdown-output.png)

## More
Shellman supports more tags, in particular: function tags.
See its [documentation][].

[shellman]: https://github.com/Pawamoy/shellman
[documentation]: https://github.com/Pawamoy/shellman/wiki

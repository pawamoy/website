---
template: post.html
title: "Adding links to a Black formatted, Pygments syntax highlighted Python code block"
date: 2023-08-09
authors:
- Timothée Mazzucotelli
tags: python cross-references html black pygments
image:
  src: /assets/codeblock.png
  add_to_post: no
  class: crop-excerpt
hide: [toc]
---

<style>
  .doc-object {
    border: 4px solid var(--md-typeset-table-color);
    padding-left: 16px;
    padding-right: 16px;
  }
</style>

One of the features of [mkdocstrings-python]
is its ability to automatically render cross-references to objects of the documented package
in code block signatures.

Adding links to code blocks is possible in HTML,
but doing so while preserving Pygments syntax highlighting
*and* Black formatting was not an easy task.
This post explains how it works.

<!--more-->

---

Let say we document a Python package that exposes one function and one class:
`do` and `Action`. The function takes an instance of the class as parameter:

```python
class Action:
    """An action."""


def do(action: Action):
    """Do an action."""
```

Let say we now want to document both using [MkDocs] and [mkdocstrings].
In our Markdown page we would add the autodoc instructions:

```md
::: package.Action

::: package.do
```

...which, depending on how we configured mkdocstrings,
would render something like this:

::: actions.Action
    options:
      heading_level: 3
      separate_signature: true
      show_root_full_path: false
      show_root_heading: true
      show_signature_annotations: true
      show_source: false

::: actions.do
    options:
      heading_level: 3
      separate_signature: true
      show_root_full_path: false
      show_root_heading: true
      show_signature_annotations: true
      show_source: false

The challenge is to render the signature of `do` like this instead,
with `Action` linking to the rendered docs for the corresponding class:

::: actions.do
    options:
      heading_level: 3
      separate_signature: true
      show_root_full_path: false
      show_root_heading: true
      show_signature_annotations: true
      show_source: false
      signature_crossrefs: true

So how do we do this?

Obviously we can use the
[`signature_crossrefs`](https://mkdocstrings.github.io/python/usage/configuration/signatures/#signature_crossrefs)
option of mkdocstrings-python (which at the time of writing is available to my sponsors only),
but that's not the point of this post.

Let's take a look at the first signature.
We can inspect the HTML generated for the signature
of the `do` function, it looks like this
<small>(with added line breaks for readability)</small>:

```html
<pre>
  <code>
    <span class="n">do</span>
    <span class="p">(</span>
    <span class="n">action</span>
    <span class="p">:</span> <span class="n">Action</span>
    <span class="p">)</span>
  </code>
</pre>
```

Can we parse this, find spans with class `n`, and add links there?
We could, but there are a few issues with this approach:

- we don't know which names (`n`) should be linked
- we don't have the names' full path (`Action`'s path really is `actions.Action` here)
- parsing and modifying HTML is costly

We can't either add links first, then syntax highlight or format the code:
neither Pygments nor Black support coloring/formatting code while
retaining HTML tags around names.

The only way to do this correctly and efficiently is by adding
pre-processing and post-processing steps.

1. First, we need the full path of names that must be linked.
   In mkdocstrings, thanks to [Griffe], expressions (like signatures)
   are stored as a list-like structure, on which we can iterate.
   Elements of this list-like structure are strings or instances
   of a special class that represent linkable names.
   Thanks to these, we know what to link, and we have the names' full path.
2. When preparing our string for formatting/syntax highlighting,
   we simply join string elements together. For each name,
   we precompute its HTML link, store it in a map with a unique identifer,
   and join this identifier to the main string. These identifiers
   must answer to a few constraints: they must be unique (obviously),
   they must have the same length as the original name (for formatting reasons),
   and they must be valid Python variable names (for formatting reasons too).
3. We format and syntax highlight this main string.
4. We finally replace each unique identifier stored in our map
   by the precomputed HTML link. Tada!

Let's illustrate this process with our example setup above.

1. The signature of the function `do` could be stored like this:

    ```python
    expression = ["do", "(", "action", ": ", Name(source="Action", full_path="actions.Action"), ")"]
    ```

2. We build our main string,
   while computing and storing links for names:
   
    ```python
    def build_string(expression, stored_links):
        string_parts = []
        for element in expression:
            if isinstance(element, str):
                string_parts.append(element)
            else:
                unique_id = get_unique_id(name.source)  # _dx7ej
                stored_links[unique_id] = get_url_to(name.full_path)  # <a href="#actions.Action">Action</a>
                string_parts.append(unique_id)
        return "".join(string_parts)

    stored_links = {}
    main_string = build_string(expression, stored_links)
    ```

3. We format and highlight the string using Black and Pygments, in that order:

    ```python
    formatted_string = black_format(main_string)
    highlighted_string = pygments_highlight(formatted_string)
    ```

4. We replace the unique ids by their values:

    ```python
    final_string = highlighted_string
    for unique_id, link in stored_links.items():
        final_string = final_string.replace(unique_id, link)
    ```

Finally, let's illustrate the different states of our signature:

1. 
    ```python
    ["do", "(", "action", ": ", Name(source="Action", full_path="actions.Action"), ")"]
    ```
2. 
    ```python
    "do(action: _dx7ej)"
    ```
3. 
    ```html    
    <pre>
      <code>
        <span class="n">do</span>
        <span class="p">(</span>
        <span class="n">action</span>
        <span class="p">:</span> <span class="n">_dx7ej</span>
        <span class="p">)</span>
      </code>
    </pre>
    ```
4. 
    ```html    
    <pre>
      <code>
        <span class="n">do</span>
        <span class="p">(</span>
        <span class="n">action</span>
        <span class="p">:</span> <span class="n"><a href="#actions.Action">Action</a></span>
        <span class="p">)</span>
      </code>
    </pre>
    ```

Ensuring the ids are unique within the final highlighted string is not easy,
since we don't know the contents of the highlighted string in advance.
In mkdocstrings-python we use ASCII digits as well as letters,
 and prefix the ids with an underscore, to reduce
the risk of collision with other existing variables in the expression.
The length constraint increases the collision risk when variables have short names.
We always create ids of minimum length 3, even for variable names of length 1 or 2.

---

The whole process is even more involved in mkdocstrings-python:
we have an additional intermediate step with [autorefs],
and we have to integrate the solution within Jinja templates!

[autorefs]: https://mkdocstrings.github.io/autorefs
[Griffe]: https://mkdocstrings.github.io/griffe
[MkDocs]: https://www.mkdocs.org/
[mkdocstrings]: https://mkdocstrings.github.io
[mkdocstrings-python]: https://mkdocstrings.github.io/python
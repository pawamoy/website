---
template: post.html
title: "How to deal with spacing in Jinja2 templates"
date: 2020-09-01
authors:
  - Timothée Mazzucotelli
tags: templates jinja2 jinja templating spacing howto
# image: /assets/fill-space-drawing.jpg
---

It started with
[a comment in a GitHub issue](https://github.com/triaxtec/openapi-python-client/issues/138#issuecomment-670053183).

> I often find it difficult to wrangle spacing jinja2 templates especially around optional clauses.

I couldn't wrap my head either about this.
So I decided to write a script and test every combination
of newlines, indentation and dashes or no dashes in `{%-`,
with the goal being to find combinations
that will not have an extra middle line
when an optional Jinja clause is false.

## Script

```python
from jinja2 import Environment


flip = (True, False)
n = "\n"


def get_template(n1, n2, n3, n4, d1, d2, d3, d4, i):
    return (
        f"  a"
        f"{(n + ('  ' if i else '')) if n1 else ''}"
        f"{{%{'-' if d1 else ''} if x {'-' if d2 else ''}%}}"
        f"{n if n2 else ''}"
        f"  b"
        f"{(n + ('  ' if i else '')) if n3 else ''}"
        f"{{%{'-' if d3 else ''} endif {'-' if d4 else ''}%}}"
        f"{n if n4 else ''}"
        f"  c"
    )


def get_templates():
    for newline1 in flip:
        for newline2 in flip:
            for newline3 in flip:
                for newline4 in flip:
                    for dash1 in flip:
                        for dash2 in flip:
                            for dash3 in flip:
                                for dash4 in flip:
                                    for indent in flip:
                                        yield get_template(
                                            newline1,
                                            newline2,
                                            newline3,
                                            newline4,
                                            dash1,
                                            dash2,
                                            dash3,
                                            dash4,
                                            indent,
                                        )


if __name__ == "__main__":
    good = []
    env = Environment()
    for n, template_string in enumerate(sorted(set(get_templates())), 1):
        template = env.from_string(template_string)
        true = template.render(x=True)
        false = template.render(x=False)
        if true == "  a\n  b\n  c" and false == "  a\n  c":
            good.append(template_string)
    print("\n\n---\n\n".join(good))
    print(f"\ntested: {n}\nvalid: {len(good)}")
```

## Results

Only 19 different combinations are valid on the 448 tested ones:

```
  a
  {% if x -%}
  b
  {% endif -%}
  c

---

  a
  {% if x -%}
  b
  {% endif -%}  c

---

  a
  {% if x -%}  b
  {% endif -%}
  c

---

  a
  {% if x -%}  b
  {% endif -%}  c

---

  a
  {%- if x %}
  b
  {%- endif %}
  c

---

  a
  {%- if x %}
  b{% endif %}
  c

---

  a
  {%- if x %}
  b{%- endif %}
  c

---

  a
{% if x %}  b
{% endif %}  c

---

  a
{%- if x %}
  b
{%- endif %}
  c

---

  a
{%- if x %}
  b{% endif %}
  c

---

  a
{%- if x %}
  b{%- endif %}
  c

---

  a{% if x %}
  b
  {%- endif %}
  c

---

  a{% if x %}
  b
{%- endif %}
  c

---

  a{% if x %}
  b{% endif %}
  c

---

  a{% if x %}
  b{%- endif %}
  c

---

  a{%- if x %}
  b
  {%- endif %}
  c

---

  a{%- if x %}
  b
{%- endif %}
  c

---

  a{%- if x %}
  b{% endif %}
  c

---

  a{%- if x %}
  b{%- endif %}
  c

tested: 448
valid: 19
```

Each one of these will render as 

```
  a
  b
  c
```

...when the condition is true, and as

```
  a
  c
```

...when the condition is false.

Now you just have to pick the style you prefer!

I find these three particularly readable (the first two are better when `b`  spans on multiple lines):

```
  a
  {%- if x %}
  b
  {%- endif %}
  c
```

```
  a
  {% if x -%}
  b
  {% endif -%}
  c
```

```
  a{% if x %}
  b{% endif %}
  c
```

The third example readability can also be improved:

```
  a   {%- if x %}
  b   {%- endif %}
  c
```

Here is an example with blank lines in `b`'s contents.
The first one collapses contents up, while the second collapses content down.

```python
class Run:
    def pause(self):
        print("pausing")
    {%- if stoppable %}


    def stop(self):
        print("stopping")
    {%- endif %}


    def resume(self):
      print("resuming")
```

```python
class Run:
    def pause(self):
        print("pausing")


    {% if stoppable -%}
    def stop(self):
        print("stopping")


    {% endif -%}
    def resume(self):
        print("resuming")
```

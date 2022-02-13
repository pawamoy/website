---
template: post.html
title: "Migrate Disqus comments to Utterances (in GitHub issues) with Python"
date: 2020-09-13
authors:
  - Timothée Mazzucotelli
tags: howto migrate disqus comments utterances github python xml
image:
  src: /assets/comments.png
  class: crop-excerpt
---

When I replaced [Jekyll](https://jekyllrb.com/)
and my [Jekyll-ReadTheDocs theme](https://github.com/pawamoy/jekyll-readthedocs/)
with [MkDocs](https://www.mkdocs.org/)
and a [blog-customised version](https://github.com/pawamoy/website) of
the [Material for MkDocs theme](https://squidfunk.github.io/mkdocs-material/),
the URLs of my posts changed.

I was using [Disqus](https://disqus.com) for comments,
and they provide a way to migrate threads from old URLs to new URLs.
Unfortunately, this time it didn't work for some reason
(I had already done it once in the past and it worked fine).

I've read more and more criticism about Disqus related to privacy,
so I looked at a replacement.
The Disqus thread migration was not working so it was the perfect occasion!

I've read a few webpages and got interested in [Isso](https://posativ.org/isso/).
Unfortunately again, I [did not manage](https://github.com/posativ/isso/issues/671)
to install it on my Raspberry Pi.

So I went with a much simpler solution: [Utterances](https://utteranc.es/).
You basically enable a GitHub app on your repository,
add a script in your posts pages, and voilà: your new comment section
powered by GitHub issues.

<!--more-->

I'm not completely satisfied because readers will need to log in
with their GitHub account to comment (no anonymous comments),
and you can't have nested discussions (well, just like in GitHub issues).

But this was really easy to setup :smile:!

Now I just needed to migrate the Disqus comments into GitHub issues.
To do this semi-automatically, I wrote the following script.
"Semi-automatically" because I still had to write a "test" comment
in each one of my posts so Utterances would initiate/create the issues.
I guess it could be implemented in the script directly,
but since I just had a dozen of posts, I took the easy/repetitive way.

## The script

!!! warning
    You'll have to create the initial issues before running the script!
    Serve your blog locally, and write a "test" comment in every post that has comments.

First, [export your Disqus comments](https://help.disqus.com/en/articles/1717164-comments-export).

Then you'll need two Python libraries:

- [`pygithub`](https://pypi.org/project/PyGithub/)
- [`xmltodict`](https://pypi.org/project/xmltodict/)

You'll also need to create a token on GitHub,
with just the `public repos` access.

Write the following environment variables in a file,
and source it.

```bash
export FILEPATH="comments.xml"
export USERNAME="yourUsername"
export TOKEN="yourToken"
export REPOSITORY="yourUsername/yourUsername.github.io"
export BASE_URL="https://yourUsername.github.io/"
```

Now you can copy/paste and run this script:

```python
import os
import time
import xmltodict
from github import Github

FILEPATH = os.environ["FILEPATH"]
USERNAME = os.environ["USERNAME"]
TOKEN = os.environ["TOKEN"]
REPOSITORY = os.environ["REPOSITORY"]
BASE_URL = os.environ["BASE_URL"]


def disqus_to_github():
    g = Github(TOKEN)
    repo = g.get_repo(REPOSITORY)
    issues = repo.get_issues()

    with open(FILEPATH) as fd:
        data = xmltodict.parse(fd.read())

    data = data["disqus"]

    threads = [dict(t) for t in data["thread"]]
    posts = sorted((dict(p) for p in data["post"]), key=lambda d: d["createdAt"])

    # only keep threads with comments
    twc_ids = set(p["thread"]["@dsq:id"] for p in posts)
    threads = {t["@dsq:id"]: t for t in threads if t["@dsq:id"] in twc_ids}

    # associate the thread to each post
    for post in posts:
        post["thread"] = threads[post["thread"]["@dsq:id"]]

    # associate the related GitHub issue to each thread
    # warning: the issues need to exist before you run this script!
    # write a "test" comment in each one of your post with comments
    # to make Utterances create the initial issues
    for thread in threads.values():
        for issue in issues:
            if issue.title == thread["link"].replace(BASE_URL, ""):
                thread["issue"] = issue
                break

    # iterate on posts and create issues comments accordingly
    for i, post in enumerate(posts, 1):
        name = post["author"]["name"]
        user = post["author"].get("username")
        mention = " @" + user if user and not user.startswith("disqus_") else ""
        date = post["createdAt"]
        message = post["message"]
        issue = post["thread"]["issue"]
        body = f"*Original date: {date}*\n\n{message}"
        # don't add original author when it's you
        if user != USERNAME:
            body = f"*Original author:* **{name}{mention}**  \n{body}" 
        print(f"Posting {i}/{len(posts)} to issue {issue.number}    \r", end="")
        issue.create_comment(body)
        # prevent hitting rate limits!
        time.sleep(0.5)

    print()


if __name__ == "__main__":
    disqus_to_github()
```

I wrote this for a one-time, personal use only,
so it could easily crash when you try it!
Just use your Python skills and adapt it :wink:
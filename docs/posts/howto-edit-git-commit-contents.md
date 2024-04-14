---
template: post.html
title: How to edit the contents of a git commit
date: 2020-10-04
authors:
  - Timothée Mazzucotelli
tags: git commit edit howto shell rebase amend
image:
  src: /assets/edit-commit3.png
  class: crop-excerpt
hide: [toc]
---

When you type `change git commit` or similar keywords in a search engine, you find many answers explaning how to rewrite a commit *message*, but not how to actually modify the *contents* of the commit.

This post quickly explains how to do that.

<!--more-->

Lets begin by listing our commits:

![edit-commit-1](../assets/edit-commit1.png)

<small>
In this screenshot I use my `gl` alias which expands to:

```bash
git log --pretty=format:'%C(yellow)%h %Cgreen%ad %Cblue%an%Cgreen%d %Creset%s' --date=short --graph
```

</small>

Here I want to modify the contents of the third commit, `feat: Refactor and add features`, because I mistakenly committed modifications to the changelog which I didn't want.

So I run an interactive git rebase down to this commit by running:

```bash
git rebase -i HEAD~3
```

![edit-commit-2](../assets/edit-commit2.png)

This command launches your git editor (vim here) to tell git what to do. Here we tell git to stop right after the commit we want to modify:

![edit-commit-3](../assets/edit-commit3.png)

We save and quit this temporary file (with `:wq`), and git tells us that it stopped at the desired commit:

![edit-commit-4](../assets/edit-commit4.png)

<small>
Don't pay attention to the commit SHA:
I took the screenshot afterwards so they don't match :smile:
</small>

Now you can start modifying, adding or deleting files!

In my case I wanted to remove wrong sections in `CHANGELOG.md`, as well as remove conflict-resolution lines in `pyproject.toml`.

![edit-commit-5](../assets/edit-commit5.png)

<small>
In this screenshot I use my `gs` alias
which expands to `git status -sb`.
</small> 

All you have to do now is to amend the current commit (the one at which we stopped, the one we wanted to modify):

```bash
git commit -a --amend --no-edit
# --no-edit because we don't want to edit the message
```

![edit-commit-6](../assets/edit-commit6.png)

And finally, let git finish the interactive rebase:

```bash
git rebase --continue
```

![edit-commit-7](../assets/edit-commit7.png)

Done!

#!/usr/bin/env bash

# add remote
git remote add gh-pages git@github.com:pawamoy/pawamoy.github.io &>/dev/null

# reset publish branch, switch to it
# this is to avoid a build commit on master
git branch -D publish &>/dev/null
git switch -c publish

# build and publish
. .venv/bin/activate
mkdocs gh-deploy \
  --force --no-history --ignore-version \
  --remote-name gh-pages \
  --remote-branch master

# switch back to master branch
git switch master

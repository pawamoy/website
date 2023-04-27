#!/usr/bin/env bash
. .venv/bin/activate
git remote add gh-pages git@github.com:pawamoy/pawamoy.github.io &>/dev/null
mkdocs gh-deploy --force \
  --remote-name gh-pages \
  --remote-branch master
# git reset --hard HEAD

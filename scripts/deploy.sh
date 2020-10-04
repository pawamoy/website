#!/usr/bin/env bash
. venv/bin/activate
cd ../pawamoy.github.io || exit 1
git pull
mkdocs gh-deploy \
  --config-file ../website/mkdocs.yml \
  --remote-branch master
git reset --hard HEAD

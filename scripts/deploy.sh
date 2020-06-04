#!/usr/bin/env bash
. venv/bin/activate
cd ../pawamoy.github.io || exit 1
mkdocs gh-deploy \
  --config-file ../website/mkdocs.yml \
  --remote-branch master

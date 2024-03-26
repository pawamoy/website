#!/usr/bin/env bash
git remote add pawamoy.github.io git@github.com:pawamoy/pawamoy.github.io &>/dev/null
.venv/bin/mkdocs gh-deploy \
  --force --ignore-version \
  --remote-name pawamoy.github.io \
  --remote-branch gh-pages

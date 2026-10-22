#!/usr/bin/env bash
set -euo pipefail

[ ! -d .venv ] && ./scripts/setup.sh
.venv/bin/zensical build
if ! git remote get-url pawamoy.github.io &>/dev/null; then
  git remote add pawamoy.github.io git@github.com:pawamoy/pawamoy.github.io
fi
.venv/bin/ghp-import --no-jekyll --push --force \
  --remote pawamoy.github.io \
  --branch gh-pages site

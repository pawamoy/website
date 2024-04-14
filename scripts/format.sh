#!/usr/bin/env bash
[ ! -d .venv ] && ./scripts/setup.sh
.venv/bin/mdformat docs/*.md docs/posts docs/showcase --ignore-missing-references

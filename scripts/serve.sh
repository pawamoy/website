#!/usr/bin/env bash
[ ! -d .venv ] && ./scripts/setup.sh
.venv/bin/mkdocs serve

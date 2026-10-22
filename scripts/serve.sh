#!/usr/bin/env bash
[ ! -d .venv ] && ./scripts/setup.sh
.venv/bin/zensical serve "$@"

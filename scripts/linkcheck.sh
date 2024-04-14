#!/usr/bin/env bash
[ ! -d .venv ] && ./scripts/setup.sh
.venv/bin/linkchecker http://localhost:8000
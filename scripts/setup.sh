#!/usr/bin/env bash
python -m venv .venv
.venv/bin/pip install -U setuptools wheel pip
.venv/bin/pip install -r requirements.txt

#!/usr/bin/env bash

export PS4='+ $0:$LINENO '
shopt -s extglob
# set -o # Show all options
set -e

virtualenv -p python .venv
source ./.venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt

echo "Run 'source .venv/bin/activate' to activate env."

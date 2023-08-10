#!/usr/bin/env bash
set -e
set -x

DOCSTRING_SRC=${1:-"src/mlstacks tests"}

find $DOCSTRING_SRC -type d -name ".terraform" -prune -o -name "*.py" -print | xargs darglint -v 2

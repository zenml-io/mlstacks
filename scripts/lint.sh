#!/usr/bin/env bash
set -e
set -x
set -o pipefail

SRC=${1:-"src/mlstacks tests"}
SRC_NO_TESTS=${1:-"src/mlstacks"}
TESTS=${1:-"tests"}

ruff $SRC_NO_TESTS

# autoflake replacement: checks for unused imports and variables
ruff $SRC --select F401,F841 --exclude "__init__.py" --isolated

black $SRC  --check

# check type annotations
mypy $SRC_NO_TESTS

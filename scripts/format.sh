#!/bin/sh -e
set -x

SRC=${1:-"src/mlstacks tests scripts"}

# autoflake replacement: removes unused imports and variables
ruff $SRC --select F401,F841 --fix --exclude "__init__.py" --isolated

# sorts imports
ruff $SRC --select I --fix --ignore D
black $SRC

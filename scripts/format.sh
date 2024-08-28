#!/bin/sh -e
set -x

SRC=${1:-"src/mlstacks tests scripts"}

# autoflake replacement: removes unused imports and variables
ruff check $SRC --select F401,F841 --fix --exclude "__init__.py" --isolated

# sorts imports
ruff check $SRC --select I --fix --ignore D
ruff format $SRC

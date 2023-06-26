#!/usr/bin/env bash
set -e
set -x

DOCSTRING_SRC=${1:-"src/mlstacks tests"}

darglint -v 2 $DOCSTRING_SRC

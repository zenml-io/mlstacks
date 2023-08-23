#!/usr/bin/env bash

set -e
set -x

TEST_SRC="tests/"


pytest $TEST_SRC --color=yes -vv

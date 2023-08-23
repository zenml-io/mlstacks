#!/usr/bin/env bash

set -e

# # Test Command
# poetry publish --build --repository test-pypi
# # add `--dry-run` if you don't want it to do anything

# # Real Command
poetry publish --build --username $PYPI_USERNAME --password $PYPI_PASSWORD

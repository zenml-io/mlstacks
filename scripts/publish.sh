#!/usr/bin/env bash

set -e

# Test Commang
poetry publish --build --repository testpypi --dry-run --username $PYPI_USERNAME --password $PYPI_PASSWORD

# Real Command
# poetry publish --build --username $PYPI_USERNAME --password $PYPI_PASSWORD

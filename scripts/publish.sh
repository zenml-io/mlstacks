#!/usr/bin/env bash

set -e

poetry publish --build --repository testpypi --dry-run --username $PYPI_USERNAME --password $PYPI_PASSWORD

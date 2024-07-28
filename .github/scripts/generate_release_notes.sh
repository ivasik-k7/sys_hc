#!/bin/bash

set -e

# git fetch --tags

LATEST_TAG=$(git describe --tags --abbrev=0 || echo "v0.0.0")

if [ "$LATEST_TAG" != "v0.0.0" ]; then
    COMMITS=$(git log ${LATEST_TAG}..HEAD --pretty=format:"%h %s" --abbrev-commit)
else
    COMMITS=$(git log --pretty=format:"%h %s" --abbrev-commit)
fi

if [ -z "$COMMITS" ]; then
    echo "## Release Notes" >RELEASE_NOTES.md
    echo "No changes since the last release." >>RELEASE_NOTES.md
else
    echo "## Release Notes" >RELEASE_NOTES.md
    echo "$COMMITS" >>RELEASE_NOTES.md
fi

echo "::set-output name=notes::$(cat RELEASE_NOTES.md)"

exit 0

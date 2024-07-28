#!/bin/bash

if [ ! -d .git ]; then
    echo "This script must be run in a Git repository."
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: $0 <event-type>"
    echo "Event type can be: major, minor, patch, beta"
    exit 1
fi

EVENT_TYPE=$1
LATEST_TAG=$(git describe --tags --abbrev=0)

if [ -z "$LATEST_TAG" ]; then
    LATEST_TAG="v0.0.0"
fi

BASE_TAG="${LATEST_TAG#v}"

IFS='.' read -r MAJOR MINOR PATCH <<<"$(echo "$BASE_TAG" | sed -E 's/-beta[0-9]*//')"
BETA=$(echo "$BASE_TAG" | grep -oP '(?<=-beta)\d*')

case "$EVENT_TYPE" in
major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    BETA=""
    ;;
minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    BETA=""
    ;;
patch)
    PATCH=$((PATCH + 1))
    BETA=""
    ;;
beta)
    PATCH=$((PATCH + 1))
    BETA=$PATCH
    ;;
*)
    echo "Unknown event type: $EVENT_TYPE"
    echo "Event type can be: major, minor, patch, beta"
    exit 1
    ;;
esac

if [ -n "$BETA" ]; then
    NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}-beta"
else
    NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
fi

git tag "$NEW_TAG"

git push origin "$NEW_TAG"

echo "::set-output name=tag_name::$NEW_TAG"

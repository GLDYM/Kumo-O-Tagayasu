#!/usr/bin/env bash

# prepare-release.sh
# Force a release tag to point at the current HEAD, then push it to origin.

set -euo pipefail

RELEASE_TAG="${1:-}"

if [[ -z "$RELEASE_TAG" ]]; then
  echo "Usage: $0 <release-tag>"
  exit 1
fi

git fetch --tags origin >/dev/null 2>&1 || true

CURRENT_COMMIT="$(git rev-parse HEAD)"
echo "Updating release tag ${RELEASE_TAG} to ${CURRENT_COMMIT}"

if git rev-parse --verify --quiet "refs/tags/${RELEASE_TAG}" >/dev/null; then
  git tag -d "${RELEASE_TAG}" >/dev/null 2>&1 || true
fi

git tag -f "${RELEASE_TAG}" "${CURRENT_COMMIT}"
git push origin "refs/tags/${RELEASE_TAG}" --force

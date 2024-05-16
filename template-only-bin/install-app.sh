#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script installs infrastructure for an application.
# It is called by other scripts.
#
# Positional parameters:
#   APP_NAME (required) - the name for the application, use kebab-case
#   DST_PREFIX (optional) - the directory that the application should be installed in
#     Defaults to "" (the current directory). If directory is supplied, must contain a
#     trailing slash.
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
DST_PREFIX=${2:-""}

echo "Creating a terraform module for application: $APP_NAME..."
cp -r template-infra/infra/app "${DST_PREFIX}infra/$APP_NAME"

# Helper to get the correct sed -i behavior for both GNU sed and BSD sed (installed by default on macOS)
# Hat tip: https://stackoverflow.com/a/38595160
sedi () {
  if sed --version >/dev/null 2>&1; then
    sed -i -- "$@"
  else
    sed -i "" "$@"
  fi
}
# Export the function so it can be used below
export -f sedi

echo "Setting up CI/CD for application: $APP_NAME..."
cp template-infra/.github/workflows/cd-app.yml "${DST_PREFIX}.github/workflows/cd-$APP_NAME.yml"
# This regex will capture all instances of `app` that end in a space, a double quote, a forward slash, or a hyphen
# We do this to avoid accidentally replacing the keyword `app_name`
LC_ALL=C sedi "s/app\([\s\"\/\-]\)/$APP_NAME\1/g" "${DST_PREFIX}.github/workflows/cd-$APP_NAME.yml"

cp template-infra/.github/workflows/ci-app-vulnerability-scans.yml  "${DST_PREFIX}.github/workflows/ci-$APP_NAME-vulnerability-scans.yml"
LC_ALL=C sedi "s/app\([\s\"\/\-]\)/$APP_NAME\1/g" "${DST_PREFIX}.github/workflows/ci-$APP_NAME-vulnerability-scans.yml"

#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script renames the application template in your project.
# Run this script in your project's root directory.
#
# Positional parameters:
#   NEW_NAME (required) - the new name for the application, in either snake- or kebab-case
#   OLD_NAME (optional) – the old name for the application, in either snake- or kebab-case
#       Defaults to the template's short name (e.g. app-rails)
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
CURRENT_VERSION=$(cat .template-version)

# Use kebab-case
APP_NAME_KEBAB=$(echo $APP_NAME | tr "_" "-")

# Helper to get the correct sed -i behavior for both GNU sed and BSD sed (installed by default on macOS)
# Hat tip: https://stackoverflow.com/a/38595160
sedi () {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}
# Export the function so it can be used later on
export -f sedi

echo "Cloning template-infra..."
git clone https://github.com/navapbc/template-infra.git

echo "Switching to this project's current version of the template..."
cd template-infra
git checkout "$CURRENT_VERSION"
cd - >& /dev/null

echo "Creating a terraform module for a new application..."
cp -r template-infra/infra/app infra/"$APP_NAME_KEBAB" 

echo "Setting up new application CI/CD..."
cp template-infra/.github/workflows/cd-app.yml .github/workflows/"cd-$APP_NAME_KEBAB.yml"
LC_ALL=C sedi "s/app\([\s\"\/\-]\)/$APP_NAME_KEBAB\1/g" .github/workflows/"cd-$APP_NAME_KEBAB.yml"

cp template-infra/.github/workflows/ci-app-vulnerability-scans.yml  .github/workflows/"ci-$APP_NAME_KEBAB-vulnerability-scans.yml"
LC_ALL=C sedi "s/app\([\s\"\/\-]\)/$APP_NAME_KEBAB\1/g" .github/workflows/"ci-$APP_NAME_KEBAB-vulnerability-scans.yml"

echo "Cleaning up template-infra folder..."
rm -fr template-infra

echo "...Done."
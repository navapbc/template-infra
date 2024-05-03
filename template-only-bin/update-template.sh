#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script updates template-infra in your project.
# Run this script in your project's root directory.
#
# Positional parameters:
#   APP_NAMES (required) – a comma-separated list of the apps in `/infra` with no spaces.
#     Defaults to `app`
#     Examples: `app`, `app,app2`, `my-app,your-app`
#
#   TARGET_VERSION (optional) – the version of the template application to install.
#     Defaults to main. Can be any target that can be checked out, including a branch,
#     version tag, or commit hash.
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAMES=${1:-"app"}
TARGET_VERSION=${2:-"main"}
CURRENT_VERSION=$(cat .template-version)

echo "Cloning template-infra..."
git clone https://github.com/navapbc/template-infra.git

echo "Creating template patch..."
cd template-infra
# Checkout the version of the template to update to
git checkout "$TARGET_VERSION"

# Get version hash to update .template-version after patch is successful
TARGET_VERSION_HASH=$(git rev-parse HEAD)

# Note: Keep this list in sync with the files copied in install-template.sh
INCLUDE_PATHS=" \
  .github \
  bin \
  docs \
  infra \
  Makefile \
  .dockleconfig \
  .grype.yml \
  .hadolint.yaml \
  .trivyignore"
git diff "$CURRENT_VERSION" "$TARGET_VERSION" -- "$INCLUDE_PATHS" > patch
cd - >& /dev/null

echo "Applying patch..."
# Note: Keep this list in sync with the removed files in install-template.sh
# Exclude the app files for now. They will be handled separately below.
EXCLUDE_OPT=" \
  --exclude=.github/workflows/template-only-* \
  --exclude=.github/workflows/*-app-*.yml \
  --exclude=infra/app"
git apply "$EXCLUDE_OPT" --allow-empty template-infra/update.patch

# Loop through the comma-separated list of apps
for APP_NAME in ${APP_NAMES//,/ }
do
  echo "Creating patch for $APP_NAME..."
  # This creates a git patch comparing a project app with the upstream `/infra/app` directory
  # --no-index allows us to compare differently named directories
  # --dst-prefix="" removes the destination prefix, essentially having the effect of removing the additional `template-infra/`
  #   path prefix, making the patch easily appliable
  # || true is necessary because this bash script includes `set -e`, which will immediately exit for any non-zero exit codes
  #   That's generally correct, but `git diff --no-index` will return 1 to indicate differences between the files. That's correct
  #   and expected behavior.
  git diff --no-index --dst-prefix="" "infra/$APP_NAME" template-infra/infra/app > "template-infra/$APP_NAME.patch" || true

  echo "Applying patch for $APP_NAME..."
  git apply --allow-empty "template-infra/$APP_NAME.patch"
done

echo "Saving new template version to .template-infra..."
echo "$TARGET_VERSION_HASH" > .template-version

echo "Cleaning up template-infra folder..."
rm -rf template-infra

echo "...Done."

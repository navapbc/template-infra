#!/bin/bash
# -----------------------------------------------------------------------------
# This script updates template-infra in your project. Run
# This script from your project's root directory.
#
# Positional parameters:
#   TARGET_VERSION (optional) – the version of template-infra to upgrade to.
#     Defaults to main.
# -----------------------------------------------------------------------------
set -euo pipefail

TARGET_VERSION=${1:-"main"}

CURRENT_VERSION=$(cat .template-version)

echo "Clone template-infra"
git clone git@github.com:navapbc/template-infra.git

echo "Creating patch"
cd template-infra
git checkout $TARGET_VERSION
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
git diff $CURRENT_VERSION $TARGET_VERSION -- $INCLUDE_PATHS > patch
cd -

echo "Applying patch"
# In addition to the template-only files, also exclude cd-app.yml and
# ci-infra.yml which have a bunch of commented out lines which can mess up the
# patch
EXCLUDE_OPT=" \
  --exclude=.github/workflows/template-only-* \
  --exclude=.github/workflows/cd-app.yml \
  --exclude=.github/workflows/ci-infra.yml"
git apply $EXCLUDE_OPT --allow-empty template-infra/patch

echo "Saving new template version to .template-infra"
echo "$TARGET_VERSION" > .template-version

echo "Clean up template-infra folder"
rm -fr template-infra

#!/bin/bash
#
# This script installs the template-infra to your project. Run
# This script from your project's root directory.
set -euox pipefail

CUR_DIR=$(pwd)
SCRIPT_DIR=$(dirname "$0")
TEMPLATE_DIR="$SCRIPT_DIR/.."

echo "Copy files from template-infra"
cd "$TEMPLATE_DIR"
# Note: Keep this list of paths in sync with INCLUDE_PATHS in update-template.sh
cp -r \
  .github \
  bin \
  docs \
  infra \
  Makefile \
  .dockleconfig \
  .grype.yml \
  .hadolint.yaml \
  .trivyignore \
  "$CUR_DIR"
cd -

echo "Remove files relevant only to template development"
# Note: Keep this list of paths in sync with EXCLUDE_OPT in update-template.sh
rm .github/workflows/template-only-*

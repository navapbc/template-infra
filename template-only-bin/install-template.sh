#!/bin/bash
#
# This script installs the template-infra to your project. Run
# This script from your project's root directory.
set -euox pipefail

CUR_DIR=$(pwd)
SCRIPT_DIR=$(dirname $0)
TEMPLATE_DIR="$SCRIPT_DIR/.."

echo "Copy files from template-infra"
cd $TEMPLATE_DIR
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
  $CUR_DIR
cd -

echo "Remove files relevant only to template development"
rm .github/workflows/template-only-*

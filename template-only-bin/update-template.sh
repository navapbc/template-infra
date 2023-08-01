#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

SCRIPT_DIR=$(dirname $0)

echo "Install template"
$SCRIPT_DIR/install-template.sh

# Restore project files with project-specific configuration that was defined as part of project setup.
# This includes the terraform backend configuration blocks and the project-config module
# Also restore project files that had lines that were commented out in the template, such as Makefile
# and cd.yml workflow
# Updates in any of these files need to be manually applied to the projects
# echo "Restore modified project files"
# git checkout HEAD -- \
  # .dockleconfig \
  # .github/workflows/build-and-publish.yml \
  # .github/workflows/cd.yml \
  # .github/workflows/ci-infra.yml \
  # .github/workflows/database-migrations.yml \
  # .grype.yml \
  # .hadolint.yaml \
  # .trivyignore \
  # infra/project-config/main.tf \
  # infra/app/app-config/main.tf


# This is the HEAD of the main branch before the commit is merged
CURRENT_VERSION=$(cat $SCRIPT_DIR/temp-track-template-version.sh)
echo $CURRENT_VERSION

git diff $CURRENT_VERSION -- .dockleconfig \
  .github/workflows/build-and-publish.yml \
  .github/workflows/cd.yml \
  .github/workflows/ci-infra.yml \
  .github/workflows/database-migrations.yml \
  .grype.yml \
  .hadolint.yaml \
  .trivyignore \
  infra/project-config/main.tf \
  infra/app/app-config/main.tf > template.patch # filter certain files.

git apply template.patch

rm template.patch
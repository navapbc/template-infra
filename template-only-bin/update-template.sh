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

echo "Clone template-infra"
git clone git@github.com:navapbc/template-infra.git

# Switch to target version
cd template-infra
git checkout $TARGET_VERSION
cd -

echo "Install template"
./template-infra/template-only-bin/install-template.sh

# Restore project files with project-specific configuration that was defined as part of project setup.
# This includes the terraform backend configuration blocks and the project-config module
# Also restore project files that had lines that were commented out in the template, such as Makefile
# and cd-app.yml workflow
# Updates in any of these files need to be manually applied to the projects
echo "Restore modified project files"
git checkout HEAD -- \
  .dockleconfig \
  .github/workflows/cd-app.yml \
  .github/workflows/ci-infra-service.yml \
  .grype.yml \
  .hadolint.yaml \
  .trivyignore \
  infra/project-config/main.tf \
  infra/app/app-config/main.tf

# Store template version in a file
cd template-infra
git rev-parse HEAD > ../.template-version
cd -

echo "Clean up template-infra folder"
rm -fr template-infra

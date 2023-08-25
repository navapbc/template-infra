#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

echo "Fetch latest version of template-infra"
git clone git@github.com:navapbc/template-infra.git

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

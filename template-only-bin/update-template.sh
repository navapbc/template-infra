#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

SCRIPT_DIR=$(dirname $0)

# echo "Install template"
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


# This is the last commit from template-infra that the project had access to.
PROJECT_VERSION=$(cat bin/template-version.txt)
# Current HEAD of the template repository
TEMPLATE_VERSION=$(git rev-parse HEAD)

# exclude certain files from automatically being changed
git diff $PROJECT_VERSION $TEMPLATE_VERSION -- ':(exclude).github/workflows/template-only-* :(exclude).dockleconfig \
  :(exclude).github/workflows/build-and-publish.yml \
  :(exclude).github/workflows/cd.yml \
  :(exclude).github/workflows/ci-infra.yml \
  :(exclude).github/workflows/database-migrations.yml \
  :(exclude).grype.yml \
  :(exclude).hadolint.yaml \
  :(exclude).trivyignore \
  :(exclude)infra/project-config/main.tf \ 
  :(exclude)infra/app/app-config/main.tf' -p > bin/template.patch 

echo "Applying patch"
git apply --ignore-whitespace --allow-empty template.patch

echo $TEMPLATE_VERSION > bin/template-version.txt
# remove patch file
rm template.patch

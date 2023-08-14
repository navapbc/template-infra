#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

SCRIPT_DIR=$(dirname $0)

# echo "Install template"
$SCRIPT_DIR/install-template.sh


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
git apply --ignore-whitespace --allow-empty bin/template.patch

echo $TEMPLATE_VERSION > bin/template-version.txt
# remove patch file
rm bin/template.patch

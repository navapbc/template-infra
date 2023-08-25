#!/bin/bash
set -euo pipefail

echo "Fetch latest version of template-infra"
git clone --single-branch --branch main --depth 1 git@github.com:navapbc/template-infra.git

echo "Install template"
./template-infra/template-only-bin/install-template.sh

# Store template version in a file
cd template-infra
git rev-parse HEAD > ../.template-version
cd -

echo "Clean up template-infra folder"
rm -fr template-infra

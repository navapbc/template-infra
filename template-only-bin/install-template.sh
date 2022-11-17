#!/bin/bash
set -euo pipefail

echo "Fetch latest version of template-infra"
git clone --single-branch --branch main --depth 1 git@github.com:navapbc/template-infra.git

echo "Copy files form template-infra"
cp -r \
  template-infra/.github \
  template-infra/bin \
  template-infra/docs \
  template-infra/infra \
  template-infra/Makefile \
  .

echo "Remove files relevant only to template development"
rm .github/workflows/template-only-*

echo "Clean up template-infra folder"
rm -fr template-infra

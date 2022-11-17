#!/bin/bash
set -euo pipefail

git clone --single-branch --branch main --depth 1 git@github.com:navapbc/template-infra.git

cp -r \
  template-infra/.github \
  template-infra/bin \
  template-infra/docs \
  template-infra/infra \
  template-infra/Makefile \
  .

rm .github/workflows/template-only-*

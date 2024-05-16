#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script downloads and installs infrastructure for an application.
# Run this script in your project's root directory.
#
# Positional parameters:
#   APP_NAME (required) - the name for the application, use kebab-case
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAME=$1
CURRENT_VERSION=$(cat .template-version)

# Enforce kebab-case
APP_NAME_KEBAB=$(echo "$APP_NAME" | tr "_" "-")

echo "Cloning template-infra..."
git clone https://github.com/navapbc/template-infra.git

echo "Switching to this project's current version of the template..."
cd template-infra
git checkout "$CURRENT_VERSION" >& /dev/null
cd - >& /dev/null

# Install the app
curl "https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/install-app.sh" | bash -s -- $APP_NAME

echo "Cleaning up template-infra folder..."
rm -fr template-infra

echo "...Done."
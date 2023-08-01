#!/bin/bash
#
# THIS FILE SHOULD BE REMOVED AFTER TESTING
# This script tracks the "version" of the template-infra repo.
# It collects the most recent commit hash so that the template deploy job can create a diff between the template repo and the application repos (e.g. template-flask)
set -euo pipefail

# Need to ensure that this is for the template
CUR_DIR=$(pwd)
SCRIPT_DIR=$(dirname $0)
TEMPLATE_DIR="$SCRIPT_DIR/.."

# Get the latest commit from template-infra
git rev-parse HEAD
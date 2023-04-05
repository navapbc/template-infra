#!/bin/bash
set -euo pipefail

# Printthe current account alias
echo -n "$(aws sts get-caller-identity --query "Account" --output text)"

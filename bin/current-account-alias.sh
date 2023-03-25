#!/bin/bash
set -euo pipefail

# Printthe current account alias
echo -n "$(aws iam list-account-aliases --query "AccountAliases" --max-items 1 --output text)"

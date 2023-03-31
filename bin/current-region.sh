#!/bin/bash
set -euo pipefail

# Print the current region
echo -n "$(aws configure list | grep region | awk '{print $2}')"

#!/bin/bash
set -euo pipefail

# Printthe current account alias
echo -n "$(aws configure get region)"

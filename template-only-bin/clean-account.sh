#!/bin/bash
#
# This script updates template-infra in your project. Run
# This script from your project's root directory.
set -euo pipefail

BUCKETS=$(aws s3api list-buckets --no-cli-pager --query 'Buckets[*].Name' --output text)

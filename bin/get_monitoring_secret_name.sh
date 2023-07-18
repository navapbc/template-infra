#!/bin/bash
# Print the name for SSM attribute that contains monitoring secret
set -euo pipefail
echo -n "$(cat infra/app/app-config/env-config/outputs.tf | grep ssm_incident_management_secret_name | awk '{print $3}' | sed 's/var\.//g' | sed 's/\"//g' | sed 's/app_name/APP_NAME/' | sed 's/environment/ENVIRONMENT/' | sed 's/{//g' | sed 's/}//g')"

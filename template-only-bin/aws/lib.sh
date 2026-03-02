#!/usr/bin/env bash

aws::extract_region_from_arn() {
  local arn=$1
  # standard ARN format is:
  #
  #   arn:<partition>:<service>:<region>:<account-id>:<resource>
  #
  # so grab the fourth field
  echo "${arn}" | cut -d: -f4
}

#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script updates template-infra in your project.
# Run this script in your project's root directory.
#
# Positional parameters:
#   APP_NAMES (required) – a comma-separated list of the apps in `/infra` with no spaces.
#     Defaults to `app`
#     Examples: `app`, `app,app2`, `my-app,your-app`
#
#   TARGET_VERSION (optional) – the version of the template application to install.
#     Defaults to main. Can be a branch, commit hash, or tag.
#
#   TARGET_VERSION_TYPE (optional) – the version of the template application to install.
#     Defaults to branch. Can be: branch, commit, tag.
# -----------------------------------------------------------------------------
set -euo pipefail

APP_NAMES=$1
TARGET_VERSION=${2:-"main"}
TARGET_VERSION_TYPE=${3:-"branch"}
CURRENT_VERSION=$(cat .template-version)
TARGET_VERSION_HASH=""

echo "====================================================================="
echo "Updating template-infra"
echo "====================================================================="
echo "APP_NAMES=$APP_NAMES"
echo "TARGET_VERSION=$TARGET_VERSION"
echo "TARGET_VERSION_TYPE=$TARGET_VERSION_TYPE"

# Check: that $APP_NAMES is not empty string
if [ -z "$APP_NAMES" ]; then
  echo "Error: APP_NAMES cannot be empty."
  echo "  Please supply a comma-separated list of applications in /infra."
  echo "  Example: app"
  echo "  Example: app,app2"
  echo "Exiting."
  exit 1
fi

# Check: that all the apps passed in exist
# Loop through the comma-separated list of apps
for APP_NAME in ${APP_NAMES//,/ }
do
  if [ ! -d "infra/$APP_NAME" ]; then
    echo "Error: infra/$APP_NAME does not exist. Exiting."
    exit 1
  fi
done

# Check: that TARGET_VERSION_TYPE is valid
case $TARGET_VERSION_TYPE in
  "branch"|"commit"|"tag")
    # Acceptable options, do nothing
    ;;
  *)
    echo "Error: TARGET_VERSION_TYPE must be: branch, commit, or tag"
    exit 1
esac

echo
echo "---------------------------------------------------------------------"
echo "1. Patching: main template"
echo "---------------------------------------------------------------------"
echo "Temporarily creating remote 'upstream-template-infra'..."
echo
git remote add upstream-template-infra https://github.com/navapbc/template-infra.git

echo "Fetching from upstream remote..."
echo
git fetch upstream-template-infra

# Get target version hash
echo
echo "Converting $TARGET_VERSION to hash..."
case $TARGET_VERSION_TYPE in
  "branch")
    TARGET_VERSION_HASH=$(git rev-parse upstream-template-infra/$TARGET_VERSION)
    ;;
  "commit")
    echo "No conversion needed."
    TARGET_VERSION_HASH=$TARGET_VERSION
    ;;
  "tag")
    TARGET_VERSION_HASH=$(git ls-remote --tags upstream-template-infra $TARGET_VERSION | cut -d$'\t' -f1)
    ;;
esac
echo "TARGET_VERSION_HASH=$TARGET_VERSION_HASH"
echo

# Note: Keep this list in sync with the files copied in install-template.sh
INCLUDE_PATHS="
  .github
  bin
  docs
  infra
  Makefile
  .dockleconfig
  .grype.yml
  .hadolint.yaml
  .trivyignore"

# Note: Exclude template-only files, terraform deployment files, and all files related to
#   application(s) as those are handled separately below.
EXCLUDE_PATHS="
  ':!.github/workflows/template-only-*'
  ':!*.terraform*'
  ':!*.tfbackend'
  ':!.github/workflows/*app*.yml'"

# Exclude all applications
for APP_NAME in ${APP_NAMES//,/ }
do
  EXCLUDE_PATHS="${EXCLUDE_PATHS} ':!infra/$APP_NAME'"
done

# Show the changes to be made
STAT_COMMAND="git --no-pager diff -R --stat $TARGET_VERSION_HASH -- $(echo $INCLUDE_PATHS) $(echo $EXCLUDE_PATHS)"
eval "$STAT_COMMAND"

# Make the patch file
DIFF_COMMAND="git diff -R $TARGET_VERSION_HASH -- $(echo $INCLUDE_PATHS) $(echo $EXCLUDE_PATHS)"
eval "$DIFF_COMMAND > main-template.patch"

# Apply the patch file
git apply --allow-empty main-template.patch

echo
echo "---------------------------------------------------------------------"
echo "2. Preparing to patch application(s)"
echo "---------------------------------------------------------------------"
git clone https://github.com/navapbc/template-infra.git
cd template-infra
git checkout "$TARGET_VERSION_HASH"
cd - >& /dev/null

# Patch each application
STEP_COUNT=3
for APP_NAME in ${APP_NAMES//,/ }
do
  echo
  echo "---------------------------------------------------------------------"
  echo "$STEP_COUNT. Patching application: $APP_NAME"
  echo "---------------------------------------------------------------------"
  # This creates a git patch comparing a project app with the upstream `/infra/app` directory
  # --no-index allows us to compare differently named directories
  # --dst-prefix="" removes the destination prefix, essentially having the effect of removing the additional `template-infra/`
  #   path prefix, making the patch easily appliable
  # || true is necessary because this bash script includes `set -e`, which will immediately exit for any non-zero exit codes
  #   That's generally correct, but `git diff --no-index` will return 1 to indicate differences between the files. That's correct
  #   and expected behavior.
  git diff --no-index --dst-prefix="" "infra/$APP_NAME" template-infra/infra/app > "template-infra/$APP_NAME.patch" || true

  # This is the second part that allows comparing between directories with different names
  # -p3 strips the first 3 path fragments from filenames
  #   Ex: if the filename is `a/infra/app/app-config/dev.tf`, then -p3 causes it to become: `app-config/dev.tf`
  # --directory="infra/$APP_NAME" prepends path parts to the filename
  #   Ex: if the filename is `a/infra/app/app-config/dev.tf`, then --directory causes it to become: `/infra/$APP_NAME/app-config/dev.tf`
  # This is the stat version of the command to output the changes
  STAT_COMMAND="git --no-pager apply --stat -p3 --directory=infra/$APP_NAME --allow-empty template-infra/$APP_NAME.patch --exclude='*.tfbackend' --exclude='*.terraform*'"
  eval "$STAT_COMMAND"

  # Actually running the command `git apply`
  git apply -p3 --directory="infra/$APP_NAME" --allow-empty "template-infra/$APP_NAME.patch" --exclude="*.tfbackend" --exclude="*.terraform*"

  # Increment step counter
  STEP_COUNT=$((STEP_COUNT+1))

  # @TODO patch for CI/CD
done

echo
echo "---------------------------------------------------------------------"
echo "$STEP_COUNT. Cleaning up"
echo "---------------------------------------------------------------------"
echo "Saving new template version to .template-infra..."
echo "$TARGET_VERSION_HASH" > .template-version

echo "Removing patch files..."
rm main-template.patch

echo "Removing git remote..."
git remote rm upstream-template-infra

# echo "Cleaning up template-infra folder..."
# rm -rf template-infra

echo
echo "====================================================================="
echo "Done."
echo "====================================================================="

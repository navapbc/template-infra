#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This script updates template-infra in your project.
# Run this script in your project's root directory.
#
# This script uses git to create patch files between the current HEAD and the
# TARGET_VERSION argument. For the main portion of the template, it sets the upstream
# github repo as a remote, creates a patch file, and applies it. The git-apply excludes
# template-only files. For applications, because they often do not retain the default
# `app` name, a different approach is needed. To create the patch for applications, the
# upstream repo is cloned into a sub-directory and `git diff --no-index` is used to
# compare differently-named directories.
#
# Usage:
#   ./template-only-bin/update-template.sh <APP_NAMES> <TARGET_VERSION> <TARGET_VERSION_TYPE>
#
# Positional parameters:
#   APP_NAMES (required) – a comma-separated list (no spaces) of the apps in `/infra`. App
#     names are expected to be hyphen-separated (i.e. kebab-case).
#     Examples: `app`, `app,app2`, `my-app,your-app`
#
#   TARGET_VERSION (optional) – the version of the template to install
#     Defaults to main. Can be a branch, commit hash, or tag.
#
#   TARGET_VERSION_TYPE (optional) – the type of TARGET_VERSION provided
#     Defaults to branch. Can be: branch, commit, or tag.
#
# Examples:
# - To update a project with one application named `app` to `main` in the template repo:
#   ./template-only-bin/update-template.sh app
#
# - To update a project with two applications to a specific commit:
#   ./template-only-bin/update-template.sh app,app2 d42963d007e55cc37ef666019428b1d06a25cf71 commit
#
# - To update a project with three applications to a tag:
#   ./template-only-bin/update-template.sh alpha,beta,gamma-three v0.8.0 tag
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
echo

# Check: that the git repo is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "Error: Commit or stash all changes before proceeding. Exiting."
  exit 1
fi

# Check: that $APP_NAMES is not an empty string
if [ -z "$APP_NAMES" ]; then
  echo "Error: APP_NAMES cannot be empty."
  echo "  Please supply a comma-separated list of applications in /infra."
  echo "  Example: app"
  echo "  Example: app,app2"
  echo "Exiting."
  exit 1
fi

# Check: that all the apps exist
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
    echo "Error: TARGET_VERSION_TYPE must be: branch, commit, or tag. Exiting."
    exit 1
esac

echo "---------------------------------------------------------------------"
echo "1. Patching: main template"
echo "---------------------------------------------------------------------"
echo "Temporarily creating remote 'upstream-template-infra'..."
echo
git remote add upstream-template-infra https://github.com/navapbc/template-infra.git

echo "Fetching from upstream remote..."
echo
git fetch upstream-template-infra >& /dev/null

# Get target version hash
echo "Converting $TARGET_VERSION to hash..."
case $TARGET_VERSION_TYPE in
  "branch")
    TARGET_VERSION_HASH="$(git rev-parse upstream-template-infra/$TARGET_VERSION)"
    ;;
  "commit")
    echo "No conversion needed."
    TARGET_VERSION_HASH=$TARGET_VERSION
    ;;
  "tag")
    TARGET_VERSION_HASH="$(git ls-remote --tags upstream-template-infra $TARGET_VERSION | cut -d$'\t' -f1)"
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

# Note: Exclude terraform deployment files, and CI/CD workflows as those are handled
# separately below.
EXCLUDE_PATHS="
  ':!*.terraform*'
  ':!*.tfbackend'
  ':!.github/workflows/'"

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
  # If the APP_NAME is not named `app`, then install a new app in template-infra to diff against
  if [ "$APP_NAME" != "app" ]; then
    curl "https://raw.githubusercontent.com/navapbc/template-infra/main/template-only-bin/install-app.sh" | bash -s -- $APP_NAME "template-infra/"
    echo
  fi

  # To create a git patch comparing a project's application:
  # --no-index allows us comparison between differently-named or -nested directories
  # --dst-prefix="" removes the destination prefix, essentially having the effect of
  #   removing the additional `template-infra/` path prefix, making the patch appliable
  # || true is necessary because this bash script includes `set -e` option, which will
  #   immediately exit for any non-zero exit codes. That's generally correct, but
  #   `git diff --no-index` will return 1 to indicate differences between the files.
  git diff --no-index --dst-prefix="" "infra/$APP_NAME" "template-infra/infra/$APP_NAME" > "template-infra/$APP_NAME.patch" || true

  # The stat version of the `git-apply` command`, used to output the changes to STDOUT
  STAT_COMMAND="git --no-pager apply --stat --allow-empty template-infra/$APP_NAME.patch --exclude='*.tfbackend' --exclude='*.terraform*'"
  eval "$STAT_COMMAND"

  # Actually run the `git apply` command
  git apply --allow-empty "template-infra/$APP_NAME.patch" --exclude="*.tfbackend" --exclude="*.terraform*"

  # Increment step counter
  STEP_COUNT=$((STEP_COUNT+1))
done

echo
echo "---------------------------------------------------------------------"
echo "$STEP_COUNT. Patching CI/CD"
echo "---------------------------------------------------------------------"
# This follows the same pattern as above
git diff --no-index --dst-prefix="" .github/workflows template-infra/.github/workflows > "template-infra/ci-$APP_NAME.patch"  || true
STAT_COMMAND="git --no-pager apply --stat --allow-empty template-infra/ci-$APP_NAME.patch --exclude='.github/workflows/template-only*'"
eval "$STAT_COMMAND"
git apply --allow-empty "template-infra/ci-$APP_NAME.patch" --exclude=".github/workflows/template-only*"
STEP_COUNT=$((STEP_COUNT+1))

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

echo "Cleaning up template-infra folder..."
rm -rf template-infra

echo
echo "====================================================================="
echo "Done."
echo "====================================================================="
echo "Review all changes carefully using 'git diff' before committing"
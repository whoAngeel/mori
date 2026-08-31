#!/usr/bin/env bash
#
# Rename this template to a fresh project.
#
#   ./rename_project.sh <new_package_name> [android_domain]
#
#   ./rename_project.sh awesome_app
#   ./rename_project.sh awesome_app com.acme
#
# Package name must be lower_snake_case. Run from the repo root.
set -euo pipefail

OLD_NAME="mori"
OLD_DOMAIN="com.example"

NEW_NAME="${1:-}"
NEW_DOMAIN="${2:-com.example}"

if [[ -z "$NEW_NAME" ]]; then
  echo "Usage: ./rename_project.sh <new_package_name> [android_domain]"
  exit 1
fi
if [[ ! "$NEW_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Error: '$NEW_NAME' is not a valid lower_snake_case package name."
  exit 1
fi

echo ">> $OLD_NAME  ->  $NEW_NAME"
echo ">> $OLD_DOMAIN.$OLD_NAME  ->  $NEW_DOMAIN.$NEW_NAME"

# 1. Dart imports, pubspec `name:`, docs. Word-boundary match avoids touching
#    substrings like "memory".
grep -rlZ --include='*.dart' --include='*.yaml' --include='*.md' \
  --binary-files=without-match "$OLD_NAME" lib test pubspec.yaml README.md 2>/dev/null |
  xargs -0 -r perl -pi -e "s/\\b\\Q${OLD_NAME}\\E\\b/${NEW_NAME}/g"

# 2. Android namespace + applicationId + Kotlin package path.
grep -rlZ --binary-files=without-match "${OLD_DOMAIN}.${OLD_NAME}" android 2>/dev/null |
  xargs -0 -r perl -pi -e "s/\\Q${OLD_DOMAIN}.${OLD_NAME}\\E/${NEW_DOMAIN}.${NEW_NAME}/g"

# 3. Drop stale generated files, then regenerate.
find lib -name '*.g.dart' -delete
flutter pub get
dart run build_runner build --delete-conflicting-outputs

echo ">> Done. Review 'git diff', rename the repo folder, then 'flutter run'."

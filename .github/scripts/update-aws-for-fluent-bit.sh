#!/usr/bin/env bash
#
# Detects and updates the version of aws-for-fluent-bit in the repository.
#
set -euo pipefail

# 1. Fetch latest release tag from GitHub (filtering for v3.x tags)
if [ -n "${GITHUB_TOKEN:-}" ]; then
  LATEST_TAG=$(curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/aws/aws-for-fluent-bit/releases | jq -r '[.[] | select(.prerelease==false and .draft==false and (.tag_name | startswith("v3.")))] | first | .tag_name')
else
  LATEST_TAG=$(curl -s -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/aws/aws-for-fluent-bit/releases | jq -r '[.[] | select(.prerelease==false and .draft==false and (.tag_name | startswith("v3.")))] | first | .tag_name')
fi

if [ -z "$LATEST_TAG" ] || [ "$LATEST_TAG" = "null" ]; then
  echo "Error: Failed to fetch latest tag from GitHub API."
  exit 1
fi

# Remove leading 'v' if present (e.g. v3.4.7 -> 3.4.7)
LATEST_VERSION="${LATEST_TAG#v}"
echo "Latest aws-for-fluent-bit 3.x version found: $LATEST_VERSION"

# 2. Search for existing aws-for-fluent-bit image tags in json/yaml/yml files
UPDATED=false

# Search for files containing amazon/aws-for-fluent-bit:
# We use 2>/dev/null and '|| true' to avoid script exit if grep finds nothing
files=$(grep -rn "amazon/aws-for-fluent-bit:" --include="*.json" --include="*.yml" --include="*.yaml" . 2>/dev/null | cut -d: -f1 | sort -u || true)

if [ -z "$files" ]; then
  echo "No aws-for-fluent-bit image definitions found in the repository."
  echo "updates_detected=false" >> "${GITHUB_OUTPUT:-/dev/null}"
  exit 0
fi

for file in $files; do
  # Extract current version
  CURRENT_VERSION=$(sed -n 's/.*amazon\/aws-for-fluent-bit:\([0-9a-zA-Z.-]*\).*/\1/p' "$file" | head -n 1)
  
  if [ -z "$CURRENT_VERSION" ]; then
    continue
  fi
  
  echo "Checking $file (current version: $CURRENT_VERSION)"
  
  # Only update if the current version in the file is a 3.x version
  if [[ ! "$CURRENT_VERSION" =~ ^3\. ]]; then
    echo "Skipping $file: version '$CURRENT_VERSION' is not a 3.x version."
    continue
  fi
  
  if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Updating $file: $CURRENT_VERSION -> $LATEST_VERSION"
    # Perform literal match and replace using Perl to be cross-platform
    perl -pi -e "s{\Qamazon/aws-for-fluent-bit:$CURRENT_VERSION\E}{amazon/aws-for-fluent-bit:$LATEST_VERSION}g" "$file"
    UPDATED=true
  fi
done

if [ "$UPDATED" = "true" ]; then
  echo "updates_detected=true" >> "${GITHUB_OUTPUT:-/dev/null}"
  echo "latest_version=$LATEST_VERSION" >> "${GITHUB_OUTPUT:-/dev/null}"
else
  echo "updates_detected=false" >> "${GITHUB_OUTPUT:-/dev/null}"
  echo "All aws-for-fluent-bit image references are up to date."
fi

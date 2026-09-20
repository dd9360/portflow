#!/usr/bin/env bash
set -Eeuo pipefail

# Pin the tested revision so a stale CDN response for main cannot reinstall old code.
# Override PF_BASE_URL when serving these same files from a trusted mirror.
BASE_URL=${PF_BASE_URL:-https://raw.githubusercontent.com/dd9360/portflow/3f0e9bee867fa0f505c5dc771a594a0077dda809}
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
for file in pf install.sh portflow.service; do
  curl --fail --location --silent --show-error --retry 3 \
    "$BASE_URL/$file" --output "$TMP_DIR/$file"
done
bash "$TMP_DIR/install.sh"

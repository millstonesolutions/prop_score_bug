#!/bin/bash
# Builds "Score Bug Server.app" into /Applications, pointed at this repository's folder.
# Re-run it if you move the repository.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(cd "$here/.." && pwd)"
app="/Applications/Score Bug Server.app"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Escape for an AppleScript string literal, then for sed.
esc_repo="$(printf '%s' "$repo" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/[&|]/\\&/g')"
sed "s|__REPO_DIR__|$esc_repo|" "$here/Score Bug Server.applescript" > "$tmp/app.applescript"

rm -rf "$app"
osacompile -o "$app" "$tmp/app.applescript"
echo "Installed $app -> serves $repo"

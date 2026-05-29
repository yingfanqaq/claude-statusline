#!/bin/bash
# Install/restore Claude Code statusline configuration.
# Run after Claude Code updates if statusline disappears.

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_SCRIPT="$HOME/.claude/statusline.sh"
SETTINGS="$HOME/.claude/settings.json"

# 1. Copy script
cp "$REPO_DIR/statusline.sh" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
echo "✓ Script installed at $TARGET_SCRIPT"

# 2. Patch settings.json — add/update statusLine field
python3 - <<EOF
import json, sys, os
path = "$SETTINGS"
if not os.path.exists(path):
    print("settings.json not found, creating one")
    data = {}
else:
    with open(path) as f:
        data = json.load(f)

data["statusLine"] = {
    "type": "command",
    "command": "$TARGET_SCRIPT",
    "refreshInterval": 5
}

with open(path, "w") as f:
    json.dump(data, f, indent=2)
print("✓ statusLine added to $SETTINGS")
EOF

echo ""
echo "Done. Restart Claude Code to see the statusline."

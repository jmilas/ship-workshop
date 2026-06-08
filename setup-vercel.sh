#!/bin/bash
set -e

WORKSHOP_DIR="/workspaces/ship-workshop"
PROJECT_DIR=$(pwd)

echo "Setting up Vercel deployment for: $PROJECT_DIR"
echo ""

# Copy deploy hook into .slack/hooks.json
cp "$WORKSHOP_DIR/vercel-deploy/hooks.json" "$PROJECT_DIR/.slack/hooks.json"

# Copy deploy script
mkdir -p "$PROJECT_DIR/scripts"
cp "$WORKSHOP_DIR/scripts/deploy.sh" "$PROJECT_DIR/scripts/deploy.sh"
chmod +x "$PROJECT_DIR/scripts/deploy.sh"

# Copy Vercel config
cp "$WORKSHOP_DIR/vercel-deploy/vercel.json" "$PROJECT_DIR/vercel.json"

# Copy HTTP-mode entry point
mkdir -p "$PROJECT_DIR/api"
cp "$WORKSHOP_DIR/vercel-deploy/api/slack.js" "$PROJECT_DIR/api/slack.js"

# Disable socket mode in manifest
sed -i 's/"socket_mode_enabled": true/"socket_mode_enabled": false/' "$PROJECT_DIR/manifest.json"

echo "✓ Project configured for Vercel deployment."
echo ""
echo "Next steps:"
echo "  1. Run: slack app install --environment deployed"
echo "  2. Run: bash /workspaces/ship-workshop/setup-vercel-credentials.sh"
echo "  3. Run: slack deploy"
echo ""

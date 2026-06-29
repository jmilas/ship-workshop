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

# Fix already_reacted error in emoji reaction tool
if [ -f "$PROJECT_DIR/agent/tools/add-emoji-reaction.js" ]; then
  sed -i "s/return \`Could not add reaction: \${err.data?.error || err.message}\`;/if (err.data?.error === 'already_reacted') return \`Reacted with :\${emoji_name}:\`;\n      return \`Could not add reaction: \${err.data?.error || err.message}\`;/" "$PROJECT_DIR/agent/tools/add-emoji-reaction.js"
fi

# Add retry logic for API rate limits
bash "$WORKSHOP_DIR/scripts/patch-retry.sh" "$PROJECT_DIR"

# Deploy a stub to Vercel to establish the project URL
echo "Creating Vercel project..."
DEPLOY_OUTPUT=$(vercel deploy --prod --yes --token "$VERCEL_TOKEN" 2>&1)
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[a-zA-Z0-9._-]+\.vercel\.app' | tail -1)

if [ -z "$DEPLOY_URL" ]; then
  echo "Error: Could not establish Vercel project URL."
  echo "$DEPLOY_OUTPUT"
  exit 1
fi

# Write the Vercel URL into the manifest
REQUEST_URL="${DEPLOY_URL}/api/slack"
sed -i.bak "s|\"request_url\": \"[^\"]*\"|\"request_url\": \"${REQUEST_URL}\"|g" "$PROJECT_DIR/manifest.json"
rm -f "$PROJECT_DIR/manifest.json.bak"

echo ""
echo "✓ Vercel deployment configured!"
echo "  URL: $DEPLOY_URL"
echo "  Request URL: $REQUEST_URL"
echo ""
echo "Next step: run 'slack deploy'"
echo ""

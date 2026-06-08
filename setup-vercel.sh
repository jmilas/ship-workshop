#!/bin/bash
set -e

WORKSHOP_DIR="/workspaces/ship-workshop"
PROJECT_DIR=$(pwd)

echo "Setting up Vercel deployment for: $PROJECT_DIR"
echo ""

# Get credentials from the user
echo "We need two values from your app settings for Vercel deployment."
echo "Opening your app settings now..."
echo ""
slack app settings
echo ""
echo "1. Go to Basic Information → copy the Signing Secret"
read -p "Paste your Signing Secret: " SIGNING_SECRET

if [ -z "$SIGNING_SECRET" ]; then
  echo "Error: Signing Secret is required."
  exit 1
fi

echo ""
echo "2. Go to OAuth & Permissions → copy the Bot User OAuth Token (starts with xoxb-)"
read -p "Paste your Bot Token: " BOT_TOKEN

if [ -z "$BOT_TOKEN" ]; then
  echo "Error: Bot Token is required."
  exit 1
fi

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

# Write env vars for Vercel deployment
cat > "$PROJECT_DIR/.env.vercel" <<EOF
SLACK_SIGNING_SECRET=$SIGNING_SECRET
SLACK_BOT_TOKEN=$BOT_TOKEN
EOF

# Add API key if set in environment
if [ -n "$OPENAI_API_KEY" ]; then
  echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> "$PROJECT_DIR/.env.vercel"
elif [ -n "$ANTHROPIC_API_KEY" ]; then
  echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> "$PROJECT_DIR/.env.vercel"
fi

echo ""
echo "✓ Vercel deployment configured!"
echo ""
echo "Run 'slack deploy' to deploy your agent."
echo ""

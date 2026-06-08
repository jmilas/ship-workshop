#!/bin/bash
set -e

PROJECT_DIR=$(pwd)

echo "Collecting credentials for Vercel deployment."
echo ""
echo "Opening your app settings..."
echo ""
slack app settings --app deployed
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
echo "✓ Credentials saved!"
echo ""
echo "Run 'slack deploy' to deploy your agent."
echo ""

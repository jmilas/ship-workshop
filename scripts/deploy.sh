#!/bin/bash
set -e

echo "Deploying to Vercel..."

# Push env vars to Vercel
if [ -f .env.vercel ]; then
  echo "Setting Vercel environment variables..."
  grep -v '^#' .env.vercel | grep -v '^$' | while IFS='=' read -r key value; do
    echo "$value" | vercel env add "$key" production --force --yes 2>/dev/null || true
  done
fi

# Deploy to Vercel and capture the production URL
DEPLOY_OUTPUT=$(vercel deploy --prod --yes 2>&1)
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[a-zA-Z0-9._-]+\.vercel\.app' | tail -1)

if [ -z "$DEPLOY_URL" ]; then
  echo "Error: Could not extract deployment URL from Vercel output."
  echo "$DEPLOY_OUTPUT"
  exit 1
fi

echo "Deployed to: $DEPLOY_URL"

# Update manifest.json with the new request URL
REQUEST_URL="${DEPLOY_URL}/slack/events"

if [ ! -f manifest.json ]; then
  echo "Error: manifest.json not found in current directory."
  exit 1
fi

# Update event subscription request_url
sed -i.bak "s|\"request_url\": \"[^\"]*\"|\"request_url\": \"${REQUEST_URL}\"|g" manifest.json
rm -f manifest.json.bak

echo "Updated manifest.json request_url to: $REQUEST_URL"

# Push the manifest update to Slack
echo "Updating Slack app manifest..."
slack manifest update

echo ""
echo "Deploy complete!"
echo "  Vercel URL: $DEPLOY_URL"
echo "  Request URL: $REQUEST_URL"
echo ""
echo "Your agent is now live. DM it in Slack!"

#!/bin/bash
set -e

echo "Deploying to Vercel..."

# Push env vars to Vercel BEFORE deploying so the function has them on first boot
if [ -n "$SLACK_BOT_TOKEN" ]; then
  echo "Setting SLACK_BOT_TOKEN..."
  if ! echo "$SLACK_BOT_TOKEN" | vercel env add SLACK_BOT_TOKEN production --force --yes --token "$VERCEL_TOKEN"; then
    echo "⚠️  Failed to set SLACK_BOT_TOKEN — the deployed app may not work."
  fi
else
  echo "⚠️  SLACK_BOT_TOKEN is not set. Make sure you're running this via 'slack deploy'."
fi

if [ -n "$OPENAI_API_KEY" ]; then
  echo "Setting OPENAI_API_KEY..."
  if ! echo "$OPENAI_API_KEY" | vercel env add OPENAI_API_KEY production --force --yes --token "$VERCEL_TOKEN"; then
    echo "⚠️  Failed to set OPENAI_API_KEY"
  fi
elif [ -n "$ANTHROPIC_API_KEY" ]; then
  echo "Setting ANTHROPIC_API_KEY..."
  if ! echo "$ANTHROPIC_API_KEY" | vercel env add ANTHROPIC_API_KEY production --force --yes --token "$VERCEL_TOKEN"; then
    echo "⚠️  Failed to set ANTHROPIC_API_KEY"
  fi
fi

# Deploy to Vercel (env vars are now set, so this deployment will have them)
echo ""
echo "Deploying code..."
DEPLOY_OUTPUT=$(vercel deploy --prod --yes --token "$VERCEL_TOKEN" 2>&1)
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[a-zA-Z0-9._-]+\.vercel\.app' | tail -1)

if [ -z "$DEPLOY_URL" ]; then
  echo "Error: Could not extract deployment URL from Vercel output."
  echo "$DEPLOY_OUTPUT"
  exit 1
fi

echo "Deployed to: $DEPLOY_URL"

# Update manifest.json with the new request URL
REQUEST_URL="${DEPLOY_URL}/api/slack"

if [ ! -f manifest.json ]; then
  echo "Error: manifest.json not found in current directory."
  exit 1
fi

# Update request_url entries
sed -i.bak "s|\"request_url\": \"[^\"]*\"|\"request_url\": \"${REQUEST_URL}\"|g" manifest.json
rm -f manifest.json.bak

echo "Updated manifest.json request_url to: $REQUEST_URL"

# Health check — verify the function responds
echo ""
echo "Verifying deployment..."
sleep 3
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$REQUEST_URL")

if [ "$HTTP_STATUS" = "000" ]; then
  echo "⚠️  Could not reach $REQUEST_URL — check your deployment."
elif [ "$HTTP_STATUS" -ge 500 ]; then
  echo "⚠️  Deployment returned HTTP $HTTP_STATUS. Try running 'slack deploy' again."
else
  echo "✓ Deployment healthy (HTTP $HTTP_STATUS)"
fi

echo ""
echo "Deploy complete!"
echo "  Vercel URL: $DEPLOY_URL"
echo "  Request URL: $REQUEST_URL"
echo ""
echo "The manifest has been updated locally."
echo "Run 'slack deploy' again to push the new request URL to Slack."
echo ""

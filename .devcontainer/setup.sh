#!/bin/bash
set -e

echo "Installing Slack CLI..."
curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash

echo "Installing Vercel CLI..."
npm install -g vercel

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run: slack login"
echo "  2. Paste the slash command into your Slack developer sandbox"
echo "  3. Run: slack create agent"
echo ""

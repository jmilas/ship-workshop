#!/bin/bash

# Avoid duplicate PATH entries on Codespace rebuild
if ! grep -q 'slack/bin' ~/.bashrc 2>/dev/null; then
  echo 'export PATH="$HOME/.slack/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/.slack/bin:$HOME/.local/bin:$PATH"

echo "Installing Slack CLI..."
if curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash; then
  echo "✓ Slack CLI installed"
else
  echo "   Retrying Slack CLI install..."
  sleep 3
  if curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash; then
    echo "✓ Slack CLI installed (on retry)"
  else
    echo "⚠️  Slack CLI install failed — run manually:"
    echo "   curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash"
  fi
fi

echo ""
echo "Installing Vercel CLI..."
if npm install -g vercel --silent; then
  echo "✓ Vercel CLI installed"
else
  echo "   Retrying Vercel CLI install..."
  sleep 3
  if npm install -g vercel --silent; then
    echo "✓ Vercel CLI installed (on retry)"
  else
    echo "⚠️  Vercel CLI install failed — run manually:"
    echo "   npm install -g vercel"
  fi
fi

# Verify both tools are available
echo ""
MISSING=""
command -v slack >/dev/null 2>&1 || MISSING="slack "
command -v vercel >/dev/null 2>&1 || MISSING="${MISSING}vercel"

if [ -z "$MISSING" ]; then
  echo "✓ Setup complete!"
  echo ""
  echo "Next steps:"
  echo "  1. Run: slack login"
  echo "  2. Paste the slash command into your Slack developer sandbox"
  echo "  3. Run: slack create agent"
else
  echo "⚠️  Setup finished with issues. Missing: $MISSING"
  echo "   Try opening a new terminal (PATH may need to reload), or install manually."
fi
echo ""

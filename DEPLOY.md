# Deploy to Vercel

This guide converts your agent from local (`slack run`) to always-on (Vercel).

## What changes

| | Local (`slack run`) | Deployed (Vercel) |
|---|---|---|
| Connection | Socket Mode (WebSocket) | HTTP (request URL) |
| Hosting | Your terminal | Vercel serverless functions |
| Lifecycle | Runs while terminal is open | Always on |

## Steps

### 1. Add the Vercel files

Copy these files into your agent project:

```bash
cp /workspaces/ship-workshop/vercel-deploy/vercel.json .
cp /workspaces/ship-workshop/vercel-deploy/api/slack.js api/slack.js
cp /workspaces/ship-workshop/vercel-deploy/hooks.json .slack/hooks.json
cp /workspaces/ship-workshop/scripts/deploy.sh scripts/deploy.sh
```

### 2. Update the manifest

In `manifest.json`, change `socket_mode_enabled` to `false`:

```json
"settings": {
  "socket_mode_enabled": false
}
```

### 3. Deploy

```bash
slack deploy
```

This single command:
1. Deploys your code to Vercel
2. Updates your manifest with the Vercel URL
3. Pushes the manifest change to Slack

### 4. Verify

DM your agent in Slack. It should respond — now powered by Vercel instead of your terminal.

## Environment variables

These are pre-configured in your Codespace:

| Variable | Purpose |
|---|---|
| `VERCEL_TOKEN` | Authenticates to the workshop Vercel team |
| `VERCEL_ORG_ID` | Targets the workshop Vercel organization |

Your agent also needs these set in Vercel (the deploy script handles this):

| Variable | Purpose |
|---|---|
| `SLACK_BOT_TOKEN` | Bot token from `slack login` |
| `SLACK_SIGNING_SECRET` | Verifies requests come from Slack |
| `ANTHROPIC_API_KEY` | LLM access for the agent |

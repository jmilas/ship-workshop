# Build a Slack Agent in 30 Minutes

Ship London Workshop — build an AI-powered Slack agent, run it locally, then deploy to Vercel.

## Prerequisites

- A GitHub account (to open the Codespace)
- A Vercel account (for deployment at the end)

## Step 1: Open the Codespace

Click the green "Code" button on this repo → "Codespaces" → "Create codespace on main"

Wait for it to build (~1-2 minutes). The Slack CLI and Vercel CLI will be installed automatically.

## Step 2: Create a Slack Developer Sandbox

While the Codespace builds, open a new tab:

1. Go to https://api.slack.com/developer-program
2. Sign up / sign in
3. You'll get a fully-featured Slack workspace to develop in

## Step 3: Authenticate the Slack CLI

In your Codespace terminal:

```bash
slack login
```

You'll see a slash command like `/slackauthticket ABC123...`. Paste that into any channel in your developer sandbox.

## Step 4: Create Your Agent

```bash
slack create agent my-agent
```

Follow the prompts. This creates a new Slack app, configures it, and scaffolds the project — all in one command.

```bash
cd my-agent
```

## Step 5: Run Your Agent

```bash
slack run
```

Your agent is now live in your developer sandbox. Open Slack, find your agent under Apps, and send it a message.

**You have a working AI agent in Slack.** The remaining steps are about making it yours and making it permanent.

## Step 6: Customize Your Agent

Open `agent/agent.js` and find the `SYSTEM_PROMPT`. Change it to whatever you want:

```js
const SYSTEM_PROMPT = `\
You are ShipBot, the unofficial concierge of the Vercel Ship conference.
You're enthusiastic about deployment, serverless, and edge computing.
Keep answers short and punchy. End every message with a shipping pun.`;
```

Save the file — `slack run` will restart automatically. Message your agent again to see the new personality.

## Step 7: Deploy to Vercel (make it permanent)

`slack run` connects your agent while your Codespace is open. To make it always-on, deploy to Vercel:

1. Switch to HTTP mode — see `DEPLOY.md` for the changes needed
2. Push to GitHub
3. Connect the repo to Vercel
4. Set environment variables (`SLACK_BOT_TOKEN`, `SLACK_SIGNING_SECRET`, `ANTHROPIC_API_KEY`)
5. Update your app's manifest `request_url` to point at your Vercel deployment

## What's Next

- **Add tools:** Give your agent the ability to call APIs, look up data, or take actions
- **Human-in-the-loop:** Pause for approval before sensitive operations
- **Go deeper:** [Vercel Academy — Slack Agents](https://vercel.com/academy/slack-agents)
- **Automate setup:** [Slack Agent Skill for coding agents](https://vercel.com/blog/building-slack-agents-can-be-easy)

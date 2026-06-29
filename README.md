# Build a Slack Agent in 30 Minutes

Ship London Workshop — build an AI-powered Slack agent, run it locally, then deploy to Vercel.

## Prerequisites

- A GitHub account (to open the Codespace)
- A Vercel account (optional — only needed if deploying to your own account instead of the workshop's shared team)

## Step 1: Open the Codespace

Click the green "Code" button on this repo → "Codespaces" → "Create codespace on main"

Wait for it to build (~1-2 minutes). The Slack CLI and Vercel CLI will be installed automatically.

## Step 2: Create a Slack Developer Sandbox

While the Codespace builds, open a new tab:

1. Go to https://api.slack.com/developer-program
2. Sign up / sign in
3. Choose the option to **provision a sandbox with an event code**
4. Enter the event code: **ship-london**
5. You'll get a fully-featured Slack workspace to develop in

## Step 3: Authenticate the Slack CLI

In your Codespace terminal:

```bash
slack login
```

You'll see a slash command like `/slackauthticket ABC123...`. Paste that into any channel in your developer sandbox.

## Step 4: Create Your Agent

```bash
slack create agent
```

When prompted:
1. Name your agent something unique (e.g., your company name + `-support`)
2. Select **Support agent** (not Starter agent)
3. Select **Bolt for JavaScript** as the language/framework
4. Select **openai-agents-sdk** as the AI framework

This creates a new Slack app, configures it, and scaffolds the project — all in one command.

```bash
cd <your-agent-name>
```

## Step 5: Run Your Agent

```bash
slack run
```

Your agent is now live in your developer sandbox. Open Slack, find your agent under Apps, and send it a message.

**You have a working AI agent in Slack.** The remaining steps are about making it yours and making it permanent.

## Step 6: Customize Your Agent

This is a support agent — make it yours. Open `agent/agent.js` and find the `SYSTEM_PROMPT`. Replace it with your own product's support persona:

```js
const SYSTEM_PROMPT = `\
You are the support agent for [Your Company/Product].
You help customers troubleshoot issues, answer questions about features,
and escalate complex problems to the right team.

## What you support
- [Describe your product in 1-2 sentences]
- [List common issues customers hit]

## Your tone
- Friendly and professional
- Acknowledge the customer's frustration before jumping to solutions
- Keep answers concise — link to docs when possible`;
```

Save the file — `slack run` will restart automatically. Message your agent with a support question about your product and see how it handles it.

## Step 7: Deploy to Vercel (make it permanent)

`slack run` only works while your terminal is open. To make your agent always-on, deploy it:

```bash
bash /workspaces/ship-workshop/setup-vercel.sh
slack deploy
```

What each step does:
1. **setup-vercel.sh** — configures your project for HTTP mode, creates the Vercel project, and sets the request URL in the manifest
2. **slack deploy** — pushes the manifest to Slack, deploys your code to Vercel, and sets env vars

---

## Appendix: What setup-vercel.sh Does

The script handles four things needed to move your agent from local (`slack run`) to deployed (Vercel):

1. **Switches from Socket Mode to HTTP mode** — `slack run` uses a WebSocket (your machine connects to Slack). On Vercel, it's the reverse: Slack sends HTTP requests to your serverless function. The script flips `socket_mode_enabled` to `false` in your manifest.

2. **Adds an HTTP entry point** — copies `api/slack.js` into your project, which is a Vercel serverless function that receives Slack events via HTTP instead of WebSocket.

3. **Does an initial deploy to get your URL** — you can't tell Slack where to send events until you have a URL. The script deploys once to establish it.

4. **Writes the URL into the manifest** — so that when `slack deploy` runs, it tells Slack: "send all events here."

---

## Appendix: Using Your Own Vercel Account

If you'd prefer to deploy to your own Vercel account instead of the workshop's shared team:

1. Log in to Vercel from the Codespace:

```bash
vercel login
```

2. Override the workshop token with your own (or unset it):

```bash
unset VERCEL_TOKEN
```

3. Run the setup and deploy as normal:

```bash
bash /workspaces/ship-workshop/setup-vercel.sh
slack deploy
```

The setup script will use your logged-in Vercel session instead of the shared token. The OpenAI API key from the Codespace will still be used.

---

## Appendix: Fixing API Rate Limit Errors

If your agent occasionally fails to respond (especially when many people are testing at the same time), it's likely hitting API rate limits. Run this to add automatic retry logic:

```bash
bash /workspaces/ship-workshop/scripts/patch-retry.sh
```

This patches `agent/agent.js` to retry up to 3 times with exponential backoff when the API returns a rate limit error. It's safe to run multiple times — it won't duplicate itself.

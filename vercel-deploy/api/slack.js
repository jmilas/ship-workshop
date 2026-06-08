import 'dotenv/config';

import bolt from '@slack/bolt';

const { App, ExpressReceiver, LogLevel } = bolt;

import { registerListeners } from '../listeners/index.js';

const receiver = new ExpressReceiver({
  signingSecret: process.env.SLACK_SIGNING_SECRET || 'workshop-no-verify',
  signatureVerification: false,
  processBeforeResponse: true,
  endpoints: '/',
});

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  receiver,
  logLevel: LogLevel.INFO,
  ignoreSelf: false,
});

registerListeners(app);

export default receiver.app;

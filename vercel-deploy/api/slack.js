import 'dotenv/config';

import { App, ExpressReceiver, LogLevel } from '@slack/bolt';

import { registerListeners } from '../listeners/index.js';

const receiver = new ExpressReceiver({
  signingSecret: process.env.SLACK_SIGNING_SECRET,
  processBeforeResponse: true,
});

const app = new App({
  token: process.env.SLACK_BOT_TOKEN,
  receiver,
  logLevel: LogLevel.INFO,
  ignoreSelf: false,
});

registerListeners(app);

export default receiver.app;

#!/bin/bash
# Adds retry with exponential backoff to the OpenAI agent runner.
# Prevents failures when many users hit the API concurrently.

PROJECT_DIR="${1:-$(pwd)}"

# Find the agent file — template may use agent.js or support-agent.js
AGENT_FILE=""
for candidate in "$PROJECT_DIR/agent/agent.js" "$PROJECT_DIR/agent/support-agent.js"; do
  if [ -f "$candidate" ]; then
    AGENT_FILE="$candidate"
    break
  fi
done

if [ -z "$AGENT_FILE" ]; then
  echo "⚠️  Could not find agent file in $PROJECT_DIR/agent/"
  exit 1
fi

# Skip if already patched
if grep -q 'withRetry' "$AGENT_FILE"; then
  echo "✓ Retry logic already present"
  exit 0
fi

# Insert the withRetry helper before the runAgent export
sed -i.bak '/^export async function runAgent/i\
async function withRetry(fn, maxAttempts = 3) {\
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {\
    try {\
      return await fn();\
    } catch (err) {\
      const status = err?.status || err?.code;\
      if (status === 429 \&\& attempt < maxAttempts) {\
        const delay = Math.pow(2, attempt - 1) * 1000;\
        await new Promise((resolve) => setTimeout(resolve, delay));\
        continue;\
      }\
      throw err;\
    }\
  }\
}\
' "$AGENT_FILE"

# Wrap the run() calls with withRetry
sed -i 's/return await run(agentWithMcp, inputItems, { context: deps });/return await withRetry(() => run(agentWithMcp, inputItems, { context: deps }));/' "$AGENT_FILE"
sed -i 's/return await run(starterAgent, inputItems, { context: deps });/return await withRetry(() => run(starterAgent, inputItems, { context: deps }));/' "$AGENT_FILE"
sed -i 's/return await run(supportAgent, inputItems, { context: deps });/return await withRetry(() => run(supportAgent, inputItems, { context: deps }));/' "$AGENT_FILE"

rm -f "$AGENT_FILE.bak"
echo "✓ Added retry logic to $(basename "$AGENT_FILE")"

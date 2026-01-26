---
name: slack
description: Send messages to Slack channels using webhooks. Use this skill to post summaries and notifications.
---

# Slack Skill

This skill allows you to send messages to Slack channels using incoming webhooks.

## When to Use

Use this skill when:
- You need to post article summaries to a channel
- You want to send notifications to your team
- You need to share research findings

## Setup Requirements

1. Go to your Slack workspace settings
2. Create an Incoming Webhook: https://api.slack.com/messaging/webhooks
3. Copy the webhook URL

## How to Use

### Send a Simple Message

```bash
$CLAUDE_CONFIG_DIR/skills/slack/scripts/send-message.sh "Your message here"
```

### Send a Formatted Summary

```bash
$CLAUDE_CONFIG_DIR/skills/slack/scripts/send-summary.sh "Article Title" "https://example.com" "Summary text"
```

## Environment Variables

- `SLACK_WEBHOOK_URL`: Your Slack incoming webhook URL

## Message Formatting

Slack supports markdown-like formatting:
- `*bold*` for bold text
- `_italic_` for italic text
- `• ` for bullet points
- `` `code` `` for inline code

## Examples

```bash
# Simple message
send-message.sh "Daily research report is ready!"

# Article summary
send-summary.sh "OpenAI launches GPT-5" "https://techcrunch.com/..." "• Enhanced reasoning\n• Better safety\n• Faster performance"
```

## Getting a Webhook URL

1. Go to https://api.slack.com/apps
2. Create a new app (or select existing)
3. Enable "Incoming Webhooks"
4. Add a new webhook to your workspace
5. Select the target channel
6. Copy the webhook URL

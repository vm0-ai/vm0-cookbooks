#!/bin/bash

# Slack - Send Message
# Usage: ./send-message.sh "Your message"

set -e

MESSAGE="$1"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "Error: SLACK_WEBHOOK_URL environment variable is not set"
    echo "Get one at: https://api.slack.com/messaging/webhooks"
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    echo "Usage: ./send-message.sh \"Your message\""
    exit 1
fi

echo "Sending message to Slack..."

# Escape special characters for JSON
MESSAGE_ESCAPED=$(echo "$MESSAGE" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\t/\\t/g')

RESPONSE=$(curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"$MESSAGE_ESCAPED\"}")

if [ "$RESPONSE" = "ok" ]; then
    echo "Message sent successfully!"
else
    echo "Error sending message: $RESPONSE"
    exit 1
fi

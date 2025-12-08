#!/bin/bash

# Slack - Send Article Summary
# Usage: ./send-summary.sh "Title" "URL" "Summary"

set -e

TITLE="$1"
URL="$2"
SUMMARY="$3"

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "Error: SLACK_WEBHOOK_URL environment variable is not set"
    exit 1
fi

if [ -z "$TITLE" ] || [ -z "$URL" ]; then
    echo "Usage: ./send-summary.sh \"Title\" \"URL\" \"Summary\""
    exit 1
fi

echo "Sending summary to Slack: $TITLE"

# Build the message with blocks for rich formatting
PAYLOAD=$(cat <<EOF
{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "🔍 Market Research Summary",
                "emoji": true
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": "*Title:*\n$TITLE"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Link:*\n<$URL|Read Article>"
                }
            ]
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Summary:*\n$SUMMARY"
            }
        },
        {
            "type": "divider"
        }
    ]
}
EOF
)

RESPONSE=$(curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

if [ "$RESPONSE" = "ok" ]; then
    echo "Summary sent successfully!"
else
    echo "Error sending summary: $RESPONSE"
    # Try simple format as fallback
    echo "Trying simple format..."
    SIMPLE_MSG="🔍 *Market Research Summary*\n*Title:* $TITLE\n*Link:* $URL\n*Summary:*\n$SUMMARY"
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"$SIMPLE_MSG\"}"
fi

#!/bin/bash

# Send daily report to Slack with rich formatting
# Usage: send-report.sh "report_file" [channel]

set -e

REPORT_FILE="$1"
CHANNEL="${2:-$SLACK_CHANNEL_ID}"

if [ -z "$REPORT_FILE" ]; then
    echo "Error: Report file path is required"
    echo "Usage: send-report.sh \"report_file\" [channel]"
    exit 1
fi

if [ ! -f "$REPORT_FILE" ]; then
    echo "Error: Report file not found: $REPORT_FILE"
    exit 1
fi

# Check for authentication
if [ -z "$SLACK_WEBHOOK_URL" ] && [ -z "$SLACK_BOT_TOKEN" ]; then
    echo "Error: Either SLACK_WEBHOOK_URL or SLACK_BOT_TOKEN must be set"
    exit 1
fi

echo "Sending daily report to Slack..."

# Read the report content
REPORT_CONTENT=$(cat "$REPORT_FILE")

# Extract the date from the report title or use today
REPORT_DATE=$(echo "$REPORT_CONTENT" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
if [ -z "$REPORT_DATE" ]; then
    REPORT_DATE=$(date +%Y-%m-%d)
fi

# Extract GitHub metrics
STARS=$(echo "$REPORT_CONTENT" | grep -E "Stars \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
FORKS=$(echo "$REPORT_CONTENT" | grep -E "Forks \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
ISSUES=$(echo "$REPORT_CONTENT" | grep -E "Open Issues \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
COMMITS=$(echo "$REPORT_CONTENT" | grep -E "\*\*Commits:\*\*" | grep -oE '[0-9]+' | head -1 || echo "0")
LINES_ADDED=$(echo "$REPORT_CONTENT" | grep -E "\*\*Lines Added:\*\*" | grep -oE '[0-9,]+' | head -1 || echo "0")
LINES_REMOVED=$(echo "$REPORT_CONTENT" | grep -E "\*\*Lines Removed:\*\*" | grep -oE '[0-9,]+' | head -1 || echo "0")
FILES_CHANGED=$(echo "$REPORT_CONTENT" | grep -E "\*\*Files Changed:\*\*" | grep -oE '[0-9]+' | head -1 || echo "0")

# Extract Plausible metrics
VISITORS=$(echo "$REPORT_CONTENT" | grep -E "Visitors \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
PAGEVIEWS=$(echo "$REPORT_CONTENT" | grep -E "Pageviews \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
BOUNCE_RATE=$(echo "$REPORT_CONTENT" | grep -E "Bounce Rate \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
VISIT_DURATION=$(echo "$REPORT_CONTENT" | grep -E "Avg Visit Duration \|" | sed 's/.*| //' | head -1 || echo "N/A")

# Extract Clerk metrics
TOTAL_USERS=$(echo "$REPORT_CONTENT" | grep -E "Total Users \|" | grep -oE '[0-9]+' | head -1 || echo "N/A")
ACTIVE_USERS=$(echo "$REPORT_CONTENT" | grep -E "Active Users" | grep -oE '[0-9]+' | head -1 || echo "N/A")
NEW_USERS=$(echo "$REPORT_CONTENT" | grep -E "New Users" | grep -oE '[0-9]+' | head -1 || echo "N/A")

# Extract top pages (first 3)
TOP_PAGE_1=$(echo "$REPORT_CONTENT" | grep -E "^1\. /" | head -1 | sed 's/^1\. //' || echo "")
TOP_PAGE_2=$(echo "$REPORT_CONTENT" | grep -E "^2\. /" | head -1 | sed 's/^2\. //' || echo "")
TOP_PAGE_3=$(echo "$REPORT_CONTENT" | grep -E "^3\. /" | head -1 | sed 's/^3\. //' || echo "")

# Extract commit summaries - get feat and fix items, extract short description
# Format: "- feat(scope): description" -> "scope: description"
FEATS=$(echo "$REPORT_CONTENT" | grep -E "^- feat" | head -3 | sed 's/^- feat(\([^)]*\)): \([^(]*\).*/• \1: \2/' | sed 's/ by @.*//' || echo "")
FIXES=$(echo "$REPORT_CONTENT" | grep -E "^- fix" | head -2 | sed 's/^- fix(\([^)]*\)): \([^(]*\).*/• \1: \2/' | sed 's/ by @.*//' || echo "")

# Extract OKR objectives (clean format)
OKR_O1=$(echo "$REPORT_CONTENT" | grep -E "\*\*O1:" | head -1 | sed 's/.*\*\*O1: //' | sed 's/\*\*.*//g' | tr -d '\n' || echo "")
OKR_O2=$(echo "$REPORT_CONTENT" | grep -E "\*\*O2:" | head -1 | sed 's/.*\*\*O2: //' | sed 's/\*\*.*//g' | tr -d '\n' || echo "")
OKR_O3=$(echo "$REPORT_CONTENT" | grep -E "\*\*O3:" | head -1 | sed 's/.*\*\*O3: //' | sed 's/\*\*.*//g' | tr -d '\n' || echo "")

# Build top pages text with actual newlines
TOP_PAGES_TEXT=""
if [ -n "$TOP_PAGE_1" ]; then
    TOP_PAGES_TEXT="• ${TOP_PAGE_1}"
fi
if [ -n "$TOP_PAGE_2" ]; then
    TOP_PAGES_TEXT="${TOP_PAGES_TEXT}
• ${TOP_PAGE_2}"
fi
if [ -n "$TOP_PAGE_3" ]; then
    TOP_PAGES_TEXT="${TOP_PAGES_TEXT}
• ${TOP_PAGE_3}"
fi
if [ -z "$TOP_PAGES_TEXT" ]; then
    TOP_PAGES_TEXT="No data"
fi

# Build commit summary text
COMMIT_TEXT=""
if [ -n "$FEATS" ]; then
    COMMIT_TEXT="*Features:*
${FEATS}"
fi
if [ -n "$FIXES" ]; then
    if [ -n "$COMMIT_TEXT" ]; then
        COMMIT_TEXT="${COMMIT_TEXT}

*Fixes:*
${FIXES}"
    else
        COMMIT_TEXT="*Fixes:*
${FIXES}"
    fi
fi
if [ -z "$COMMIT_TEXT" ]; then
    COMMIT_TEXT="No feature/fix commits yesterday"
fi

# Build OKR text with actual newlines
OKR_TEXT=""
if [ -n "$OKR_O1" ]; then
    OKR_TEXT="• *O1:* ${OKR_O1}"
fi
if [ -n "$OKR_O2" ]; then
    OKR_TEXT="${OKR_TEXT}
• *O2:* ${OKR_O2}"
fi
if [ -n "$OKR_O3" ]; then
    OKR_TEXT="${OKR_TEXT}
• *O3:* ${OKR_O3}"
fi
if [ -z "$OKR_TEXT" ]; then
    OKR_TEXT="No OKR data available"
fi

# Build Slack Block Kit message using jq
PAYLOAD=$(jq -n \
    --arg channel "$CHANNEL" \
    --arg date "$REPORT_DATE" \
    --arg stars "$STARS" \
    --arg forks "$FORKS" \
    --arg issues "$ISSUES" \
    --arg commits "$COMMITS" \
    --arg files "$FILES_CHANGED" \
    --arg added "$LINES_ADDED" \
    --arg removed "$LINES_REMOVED" \
    --arg visitors "$VISITORS" \
    --arg pageviews "$PAGEVIEWS" \
    --arg bounce "$BOUNCE_RATE" \
    --arg duration "$VISIT_DURATION" \
    --arg top_pages "$TOP_PAGES_TEXT" \
    --arg commit_text "$COMMIT_TEXT" \
    --arg okr_text "$OKR_TEXT" \
    --arg total_users "$TOTAL_USERS" \
    --arg active_users "$ACTIVE_USERS" \
    --arg new_users "$NEW_USERS" \
    '{
        channel: $channel,
        text: ("Daily Data Report - " + $date),
        blocks: [
            {
                type: "header",
                text: {
                    type: "plain_text",
                    text: ("📊 Daily Data Report - " + $date),
                    emoji: true
                }
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: "*🐙 GitHub: vm0-ai/vm0*"
                }
            },
            {
                type: "section",
                fields: [
                    { type: "mrkdwn", text: ("⭐ *Stars*\n" + $stars) },
                    { type: "mrkdwn", text: ("🍴 *Forks*\n" + $forks) },
                    { type: "mrkdwn", text: ("📋 *Issues*\n" + $issues) },
                    { type: "mrkdwn", text: ("📝 *Commits*\n" + $commits) }
                ]
            },
            {
                type: "section",
                fields: [
                    { type: "mrkdwn", text: ("📁 *Files*\n" + $files) },
                    { type: "mrkdwn", text: ("📈 *Lines*\n+" + $added + " / -" + $removed) }
                ]
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: $commit_text
                }
            },
            {
                type: "divider"
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: "*📈 Website Traffic*"
                }
            },
            {
                type: "section",
                fields: [
                    { type: "mrkdwn", text: ("👥 *Visitors*\n" + $visitors) },
                    { type: "mrkdwn", text: ("📄 *Pageviews*\n" + $pageviews) },
                    { type: "mrkdwn", text: ("↩️ *Bounce*\n" + $bounce + "%") },
                    { type: "mrkdwn", text: ("⏱️ *Duration*\n" + $duration) }
                ]
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: ("*Top Pages*\n" + $top_pages)
                }
            },
            {
                type: "divider"
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: "*👥 User Metrics (Clerk)*"
                }
            },
            {
                type: "section",
                fields: [
                    { type: "mrkdwn", text: ("📊 *Total Users*\n" + $total_users) },
                    { type: "mrkdwn", text: ("🟢 *Active (Yesterday)*\n" + $active_users) },
                    { type: "mrkdwn", text: ("✨ *New (Yesterday)*\n" + $new_users) }
                ]
            },
            {
                type: "divider"
            },
            {
                type: "section",
                text: {
                    type: "mrkdwn",
                    text: ("*🎯 OKR Q4*\n" + $okr_text)
                }
            },
            {
                type: "context",
                elements: [
                    {
                        type: "mrkdwn",
                        text: "🤖 _Generated by vm0 Daily Report Agent_"
                    }
                ]
            }
        ]
    }')

# Send to Slack
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    WEBHOOK_PAYLOAD=$(echo "$PAYLOAD" | jq 'del(.channel)')
    RESPONSE=$(curl -s -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$WEBHOOK_PAYLOAD")

    if [ "$RESPONSE" = "ok" ]; then
        echo "Report sent successfully via webhook!"
    else
        echo "Error sending to Slack: $RESPONSE"
        exit 1
    fi

elif [ -n "$SLACK_BOT_TOKEN" ]; then
    if [ -z "$CHANNEL" ]; then
        echo "Error: Channel is required when using Bot Token"
        exit 1
    fi

    RESPONSE=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
        -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD")

    OK=$(echo "$RESPONSE" | jq -r '.ok')
    if [ "$OK" = "true" ]; then
        TS=$(echo "$RESPONSE" | jq -r '.ts')
        CHANNEL_NAME=$(echo "$RESPONSE" | jq -r '.channel')
        echo "Report sent successfully!"
        echo "Channel: $CHANNEL_NAME"
        echo "Message timestamp: $TS"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.error')
        echo "Error sending to Slack: $ERROR"
        exit 1
    fi
fi

echo "Done!"

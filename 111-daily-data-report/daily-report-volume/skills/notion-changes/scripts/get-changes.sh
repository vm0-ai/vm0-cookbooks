#!/bin/bash

# Get Notion workspace changes for a specific date
# Usage: get-changes.sh [date]

set -e

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

# Default to yesterday if no date provided
if [ -z "$1" ]; then
    TARGET_DATE=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
else
    TARGET_DATE="$1"
fi

# Calculate date range
START_TIME="${TARGET_DATE}T00:00:00.000Z"
END_TIME="${TARGET_DATE}T23:59:59.999Z"

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/notion_changes_${TIMESTAMP}.json"

echo "Fetching Notion changes for ${TARGET_DATE}..."

# Search for pages edited on the target date
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/search" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d '{
        "filter": {
            "property": "object",
            "value": "page"
        },
        "sort": {
            "direction": "descending",
            "timestamp": "last_edited_time"
        },
        "page_size": 100
    }')

# Check for errors
if echo "$RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Error from Notion API:"
    echo "$RESPONSE" | jq -r '.message'
    exit 1
fi

# Filter pages by date - using simpler jq syntax to avoid shell quoting issues
# Pages created on target date
PAGES_CREATED=$(echo "$RESPONSE" | jq --arg start "$START_TIME" --arg end "$END_TIME" \
    '[.results[] | select(.created_time >= $start and .created_time <= $end) | {id: .id, title: ((.properties.title.title[0].plain_text // .properties.Name.title[0].plain_text) // "Untitled"), url: .url, created_by: .created_by.id, created_time: .created_time}]' 2>/dev/null || echo "[]")

# Pages edited on target date (but not created on that date)
PAGES_EDITED=$(echo "$RESPONSE" | jq --arg start "$START_TIME" --arg end "$END_TIME" \
    '[.results[] | select(.last_edited_time >= $start and .last_edited_time <= $end and .created_time < $start) | {id: .id, title: ((.properties.title.title[0].plain_text // .properties.Name.title[0].plain_text) // "Untitled"), url: .url, last_edited_by: .last_edited_by.id, last_edited_time: .last_edited_time}]' 2>/dev/null || echo "[]")

# Ensure we have valid JSON
if [ -z "$PAGES_CREATED" ] || [ "$PAGES_CREATED" = "null" ]; then
    PAGES_CREATED="[]"
fi
if [ -z "$PAGES_EDITED" ] || [ "$PAGES_EDITED" = "null" ]; then
    PAGES_EDITED="[]"
fi

# Build result
RESULT=$(jq -n \
    --arg date "$TARGET_DATE" \
    --argjson created "$PAGES_CREATED" \
    --argjson edited "$PAGES_EDITED" \
    '{
        date: $date,
        pages_created: $created,
        pages_edited: $edited
    }')

# Save results
echo "$RESULT" > "$OUTPUT_FILE"

# Print summary
CREATED_COUNT=$(echo "$PAGES_CREATED" | jq 'length' 2>/dev/null || echo "0")
EDITED_COUNT=$(echo "$PAGES_EDITED" | jq 'length' 2>/dev/null || echo "0")

echo ""
echo "Notion Changes for ${TARGET_DATE}"
echo ""
echo "Pages Created (${CREATED_COUNT}):"
if [ "$CREATED_COUNT" -gt 0 ] 2>/dev/null; then
    echo "$PAGES_CREATED" | jq -r '.[] | "  - \(.title)"'
else
    echo "  None"
fi

echo ""
echo "Pages Edited (${EDITED_COUNT}):"
if [ "$EDITED_COUNT" -gt 0 ] 2>/dev/null; then
    echo "$PAGES_EDITED" | jq -r '.[] | "  - \(.title)"'
else
    echo "  None"
fi

echo ""
echo "Results saved to: $OUTPUT_FILE"

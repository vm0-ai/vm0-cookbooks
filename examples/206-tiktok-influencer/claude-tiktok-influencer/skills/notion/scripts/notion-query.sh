#!/bin/bash

# Notion - Query Database
# Usage: ./notion-query.sh "database_id"

set -e

DATABASE_ID="$1"

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$DATABASE_ID" ]; then
    echo "Usage: ./notion-query.sh \"database_id\""
    exit 1
fi

OUTPUT_DIR="/tmp/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/notion_${TIMESTAMP}.json"

mkdir -p "$OUTPUT_DIR"

echo "Querying Notion database: $DATABASE_ID"

# Query database
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d '{"page_size": 100}')

# Save to file
echo "$RESPONSE" | jq '.' > "$OUTPUT_FILE"

# Display results
RESULTS=$(echo "$RESPONSE" | jq -r '.results // []')
COUNT=$(echo "$RESULTS" | jq 'length')

echo "Found $COUNT entries"
echo "Results saved to: $OUTPUT_FILE"
echo ""
echo "Entries:"
echo "========"

echo "$RESPONSE" | jq -r '.results[]? |
    "Profile ID: \(.properties["Profile ID"].title[0].text.content // "N/A")
Username: \(.properties.Username.rich_text[0].text.content // "N/A")
Followers: \(.properties.Followers.number // "N/A")
Collaboration: \(.properties.Collaboration.select.name // "Not analyzed")
Page ID: \(.id)
---"'

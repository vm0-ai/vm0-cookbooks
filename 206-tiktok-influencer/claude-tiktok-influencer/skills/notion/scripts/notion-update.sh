#!/bin/bash

# Notion - Update Page Properties
# Usage: ./notion-update.sh "page_id" "collaboration" "analysis"

set -e

PAGE_ID="$1"
COLLABORATION="$2"
ANALYSIS="$3"

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$PAGE_ID" ] || [ -z "$COLLABORATION" ]; then
    echo "Usage: ./notion-update.sh \"page_id\" \"collaboration\" \"analysis\""
    exit 1
fi

echo "Updating page: $PAGE_ID"
echo "Collaboration: $COLLABORATION"

# Update page
RESPONSE=$(curl -s -X PATCH "https://api.notion.com/v1/pages/$PAGE_ID" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "{
        \"properties\": {
            \"Collaboration\": {
                \"select\": {\"name\": \"$COLLABORATION\"}
            },
            \"Analysis\": {
                \"rich_text\": [{\"text\": {\"content\": \"$(echo "$ANALYSIS" | head -c 2000)\"}}]
            }
        }
    }")

# Check result
UPDATED_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ ! -z "$UPDATED_ID" ]; then
    echo "Successfully updated page: $UPDATED_ID"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.message // .error // "Unknown error"')
    echo "Error updating page: $ERROR"
    exit 1
fi

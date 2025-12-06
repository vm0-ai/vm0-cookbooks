#!/bin/bash

# Notion - Add Page to Database
# Usage: ./notion-add.sh "database_id" "profile_id" "username" "url" "description" "followers"

set -e

DATABASE_ID="$1"
PROFILE_ID="$2"
USERNAME="$3"
URL="$4"
DESCRIPTION="$5"
FOLLOWERS="$6"

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$DATABASE_ID" ] || [ -z "$PROFILE_ID" ]; then
    echo "Usage: ./notion-add.sh \"database_id\" \"profile_id\" \"username\" \"url\" \"description\" \"followers\""
    exit 1
fi

# Convert followers to number
# Handles: 1500000, 1.5M, 150K, 1,500,000, etc.
convert_followers() {
    local val="$1"
    # Remove commas and spaces
    val=$(echo "$val" | tr -d ', ')

    # Handle M (millions)
    if echo "$val" | grep -iq 'm'; then
        val=$(echo "$val" | sed 's/[mM]//g')
        val=$(echo "$val * 1000000" | bc 2>/dev/null || echo "0")
    # Handle K (thousands)
    elif echo "$val" | grep -iq 'k'; then
        val=$(echo "$val" | sed 's/[kK]//g')
        val=$(echo "$val * 1000" | bc 2>/dev/null || echo "0")
    fi

    # Convert to integer
    echo "$val" | cut -d'.' -f1 | grep -o '[0-9]*' | head -1 || echo "0"
}

FOLLOWERS_NUM=$(convert_followers "$FOLLOWERS")
# Default to 0 if empty
FOLLOWERS_NUM="${FOLLOWERS_NUM:-0}"

echo "Adding influencer to Notion: $USERNAME (Followers: $FOLLOWERS -> $FOLLOWERS_NUM)"

# Escape special characters in description for JSON
DESCRIPTION_ESCAPED=$(echo "$DESCRIPTION" | head -c 2000 | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' ' ')

# Create page
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d "{
        \"parent\": {\"database_id\": \"$DATABASE_ID\"},
        \"properties\": {
            \"Profile ID\": {
                \"title\": [{\"text\": {\"content\": \"$PROFILE_ID\"}}]
            },
            \"Username\": {
                \"rich_text\": [{\"text\": {\"content\": \"$USERNAME\"}}]
            },
            \"URL\": {
                \"url\": \"$URL\"
            },
            \"Description\": {
                \"rich_text\": [{\"text\": {\"content\": \"$DESCRIPTION_ESCAPED\"}}]
            },
            \"Followers\": {
                \"number\": $FOLLOWERS_NUM
            }
        }
    }")

# Check result
PAGE_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ ! -z "$PAGE_ID" ]; then
    echo "Successfully added page: $PAGE_ID"
    echo "$PAGE_ID"
else
    ERROR=$(echo "$RESPONSE" | jq -r '.message // .error // "Unknown error"')
    echo "Error adding page: $ERROR"
    echo "Response: $RESPONSE"
    exit 1
fi

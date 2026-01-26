#!/bin/bash

# Query a Notion database
# Usage: query-database.sh "DATABASE_ID"

set -e

DATABASE_ID="$1"

if [ -z "$DATABASE_ID" ]; then
    echo "Error: Database ID is required"
    echo "Usage: query-database.sh \"DATABASE_ID\""
    exit 1
fi

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/notion_query_${TIMESTAMP}.json"

# Make API request
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/databases/${DATABASE_ID}/query" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d '{}')

# Check for errors
if echo "$RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Error from Notion API:"
    echo "$RESPONSE" | jq -r '.message'
    exit 1
fi

# Save results
echo "$RESPONSE" > "$OUTPUT_FILE"

# Print summary
COUNT=$(echo "$RESPONSE" | jq '.results | length')
echo "Found $COUNT entries in database"
echo "Results saved to: $OUTPUT_FILE"

# Print preview
echo ""
echo "Existing entries:"
echo "$RESPONSE" | jq -r '.results[:10][] | .properties.Name.title[0].text.content // "Untitled"' | while read -r name; do
    echo "  - $name"
done

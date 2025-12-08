#!/bin/bash

# FireCrawl - Scrape Single Page
# Usage: ./scrape.sh "https://example.com/article"

set -e

URL="$1"

if [ -z "$FIRECRAWL_API_KEY" ]; then
    echo "Error: FIRECRAWL_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$URL" ]; then
    echo "Usage: ./scrape.sh \"https://example.com/article\""
    exit 1
fi

OUTPUT_DIR="/tmp/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/scrape_${TIMESTAMP}.json"

mkdir -p "$OUTPUT_DIR"

echo "Scraping: $URL"

RESPONSE=$(curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
    -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"url\": \"$URL\",
        \"formats\": [\"markdown\", \"html\"]
    }")

# Save results
echo "$RESPONSE" | jq '.' > "$OUTPUT_FILE"

echo "Results saved to: $OUTPUT_FILE"
echo ""

# Display extracted content
TITLE=$(echo "$RESPONSE" | jq -r '.data.metadata.title // "N/A"')
DESCRIPTION=$(echo "$RESPONSE" | jq -r '.data.metadata.description // "N/A"')

echo "Title: $TITLE"
echo "Description: $DESCRIPTION"
echo ""
echo "Content preview:"
echo "$RESPONSE" | jq -r '.data.markdown // .data.content // "No content"' | head -20

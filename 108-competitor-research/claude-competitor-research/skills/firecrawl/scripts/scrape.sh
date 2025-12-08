#!/bin/bash

# Scrape a webpage using Firecrawl
# Usage: scrape.sh "https://example.com/page"

set -e

URL="$1"

if [ -z "$URL" ]; then
    echo "Error: URL is required"
    echo "Usage: scrape.sh \"https://example.com/page\""
    exit 1
fi

if [ -z "$FIRECRAWL_API_KEY" ]; then
    echo "Error: FIRECRAWL_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/scraped_${TIMESTAMP}.json"

# Make API request
RESPONSE=$(curl -s -X POST "https://api.firecrawl.dev/v1/scrape" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
    -d "{
        \"url\": \"$URL\",
        \"formats\": [\"markdown\"],
        \"onlyMainContent\": true,
        \"removeTags\": [\"img\", \"svg\", \"video\", \"audio\", \"nav\", \"footer\"]
    }")

# Check for errors
if echo "$RESPONSE" | jq -e '.success == false' > /dev/null 2>&1; then
    echo "Error from Firecrawl API:"
    echo "$RESPONSE" | jq -r '.error // "Unknown error"'
    exit 1
fi

# Save results
echo "$RESPONSE" > "$OUTPUT_FILE"

# Print summary
TITLE=$(echo "$RESPONSE" | jq -r '.data.metadata.title // "Unknown"')
echo "Scraped: $TITLE"
echo "URL: $URL"
echo "Results saved to: $OUTPUT_FILE"

# Print content preview (first 500 chars)
echo ""
echo "Content preview:"
echo "$RESPONSE" | jq -r '.data.markdown // ""' | head -c 500
echo "..."

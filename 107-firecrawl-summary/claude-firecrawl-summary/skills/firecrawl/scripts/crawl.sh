#!/bin/bash

# FireCrawl - Crawl Website
# Usage: ./crawl.sh "https://example.com" [limit]

set -e

URL="$1"
LIMIT="${2:-10}"

if [ -z "$FIRECRAWL_API_KEY" ]; then
    echo "Error: FIRECRAWL_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$URL" ]; then
    echo "Usage: ./crawl.sh \"https://example.com\" [limit]"
    exit 1
fi

OUTPUT_DIR="/tmp/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/firecrawl_${TIMESTAMP}.json"

mkdir -p "$OUTPUT_DIR"

echo "Crawling: $URL"
echo "Limit: $LIMIT pages"

# Start crawl job
RESPONSE=$(curl -s -X POST "https://api.firecrawl.dev/v1/crawl" \
    -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"url\": \"$URL\",
        \"limit\": $LIMIT,
        \"scrapeOptions\": {
            \"formats\": [\"markdown\", \"html\"]
        }
    }")

# Check for job ID
JOB_ID=$(echo "$RESPONSE" | jq -r '.id // .jobId // empty')

if [ -z "$JOB_ID" ]; then
    # Maybe it's a direct response (scrape mode)
    echo "$RESPONSE" | jq '.' > "$OUTPUT_FILE"
    echo "Results saved to: $OUTPUT_FILE"
    echo "$RESPONSE" | jq -r '.data[]? | "Title: \(.metadata.title // "N/A")\nURL: \(.metadata.sourceURL // "N/A")\n---"' 2>/dev/null
    exit 0
fi

echo "Crawl job started: $JOB_ID"
echo "Waiting for results..."

# Poll for results
MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    sleep 10
    ATTEMPT=$((ATTEMPT + 1))

    STATUS_RESPONSE=$(curl -s "https://api.firecrawl.dev/v1/crawl/$JOB_ID" \
        -H "Authorization: Bearer $FIRECRAWL_API_KEY")

    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status // "unknown"')

    echo "Status: $STATUS (attempt $ATTEMPT/$MAX_ATTEMPTS)"

    if [ "$STATUS" = "completed" ]; then
        echo "$STATUS_RESPONSE" | jq '.' > "$OUTPUT_FILE"
        echo ""
        echo "Crawl completed!"
        echo "Results saved to: $OUTPUT_FILE"

        # Show summary
        COUNT=$(echo "$STATUS_RESPONSE" | jq '.data | length' 2>/dev/null || echo "0")
        echo "Found $COUNT pages"
        echo ""
        echo "Articles:"
        echo "========="
        echo "$STATUS_RESPONSE" | jq -r '.data[]? | "Title: \(.metadata.title // "N/A")\nURL: \(.metadata.sourceURL // "N/A")\n---"' 2>/dev/null | head -50
        exit 0
    elif [ "$STATUS" = "failed" ]; then
        echo "Crawl failed!"
        echo "$STATUS_RESPONSE" | jq '.'
        exit 1
    fi
done

echo "Timeout waiting for crawl to complete"
exit 1

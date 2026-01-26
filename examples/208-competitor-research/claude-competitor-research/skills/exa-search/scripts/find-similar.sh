#!/bin/bash

# Find similar companies using Exa.ai
# Usage: find-similar.sh "https://example.com" [limit]

set -e

URL="$1"
LIMIT="${2:-10}"

if [ -z "$URL" ]; then
    echo "Error: URL is required"
    echo "Usage: find-similar.sh \"https://example.com\" [limit]"
    exit 1
fi

if [ -z "$EXA_API_KEY" ]; then
    echo "Error: EXA_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

# Extract domain for exclusion
DOMAIN=$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|')

# Make API request
RESPONSE=$(curl -s -X POST "https://api.exa.ai/findSimilar" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $EXA_API_KEY" \
    -d "{
        \"url\": \"$URL\",
        \"numResults\": $LIMIT,
        \"type\": \"neural\",
        \"useAutoprompt\": true,
        \"contents\": {
            \"text\": false
        },
        \"excludeDomains\": [\"$DOMAIN\", \"github.com\", \"linkedin.com\", \"twitter.com\", \"facebook.com\", \"youtube.com\"]
    }")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error from Exa API:"
    echo "$RESPONSE" | jq -r '.error'
    exit 1
fi

# Save results
OUTPUT_FILE="/tmp/data/competitors.json"
echo "$RESPONSE" > "$OUTPUT_FILE"

# Print summary
COUNT=$(echo "$RESPONSE" | jq '.results | length')
echo "Found $COUNT similar companies"
echo "Results saved to: $OUTPUT_FILE"

# Print preview
echo ""
echo "Top results:"
echo "$RESPONSE" | jq -r '.results[:5][] | "  - \(.title): \(.url)"'

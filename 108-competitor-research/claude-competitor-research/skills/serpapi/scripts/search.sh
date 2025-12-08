#!/bin/bash

# Perform a Google search using SerpAPI
# Usage: search.sh "query" [num_results]

set -e

QUERY="$1"
NUM_RESULTS="${2:-10}"

if [ -z "$QUERY" ]; then
    echo "Error: Query is required"
    echo "Usage: search.sh \"query\" [num_results]"
    exit 1
fi

if [ -z "$SERPAPI_API_KEY" ]; then
    echo "Error: SERPAPI_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/search_${TIMESTAMP}.json"

# URL encode the query
ENCODED_QUERY=$(echo -n "$QUERY" | jq -sRr @uri)

# Make API request
RESPONSE=$(curl -s "https://serpapi.com/search.json?q=${ENCODED_QUERY}&num=${NUM_RESULTS}&api_key=${SERPAPI_API_KEY}")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error from SerpAPI:"
    echo "$RESPONSE" | jq -r '.error'
    exit 1
fi

# Extract relevant fields and save
echo "$RESPONSE" | jq '{
    organic_results: [.organic_results[]? | {
        position: .position,
        title: .title,
        link: .link,
        snippet: .snippet,
        source: .source
    }]
}' > "$OUTPUT_FILE"

# Print summary
COUNT=$(jq '.organic_results | length' "$OUTPUT_FILE")
echo "Found $COUNT results for: $QUERY"
echo "Results saved to: $OUTPUT_FILE"

# Print preview
echo ""
echo "Top results:"
jq -r '.organic_results[:5][] | "  \(.position). \(.title)\n     \(.link)"' "$OUTPUT_FILE"

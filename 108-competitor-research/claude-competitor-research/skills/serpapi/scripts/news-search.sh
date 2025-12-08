#!/bin/bash

# Perform a Google News search using SerpAPI
# Usage: news-search.sh "query"

set -e

QUERY="$1"

if [ -z "$QUERY" ]; then
    echo "Error: Query is required"
    echo "Usage: news-search.sh \"query\""
    exit 1
fi

if [ -z "$SERPAPI_API_KEY" ]; then
    echo "Error: SERPAPI_API_KEY environment variable is not set"
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/news_${TIMESTAMP}.json"

# URL encode the query
ENCODED_QUERY=$(echo -n "$QUERY" | jq -sRr @uri)

# Make API request
RESPONSE=$(curl -s "https://serpapi.com/search.json?q=${ENCODED_QUERY}&engine=google_news&api_key=${SERPAPI_API_KEY}")

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    echo "Error from SerpAPI:"
    echo "$RESPONSE" | jq -r '.error'
    exit 1
fi

# Extract relevant fields and save
echo "$RESPONSE" | jq '{
    news_results: [.news_results[]? | {
        position: .position,
        title: .title,
        link: .link,
        snippet: .snippet,
        source: .source.name,
        date: .date
    }]
}' > "$OUTPUT_FILE"

# Print summary
COUNT=$(jq '.news_results | length' "$OUTPUT_FILE")
echo "Found $COUNT news articles for: $QUERY"
echo "Results saved to: $OUTPUT_FILE"

# Print preview
echo ""
echo "Latest articles:"
jq -r '.news_results[:5][] | "  \(.position). \(.title)\n     \(.source) - \(.date)\n     \(.link)"' "$OUTPUT_FILE"

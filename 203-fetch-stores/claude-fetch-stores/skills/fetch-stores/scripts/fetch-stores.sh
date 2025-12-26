#!/bin/bash

# Dumpling AI Store Fetcher
# Usage: ./fetch-stores.sh "search query"

API_URL="https://app.dumplingai.com/api/v1/search-places"

# Check if API key is set
if [ -z "$DUMPLING_AI_API_KEY" ]; then
    echo "Error: DUMPLING_AI_API_KEY environment variable is not set"
    echo "Please set it with: export DUMPLING_AI_API_KEY=your_api_key"
    exit 1
fi

# Check if query is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a search query"
    echo "Usage: ./fetch-stores.sh \"best restaurants in New York\""
    exit 1
fi

QUERY="$1"
LOCATION="${2:-}"
OUTPUT_DIR="/tmp/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/stores_${TIMESTAMP}.json"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Searching for: $QUERY"
if [ ! -z "$LOCATION" ]; then
    echo "Location: $LOCATION"
fi
echo "API URL: $API_URL"

# Build request body
if [ ! -z "$LOCATION" ]; then
    REQUEST_BODY="{\"query\": \"$QUERY\", \"location\": \"$LOCATION\", \"language\": \"en\"}"
else
    REQUEST_BODY="{\"query\": \"$QUERY\", \"language\": \"en\"}"
fi

# Call Dumpling AI API
response=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DUMPLING_AI_API_KEY" \
    -d "$REQUEST_BODY")

# Check if request was successful
if [ $? -eq 0 ]; then
    echo "$response" | jq '.' > "$OUTPUT_FILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✓ Data saved to: $OUTPUT_FILE"

        # Display number of stores
        count=$(echo "$response" | jq '.places | length' 2>/dev/null)
        if [ ! -z "$count" ] && [ "$count" != "null" ]; then
            echo "✓ Retrieved $count places"
        fi

        # Display top rated places
        echo ""
        echo "Top rated places:"
        echo "$response" | jq -r '.places[]? | select(.rating != null) | "- \(.title) ★\(.rating) (\(.ratingCount) reviews) - \(.address)"' 2>/dev/null | head -n 10

        # Find the best rated place
        echo ""
        echo "Best rated place:"
        echo "$response" | jq -r '[.places[]? | select(.rating != null)] | sort_by(-.rating, -.ratingCount) | first | "🏆 \(.title)\n   Rating: ★\(.rating) (\(.ratingCount) reviews)\n   Address: \(.address)\n   Phone: \(.phoneNumber // "N/A")\n   Website: \(.website // "N/A")"' 2>/dev/null

    else
        # If jq is not available, save raw data
        echo "$response" > "$OUTPUT_FILE"
        echo "✓ Data saved to: $OUTPUT_FILE (raw format)"
        echo ""
        echo "Raw response preview:"
        echo "$response" | head -c 500
    fi
else
    echo "✗ API request failed"
    exit 1
fi

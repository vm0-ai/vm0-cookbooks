#!/bin/bash

# Bright Data TikTok Scraper - Trigger Script
# Usage: ./trigger-scrape.sh "search_keyword"

API_URL="https://api.brightdata.com/datasets/v3/trigger"
DATASET_ID="${BRIGHTDATA_DATASET_ID:-gd_l1villgoiiidt09ci}"

# Check if API key is set
if [ -z "$BRIGHTDATA_API_KEY" ]; then
    echo "Error: BRIGHTDATA_API_KEY environment variable is not set"
    echo "Please set it with: vm0 secret set BRIGHTDATA_API_KEY your_api_key"
    exit 1
fi

# Check if keyword is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a search keyword"
    echo "Usage: ./trigger-scrape.sh \"fitness trainer\""
    exit 1
fi

KEYWORD="$1"
LIMIT="${2:-5}"

echo "Triggering TikTok scrape for keyword: $KEYWORD"
echo "Results limit: $LIMIT"

# Build request body - using search_url format
REQUEST_BODY=$(cat <<EOF
{
  "input": [
    {
      "search_url": "https://www.tiktok.com/search?q=$KEYWORD",
      "country": "US"
    }
  ]
}
EOF
)

# Call Bright Data API
response=$(curl -s -X POST "$API_URL?dataset_id=$DATASET_ID&include_errors=true&type=discover_new&discover_by=search_url&limit_per_input=$LIMIT" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
    -d "$REQUEST_BODY")

# Check if request was successful
if [ $? -eq 0 ]; then
    # Extract snapshot_id
    snapshot_id=$(echo "$response" | jq -r '.snapshot_id' 2>/dev/null)

    if [ ! -z "$snapshot_id" ] && [ "$snapshot_id" != "null" ]; then
        echo ""
        echo "Scrape triggered successfully!"
        echo "Snapshot ID: $snapshot_id"
        echo ""
        echo "Wait 2-3 minutes, then fetch results with:"
        echo "  get-snapshot.sh \"$snapshot_id\""
    else
        echo "Error: Could not get snapshot_id from response"
        echo "Response: $response"
        exit 1
    fi
else
    echo "Error: API request failed"
    exit 1
fi

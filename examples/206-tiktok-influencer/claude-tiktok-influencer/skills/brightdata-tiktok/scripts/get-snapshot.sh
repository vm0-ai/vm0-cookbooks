#!/bin/bash

# Bright Data TikTok Scraper - Get Snapshot Script
# Usage: ./get-snapshot.sh "snapshot_id"

API_BASE="https://api.brightdata.com/datasets/v3/snapshot"

# Check if API key is set
if [ -z "$BRIGHTDATA_API_KEY" ]; then
    echo "Error: BRIGHTDATA_API_KEY environment variable is not set"
    echo "Please set it with: vm0 secret set BRIGHTDATA_API_KEY your_api_key"
    exit 1
fi

# Check if snapshot_id is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a snapshot_id"
    echo "Usage: ./get-snapshot.sh \"snapshot_id\""
    exit 1
fi

SNAPSHOT_ID="$1"
OUTPUT_DIR="/tmp/data"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/tiktok_${TIMESTAMP}.json"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Fetching snapshot: $SNAPSHOT_ID"

# Call Bright Data API
response=$(curl -s -X GET "${API_BASE}/${SNAPSHOT_ID}?format=json" \
    -H "Authorization: Bearer $BRIGHTDATA_API_KEY")

# Check if request was successful
if [ $? -eq 0 ]; then
    # Check if still running
    status=$(echo "$response" | jq -r '.status' 2>/dev/null)

    if [ "$status" = "running" ]; then
        echo ""
        echo "Snapshot is still being prepared..."
        echo "Please wait 1-2 more minutes and try again."
        exit 0
    fi

    # Check for errors
    error=$(echo "$response" | jq -r '.error' 2>/dev/null)
    if [ ! -z "$error" ] && [ "$error" != "null" ]; then
        echo "Error: $error"
        exit 1
    fi

    # Save results
    echo "$response" | jq '.' > "$OUTPUT_FILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo ""
        echo "Results saved to: $OUTPUT_FILE"

        # Count profiles
        count=$(echo "$response" | jq 'length' 2>/dev/null)
        if [ ! -z "$count" ] && [ "$count" != "null" ]; then
            echo "Found $count TikTok profiles"
        fi

        echo ""
        echo "Influencer Profiles Found:"
        echo "=========================="
        # Use actual field names from Bright Data response
        echo "$response" | jq -r '.[]? | "
Username: @\(.author.name // .author.id // "N/A")
Profile URL: \(.author.url // "N/A")
Followers: \(.author.followers // "N/A")
Bio: \(.author.bio // "N/A" | .[0:100])
---"' 2>/dev/null

    else
        # If jq fails, save raw
        echo "$response" > "$OUTPUT_FILE"
        echo "Results saved to: $OUTPUT_FILE (raw format)"
    fi
else
    echo "Error: API request failed"
    exit 1
fi

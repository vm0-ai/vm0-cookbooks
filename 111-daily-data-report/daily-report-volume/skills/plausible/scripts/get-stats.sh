#!/bin/bash

# Get Plausible Analytics statistics
# Usage: get-stats.sh [date] [end_date]

set -e

if [ -z "$PLAUSIBLE_API_KEY" ]; then
    echo "Error: PLAUSIBLE_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$PLAUSIBLE_SITE_ID" ]; then
    echo "Error: PLAUSIBLE_SITE_ID environment variable is not set"
    exit 1
fi

# Default to yesterday if no date provided
if [ -z "$1" ]; then
    DATE=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
else
    DATE="$1"
fi

# Plausible custom period requires two dates: start,end
# If end date provided, use date range; otherwise use same date for both
if [ -n "$2" ]; then
    PERIOD="${DATE},${2}"
else
    PERIOD="${DATE},${DATE}"
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/plausible_stats_${TIMESTAMP}.json"

# Plausible API base URL (default to cloud, can be overridden)
PLAUSIBLE_API_URL="${PLAUSIBLE_API_URL:-https://plausible.io/api/v1}"

# Fetch aggregate stats
echo "Fetching aggregate stats for ${PLAUSIBLE_SITE_ID}..."
AGGREGATE=$(curl -s -X GET "${PLAUSIBLE_API_URL}/stats/aggregate?site_id=${PLAUSIBLE_SITE_ID}&period=custom&date=${PERIOD}&metrics=visitors,pageviews,bounce_rate,visit_duration" \
    -H "Authorization: Bearer $PLAUSIBLE_API_KEY")

# Check for errors
if echo "$AGGREGATE" | jq -e '.error' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$AGGREGATE" | jq -r '.error')
    echo "Error from Plausible API: $ERROR_MSG"
    exit 1
fi

# Fetch top pages
echo "Fetching top pages..."
TOP_PAGES=$(curl -s -X GET "${PLAUSIBLE_API_URL}/stats/breakdown?site_id=${PLAUSIBLE_SITE_ID}&period=custom&date=${PERIOD}&property=event:page&limit=10" \
    -H "Authorization: Bearer $PLAUSIBLE_API_KEY")

# Fetch top sources
echo "Fetching top sources..."
TOP_SOURCES=$(curl -s -X GET "${PLAUSIBLE_API_URL}/stats/breakdown?site_id=${PLAUSIBLE_SITE_ID}&period=custom&date=${PERIOD}&property=visit:source&limit=10" \
    -H "Authorization: Bearer $PLAUSIBLE_API_KEY")

# Combine results
RESULT=$(jq -n \
    --argjson aggregate "$AGGREGATE" \
    --argjson pages "$TOP_PAGES" \
    --argjson sources "$TOP_SOURCES" \
    --arg site "$PLAUSIBLE_SITE_ID" \
    --arg date "$DATE" \
    '{
        site_id: $site,
        date: $date,
        visitors: $aggregate.results.visitors.value,
        pageviews: $aggregate.results.pageviews.value,
        bounce_rate: $aggregate.results.bounce_rate.value,
        visit_duration: $aggregate.results.visit_duration.value,
        top_pages: $pages.results,
        top_sources: $sources.results
    }')

# Save results
echo "$RESULT" > "$OUTPUT_FILE"

# Print summary
echo ""
echo "Site: $PLAUSIBLE_SITE_ID"
echo "Date: $DATE"
echo "Visitors: $(echo "$RESULT" | jq -r '.visitors // "N/A"')"
echo "Pageviews: $(echo "$RESULT" | jq -r '.pageviews // "N/A"')"
echo "Bounce Rate: $(echo "$RESULT" | jq -r '.bounce_rate // "N/A"')%"

DURATION=$(echo "$RESULT" | jq -r '.visit_duration // 0')
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))
echo "Avg Visit Duration: ${MINUTES}m ${SECONDS}s"

echo ""
echo "Top Pages:"
echo "$RESULT" | jq -r '.top_pages[:5][] | "  - \(.page) - \(.visitors) visitors"' 2>/dev/null || echo "  No data"

echo ""
echo "Top Sources:"
echo "$RESULT" | jq -r '.top_sources[:5][] | "  - \(.source) - \(.visitors) visitors"' 2>/dev/null || echo "  No data"

echo ""
echo "Results saved to: $OUTPUT_FILE"

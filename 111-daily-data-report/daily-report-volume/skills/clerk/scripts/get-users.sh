#!/bin/bash

# Get Clerk user metrics
# Usage: get-users.sh [date]

set -e

if [ -z "$CLERK_SECRET_KEY" ]; then
    echo "Error: CLERK_SECRET_KEY environment variable is not set"
    exit 1
fi

# Default to yesterday if no date provided
if [ -z "$1" ]; then
    TARGET_DATE=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
else
    TARGET_DATE="$1"
fi

# Calculate timestamps for the target date (UTC)
START_TS=$(date -d "${TARGET_DATE} 00:00:00 UTC" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${TARGET_DATE} 00:00:00" +%s)
END_TS=$(date -d "${TARGET_DATE} 23:59:59 UTC" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "${TARGET_DATE} 23:59:59" +%s)

# Convert to milliseconds for Clerk API
START_MS=$((START_TS * 1000))
END_MS=$((END_TS * 1000))

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/clerk_users_${TIMESTAMP}.json"

CLERK_API_URL="https://api.clerk.com/v1"
AUTH_HEADER="Authorization: Bearer ${CLERK_SECRET_KEY}"

echo "Fetching Clerk user metrics for ${TARGET_DATE}..."

# Get total user count
echo "Getting total users..."
TOTAL_RESPONSE=$(curl -s -X GET "${CLERK_API_URL}/users/count" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json")

# Check for error
if echo "$TOTAL_RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$TOTAL_RESPONSE" | jq -r '.errors[0].message // .errors[0].long_message // "Unknown error"')
    echo "Error from Clerk API: $ERROR_MSG"
    echo "Response: $TOTAL_RESPONSE"
    exit 1
fi

TOTAL_USERS=$(echo "$TOTAL_RESPONSE" | jq -r '.total_count // 0')

# Get new users (created on target date)
echo "Getting new users..."
NEW_USERS_RESPONSE=$(curl -s -X GET "${CLERK_API_URL}/users?limit=100&order_by=-created_at" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json")

# Check for API error
if echo "$NEW_USERS_RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    echo "Warning: Could not fetch new users"
    NEW_USERS=0
else
    # Count users created on target date - Clerk returns array of users
    NEW_USERS=$(echo "$NEW_USERS_RESPONSE" | jq --argjson start "$START_MS" --argjson end "$END_MS" \
        '[.data // . | .[] | select(.created_at >= $start and .created_at <= $end)] | length' 2>/dev/null || echo "0")
fi

# Get active users (last_active_at on target date)
echo "Getting active users..."
ACTIVE_USERS_RESPONSE=$(curl -s -X GET "${CLERK_API_URL}/users?limit=100&order_by=-last_active_at" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json")

# Check for API error
if echo "$ACTIVE_USERS_RESPONSE" | jq -e '.errors' > /dev/null 2>&1; then
    echo "Warning: Could not fetch active users"
    ACTIVE_USERS=0
else
    # Count users active on target date
    ACTIVE_USERS=$(echo "$ACTIVE_USERS_RESPONSE" | jq --argjson start "$START_MS" --argjson end "$END_MS" \
        '[.data // . | .[] | select(.last_active_at != null and .last_active_at >= $start and .last_active_at <= $end)] | length' 2>/dev/null || echo "0")
fi

# Ensure we have numbers
NEW_USERS=${NEW_USERS:-0}
ACTIVE_USERS=${ACTIVE_USERS:-0}

# Build result
RESULT=$(jq -n \
    --arg date "$TARGET_DATE" \
    --argjson total "${TOTAL_USERS:-0}" \
    --argjson active "${ACTIVE_USERS}" \
    --argjson new "${NEW_USERS}" \
    '{
        date: $date,
        total_users: $total,
        active_users: $active,
        new_users: $new
    }')

# Save results
echo "$RESULT" > "$OUTPUT_FILE"

# Print summary
echo ""
echo "Clerk User Metrics for ${TARGET_DATE}"
echo "Total Users: ${TOTAL_USERS:-0}"
echo "Active Users: ${ACTIVE_USERS}"
echo "New Users: ${NEW_USERS}"
echo ""
echo "Results saved to: $OUTPUT_FILE"

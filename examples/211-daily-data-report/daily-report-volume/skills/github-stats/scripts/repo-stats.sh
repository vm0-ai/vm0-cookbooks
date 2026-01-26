#!/bin/bash

# Get GitHub repository statistics
# Usage: repo-stats.sh "owner/repo"

set -e

REPO="$1"

if [ -z "$REPO" ]; then
    echo "Error: Repository is required"
    echo "Usage: repo-stats.sh \"owner/repo\""
    exit 1
fi

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/github_stats_${TIMESTAMP}.json"

# Build authorization header if token is available
AUTH_HEADER=""
if [ -n "$GITHUB_TOKEN" ]; then
    AUTH_HEADER="-H \"Authorization: Bearer $GITHUB_TOKEN\""
fi

# Make API request
RESPONSE=$(curl -s -X GET "https://api.github.com/repos/${REPO}" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "User-Agent: vm0-daily-report" \
    ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"})

# Check for errors
if echo "$RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.message')
    if [ "$ERROR_MSG" != "null" ]; then
        echo "Error from GitHub API: $ERROR_MSG"
        exit 1
    fi
fi

# Extract relevant fields
STATS=$(echo "$RESPONSE" | jq '{
    full_name: .full_name,
    description: .description,
    stargazers_count: .stargazers_count,
    forks_count: .forks_count,
    watchers_count: .watchers_count,
    open_issues_count: .open_issues_count,
    subscribers_count: .subscribers_count,
    created_at: .created_at,
    updated_at: .updated_at,
    pushed_at: .pushed_at,
    default_branch: .default_branch,
    language: .language
}')

# Save results
echo "$STATS" > "$OUTPUT_FILE"

# Print summary
echo "Repository: $(echo "$STATS" | jq -r '.full_name')"
echo "Stars: $(echo "$STATS" | jq -r '.stargazers_count')"
echo "Forks: $(echo "$STATS" | jq -r '.forks_count')"
echo "Watchers: $(echo "$STATS" | jq -r '.watchers_count')"
echo "Open Issues: $(echo "$STATS" | jq -r '.open_issues_count')"
echo ""
echo "Results saved to: $OUTPUT_FILE"

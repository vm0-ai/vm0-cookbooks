#!/bin/bash

# Get GitHub repository code changes for a specific date
# Usage: get-changes.sh "owner/repo" [date]

set -e

REPO="$1"

if [ -z "$REPO" ]; then
    echo "Error: Repository is required"
    echo "Usage: get-changes.sh \"owner/repo\" [date]"
    exit 1
fi

# Default to yesterday if no date provided
if [ -z "$2" ]; then
    TARGET_DATE=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)
else
    TARGET_DATE="$2"
fi

# Calculate date range (start of day to end of day)
SINCE="${TARGET_DATE}T00:00:00Z"
UNTIL="${TARGET_DATE}T23:59:59Z"

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/github_changes_${TIMESTAMP}.json"

echo "Fetching commits for ${REPO} on ${TARGET_DATE}..."

# Fetch commits for the date range
COMMITS_RESPONSE=$(curl -s -X GET "https://api.github.com/repos/${REPO}/commits?since=${SINCE}&until=${UNTIL}&per_page=100" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "User-Agent: vm0-daily-report" \
    ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"})

# Check for errors
if echo "$COMMITS_RESPONSE" | jq -e '.message' > /dev/null 2>&1; then
    ERROR_MSG=$(echo "$COMMITS_RESPONSE" | jq -r '.message')
    if [ "$ERROR_MSG" != "null" ]; then
        echo "Error from GitHub API: $ERROR_MSG"
        exit 1
    fi
fi

# Count commits
COMMIT_COUNT=$(echo "$COMMITS_RESPONSE" | jq 'length')

if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "No commits found for ${TARGET_DATE}"

    # Create empty result
    RESULT=$(jq -n \
        --arg repo "$REPO" \
        --arg date "$TARGET_DATE" \
        '{
            repository: $repo,
            date: $date,
            total_commits: 0,
            commits: [],
            summary: {
                total_additions: 0,
                total_deletions: 0,
                total_files_changed: 0,
                authors: []
            }
        }')

    echo "$RESULT" > "$OUTPUT_FILE"
    echo "Results saved to: $OUTPUT_FILE"
    exit 0
fi

echo "Found ${COMMIT_COUNT} commits. Fetching details..."

# Process each commit to get detailed stats
COMMITS_DETAIL="[]"
TOTAL_ADDITIONS=0
TOTAL_DELETIONS=0
TOTAL_FILES=0
AUTHORS=""

for sha in $(echo "$COMMITS_RESPONSE" | jq -r '.[].sha'); do
    # Get detailed commit info
    COMMIT_DETAIL=$(curl -s -X GET "https://api.github.com/repos/${REPO}/commits/${sha}" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "User-Agent: vm0-daily-report" \
        ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"})

    # Extract info
    MESSAGE=$(echo "$COMMIT_DETAIL" | jq -r '.commit.message' | head -1)
    AUTHOR=$(echo "$COMMIT_DETAIL" | jq -r '.author.login // .commit.author.name')
    DATE=$(echo "$COMMIT_DETAIL" | jq -r '.commit.author.date')
    ADDITIONS=$(echo "$COMMIT_DETAIL" | jq -r '.stats.additions // 0')
    DELETIONS=$(echo "$COMMIT_DETAIL" | jq -r '.stats.deletions // 0')
    FILES_CHANGED=$(echo "$COMMIT_DETAIL" | jq -r '.files | length')

    # Add to totals
    TOTAL_ADDITIONS=$((TOTAL_ADDITIONS + ADDITIONS))
    TOTAL_DELETIONS=$((TOTAL_DELETIONS + DELETIONS))
    TOTAL_FILES=$((TOTAL_FILES + FILES_CHANGED))

    # Track authors
    if [[ ! "$AUTHORS" =~ "$AUTHOR" ]]; then
        if [ -n "$AUTHORS" ]; then
            AUTHORS="${AUTHORS},\"${AUTHOR}\""
        else
            AUTHORS="\"${AUTHOR}\""
        fi
    fi

    # Add to commits array
    COMMIT_INFO=$(jq -n \
        --arg sha "$sha" \
        --arg message "$MESSAGE" \
        --arg author "$AUTHOR" \
        --arg date "$DATE" \
        --argjson additions "$ADDITIONS" \
        --argjson deletions "$DELETIONS" \
        --argjson files "$FILES_CHANGED" \
        '{
            sha: $sha,
            message: $message,
            author: $author,
            date: $date,
            additions: $additions,
            deletions: $deletions,
            files_changed: $files
        }')

    COMMITS_DETAIL=$(echo "$COMMITS_DETAIL" | jq --argjson commit "$COMMIT_INFO" '. + [$commit]')

    # Small delay to avoid rate limiting
    sleep 0.5
done

# Build final result
RESULT=$(jq -n \
    --arg repo "$REPO" \
    --arg date "$TARGET_DATE" \
    --argjson commits "$COMMITS_DETAIL" \
    --argjson total_commits "$COMMIT_COUNT" \
    --argjson total_additions "$TOTAL_ADDITIONS" \
    --argjson total_deletions "$TOTAL_DELETIONS" \
    --argjson total_files "$TOTAL_FILES" \
    --argjson authors "[$AUTHORS]" \
    '{
        repository: $repo,
        date: $date,
        total_commits: $total_commits,
        commits: $commits,
        summary: {
            total_additions: $total_additions,
            total_deletions: $total_deletions,
            total_files_changed: $total_files,
            authors: $authors
        }
    }')

# Save results
echo "$RESULT" > "$OUTPUT_FILE"

# Print summary
echo ""
echo "Repository: $REPO"
echo "Date: $TARGET_DATE"
echo "Total Commits: $COMMIT_COUNT"
echo ""
echo "Commits:"
echo "$COMMITS_DETAIL" | jq -r '.[] | "  - \(.message | split("\n")[0]) by @\(.author)"'
echo ""
echo "Summary:"
echo "  Files Changed: $TOTAL_FILES"
echo "  Lines Added: +$TOTAL_ADDITIONS"
echo "  Lines Removed: -$TOTAL_DELETIONS"
echo ""
echo "Results saved to: $OUTPUT_FILE"

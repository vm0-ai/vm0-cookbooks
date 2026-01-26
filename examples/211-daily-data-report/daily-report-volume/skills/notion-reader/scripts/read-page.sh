#!/bin/bash

# Read a Notion page by ID
# Usage: read-page.sh "PAGE_ID"

set -e

PAGE_ID="$1"

if [ -z "$PAGE_ID" ]; then
    echo "Error: Page ID is required"
    echo "Usage: read-page.sh \"PAGE_ID\""
    exit 1
fi

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

# Normalize page ID (remove hyphens if present, then format correctly)
PAGE_ID=$(echo "$PAGE_ID" | tr -d '-')

# Create output directory
mkdir -p /tmp/data

TIMESTAMP=$(date +%s)
OUTPUT_FILE="/tmp/data/notion_page_${TIMESTAMP}.json"

echo "Fetching Notion page: ${PAGE_ID}..."

# Get page metadata
PAGE_RESPONSE=$(curl -s -X GET "https://api.notion.com/v1/pages/${PAGE_ID}" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28")

# Check for errors
if echo "$PAGE_RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Error from Notion API:"
    echo "$PAGE_RESPONSE" | jq -r '.message'
    exit 1
fi

# Extract page info
PAGE_TITLE=$(echo "$PAGE_RESPONSE" | jq -r '
    if .properties.title then
        .properties.title.title[0].plain_text // "Untitled"
    elif .properties.Name then
        .properties.Name.title[0].plain_text // "Untitled"
    else
        "Untitled"
    end
')

echo "Page found: ${PAGE_TITLE}"
echo "Fetching page content..."

# Get page blocks (content)
BLOCKS_RESPONSE=$(curl -s -X GET "https://api.notion.com/v1/blocks/${PAGE_ID}/children?page_size=100" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Notion-Version: 2022-06-28")

# Check for errors
if echo "$BLOCKS_RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Warning: Could not fetch page content"
    BLOCKS_RESPONSE='{"results": []}'
fi

# Extract text content from blocks
CONTENT=$(echo "$BLOCKS_RESPONSE" | jq '[.results[] | {
    type: .type,
    text: (
        if .type == "paragraph" then
            ([.paragraph.rich_text[]?.plain_text] | join(""))
        elif .type == "heading_1" then
            ([.heading_1.rich_text[]?.plain_text] | join(""))
        elif .type == "heading_2" then
            ([.heading_2.rich_text[]?.plain_text] | join(""))
        elif .type == "heading_3" then
            ([.heading_3.rich_text[]?.plain_text] | join(""))
        elif .type == "bulleted_list_item" then
            ([.bulleted_list_item.rich_text[]?.plain_text] | join(""))
        elif .type == "numbered_list_item" then
            ([.numbered_list_item.rich_text[]?.plain_text] | join(""))
        elif .type == "to_do" then
            (if .to_do.checked then "[x] " else "[ ] " end) + ([.to_do.rich_text[]?.plain_text] | join(""))
        elif .type == "toggle" then
            ([.toggle.rich_text[]?.plain_text] | join(""))
        elif .type == "quote" then
            ([.quote.rich_text[]?.plain_text] | join(""))
        elif .type == "callout" then
            ([.callout.rich_text[]?.plain_text] | join(""))
        elif .type == "code" then
            ([.code.rich_text[]?.plain_text] | join(""))
        elif .type == "divider" then
            "---"
        else
            ""
        end
    ),
    has_children: .has_children
}]')

# Build result
RESULT=$(jq -n \
    --arg id "$PAGE_ID" \
    --arg title "$PAGE_TITLE" \
    --argjson page "$PAGE_RESPONSE" \
    --argjson content "$CONTENT" \
    '{
        id: $id,
        title: $title,
        url: $page.url,
        created_time: $page.created_time,
        last_edited_time: $page.last_edited_time,
        properties: $page.properties,
        content: $content
    }')

# Save results
echo "$RESULT" > "$OUTPUT_FILE"

# Print summary
echo ""
echo "Page: ${PAGE_TITLE}"
echo "Last edited: $(echo "$PAGE_RESPONSE" | jq -r '.last_edited_time')"
echo ""
echo "Content Preview:"
echo "$CONTENT" | jq -r '.[:20][] |
    if .type == "heading_1" then "# " + .text
    elif .type == "heading_2" then "## " + .text
    elif .type == "heading_3" then "### " + .text
    elif .type == "bulleted_list_item" then "- " + .text
    elif .type == "numbered_list_item" then "1. " + .text
    elif .type == "to_do" then .text
    elif .type == "quote" then "> " + .text
    elif .text != "" then .text
    else empty
    end
' | head -30

echo ""
echo "Results saved to: $OUTPUT_FILE"

#!/bin/bash

# Add a competitor to a Notion database
# Usage: add-competitor.sh "DATABASE_ID" "competitor_data.json"

set -e

DATABASE_ID="$1"
JSON_FILE="$2"

if [ -z "$DATABASE_ID" ] || [ -z "$JSON_FILE" ]; then
    echo "Error: Database ID and JSON file are required"
    echo "Usage: add-competitor.sh \"DATABASE_ID\" \"competitor_data.json\""
    exit 1
fi

if [ -z "$NOTION_API_KEY" ]; then
    echo "Error: NOTION_API_KEY environment variable is not set"
    exit 1
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found: $JSON_FILE"
    exit 1
fi

# Read competitor data
DATA=$(cat "$JSON_FILE")

# Extract values from JSON
COMPANY_NAME=$(echo "$DATA" | jq -r '.company_name // "Unknown"')
YEAR_FOUNDED=$(echo "$DATA" | jq -r '.year_founded // ""')
FUNDING_STATUS=$(echo "$DATA" | jq -r '.funding_status // ""')
MONEY_RAISED=$(echo "$DATA" | jq -r '.money_raised // ""')
POSITIVE_PCT=$(echo "$DATA" | jq -r '.["positive_mentions_%"] // ""')
TOP_PROS=$(echo "$DATA" | jq -r '.top_pros | if type == "array" then join(", ") else "" end')
TOP_CONS=$(echo "$DATA" | jq -r '.top_cons | if type == "array" then join(", ") else "" end')

# Build page content blocks
OFFICES=$(echo "$DATA" | jq -r '.offices | if type == "array" and length > 0 then [.[] | "\(.address), \(.city)"] | join("\n") else "Not available" end')
FOUNDERS=$(echo "$DATA" | jq -r '.founders | if type == "array" and length > 0 then [.[] | "\(.name) (\(.linkedIn // ""))"] | join("\n") else "Not available" end')
CEO=$(echo "$DATA" | jq -r '.ceo | if type == "array" and length > 0 then [.[] | "\(.name) (\(.linkedIn // ""))"] | join("\n") else "Not available" end')
EMPLOYEES=$(echo "$DATA" | jq -r '.employees | if type == "array" and length > 0 then [.[] | "\(.name) - \(.role), (\(.linkedIn // ""))"] | join("\n") else "Not available" end')
OPEN_JOBS=$(echo "$DATA" | jq -r '.open_jobs | if type == "array" and length > 0 then [.[] | "\(.role) (\(.published // "")), \(.description // "")"] | join("\n") else "Not available" end')
INVESTORS=$(echo "$DATA" | jq -r '.investors | if type == "array" and length > 0 then [.[] | "\(.name), \(.description // "") (\(.linkedIn // ""))"] | join("\n") else "Not available" end')
CUSTOMERS=$(echo "$DATA" | jq -r '.customers | if type == "array" and length > 0 then [.[] | "\(.name) (\(.url // ""))"] | join("\n") else "Not available" end')
ARTICLES=$(echo "$DATA" | jq -r '.latest_articles | if type == "array" and length > 0 then [.[] | "**\(.title)**\n\(.url // "")\n\(.published_date // "") | \(.snippet // "")"] | join("\n\n") else "None found" end')
FEATURES=$(echo "$DATA" | jq -r '.features | if type == "array" and length > 0 then [.[] | "\(.name) - \(.description // "")"] | join("\n") else "Not available" end')
PRICING=$(echo "$DATA" | jq -r '.pricing_plans | if type == "array" and length > 0 then [.[] | "\(.name) - \(.price // "") (\(.tier // ""))\n* \(.description // "")"] | join("\n\n") else "Not available" end')

YOY_CUSTOMER=$(echo "$DATA" | jq -r '.yoy_customer_growth // "Unknown"')
ANNUAL_REV=$(echo "$DATA" | jq -r '.annual_revenue // "Unknown"')
YOY_REV=$(echo "$DATA" | jq -r '.yoy_revenue_growth // "Unknown"')
NUM_REVIEWS=$(echo "$DATA" | jq -r '.number_of_reviews // 0')
NEGATIVE_PCT=$(echo "$DATA" | jq -r '.["negative_mentions_%"] // ""')

# Create the Notion page with properties and content
RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_API_KEY" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d @- <<EOF
{
  "parent": {"database_id": "$DATABASE_ID"},
  "properties": {
    "Name": {"title": [{"text": {"content": "$COMPANY_NAME"}}]},
    "Founded": {"rich_text": [{"text": {"content": "$YEAR_FOUNDED"}}]},
    "Funding Status": {"rich_text": [{"text": {"content": "$FUNDING_STATUS"}}]},
    "Money Raised": {"rich_text": [{"text": {"content": "$MONEY_RAISED"}}]},
    "Positive Reviews (%)": {"rich_text": [{"text": {"content": "${POSITIVE_PCT}%"}}]},
    "Pros": {"rich_text": [{"text": {"content": "$TOP_PROS"}}]},
    "Cons": {"rich_text": [{"text": {"content": "$TOP_CONS"}}]}
  },
  "children": [
    {"object": "block", "type": "heading_1", "heading_1": {"rich_text": [{"type": "text", "text": {"content": "$COMPANY_NAME"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Report generated on $(date '+%d %b %Y')"}}]}},
    {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"type": "text", "text": {"content": "Company Overview"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Offices:\n$OFFICES\n\nYear Founded:\n$YEAR_FOUNDED\n\nFounders:\n$FOUNDERS\n\nCEO:\n$CEO\n\nEmployees:\n$EMPLOYEES\n\nOpen Roles:\n$OPEN_JOBS"}}]}},
    {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"type": "text", "text": {"content": "Company Funding"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Money Raised:\n$MONEY_RAISED\n\nFunding Status:\n$FUNDING_STATUS\n\nYoY Customer Growth:\n$YOY_CUSTOMER\n\nAnnual Revenue:\n$ANNUAL_REV\n\nYoY Revenue Growth:\n$YOY_REV\n\nInvestors:\n$INVESTORS\n\nCustomers:\n$CUSTOMERS"}}]}},
    {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"type": "text", "text": {"content": "Company News"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "$ARTICLES"}}]}},
    {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"type": "text", "text": {"content": "Product Offering"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Features:\n$FEATURES"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Pricing Plans:\n$PRICING"}}]}},
    {"object": "block", "type": "heading_2", "heading_2": {"rich_text": [{"type": "text", "text": {"content": "Product Reviews"}}]}},
    {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"type": "text", "text": {"content": "Number of Reviews: $NUM_REVIEWS\nPositive Mentions (%): ${POSITIVE_PCT}%\nNegative Mentions (%): ${NEGATIVE_PCT}%\n\nTop Pros:\n$TOP_PROS\n\nTop Cons:\n$TOP_CONS"}}]}}
  ]
}
EOF
)

# Check for errors
if echo "$RESPONSE" | jq -e '.object == "error"' > /dev/null 2>&1; then
    echo "Error from Notion API:"
    echo "$RESPONSE" | jq -r '.message'
    exit 1
fi

PAGE_ID=$(echo "$RESPONSE" | jq -r '.id')
echo "Created Notion page: $PAGE_ID"
echo "Competitor '$COMPANY_NAME' added to database"

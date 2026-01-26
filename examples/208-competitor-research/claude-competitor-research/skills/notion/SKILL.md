---
name: notion
description: Store and manage competitor research results in a Notion database
---

# Notion Skill

This skill manages competitor research data in Notion databases. It can add new competitor entries, update existing records, and query the database.

## When to Use

Use this skill when:
- You need to store competitor research results
- You want to update an existing competitor record
- You need to check what competitors have already been analyzed
- You want to add structured data with formatted content blocks

## How to Use

### Prerequisites
- `NOTION_API_KEY` environment variable must be set
- The Notion database must be shared with your integration
- The database should have the required properties (see Database Schema below)

### Basic Usage

```bash
# Add a new competitor
add-competitor.sh "DATABASE_ID" "competitor_data.json"

# Query existing entries
query-database.sh "DATABASE_ID"
```

### Database Schema

Your Notion database should have these properties:

| Property | Type | Description |
|----------|------|-------------|
| Name | Title | Company name (primary) |
| Founded | Rich Text | Year founded |
| Funding Status | Rich Text | e.g., "Series B", "Public" |
| Money Raised | Rich Text | e.g., "$50M" |
| Positive Reviews (%) | Rich Text | e.g., "85%" |
| Pros | Rich Text | Comma-separated list of pros |
| Cons | Rich Text | Comma-separated list of cons |

### Examples

```bash
# Add a competitor to the database
add-competitor.sh "2d1c3c72-6e8e-42f3-aece-c6338fd24333" "/tmp/data/competitor.json"

# Query existing competitors
query-database.sh "2d1c3c72-6e8e-42f3-aece-c6338fd24333"
```

### Competitor JSON Format

```json
{
  "company_name": "Competitor Inc",
  "company_website": "https://competitor.com",
  "year_founded": "2015",
  "founders": [{"name": "John Doe", "linkedIn": "linkedin.com/in/johndoe"}],
  "ceo": [{"name": "Jane Smith", "linkedIn": "linkedin.com/in/janesmith"}],
  "employees": [],
  "open_jobs": [],
  "offices": [{"address": "123 Main St", "city": "San Francisco"}],
  "money_raised": "$50M",
  "funding_status": "Series B",
  "investors": [],
  "customers": [],
  "latest_articles": [],
  "features": [{"name": "Feature 1", "description": "Description"}],
  "pricing_plans": [{"name": "Pro", "price": "$10/mo", "tier": "Mid"}],
  "number_of_reviews": 100,
  "positive_mentions_%": "85",
  "negative_mentions_%": "15",
  "top_pros": ["Easy to use", "Great support"],
  "top_cons": ["Expensive", "Limited integrations"]
}
```

## Output

### add-competitor.sh

Prints the created page ID and confirmation:
```
Created Notion page: abc123-def456-...
Competitor 'Competitor Inc' added to database
```

### query-database.sh

Results are saved to `/tmp/data/notion_query_[timestamp].json`:

```json
{
  "results": [
    {
      "id": "page-id-123",
      "properties": {
        "Name": {"title": [{"text": {"content": "Competitor Inc"}}]}
      }
    }
  ]
}
```

## Guidelines

1. Ensure the database is shared with your Notion integration
2. Use the correct database ID (found in the Notion URL)
3. All properties in the JSON should match the database schema
4. The page body includes formatted sections for all research data

## Error Handling

- **401 Unauthorized**: Check that NOTION_API_KEY is set correctly
- **404 Not Found**: The database ID may be incorrect or not shared
- **400 Bad Request**: Check that the JSON data matches the expected schema
- **Property not found**: Ensure the database has all required properties

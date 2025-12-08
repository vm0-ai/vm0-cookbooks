---
name: serpapi
description: Search Google for company profiles, product pages, and reviews using SerpAPI
---

# SerpAPI Skill

This skill uses SerpAPI to perform Google searches and Google News searches. It's useful for finding company profiles on various platforms and discovering news articles.

## When to Use

Use this skill when:
- You need to find company profiles on Crunchbase, WellFound, LinkedIn
- You want to search for pricing pages or product features
- You need to find customer reviews on Trustpilot, ProductHunt
- You want to find recent news articles about a company

## How to Use

### Prerequisites
- `SERPAPI_API_KEY` environment variable must be set

### Basic Usage

```bash
# Regular Google search
search.sh "query" [num_results]

# Google News search
news-search.sh "query"
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| query | Yes | - | The search query |
| num_results | No | 10 | Number of results to return (max 100) |

### Examples

```bash
# Find Crunchbase profile
search.sh "site:crunchbase.com/organization notion"

# Find WellFound profile
search.sh "site:wellfound.com/company notion"

# Find LinkedIn company page
search.sh "site:linkedin.com/company notion"

# Find pricing page
search.sh "notion pricing plans"

# Find reviews
search.sh "notion reviews site:trustpilot.com OR site:producthunt.com" 5

# Find news articles
news-search.sh "notion funding announcement"
```

## Output

### search.sh

Results are saved to `/tmp/data/search_[timestamp].json`:

```json
{
  "organic_results": [
    {
      "position": 1,
      "title": "Notion - Crunchbase Company Profile",
      "link": "https://www.crunchbase.com/organization/notion",
      "snippet": "Notion is a collaboration platform...",
      "source": "Crunchbase"
    }
  ]
}
```

### news-search.sh

Results are saved to `/tmp/data/news_[timestamp].json`:

```json
{
  "news_results": [
    {
      "position": 1,
      "title": "Notion Raises $275M Series C",
      "link": "https://techcrunch.com/...",
      "snippet": "Notion announced today...",
      "source": "TechCrunch",
      "date": "2 days ago"
    }
  ]
}
```

## Guidelines

1. Use site-specific queries for targeted searches (e.g., `site:crunchbase.com`)
2. Limit results to reduce API usage
3. News search is useful for recent company announcements
4. Combine multiple sites with OR operator for broader searches

## Error Handling

- **401 Unauthorized**: Check that SERPAPI_API_KEY is set correctly
- **429 Rate Limited**: Wait and retry, consider reducing request frequency
- **No Results**: Try a broader or alternative query

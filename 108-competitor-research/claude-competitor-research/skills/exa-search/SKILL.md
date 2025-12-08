---
name: exa-search
description: Find similar companies using Exa.ai's neural search API
---

# Exa Search Skill

This skill uses Exa.ai's findSimilar endpoint to discover companies similar to a given URL. It's perfect for competitor discovery as it uses neural search to find semantically similar businesses.

## When to Use

Use this skill when:
- You need to find competitors for a company
- You want to discover similar businesses in a market
- You need to research the competitive landscape

## How to Use

### Prerequisites
- `EXA_API_KEY` environment variable must be set

### Basic Usage

```bash
find-similar.sh "https://example.com" [limit]
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| url | Yes | - | The company URL to find similar companies for |
| limit | No | 10 | Maximum number of similar companies to return |

### Examples

```bash
# Find 10 competitors for Notion
find-similar.sh "https://notion.so"

# Find top 5 competitors for Slack
find-similar.sh "https://slack.com" 5

# Find competitors for a SaaS company
find-similar.sh "https://linear.app" 15
```

## Output

Results are saved to `/tmp/data/competitors.json`:

```json
{
  "results": [
    {
      "title": "Competitor Name",
      "url": "https://competitor.com/",
      "score": 0.95
    }
  ]
}
```

## Guidelines

1. The URL must be a valid company website
2. Results exclude common non-competitor domains (github.com, linkedin.com)
3. Results are sorted by similarity score (highest first)

## Error Handling

- **401 Unauthorized**: Check that EXA_API_KEY is set correctly
- **429 Rate Limited**: Wait and retry after a few seconds
- **Invalid URL**: Ensure the URL is a valid website address

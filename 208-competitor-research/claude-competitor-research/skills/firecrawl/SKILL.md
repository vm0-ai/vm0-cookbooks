---
name: firecrawl
description: Scrape and extract content from web pages using Firecrawl API
---

# Firecrawl Skill

This skill uses Firecrawl to scrape web pages and extract their content as clean markdown. It handles JavaScript-rendered pages and provides structured content extraction.

## When to Use

Use this skill when:
- You need to extract content from a web page
- You want to read company profiles from Crunchbase, WellFound, LinkedIn
- You need to scrape pricing pages, feature lists, or reviews
- The page requires JavaScript rendering

## How to Use

### Prerequisites
- `FIRECRAWL_API_KEY` environment variable must be set

### Basic Usage

```bash
scrape.sh "https://example.com/page"
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| url | Yes | - | The URL of the page to scrape |

### Examples

```bash
# Scrape a Crunchbase profile
scrape.sh "https://www.crunchbase.com/organization/notion"

# Scrape a pricing page
scrape.sh "https://notion.so/pricing"

# Scrape a Trustpilot review page
scrape.sh "https://www.trustpilot.com/review/notion.so"
```

## Output

Results are saved to `/tmp/data/scraped_[timestamp].json`:

```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nPage content in markdown format...",
    "metadata": {
      "title": "Page Title",
      "description": "Page description",
      "sourceURL": "https://example.com/page"
    }
  }
}
```

## Guidelines

1. Pages with heavy JavaScript may take longer to scrape
2. Some pages may require authentication (these will fail)
3. The markdown output has images, SVGs, videos removed for cleaner text
4. Only main content is extracted (navigation, footers excluded)

## Error Handling

- **401 Unauthorized**: Check that FIRECRAWL_API_KEY is set correctly
- **403 Forbidden**: The page may be blocking scraping
- **500 Error**: The page may be temporarily unavailable, retry later
- **Timeout**: Very large pages may timeout, try a more specific URL

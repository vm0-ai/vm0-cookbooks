---
name: firecrawl
description: Crawl and scrape websites using FireCrawl API. Use this skill to extract articles and content from websites.
---

# FireCrawl Skill

This skill allows you to crawl websites and extract content using the FireCrawl API.

## When to Use

Use this skill when:
- You need to scrape articles from a news website
- You want to extract content from multiple pages
- You need structured article data (title, content, author)

## How to Use

### Crawl a Website (Multiple Pages)

```bash
$CLAUDE_CONFIG_DIR/skills/firecrawl/scripts/crawl.sh "https://techcrunch.com"
```

### Scrape a Single Page

```bash
$CLAUDE_CONFIG_DIR/skills/firecrawl/scripts/scrape.sh "https://techcrunch.com/article/123"
```

## Environment Variables

- `FIRECRAWL_API_KEY`: Your FireCrawl API key

## Output

Results are saved to `/tmp/data/firecrawl_[timestamp].json`

Each article includes:
- `title`: Article title
- `content`: Full article text
- `author`: Author name
- `published_at`: Publication date
- `url`: Source URL

## Examples

```bash
# Crawl TechCrunch
crawl.sh "https://techcrunch.com"

# Scrape specific article
scrape.sh "https://techcrunch.com/2024/01/15/openai-gpt5"
```

## Getting an API Key

1. Visit https://firecrawl.dev
2. Sign up for an account
3. Get your API key from the dashboard

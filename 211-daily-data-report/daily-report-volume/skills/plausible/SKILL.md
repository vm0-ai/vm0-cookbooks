---
name: plausible
description: Fetch website traffic analytics from Plausible
---

# Plausible Analytics Skill

Fetches website traffic statistics from Plausible Analytics API.

## When to Use

Use this skill when you need to get:
- Visitor counts
- Pageview statistics
- Bounce rate
- Visit duration
- Top pages
- Top traffic sources

## How to Use

```bash
# Get yesterday's stats (default)
$CLAUDE_CONFIG_DIR/skills/plausible/scripts/get-stats.sh

# Get stats for a specific date
$CLAUDE_CONFIG_DIR/skills/plausible/scripts/get-stats.sh "2024-12-15"

# Get stats for a date range
$CLAUDE_CONFIG_DIR/skills/plausible/scripts/get-stats.sh "2024-12-01" "2024-12-15"
```

### Arguments
- `date` (optional): Specific date in YYYY-MM-DD format. Defaults to yesterday.
- `end_date` (optional): End date for range queries.

### Prerequisites
- `PLAUSIBLE_API_KEY` environment variable must be set
- `PLAUSIBLE_SITE_ID` environment variable must be set (e.g., "vm0.ai")

## Output

Results are saved to `/tmp/data/plausible_stats_[timestamp].json`:

```json
{
  "visitors": 1234,
  "pageviews": 5678,
  "bounce_rate": 45.5,
  "visit_duration": 120,
  "top_pages": [
    {"page": "/", "visitors": 500},
    {"page": "/docs", "visitors": 300}
  ],
  "top_sources": [
    {"source": "Google", "visitors": 400},
    {"source": "Twitter", "visitors": 200}
  ]
}
```

Console output summary:
```
Site: vm0.ai
Date: 2024-12-15
Visitors: 1234
Pageviews: 5678
Bounce Rate: 45.5%
Avg Visit Duration: 2m 0s
```

## Error Handling

- **401 Unauthorized**: Check that PLAUSIBLE_API_KEY is set correctly
- **404 Not Found**: The site ID may be incorrect
- **400 Bad Request**: Check date format (YYYY-MM-DD)

---
name: notion
description: Store and manage influencer data in Notion database
---

# Notion Skill

Add, update, and query influencer data in a Notion database.

## When to Use

Use this skill when you need to:
- Store new influencer data in Notion
- Update influencer records with analysis results
- Query existing data from the database

## Setup Requirements

1. Create a Notion Integration: https://www.notion.so/my-integrations
2. Copy the Integration Token (starts with `ntn_` or `secret_`)
3. Create a database in Notion with the required columns
4. Share the database with your integration (click "..." → "Add connections")

## Database Structure

The Notion database should have these properties:

| Property | Type | Description |
|----------|------|-------------|
| Profile ID | Title | Unique TikTok profile ID |
| Username | Text | TikTok username (e.g., @username) |
| URL | URL | Link to TikTok profile |
| Description | Text | Profile description |
| Followers | Number | Follower count |
| Collaboration | Select | Options: "Highly Relevant", "Not Relevant" |
| Analysis | Text | 50-word analysis of relevance |

## How to Use

### Add a New Influencer

```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-add.sh "database_id" "profile_id" "username" "url" "description" "followers"
```

**Parameters:**
- `database_id`: The Notion database ID (from the URL)
- `profile_id`: Unique TikTok profile ID
- `username`: TikTok username (e.g., "@fitness_guru")
- `url`: Full TikTok profile URL
- `description`: Profile description text
- `followers`: Follower count (number)

**Returns:** The created page ID (save this for updates)

**Example:**
```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-add.sh "abc123def" "12345" "@fitness_guru" "https://tiktok.com/@fitness_guru" "Personal trainer sharing workout tips" "150000"
# Output: page_id=xyz789
```

### Update with Analysis

```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-update.sh "page_id" "collaboration" "analysis"
```

**Parameters:**
- `page_id`: The page ID returned from notion-add.sh
- `collaboration`: Either "Highly Relevant" or "Not Relevant"
- `analysis`: 50-word analysis explaining the classification

**Example:**
```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-update.sh "xyz789" "Highly Relevant" "Strong alignment with fitness industry. 150K engaged followers interested in workout content. Profile description mentions personal training which matches client needs. Content style professional and brand-safe. Excellent candidate for fitness brand collaboration."
```

### Query Database

```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-query.sh "database_id"
```

**Parameters:**
- `database_id`: The Notion database ID

**Returns:** JSON with all entries in the database

**Example:**
```bash
$CLAUDE_CONFIG_DIR/skills/notion/scripts/notion-query.sh "abc123def"
```

## Environment Variables

- `NOTION_API_KEY`: Required. Your Notion Integration Token.

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Invalid API key | Verify NOTION_API_KEY is correct |
| 404 Not Found | Database not shared | Share database with your integration |
| 400 Bad Request | Invalid property format | Check database schema matches expected structure |

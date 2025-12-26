---
name: clerk
description: Get user metrics from Clerk (total users, active users, new users)
---

# Clerk User Metrics Skill

Fetches user statistics from Clerk authentication service.

## When to Use

Use this skill when you need to get:
- Total user count
- Active users (users with activity yesterday)
- New users (users created yesterday)

## How to Use

```bash
# Get yesterday's user metrics (default)
$CLAUDE_CONFIG_DIR/skills/clerk/scripts/get-users.sh

# Get metrics for a specific date
$CLAUDE_CONFIG_DIR/skills/clerk/scripts/get-users.sh "2024-12-17"
```

### Arguments
- `date` (optional): Specific date in YYYY-MM-DD format. Defaults to yesterday.

### Prerequisites
- `CLERK_SECRET_KEY` environment variable must be set (starts with `sk_live_` or `sk_test_`)

## Output

Results are saved to `/tmp/data/clerk_users_[timestamp].json`:

```json
{
  "date": "2024-12-17",
  "total_users": 150,
  "active_users": 25,
  "new_users": 5
}
```

Console output:
```
Clerk User Metrics for 2024-12-17
Total Users: 150
Active Users: 25
New Users: 5
```

## API Reference

- [getCount()](https://clerk.com/docs/references/backend/user/get-count) - Get total user count
- [getUserList()](https://clerk.com/docs/references/backend/user/get-user-list) - List users with filters

## Error Handling

- **401 Unauthorized**: Check that CLERK_SECRET_KEY is set correctly
- **403 Forbidden**: The API key may not have the required permissions
- **429 Rate Limited**: Too many requests, try again later

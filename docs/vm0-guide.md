# How to Make an Agent

This guide walks you through creating your own VM0 agent from scratch. By the end, you'll understand the complete structure and be able to build agents for any use case.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Step-by-Step Guide](#step-by-step-guide)
- [Adding Skills](#adding-skills)
- [Using Secrets](#using-secrets)
- [Testing Your Agent](#testing-your-agent)
- [Best Practices](#best-practices)
- [Complete Example: Travel Planner Agent](#complete-example-travel-planner-agent)

---

## Overview

A VM0 agent consists of three main components:

```
my-agent/
├── vm0.yaml              # Agent configuration
└── my-volume/            # Volume with agent resources
    ├── CLAUDE.md         # Agent persona & instructions
    └── skills/           # Optional: reusable skills
```

**Key files:**
| File | Purpose |
|------|---------|
| `vm0.yaml` | Defines agent settings, volumes, and environment |
| `CLAUDE.md` | Defines who the agent is and how it behaves |
| `skills/` | Optional modular capabilities |

---

## Project Structure

### Minimal Agent

The simplest agent needs just two files:

```
my-agent/
├── vm0.yaml
└── my-volume/
    └── CLAUDE.md
```

### Agent with Skills

For more complex agents with reusable capabilities:

```
my-agent/
├── vm0.yaml
└── my-volume/
    ├── CLAUDE.md
    └── skills/
        └── my-skill/
            ├── SKILL.md
            └── scripts/
                └── my-script.sh
```

---

## Step-by-Step Guide

### Step 1: Create the Directory Structure

```bash
mkdir -p my-agent/my-volume
mkdir -p my-agent/my-volume/skills  # Optional
cd my-agent
```

### Step 2: Create vm0.yaml

Create the main configuration file:

```yaml
version: "1.0"

agents:
  my-agent:
    description: "Description of what your agent does"
    provider: claude-code
    volumes:
      - my-volume:/home/user/.claude
    working_dir: /home/user/workspace

volumes:
  my-volume:
    name: my-volume    # Must match the folder name!
    version: latest
```

**Configuration explained:**

| Field | Description |
|-------|-------------|
| `agents.<name>` | Unique identifier for your agent |
| `description` | Human-readable description |
| `provider` | AI provider (use `claude-code`) |
| `volumes` | Volume mappings (`<ref>:<mount-path>`) |
| `working_dir` | Agent's working directory |
| `volumes.<ref>.name` | Cloud volume name (**must match folder name**) |
| `volumes.<ref>.version` | Version (`latest` or specific hash) |

> **Important**: The `volumes.<ref>.name` must exactly match the volume folder name. For example, if your folder is `my-volume/`, then `name: my-volume`. This is how vm0 links the local folder to the cloud volume.

### Step 3: Create CLAUDE.md

Create `CLAUDE.md` in your volume folder. This is where you describe what you want the agent to do.

```markdown
You are a [role] that helps users with [task].

## Workflow
1. First, [step 1]
2. Then, [step 2]
3. Finally, [step 3]

## Guidelines
- [Guideline 1]
- [Guideline 2]
```

The `CLAUDE.md` file is the heart of your agent. It defines:
- Who the agent is (persona)
- How it should behave (guidelines)
- What workflow it follows (phases/steps)
- What output it produces (deliverables)

See [Complete Example: Travel Planner Agent](#complete-example-travel-planner-agent) for a full example.

### Step 4: Cook it

```bash
vm0 cook "Your prompt here"
```

---

## Adding Skills

Skills are modular, reusable capabilities. Use them when you need to integrate external APIs or have complex logic that needs scripting.

### Skill Structure

```
skills/
└── my-skill/
    ├── SKILL.md           # Documentation: when & how to use
    └── scripts/
        └── my-script.sh   # Executable script
```

### Key Components

1. **SKILL.md**: Document when to use, how to call, required environment variables, and expected output
2. **Script**: Handle errors, validate inputs

### Making Scripts Executable

Scripts must have execute permissions. Add them before pushing:

```bash
chmod +x my-volume/skills/my-skill/scripts/my-script.sh
```

---

## Using Secrets

For sensitive data like API keys, use environment variables or `.env` files instead of hardcoding.

### Setting Secrets

Create a `.env` file in your project directory:

```bash
# .env
MY_API_KEY=sk-your-secret-key
```

Or pass secrets directly when running:

```bash
vm0 run my-agent --secrets MY_API_KEY=sk-your-secret-key "prompt"
```

### Using in vm0.yaml

```yaml
agents:
  my-agent:
    # ... other config ...
    environment:
      MY_API_KEY: ${{ secrets.MY_API_KEY }}
```

### Accessing in Scripts

```bash
# The secret is available as an environment variable
if [ -z "$MY_API_KEY" ]; then
    echo "Error: MY_API_KEY is not set"
    exit 1
fi

curl -H "Authorization: Bearer $MY_API_KEY" ...
```

---

## Testing Your Agent

### Quick Test with Cook

```bash
vm0 cook "Simple test prompt"
```

### Full Manual Test

```bash
# 1. Push volume
cd my-volume
vm0 volume init # if needed
vm0 volume push

# 2. Push artifact
cd ..
mkdir artifact # if needed
cd artifact
vm0 artifact init # if needed
rm -rf ./* # clean last run artifact if needed
vm0 artifact push

# 3. Build configuration
cd ..
vm0 compose vm0.yaml

# 4. Run with artifact storage
vm0 run my-agent --artifact-name artifact "Test prompt"

# 5. Check results
cd artifact
vm0 artifact pull
```

### Iterative Development

1. Edit `CLAUDE.md`
2. Push volume: `vm0 volume push`
3. Test: `vm0 cook "test prompt"`
4. Repeat until satisfied

---

## Best Practices

### Agent Design

1. **Single responsibility**: One agent, one purpose
2. **Clear phases**: Break complex workflows into steps
3. **Explicit outputs**: Define what files/formats to produce
4. **Error guidance**: Tell the agent what to do when stuck

### CLAUDE.md

1. **Start with role**: "You are a [specific role]..."
2. **Use natural language**: Describe tasks in plain language, no code
3. **Don't reference skills**: Claude Code discovers skills automatically
4. **Define structure**: Use phases for complex workflows
5. **Set boundaries**: Clarify what the agent should and shouldn't do
6. **Include output examples**: Show expected file formats (not code)
7. **End with action**: Prompt the agent to begin (e.g., "Where would you like to travel?")

### Skills

1. **Complete documentation**: SKILL.md must include full usage instructions
2. **Include examples**: Show how to call the script with real examples
3. **Handle errors**: Check inputs and environment in scripts
4. **Provide feedback**: Echo progress and results

### Secrets

1. **Never hardcode**: Always use `${{ secrets.NAME }}`
2. **Document requirements**: List required secrets in README
3. **Validate early**: Check for secrets at script start

---

## Complete Example: Travel Planner Agent

Here's a complete example putting it all together:

### Directory Structure

```
travel-planner/
├── vm0.yaml
└── travel-planner-volume/
    ├── CLAUDE.md
    └── skills/
        └── search-places/
            ├── SKILL.md
            └── scripts/
                └── search-places.sh
```

### vm0.yaml

```yaml
version: "1.0"

agents:
  travel-planner:
    description: "Travel planning assistant that creates personalized itineraries"
    provider: claude-code
    volumes:
      - travel-planner-volume:/home/user/.claude
    working_dir: /home/user/workspace
    environment:
      DUMPLING_AI_API_KEY: ${{ secrets.DUMPLING_AI_API_KEY }}

volumes:
  travel-planner-volume:
    name: travel-planner-volume    # Must match folder name
    version: latest
```

### CLAUDE.md

```markdown
You are a travel planning assistant that helps users create detailed trip itineraries.

## Workflow

### Phase 1: Understand the Trip
1. Confirm the destination and travel dates
2. Ask about preferences: budget, pace, interests (food, culture, nature, etc.)
3. Check for any constraints (mobility, dietary, must-see places)

### Phase 2: Research the Destination
Search for relevant information about the destination:
- Attractions and landmarks
- Restaurants and cafes
- Hotels and accommodations

### Phase 3: Build the Itinerary
1. Group nearby locations together
2. Balance activities throughout each day
3. Include meal recommendations near activity locations

### Phase 4: Deliver the Plan
Create itinerary.md with this structure:

# [Destination] Trip Itinerary

## Overview
- Dates: [Start] - [End]
- Duration: [X] days
- Style: [Relaxed/Moderate/Packed]

## Day 1: [Theme]
### Morning
- [ ] [Activity] - [Location]
  - Rating: ★4.5 | Hours: 9AM-5PM

### Lunch
- [ ] [Restaurant] - [Cuisine]
  - Rating: ★4.3 | Price: $$

### Afternoon
- [ ] [Activity]

### Dinner
- [ ] [Restaurant]

## Practical Tips
- Transportation advice
- Money-saving tips

## Guidelines
- Prioritize highly-rated places (4.0+ stars)
- Keep walking distances reasonable
- Include backup restaurant options

Where would you like to travel?
```

### skills/search-places/SKILL.md

````markdown
---
name: search-places
description: Search for places using Dumpling AI's Google Maps API
---

# Search Places

Search for places, businesses, and points of interest.

## Usage

```bash
$CLAUDE_CONFIG_DIR/skills/search-places/scripts/search-places.sh "query" "location"
```

### Arguments
| Argument | Required | Description |
|----------|----------|-------------|
| query | Yes | What to search for (e.g., "coffee shop", "museum") |
| location | Yes | Where to search (e.g., "Tokyo, Japan") |

### Examples
```bash
# Search for museums in Tokyo
./search-places.sh "museum" "Tokyo, Japan"

# Search for ramen restaurants in Shinjuku
./search-places.sh "ramen restaurant" "Shinjuku, Tokyo"
```

## Prerequisites

The `DUMPLING_AI_API_KEY` environment variable must be set.

## Output

Returns JSON with places containing: title, address, rating, ratingCount, category, phoneNumber, website, latitude/longitude.
````

### skills/search-places/scripts/search-places.sh

```bash
#!/bin/bash

# Search Places Script
# Usage: ./search-places.sh "query" "location"

API_URL="https://app.dumplingai.com/api/v1/search-places"

if [ -z "$DUMPLING_AI_API_KEY" ]; then
    echo "Error: DUMPLING_AI_API_KEY environment variable is not set"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: ./search-places.sh \"query\" \"location\""
    exit 1
fi

QUERY="$1"
LOCATION="${2:-}"

if [ -n "$LOCATION" ]; then
    REQUEST_BODY=$(jq -n --arg q "$QUERY" --arg loc "$LOCATION" '{query: $q, location: $loc}')
else
    REQUEST_BODY=$(jq -n --arg q "$QUERY" '{query: $q}')
fi

response=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DUMPLING_AI_API_KEY" \
    -d "$REQUEST_BODY")

echo "Top places found:"
echo "$response" | jq -r '.places[:10][] | "- \(.title) ★\(.rating // "N/A") (\(.ratingCount // 0) reviews) - \(.address)"'
```

### Make Script Executable

```bash
chmod +x travel-planner-volume/skills/search-places/scripts/search-places.sh
```

### Cook Agent

Create a `.env` file with your API key:

```bash
# .env
DUMPLING_AI_API_KEY=your-api-key
```

Then run:

```bash
vm0 cook "Plan a 3-day trip to Tokyo, Japan. I love food and culture."
```
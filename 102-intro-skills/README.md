## Step-by-Step

## Setup Skills

Open `vm0.yaml` and add the skills you want to use:

```yaml
agents:
  intro-skills:
    provider: claude-code
    instructions: AGENTS.md
    skills:
      - https://github.com/vm0-ai/vm0-skills/tree/main/elevenlabs
    environment:
      CLAUDE_CODE_OAUTH_TOKEN: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
      ELEVENLABS_API_KEY: ${{ secrets.ELEVENLABS_API_KEY }}
```

### Find More Skills

- Browse available skills: https://github.com/vm0-ai/vm0-skills
- Learn about Agent Skills: https://agentskills.io/home

## Authentication Setup

Create a `.env` file in this directory with required API keys:

```bash
# Generate token: claude setup-token
CLAUDE_CODE_OAUTH_TOKEN=<your-token>

# Add skill-specific environment variables (e.g., for ElevenLabs)
ELEVENLABS_API_KEY=<your-api-key>
```

## Quick Start

```bash
vm0 cook "let's start working."
```

This will automatically handle artifact setup and run the agent with the configured skills.

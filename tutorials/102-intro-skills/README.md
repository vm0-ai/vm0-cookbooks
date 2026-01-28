## Step-by-Step

## Setup Skills

Open `vm0.yaml` and add the skills you want to use:

```yaml
agents:
  intro-skills:
    framework: claude-code
    instructions: AGENTS.md
    skills:
      - https://github.com/vm0-ai/vm0-skills/tree/main/elevenlabs
    environment:
      ELEVENLABS_API_KEY: ${{ secrets.ELEVENLABS_API_KEY }}
```

### Find More Skills

- Browse available skills: https://github.com/vm0-ai/vm0-skills
- Learn about Agent Skills: https://agentskills.io/home

## Environment Setup

Create a `.env` file in this directory with skill-specific API keys:

```bash
# Add skill-specific environment variables (e.g., for ElevenLabs)
ELEVENLABS_API_KEY=<your-api-key>
```

## Quick Start

```bash
vm0 cook --env-file .env "let's start working."
```

This will automatically handle artifact setup and run the agent with the configured skills.

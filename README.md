# vm0-cookbooks

A collection of VM0 Agent examples.

## Installation

```bash
npm install -g @vm0/cli
```

## Quick Start

```bash
vm0 auth login
cd 101-intro
vm0 cook "echo hello world to readme.md"
```

## Setup Secrets

All cookbooks require Claude Code authentication. Create a `.env` file in the cookbook directory:

```bash
# Generate token first: claude setup-token
CLAUDE_CODE_OAUTH_TOKEN=<your-token>

# Additional secrets (check vm0.yaml for requirements)
DUMPLING_AI_API_KEY=<your-api-key>    # 103-fetch-stores
FAL_KEY=<your-fal-key>                 # 104-content-farm
DEVTO_API_KEY=<your-devto-key>         # 104-content-farm
```

Secrets are auto-loaded from `.env` or environment variables when running `vm0 cook` or `vm0 run`.

## Setup and Run

### Automatic Setup

The simplest way to run an agent. Automatically handles volume and artifact setup:

```bash
cd 101-intro
vm0 cook                  # auto setup
```

### Manual Setup (Step by Step)

Navigate to the example directory:

```bash
cd 101-intro
```

Prepare a volume for CLAUDE.md:

```bash
cd claude-files
vm0 volume init    # Initialize volume
vm0 volume push    # Upload to cloud
cd ..
```

Prepare an artifact for the workspace:

```bash
mkdir artifact
cd artifact
vm0 artifact init    # Initialize artifact
vm0 artifact push    # Upload to cloud
cd ..
```

### Compose and Run

```bash
vm0 compose vm0.yaml
vm0 run intro --artifact-name artifact "echo hello world to readme.md"
```

### Pull the result

```bash
cd artifact
vm0 artifact pull
cat readme.md
```

## Creating Your Own Agent

See [vm0-guide.md](docs/vm0-guide.md)

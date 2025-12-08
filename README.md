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
vm0 cook
```

## Setup and Run

### Automatic Setup

The simplest way to run an agent. Automatically handles volume and artifact setup:

```bash
cd 101-intro
vm0 cook                  # Set up and run the agent
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
mkdir my-artifact
cd my-artifact
vm0 artifact init    # Initialize artifact
vm0 artifact push    # Upload to cloud
cd ..
```

### Compose and Run

```bash
vm0 compose vm0.yaml
vm0 run intro --artifact-name my-artifact "echo hello world to readme.md"
```

Pull the result:

```bash
cd my-artifact
vm0 artifact pull
cat readme.md
```

## Creating Your Own Agent

See [vm0-guide.md](docs/vm0-guide.md)

# 104: Introduction to Artifacts

This tutorial introduces VM0 **artifacts** - a mechanism for managing input/output data with agents.

## What are Artifacts?

Artifacts are working directories that contain files your agent can read and write. They allow you to:

1. **Provide Input Data**: Supply files for the agent to process
2. **Receive Output**: Get files created or modified by the agent
3. **Switch Between Contexts**: Use different artifacts for different projects

## Directory Structure

```
104-intro-artifact/
├── README.md                    # This tutorial guide
├── AGENTS.md                    # Agent instructions
├── vm0.yaml                     # Agent configuration
├── my-artifact-1/               # First artifact
│   ├── .vm0/
│   │   └── storage.yaml        # Artifact metadata
│   └── file.md                 # Contains "This is from my-artifact-1"
└── my-artifact-2/               # Second artifact
    ├── .vm0/
    │   └── storage.yaml        # Artifact metadata
    └── file.md                 # Contains "This is from my-artifact-2"
```

## Step-by-Step Guide

### 1. Initialize Artifacts

Each artifact needs to be initialized and pushed to the VM0 cloud:

```bash
# Initialize and push artifact 1
cd my-artifact-1
vm0 artifact init
vm0 artifact push
cd ..

# Initialize and push artifact 2
cd my-artifact-2
vm0 artifact init
vm0 artifact push
cd ..
```

### 2. Compose the Agent

Deploy your agent configuration:

```bash
vm0 compose vm0.yaml
```

### 3. Run with Different Artifacts

Now you can run the same agent with different artifacts:

```bash
# Run with default artifact (uses current directory)
vm0 run intro-artifact "What content is in file.md"

# Run with my-artifact-1
vm0 run intro-artifact --artifact-name my-artifact-1 "What content is in file.md"

# Run with my-artifact-2
vm0 run intro-artifact --artifact-name my-artifact-2 "What content is in file.md"
```

**Expected Output:**
- First command: Depends on current directory
- Second command: "This is from my-artifact-1"
- Third command: "This is from my-artifact-2"

## Key Concepts

- **Artifact**: A versioned directory containing files for agent input/output
- **Artifact Name**: Identifier used to specify which artifact to use
- **Default Artifact**: When no `--artifact-name` is specified, uses the current directory
- **Storage Metadata**: `.vm0/storage.yaml` contains artifact configuration

## Use Cases

- **Multi-Project Workflows**: Switch between different project contexts
- **Testing**: Test agents with different data sets
- **Collaboration**: Share artifacts with team members
- **Version Control**: Track changes to your working data

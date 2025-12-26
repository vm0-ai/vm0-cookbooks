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

```bash
vm0 compose vm0.yaml
```

### 3. Run with Different Artifacts

Now you can run the same agent with different artifacts:

```bash
# Run without artifact
vm0 run intro-artifact "What content is in file.md? Write hello to hello.md"
# You cannot retrieve hello.md from the cloud since no artifact is specified

# Run with my-artifact-1
vm0 run intro-artifact --artifact-name my-artifact-1 "What content is in file.md? Write number 1 to hello.md"
# You can retrieve hello.md by running: cd my-artifact-1 && vm0 artifact pull

# Run with my-artifact-2
vm0 run intro-artifact --artifact-name my-artifact-2 "What content is in file.md? Write number 2 to hello.md"
# You can retrieve hello.md by running: cd my-artifact-2 && vm0 artifact pull
```

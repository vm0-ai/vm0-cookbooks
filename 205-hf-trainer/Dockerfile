# HF Trainer Agent Dockerfile
# Base image with Claude Code and Hugging Face CLI

FROM node:20-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Install Hugging Face CLI
RUN pip3 install --break-system-packages huggingface_hub

# 901-qwen-code

Run Qwen Code agent with VM0.

## Prerequisites

Before building the image, you need to set up OAuth credentials:

1. Run `brew install qwen-code` or `npm install -g @qwen-code/qwen-code@latest` to install qwen-code locally
2. Run `qwen` locally once to complete OAuth authentication
3. Copy the credentials file to the config directory:

```bash
cp ~/.qwen/oauth_creds.json qwen-config/
```

## Usage

Build the image and run the agent:

```bash
vm0 image build -f Dockerfile -t 901-qwen-code
vm0 cook "run qwen -y 'write hello to foo.md'"
```

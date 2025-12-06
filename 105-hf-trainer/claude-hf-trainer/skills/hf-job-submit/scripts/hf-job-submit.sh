#!/bin/bash

# HF Job Submit Script
# Usage: ./hf-job-submit.sh <script_path> <hardware> <packages>

set -e

SCRIPT_PATH="$1"
HARDWARE="${2:-t4-small}"
PACKAGES="${3:-trl transformers datasets}"

# Validate inputs
if [ -z "$HF_TOKEN" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    echo "Please set it with: export HF_TOKEN=hf_..."
    exit 1
fi

if [ -z "$SCRIPT_PATH" ]; then
    echo "Usage: ./hf-job-submit.sh <script_path> <hardware> <packages>"
    echo ""
    echo "Arguments:"
    echo "  script_path  Path to Python training script"
    echo "  hardware     GPU type: t4-small, t4-medium, a10g-small, a10g-large, a100-large"
    echo "  packages     Space-separated pip packages to install"
    exit 1
fi

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: Script not found: $SCRIPT_PATH"
    exit 1
fi

# Validate hardware option
case "$HARDWARE" in
    t4-small|t4-medium|a10g-small|a10g-large|a100-large)
        ;;
    *)
        echo "Error: Invalid hardware type: $HARDWARE"
        echo "Valid options: t4-small, t4-medium, a10g-small, a10g-large, a100-large"
        exit 1
        ;;
esac

OUTPUT_DIR="/tmp/hf-jobs"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
JOB_DIR="$OUTPUT_DIR/job_$TIMESTAMP"
mkdir -p "$JOB_DIR"

# Copy script to job directory
cp "$SCRIPT_PATH" "$JOB_DIR/train.py"

# Create requirements.txt
echo "$PACKAGES" | tr ' ' '\n' > "$JOB_DIR/requirements.txt"

echo "========================================="
echo "HF Training Job Submission"
echo "========================================="
echo "Script: $SCRIPT_PATH"
echo "Hardware: $HARDWARE"
echo "Packages: $PACKAGES"
echo "========================================="

# Login to Hugging Face
echo "Authenticating with Hugging Face..."
huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential 2>/dev/null || true

# Submit the job using huggingface_hub
echo "Submitting training job..."

python3 << PYTHON_SCRIPT
import os
import sys

try:
    from huggingface_hub import HfApi
except ImportError:
    print("Installing huggingface_hub...")
    os.system("pip install -q huggingface_hub")
    from huggingface_hub import HfApi

api = HfApi()

# Read the training script
with open("$JOB_DIR/train.py", "r") as f:
    script_content = f.read()

# Hardware mapping
hardware_map = {
    "t4-small": "t4-small",
    "t4-medium": "t4-medium",
    "a10g-small": "a10g-small",
    "a10g-large": "a10g-large",
    "a100-large": "a100-large",
}

hardware = hardware_map.get("$HARDWARE", "t4-small")
packages = "$PACKAGES".split()

try:
    # Submit training job
    job = api.submit_training_job(
        script=script_content,
        hardware=hardware,
        requirements=packages,
    )

    print(f"")
    print(f"Job submitted successfully!")
    print(f"========================================")
    print(f"Job ID: {job.job_id}")
    print(f"Status: {job.status}")
    print(f"Hardware: {hardware}")
    print(f"========================================")
    print(f"")
    print(f"Monitor with: hf-job-status.sh {job.job_id}")
    print(f"View logs with: hf-job-logs.sh {job.job_id}")

    # Save job info
    with open("$JOB_DIR/job_info.txt", "w") as f:
        f.write(f"job_id={job.job_id}\\n")
        f.write(f"status={job.status}\\n")
        f.write(f"hardware={hardware}\\n")

    print(f"")
    print(f"Job info saved to: $JOB_DIR/job_info.txt")

except AttributeError:
    # Fallback: Use the jobs CLI if API method doesn't exist
    print("Note: Using huggingface-cli for job submission")
    print("Please ensure you have the latest huggingface_hub installed")
    print("")
    print("Alternative: Run this command manually:")
    print(f"  huggingface-cli jobs submit $JOB_DIR/train.py --hardware {hardware}")
    sys.exit(1)

except Exception as e:
    print(f"Error submitting job: {e}")
    print("")
    print("Troubleshooting:")
    print("1. Ensure HF_TOKEN has write access")
    print("2. Verify you have a Pro/Team account with GPU Jobs access")
    print("3. Check your quota at https://huggingface.co/settings/billing")
    sys.exit(1)

PYTHON_SCRIPT

echo ""
echo "Done!"

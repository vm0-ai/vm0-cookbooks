#!/bin/bash

# HF Job Status Script
# Usage: ./hf-job-status.sh <job_id>

set -e

JOB_ID="$1"

# Validate inputs
if [ -z "$HF_TOKEN" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$JOB_ID" ]; then
    echo "Usage: ./hf-job-status.sh <job_id>"
    echo ""
    echo "Arguments:"
    echo "  job_id  The job ID from hf-job-submit"
    exit 1
fi

echo "Checking status for job: $JOB_ID"
echo ""

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

try:
    job = api.get_training_job("$JOB_ID")

    print("=========================================")
    print(f"Job ID:    {job.job_id}")
    print(f"Status:    {job.status}")

    if hasattr(job, 'progress') and job.progress:
        print(f"Progress:  {job.progress}%")

    if hasattr(job, 'runtime') and job.runtime:
        minutes = int(job.runtime // 60)
        seconds = int(job.runtime % 60)
        print(f"Runtime:   {minutes}m {seconds}s")

    if hasattr(job, 'hardware') and job.hardware:
        print(f"Hardware:  {job.hardware}")

    if hasattr(job, 'cost') and job.cost:
        print(f"Cost:      \${job.cost:.2f}")

    print("=========================================")

    if job.status == "completed":
        print("")
        print("Training completed successfully!")
        if hasattr(job, 'output_model') and job.output_model:
            print(f"Model URL: https://huggingface.co/{job.output_model}")

    elif job.status == "failed":
        print("")
        print("Training failed. Check logs with:")
        print(f"  hf-job-logs.sh $JOB_ID")

    elif job.status == "running":
        print("")
        print("Training in progress...")
        print("Check again later or view logs with:")
        print(f"  hf-job-logs.sh $JOB_ID")

except AttributeError:
    print("Note: Job status API may not be available")
    print("Try using: huggingface-cli jobs status $JOB_ID")
    sys.exit(1)

except Exception as e:
    print(f"Error checking job status: {e}")
    print("")
    print("The job ID might be invalid or expired.")
    sys.exit(1)

PYTHON_SCRIPT

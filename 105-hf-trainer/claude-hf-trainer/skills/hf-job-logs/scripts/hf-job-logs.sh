#!/bin/bash

# HF Job Logs Script
# Usage: ./hf-job-logs.sh <job_id> [tail_lines]

set -e

JOB_ID="$1"
TAIL_LINES="${2:-50}"

# Validate inputs
if [ -z "$HF_TOKEN" ]; then
    echo "Error: HF_TOKEN environment variable is not set"
    exit 1
fi

if [ -z "$JOB_ID" ]; then
    echo "Usage: ./hf-job-logs.sh <job_id> [tail_lines]"
    echo ""
    echo "Arguments:"
    echo "  job_id      The job ID from hf-job-submit"
    echo "  tail_lines  Number of lines to show (default: 50)"
    exit 1
fi

echo "Fetching logs for job: $JOB_ID (last $TAIL_LINES lines)"
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
    logs = api.get_training_job_logs("$JOB_ID")

    if logs:
        # Split into lines and get last N
        lines = logs.strip().split('\n')
        tail_count = int("$TAIL_LINES")

        if len(lines) > tail_count:
            print(f"... (showing last {tail_count} of {len(lines)} lines)")
            print("")
            lines = lines[-tail_count:]

        for line in lines:
            print(line)

        print("")
        print("=========================================")
        print(f"Showing {len(lines)} log lines")

        # Check for common patterns
        if "error" in logs.lower() or "exception" in logs.lower():
            print("Warning: Errors detected in logs")

        if "completed" in logs.lower() or "finished" in logs.lower():
            print("Training appears to have completed")

    else:
        print("No logs available yet.")
        print("The job might still be starting up.")

except AttributeError:
    print("Note: Job logs API may not be available")
    print("Try using: huggingface-cli jobs logs $JOB_ID")
    sys.exit(1)

except Exception as e:
    print(f"Error fetching logs: {e}")
    print("")
    print("The job ID might be invalid or the job hasn't started yet.")
    sys.exit(1)

PYTHON_SCRIPT

#!/bin/bash

# Startup Team Portrait Generator
# Scans current directory for images and generates professional portraits based on them
# Usage: startup-portrait.sh [--style STYLE] [--output-dir DIR]

set -e

# Default values
STYLE="founder"
OUTPUT_DIR="."
GENERATED_MARKER="_generated"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --style)
            STYLE="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if API key is set
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY environment variable is not set"
    echo "Please set it with: export FAL_KEY=your_api_key"
    exit 1
fi

# Main script
echo "========================================"
echo "   Startup Team Portrait Generator"
echo "========================================"
echo ""
echo "Scanning directory: $(pwd)"
echo "Output directory: $OUTPUT_DIR"
echo "Portrait style: $STYLE"
echo ""

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

# Find all existing images
echo "Looking for existing images..."
existing_images=$(find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | sort)

if [ -z "$existing_images" ]; then
    echo "No images found in current directory."
    echo ""
    echo "Please add photos of team members to this directory first."
    echo "Supported formats: jpg, jpeg, png, webp"
    echo ""
    echo "The script will transform these photos into professional portraits."
    exit 0
fi

echo "Found existing images:"
echo "$existing_images" | while read -r img; do
    echo "  - $img"
done
echo ""

# Count images
total_images=$(echo "$existing_images" | wc -l | tr -d ' ')
echo "Processing $total_images image(s)..."
echo ""

# Process each image using Python for proper JSON handling
echo "$existing_images" | while read -r img; do
    # Get base name without extension
    basename_file=$(basename "$img")
    name="${basename_file%.*}"

    # Skip already generated images
    if [[ "$name" == *"$GENERATED_MARKER"* ]] || [[ "$name" == *"portrait_"* ]]; then
        echo "Skipping (already generated): $basename_file"
        continue
    fi

    # Check if a generated version already exists
    if ls "$OUTPUT_DIR"/portrait_${name}_*${GENERATED_MARKER}.png 1>/dev/null 2>&1; then
        echo "Skipping (portrait exists): $basename_file"
        continue
    fi

    echo "Processing: $basename_file"
    echo "Style: $STYLE"

    # Use Python for proper JSON handling and API call
    python3 << PYTHON_SCRIPT
import json
import urllib.request
import os
import base64
import time
import sys

# Image path and style
image_path = "$img"
style = "$STYLE"
output_dir = "$OUTPUT_DIR"
name = "$name"

# Style prompts
prompts = {
    "founder": "Transform this photo into a professional startup founder headshot. Keep the same person's face and features. Smart casual blazer over crisp shirt, warm confident smile, soft studio lighting, clean neutral gray background, sharp focus, high-end corporate photography style",
    "corporate": "Transform this photo into an executive business portrait. Keep the same person's face and features. Formal navy suit with white dress shirt, confident professional expression, soft even studio lighting, neutral office background, corporate photography style",
    "creative": "Transform this photo into a modern creative professional headshot. Keep the same person's face and features. Stylish casual attire, relaxed confident smile, natural warm lighting, minimalist white background, artistic photography style",
    "casual": "Transform this photo into a friendly professional portrait. Keep the same person's face and features. Smart casual clothing, genuine warm smile, soft natural lighting, clean simple background, approachable startup culture vibe",
    "natural": "Transform this photo into a relaxed natural portrait. Keep the same person's face and features. Comfortable everyday clothing like soft sweater or simple shirt, genuine relaxed smile with natural expression, soft diffused daylight, clean solid warm beige background, professional portrait photography with cozy inviting feel"
}

prompt = prompts.get(style, prompts["founder"])

# Get mime type from extension
ext = os.path.splitext(image_path)[1].lower()
mime_types = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp"
}
mime_type = mime_types.get(ext, "image/jpeg")

# Convert image to base64 data URI
print(f"Converting image to base64...")
with open(image_path, "rb") as f:
    base64_data = base64.b64encode(f.read()).decode("utf-8")
data_uri = f"data:{mime_type};base64,{base64_data}"

print(f"Calling fal.ai API...")

# Build request payload
payload = {
    "prompt": prompt,
    "image_urls": [data_uri],
    "aspect_ratio": "1:1",
    "resolution": "1K",
    "output_format": "png",
    "num_images": 1
}

# Make API request
request = urllib.request.Request(
    "https://fal.run/fal-ai/nano-banana-pro/edit",
    data=json.dumps(payload).encode("utf-8"),
    headers={
        "Authorization": f"Key {os.environ['FAL_KEY']}",
        "Content-Type": "application/json"
    }
)

try:
    with urllib.request.urlopen(request, timeout=120) as response:
        result = json.loads(response.read())

        if "images" in result and len(result["images"]) > 0:
            image_url = result["images"][0]["url"]
            print(f"Generated image URL: {image_url}")

            # Download the image
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            output_file = f"{output_dir}/portrait_{name}_{timestamp}_generated.png"

            print(f"Downloading to: {output_file}")
            urllib.request.urlretrieve(image_url, output_file)

            file_size = os.path.getsize(output_file)
            print(f"Success! Saved: {output_file} ({file_size // 1024}KB)")
        else:
            print("Error: No image in response")
            print(json.dumps(result, indent=2))
            sys.exit(1)
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code}")
    print(e.read().decode())
    sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
PYTHON_SCRIPT

    echo ""
    # Small delay to avoid rate limiting
    sleep 1
done

echo ""
echo "========================================"
echo "   Complete!"
echo "========================================"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Generated portraits are saved with '${GENERATED_MARKER}' suffix"
echo "to distinguish them from original images."

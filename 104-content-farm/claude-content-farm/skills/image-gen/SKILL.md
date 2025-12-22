---
name: image-gen
description: Generate images using fal.ai Nano Banana Pro API. Use this skill when you need to create a featured image for blog content.
---

# Image Generator (Nano Banana Pro)

This skill generates high-quality images using the fal.ai Nano Banana Pro API (powered by Google Gemini 3 Pro Image).

## When to Use

Use this skill when:
- Creating a featured image for a blog post
- Need a visual representation of the article topic
- Want to generate custom illustrations for content

## Prerequisites

The `FAL_KEY` environment variable must be set with your fal.ai API key.

## How to Use

Execute the script with a prompt describing the desired image:

```bash
/home/user/.claude/skills/image-gen/scripts/image-gen.sh "prompt" [aspect_ratio] [resolution]
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| prompt | Yes | - | Text description of the image to generate |
| aspect_ratio | No | 16:9 | Image aspect ratio (1:1, 16:9, 4:3, 9:16, etc.) |
| resolution | No | 1K | Image resolution (1K, 2K, 4K) |

### Examples

```bash
# Generate a blog header image with default settings
/home/user/.claude/skills/image-gen/scripts/image-gen.sh "Modern AI technology concept, neural networks and data visualization, blue and purple gradient, clean professional style" "16:9" "1K"

# Generate a square image for social media
/home/user/.claude/skills/image-gen/scripts/image-gen.sh "Modern tech startup office with developers" "1:1"

# Generate a high-resolution vertical image
/home/user/.claude/skills/image-gen/scripts/image-gen.sh "Abstract neural network visualization" "9:16" "2K"
```

## Output

- Images are saved to `/tmp/images/generated_[timestamp].png`
- The script outputs the file path upon completion
- Image URL from fal.ai is also displayed (use this URL for Dev.to cover images)

## Prompt Guidelines

For best results when creating blog featured images:

1. Describe the article's main theme visually
2. Include style hints: "modern", "professional", "tech-style", "digital art", "photorealistic", "minimalist"
3. Specify colors that match the topic mood
4. Add "professional", "clean", "modern" for business content

Example prompt for an AI article:
```
"Modern AI technology concept, neural networks and data visualization, blue and purple gradient, clean professional style"
```

## Copying Output for Publishing

After generating the image, copy it to the output folder:

```bash
mkdir -p /home/user/workspace/output
cp /tmp/images/generated_*.png /home/user/workspace/output/featured.png
```

## Response Format

The fal.ai API returns:
```json
{
  "images": [{
    "url": "https://storage.googleapis.com/...",
    "width": 1920,
    "height": 1080,
    "content_type": "image/png"
  }]
}
```

Use the `url` field directly as the cover image URL when publishing to Dev.to.

## Pricing

- 1K resolution: ~$0.15 per image
- 2K resolution: ~$0.15 per image
- 4K resolution: ~$0.30 per image

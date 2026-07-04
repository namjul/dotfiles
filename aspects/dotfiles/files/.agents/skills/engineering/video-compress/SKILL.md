---
name: video-compress
description: This skill should be used when the user asks to "compress this video", "reduce file size", "make this video smaller", "optimize for web", "shrink this video", "compress to under X MB", "reduce bitrate", "make it smaller without losing quality", "encode with H.265", or "re-encode this video".
---
# Video Compress

Compress a video using quality-based (CRF) or size-based (2-pass) encoding.

## Process

### 1. Obtain input file

If the user did not provide a file path, ask for it with AskUserQuestion before proceeding.

### 2. Probe the source

```bash
ffprobe -v quiet -print_format json -show_streams -show_format "$INPUT"
```

Extract: duration (seconds), file size (bytes), existing video codec, audio bitrate. If ffprobe fails (file not found, not a valid video), report the error and stop — do not attempt encoding.

### 3. Determine mode from user intent

- **CRF mode** (quality-based): user says "without losing quality", "good quality", "make it smaller", or gives no size target
- **2-pass mode** (size-based): user specifies a target ("under 50MB", "around 20MB", "fit on X")

### 4. Choose codec

H.264 is the safe default: universally device-compatible and fast to encode. Use H.265 only when the size reduction justifies the slower encode time and narrower device support.

- **H.265 / libx265**: target is ≤50% of original size, or user asks for "maximum compression" / "HEVC"
- **H.264 / libx264**: otherwise — faster encode, wider device compatibility, safe default

### 5. Construct command

**CRF mode:**
```bash
ffmpeg -i "$INPUT" -c:v libx264 -crf 23 -c:a copy -movflags +faststart "$OUTPUT"
# CRF scale: 18=near-lossless, 23=default quality, 28=aggressive (visible loss)
# -movflags +faststart moves moov atom to front — enables progressive web playback
```

**2-pass mode** — calculate video bitrate first:
```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/compress-video/scripts/calc_bitrate.py "$INPUT" --target-mb "$TARGET_MB"
# Outputs: VIDEO_BITRATE_KBPS (integer)
# Formula: (target_mb * 8192 / duration_s) - audio_bitrate_kbps
# Typical audio budget: 128 kbps
# Exit 1 = target too small (bitrate would go negative); report the error and ask for a larger target before retrying.

# Pass 1 — video analysis only, no output file:
ffmpeg -y -i "$INPUT" -c:v libx264 -b:v ${VIDEO_BITRATE_KBPS}k -pass 1 -an -f null /dev/null

# Pass 2 — final encode with audio:
ffmpeg -i "$INPUT" -c:v libx264 -b:v ${VIDEO_BITRATE_KBPS}k -pass 2 \
  -c:a aac -b:a 128k -movflags +faststart "$OUTPUT"
```

### 6. Confirm with user

Show: input file size, chosen codec, mode (CRF value or calculated bitrate), output path. Wait for approval before running.

### 7. Run and report

After completion: input size → output size, compression ratio (e.g., "73.2 MB → 18.4 MB, 75% reduction").

## Key Decisions

- In CRF mode, use `-c:a copy` to preserve audio losslessly. In 2-pass mode, audio must be re-encoded (AAC 128k) because pass 1 is video-only — no audio stream is processed.
- If input is already H.264 and the user only wants to trim or remux, recommend `convert-video` with `-c copy` instead — instant and lossless.
- For H.265 output, substitute `libx265` and add `-tag:v hvc1` for Apple device compatibility.
- Clean up `ffmpeg2pass-0.log` and `ffmpeg2pass-0.log.mbtree` after 2-pass encoding completes.

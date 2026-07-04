#!/usr/bin/env python3
"""
Calculate recommended video bitrate for 2-pass FFmpeg encoding.

Usage:
    calc_bitrate.py <input_file> --target-mb <float> [--audio-kbps <int>]

Output (stdout): integer kbps for use as -b:v value
Diagnostics (stderr): source info and budget breakdown
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys


def get_file_info(path: str) -> dict:
    result = subprocess.run(
        ["ffprobe", "-v", "quiet", "-print_format", "json",
         "-show_streams", "-show_format", path],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        print(f"Error: ffprobe failed:\n{result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Calculate video bitrate for 2-pass FFmpeg encoding"
    )
    parser.add_argument("input_file", help="Input video file path")
    parser.add_argument("--target-mb", type=float, required=True,
                        help="Target output file size in MB")
    parser.add_argument("--audio-kbps", type=int, default=128,
                        help="Audio bitrate budget in kbps (default: 128)")
    args = parser.parse_args()

    info = get_file_info(args.input_file)

    duration_s = float(info["format"].get("duration", 0))
    if duration_s <= 0:
        print("Error: could not determine video duration", file=sys.stderr)
        sys.exit(1)

    # total_kbps = (target_mb * 8192) / duration_s
    # 1 MB = 8 Mbit = 8192 kbit
    total_kbps = (args.target_mb * 8192) / duration_s
    video_kbps = int(total_kbps - args.audio_kbps)

    current_mb = float(info["format"].get("size", 0)) / (1024 * 1024)
    print(f"Source: {current_mb:.1f} MB, {duration_s:.1f}s", file=sys.stderr)
    print(
        f"Budget: {args.target_mb} MB → {total_kbps:.0f} kbps total "
        f"→ {video_kbps} kbps video + {args.audio_kbps} kbps audio",
        file=sys.stderr,
    )

    if video_kbps <= 0:
        print(
            f"Error: target {args.target_mb} MB is too small — only "
            f"{total_kbps:.0f} kbps total, which is less than the "
            f"{args.audio_kbps} kbps audio budget.",
            file=sys.stderr,
        )
        sys.exit(1)

    # stdout: just the integer for clean shell capture
    # e.g.: VIDEO_KBPS=$(python3 calc_bitrate.py video.mp4 --target-mb 50)
    print(video_kbps)


if __name__ == "__main__":
    main()

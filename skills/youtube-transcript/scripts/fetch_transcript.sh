#!/bin/bash
# Fetches a YouTube video's transcript via the getyoutubetranscript.com API.
#
# Usage:
#   YOUTUBE_TRANSCRIPT_API_KEY=sk_live_... ./fetch_transcript.sh <video_id_or_url> [language]
#
# Prints the raw JSON response to stdout. A non-2xx response is still valid
# JSON with a "code" field to branch on - see SKILL.md's Errors table.
set -euo pipefail

VIDEO="${1:?Usage: fetch_transcript.sh <video_id_or_url> [language]}"
LANGUAGE="${2:-en}"

source "$(dirname "$0")/lib/key.sh"

curl -s -G "${API_BASE}/transcript" \
    --data-urlencode "v=${VIDEO}" \
    --data-urlencode "language=${LANGUAGE}" \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

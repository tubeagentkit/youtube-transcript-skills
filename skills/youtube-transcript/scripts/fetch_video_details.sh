#!/bin/bash
# Gets a video's details (GET /video). 1 credit per successful call.
#
# Usage:
#   ./fetch_video_details.sh <video_id_or_url>
#
# Prints JSON: data.title, data.description, data.channel, data.views (exact, a digit string),
# data.likes (rounded label like "19M"), data.upload_date, data.duration (seconds), data.keywords.
set -euo pipefail

VIDEO="${1:?Usage: fetch_video_details.sh <video_id_or_url>}"

source "$(dirname "$0")/lib/key.sh"

curl -s -G "${API_BASE}/video" \
    --data-urlencode "v=${VIDEO}" \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

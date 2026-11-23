#!/bin/bash
# Gets one page of a video's top comments (GET /video/comments). 1 credit per page.
#
# Usage (first page):
#   ./fetch_video_comments.sh <video_id_or_url>
# Usage (later pages - the same video plus the previous response's data.continuation_token,
# passed back verbatim; it's opaque, don't construct it yourself):
#   ./fetch_video_comments.sh <video_id_or_url> <continuation_token>
#
# Prints JSON: data.comments[] (text, channel.handle, likes, replies, published_date),
# data.has_more, data.continuation_token (null on the last page).
set -euo pipefail

VIDEO="${1:?Usage: fetch_video_comments.sh <video_id_or_url> [continuation_token]}"
CONTINUATION="${2:-}"

source "$(dirname "$0")/lib/key.sh"

query=(--data-urlencode "v=${VIDEO}")
if [ -n "$CONTINUATION" ]; then
    query+=(--data-urlencode "continuation=${CONTINUATION}")
fi

curl -s -G "${API_BASE}/video/comments" "${query[@]}" \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

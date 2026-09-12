#!/bin/bash
# Fetches a playlist's videos via the getyoutubetranscript.com API -
# 1 credit/page. First page only - see SKILL.md's Errors/playlist notes.
#
# Usage:
#   YOUTUBE_TRANSCRIPT_API_KEY=sk_live_... ./fetch_playlist.sh <playlist_id_or_url>
set -euo pipefail

PLAYLIST="${1:?Usage: fetch_playlist.sh <playlist_id_or_url>}"

if [ -z "${YOUTUBE_TRANSCRIPT_API_KEY:-}" ]; then
    echo "Error: set YOUTUBE_TRANSCRIPT_API_KEY first (get a free key at https://getyoutubetranscript.com/dashboard)" >&2
    exit 1
fi

curl -s -G "https://getyoutubetranscript.com/api/v1/playlist" \
    --data-urlencode "list=${PLAYLIST}" \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

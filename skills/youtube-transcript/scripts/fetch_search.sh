#!/bin/bash
# Searches YouTube via the getyoutubetranscript.com API.
#
# Usage:
#   YOUTUBE_TRANSCRIPT_API_KEY=sk_live_... ./fetch_search.sh <query> [page_token]
#
# Prints the raw JSON response to stdout. A non-2xx response is still valid
# JSON with a "code" field to branch on - see SKILL.md's Errors table.
set -euo pipefail

QUERY="${1:?Usage: fetch_search.sh <query> [page_token]}"
PAGE_TOKEN="${2:-}"

if [ -z "${YOUTUBE_TRANSCRIPT_API_KEY:-}" ]; then
    echo "Error: set YOUTUBE_TRANSCRIPT_API_KEY first (get a free key at https://getyoutubetranscript.com/dashboard)" >&2
    exit 1
fi

ARGS=(-G "https://getyoutubetranscript.com/api/v1/search" --data-urlencode "q=${QUERY}")
if [ -n "$PAGE_TOKEN" ]; then
    ARGS+=(--data-urlencode "page_token=${PAGE_TOKEN}")
fi

curl -s "${ARGS[@]}" -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

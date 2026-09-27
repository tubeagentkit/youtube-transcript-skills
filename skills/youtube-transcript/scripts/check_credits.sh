#!/bin/bash
# Checks the remaining credit balance for this API key via
# getyoutubetranscript.com. Free - 0 credits, never charged.
#
# Usage:
#   YOUTUBE_TRANSCRIPT_API_KEY=sk_live_... ./check_credits.sh
set -euo pipefail

if [ -z "${YOUTUBE_TRANSCRIPT_API_KEY:-}" ]; then
    echo "Error: set YOUTUBE_TRANSCRIPT_API_KEY first (get a free key at https://getyoutubetranscript.com/dashboard)" >&2
    exit 1
fi

curl -s "https://getyoutubetranscript.com/api/v1/credits" \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}"

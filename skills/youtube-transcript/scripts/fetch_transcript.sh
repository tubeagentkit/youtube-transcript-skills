#!/bin/bash
# Fetches a YouTube video's transcript via the getyoutubetranscript.com API.
#
# Usage:
#   YOUTUBE_TRANSCRIPT_API_KEY=sk_live_... ./fetch_transcript.sh <video_id_or_url> [language] [timestamps|plain] [translate] [mode]
#
# Pass `timestamps` as the third argument to also get data.segments
# ({start, duration, text} per caption line, seconds). Pass a language code
# as the fourth argument (e.g. es, zh-CN) to machine-translate the transcript;
# use `plain` as the third argument to translate without timestamps.
#
# Pass `auto` or `generate` as the fifth argument for an AI transcript of a
# video with no captions (3 credits per minute of video; leave translate as ""
# because the two can't be combined, and leave language as "" to use the
# video's own audio language). If the API answers 202, this script polls
# GET /transcript/jobs every 5 seconds, for up to about 5 minutes, and prints
# the final answer.
#
# Prints the raw JSON response to stdout. A non-2xx response is still valid
# JSON with a "code" field to branch on - see SKILL.md's Errors table.
set -euo pipefail

VIDEO="${1:?Usage: fetch_transcript.sh <video_id_or_url> [language] [timestamps|plain] [translate] [mode]}"
LANGUAGE="${2:-}"
TIMESTAMPS="false"
if [ "${3:-}" = "timestamps" ]; then TIMESTAMPS="true"; fi
TRANSLATE="${4:-}"
MODE="${5:-}"

source "$(dirname "$0")/lib/key.sh"

# The API defaults language to en, so leaving it out changes nothing for captions,
# and with mode=auto|generate it means "the language spoken in the video".
OPTIONAL_ARGS=()
if [ -n "$LANGUAGE" ]; then OPTIONAL_ARGS+=(--data-urlencode "language=${LANGUAGE}"); fi
if [ -n "$TRANSLATE" ]; then OPTIONAL_ARGS+=(--data-urlencode "translate=${TRANSLATE}"); fi
if [ -n "$MODE" ]; then OPTIONAL_ARGS+=(--data-urlencode "mode=${MODE}"); fi

# Body and HTTP status, split on the last line that curl's -w adds.
RESPONSE="$(curl -s -w '\n%{http_code}' -G "${API_BASE}/transcript" \
    --data-urlencode "v=${VIDEO}" \
    --data-urlencode "timestamps=${TIMESTAMPS}" \
    ${OPTIONAL_ARGS[@]+"${OPTIONAL_ARGS[@]}"} \
    -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}")"

# 202 = the AI transcript is still being made: poll its job (free) until it answers.
for _ in $(seq 1 60); do
    [ "${RESPONSE##*$'\n'}" = "202" ] || break
    JOB_ID="$(printf '%s' "${RESPONSE%$'\n'*}" | sed -n 's/.*"job_id": *"\([0-9a-fA-F-]*\)".*/\1/p')"
    [ -n "$JOB_ID" ] || break
    sleep 5
    RESPONSE="$(curl -s -w '\n%{http_code}' -G "${API_BASE}/transcript/jobs" \
        --data-urlencode "id=${JOB_ID}" \
        --data-urlencode "timestamps=${TIMESTAMPS}" \
        -H "Authorization: Bearer ${YOUTUBE_TRANSCRIPT_API_KEY}")"
done

if [ "${RESPONSE##*$'\n'}" = "202" ]; then
    echo "Still running after about 5 minutes. Poll GET /transcript/jobs?id=<job_id> again later (free)." >&2
fi
printf '%s\n' "${RESPONSE%$'\n'*}"

# Sourced by every script in scripts/. Loads the API key from
# YOUTUBE_TRANSCRIPT_API_KEY, or from the file save_key.sh writes, so the key
# survives new sessions and sandboxed agent shells that don't inherit env vars.

KEY_FILE="${YOUTUBE_TRANSCRIPT_KEY_FILE:-$HOME/.config/getyoutubetranscript/api_key}"
API_BASE="${YOUTUBE_TRANSCRIPT_API_BASE:-https://getyoutubetranscript.com/api/v1}"

if [ -z "${YOUTUBE_TRANSCRIPT_API_KEY:-}" ] && [ -r "$KEY_FILE" ]; then
    YOUTUBE_TRANSCRIPT_API_KEY="$(tr -d '[:space:]' < "$KEY_FILE")"
fi

if [ -z "${YOUTUBE_TRANSCRIPT_API_KEY:-}" ]; then
    echo "Error: no API key yet. The user creates one at https://getyoutubetranscript.com/dashboard; save it with: printf '%s' \"<key>\" | scripts/save_key.sh (see SKILL.md, 'API key setup')." >&2
    exit 1
fi

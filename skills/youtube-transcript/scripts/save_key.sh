#!/bin/bash
# Step 2 of API key setup: exchanges the emailed code for an API key and saves
# it, without ever printing the key. The key goes to
# ~/.config/getyoutubetranscript/api_key (mode 600), which every script in
# scripts/ reads. Unless --no-profile is passed, one line is added to the shell
# profile so new terminals get YOUTUBE_TRANSCRIPT_API_KEY too; that line reads
# the file, so the key itself is not copied into the profile.
#
# Usage:
#   ./save_key.sh <email> <6-digit-code> [--no-profile]
set -euo pipefail

EMAIL="${1:?Usage: save_key.sh <email> <code> [--no-profile]}"
CODE="${2:?Usage: save_key.sh <email> <code> [--no-profile]}"
UPDATE_PROFILE=1
[ "${3:-}" = "--no-profile" ] && UPDATE_PROFILE=0

API_BASE="${YOUTUBE_TRANSCRIPT_API_BASE:-https://getyoutubetranscript.com/api/v1}"
KEY_FILE="${YOUTUBE_TRANSCRIPT_KEY_FILE:-$HOME/.config/getyoutubetranscript/api_key}"

RESPONSE="$(curl -s -X POST "${API_BASE}/signup/verify" \
    -H "Content-Type: application/json" \
    -H "User-Agent: youtube-transcript-skill/1.1" \
    --data "$(printf '{"email": "%s", "otp": "%s"}' "$EMAIL" "$CODE")")"

KEY="$(printf '%s' "$RESPONSE" | sed -n 's/.*"api_key" *: *"\(sk_live_[A-Za-z0-9_-]*\)".*/\1/p')"
if [ -z "$KEY" ]; then
    # No key in the response, so it is safe to show: it is the server's error.
    echo "Error: could not verify the code. Server response: ${RESPONSE}" >&2
    exit 1
fi

mkdir -p "$(dirname "$KEY_FILE")"
chmod 700 "$(dirname "$KEY_FILE")"
(umask 077 && printf '%s\n' "$KEY" > "$KEY_FILE")
echo "Saved the API key to ${KEY_FILE} (readable only by you)."

if [ "$UPDATE_PROFILE" = 1 ]; then
    case "$(basename "${SHELL:-}")" in
        zsh) PROFILE="$HOME/.zshrc" ;;
        bash) PROFILE="$HOME/.bashrc" ;;
        *) PROFILE="$HOME/.profile" ;;
    esac
    LINE="[ -r \"${KEY_FILE}\" ] && export YOUTUBE_TRANSCRIPT_API_KEY=\"\$(cat \"${KEY_FILE}\")\"  # getyoutubetranscript.com"
    if ! grep -qF "# getyoutubetranscript.com" "$PROFILE" 2>/dev/null; then
        printf '\n%s\n' "$LINE" >> "$PROFILE"
        echo "Added one line to ${PROFILE} so new terminals load YOUTUBE_TRANSCRIPT_API_KEY from that file."
    fi
fi

# Confirm the saved key works (prints the credit balance, not the key).
curl -s "${API_BASE}/credits" -H "Authorization: Bearer ${KEY}" -H "User-Agent: youtube-transcript-skill/1.1"
echo

#!/bin/bash
# Saves an API key that the user created at https://getyoutubetranscript.com/dashboard
# and pasted into the conversation. The key is read from standard input, so it
# is not passed as a command-line argument, and it is never printed. It is
# checked against the free /credits endpoint first, then written to
# ~/.config/getyoutubetranscript/api_key (mode 600), which every script in
# scripts/ reads.
#
# Only with --profile (pass it only after the user has explicitly agreed), one
# line is appended to the shell profile (~/.zshrc, ~/.bashrc or ~/.profile):
#   [ -r "<key file>" ] && export YOUTUBE_TRANSCRIPT_API_KEY="$(cat "<key file>")"  # getyoutubetranscript.com
# That line reads the key file; the key itself is not copied into the profile.
#
# Usage:
#   printf '%s' "<api key>" | ./save_key.sh [--profile]
set -euo pipefail

UPDATE_PROFILE=0
[ "${1:-}" = "--profile" ] && UPDATE_PROFILE=1

API_BASE="${YOUTUBE_TRANSCRIPT_API_BASE:-https://getyoutubetranscript.com/api/v1}"
KEY_FILE="${YOUTUBE_TRANSCRIPT_KEY_FILE:-$HOME/.config/getyoutubetranscript/api_key}"

KEY="$(tr -d '[:space:]')"
case "$KEY" in
    sk_live_*) ;;
    *)
        echo "Error: expected an API key starting with sk_live_ on standard input." >&2
        exit 1
        ;;
esac

# Check the key before saving it (the credits call is free and prints the balance, not the key).
BALANCE="$(curl -s "${API_BASE}/credits" -H "Authorization: Bearer ${KEY}" -H "User-Agent: youtube-transcript-skill/1.2")"
case "$BALANCE" in
    *'"success":true'*) ;;
    *)
        echo "Error: the key was not accepted, nothing was saved. Server response: ${BALANCE}" >&2
        exit 1
        ;;
esac

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
    if grep -qF "# getyoutubetranscript.com" "$PROFILE" 2>/dev/null; then
        echo "${PROFILE} already loads the key file; left it unchanged."
    else
        printf '\n%s\n' "$LINE" >> "$PROFILE"
        echo "Added one line to ${PROFILE} so new terminals load YOUTUBE_TRANSCRIPT_API_KEY from that file."
    fi
fi

echo "$BALANCE"

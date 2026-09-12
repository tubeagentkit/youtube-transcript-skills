---
name: youtube-transcript
description: Use when the user wants a YouTube video's transcript fetched, wants to summarize/analyze/quote a YouTube video by its spoken content, wants to search YouTube (globally or a channel handle's videos), wants a channel handle resolved to its channel ID, or wants the videos in a YouTube playlist. Calls the getyoutubetranscript.com public API - requires an API key (free tier available, no card required).
source: https://github.com/tubeagentkit/youtube-transcript-skills
---

# YouTube Transcript

Fetches transcripts, search results, and playlist/channel data from YouTube via
the [getyoutubetranscript.com](https://getyoutubetranscript.com) REST API, so
you can summarize, quote, search, or analyze a video's actual spoken content
without the user having to copy-paste it in by hand.

## Prerequisite: an API key

Every call needs an API key. Look for one, in this order:

1. The `YOUTUBE_TRANSCRIPT_API_KEY` environment variable.
2. A key the user has already pasted into this conversation.

If neither exists, you can get one for the user right now instead of just
linking to the dashboard - see **Getting a key automatically** below. Once you
have a key (however you got it), prefer running the rest of this session with
it set as `YOUTUBE_TRANSCRIPT_API_KEY` so you don't have to ask again.

### Getting a key automatically

This is a two-step email+code flow, no password and no browser required.

1. Ask the user: *"I don't have an API key yet. What's the email you'd like
   to use? I'll send a 6-digit code to verify it and set you up with a free
   key (100 credits, no card required)."*
2. Send the code:

   ```bash
   curl -s -X POST "https://getyoutubetranscript.com/api/v1/signup" \
     -H "Content-Type: application/json" \
     -d '{"email": "the_user_email"}'
   ```

   A `{"success": true, ...}` response means the code was sent - tell the user
   to check their inbox (including spam) and give you the 6-digit code. The
   code expires in 10 minutes; a disposable/throwaway email address will be
   rejected with a clear error.
3. Once they give you the code, verify it:

   ```bash
   curl -s -X POST "https://getyoutubetranscript.com/api/v1/signup/verify" \
     -H "Content-Type: application/json" \
     -d '{"email": "the_user_email", "otp": "123456"}'
   ```

   Success looks like `{"success": true, "api_key": "sk_live_..."}`. This
   `api_key` is shown ONCE. Ask the user before persisting it anywhere beyond
   the current session (e.g. "Want me to save this to your shell profile so
   you don't need to re-enter it next time?") - don't write it to a shell
   profile or any other persistent file without that confirmation. For the
   rest of the current session, holding it as the `YOUTUBE_TRANSCRIPT_API_KEY`
   environment variable in memory is enough to make every request below work.
   If your tool's own output redacts the key so you can't see it to store it,
   that redaction is a safety feature working as intended - don't try to
   route around it (e.g. by writing the raw response to a temp file). Instead
   tell the user their key was created and point them to
   <https://getyoutubetranscript.com/dashboard> to copy it directly.

   A wrong or expired code returns a 400 with a `message` you should relay to
   the user verbatim (e.g. "Invalid OTP") - ask them to check the code or
   request a new one via step 2 rather than guessing at a fix.

If the user says they already have an account, skip this and send them to
<https://getyoutubetranscript.com/dashboard> to grab an existing key instead
of creating a new one.

Every response is metered: 1 credit per successful call (free tier included;
failed calls are never charged). If a call returns `402 PAYMENT_REQUIRED`, tell
the user they're out of credits and link them to the dashboard to top up or
upgrade - don't retry the same call expecting a different result.

## Base URL and auth

```
https://getyoutubetranscript.com/api/v1
```

Send the key as either header (both are accepted identically):

```
Authorization: Bearer <API_KEY>
# or
x-api-key: <API_KEY>
```

## Get a transcript (the primary use case)

```bash
curl -s "https://getyoutubetranscript.com/api/v1/transcript?v=<VIDEO_ID_OR_URL>&language=en" \
  -H "Authorization: Bearer $YOUTUBE_TRANSCRIPT_API_KEY"
```

- `v` accepts a bare 11-char video ID OR any full YouTube URL (`youtube.com/watch?v=...`,
  `youtu.be/...`, `/shorts/...`) - don't parse the URL yourself, just pass it through.
- `language` is optional, defaults to `en`. Use the response's own error if a
  requested language isn't available (see Errors below) rather than guessing
  which languages exist.
- The bundled `scripts/fetch_transcript.sh` wraps this exact call if you'd
  rather invoke a script than hand-build the curl command.

Successful response:

```json
{
  "success": true,
  "data": {
    "video_id": "jNQXAC9IVRw",
    "language_code": "en",
    "title": "Me at the zoo",
    "author_name": "jawed",
    "author_url": "https://www.youtube.com/channel/UC4Qob...",
    "thumbnail_url": "https://...",
    "transcript": "All right, so here we are...",
    "word_count": 39
  }
}
```

`transcript` is the full spoken text as one plain string - there is no
per-line timestamp breakdown in this API. If the user specifically needs
timestamps, tell them that's not something this endpoint provides rather than
inventing fake timestamps.

## Other available endpoints

Same base URL, auth, and error shape as above.

**Search YouTube** - `GET /search?q=<query>&country=us&language=en&limit=20` (1
credit/page). Add `page_token` from a previous response's
`data.pagination.next_page_token` to fetch the next page.

**Resolve a channel handle to its channel ID** - `GET /resolve?handle=@mkbhd`
(free, 0 credits). Accepts a channel ID, a channel URL, or a bare `@handle`.

**Channel info + latest videos** - `GET /channel/latest?channel=@mkbhd`
(free, 0 credits). Full channel metadata (subscribers, description, avatar)
plus whatever "Latest Videos" the channel's home tab is currently showing -
not the complete upload history. For that, use channel/videos below.

**All of a channel's uploaded videos** - `GET
/channel/videos?channel=@mkbhd` (1 credit/page). Provide either `channel`
(first page) or `continuation` (1 credit/page too - it's still a real
scrape, not a free re-read). The response's `data.continuation_token`, when
non-null, is an opaque string - pass it back verbatim as `continuation` to
get the next page; never construct or decode it yourself. `null` means
there are no more pages.

**Search within a channel** - `GET
/channel/search?channel=@mkbhd&q=iphone` (1 credit/page). Same `channel` +
`q` for the first page, or `continuation` alone for subsequent pages -
identical opaque-token convention as channel/videos.

**Playlist videos** - `GET /playlist?list=<playlist ID or URL>` (1 credit/page).
Currently returns the first page only; the response's `data.has_more` tells you
if there are more, but there is no pagination parameter yet - don't invent one.

## Errors

Every error is JSON with a stable `code` you can branch on, plus a matching
HTTP status:

| Status | Code | Meaning |
|---|---|---|
| 400 | `BAD_REQUEST` / `MISSING_URL` / `INVALID_URL` | Missing or malformed parameter |
| 401 | `MISSING_API_KEY` / `INVALID_API_KEY` | No key provided, or it's invalid/revoked |
| 402 | `PAYMENT_REQUIRED` | Out of credits - direct the user to the dashboard, don't retry |
| 404 | `VIDEO_UNAVAILABLE` / `TRANSCRIPT_NOT_FOUND` / `TRANSCRIPT_DISABLED` | Video/resource doesn't exist, or has no transcript |
| 404 | `LANGUAGE_NOT_AVAILABLE` | The requested `language` isn't available for this video |
| 429 | `RATE_LIMITED` | Too many requests for the key's plan tier - back off, don't hammer it in a retry loop |
| 503 | `UPSTREAM_UNAVAILABLE` / `UPSTREAM_TIMEOUT` | Transient upstream issue - safe to retry once after a short delay |

Report the real `message` field to the user on any error rather than a generic
"something went wrong" - it's written to be end-user-readable already.

Full reference (all endpoints, request-limit tiers, pricing): <https://getyoutubetranscript.com/docs>

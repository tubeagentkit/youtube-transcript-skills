# YouTube Transcript Skill 🎬

[![skills.sh](https://skills.sh/b/tubeagentkit/youtube-transcript-skills)](https://skills.sh/tubeagentkit/youtube-transcript-skills)
[![License](https://img.shields.io/badge/License-MIT-4CAF50?style=for-the-badge)](./LICENSE)
[![Website](https://img.shields.io/badge/Website-getyoutubetranscript.com-FF3B00?style=for-the-badge)](https://getyoutubetranscript.com)

> Get YouTube transcripts, search videos, browse channels, and pull playlists — from any AI agent, with no dashboard visit required to get started.

An [Agent Skill](https://skills.sh) that teaches Claude, Cursor, Antigravity, Windsurf, and any other Agent Skills-compatible tool how to fetch YouTube transcripts, search YouTube (videos or channels), resolve channel handles, browse a channel's full upload history, search inside a channel, and pull playlist contents — all through the [getyoutubetranscript.com](https://getyoutubetranscript.com) public API.

Works with Claude Code, Cursor, Antigravity, Windsurf, Cline, Codex, and 70+ other agent runtimes via [skills.sh](https://skills.sh), and via [ClawHub](https://clawhub.ai) for OpenClaw/ClawdBot/Moltbot.

**Free tier · No credit card · 100 credits on signup · Your agent can set the whole thing up for you**

---

## Install

```bash
npx skills add tubeagentkit/youtube-transcript-skills --skill youtube-transcript
```

**ClawHub (OpenClaw/ClawdBot/Moltbot):**

```bash
npx clawhub@latest install tubeagentkit/youtube-transcript
```

**Manual (git clone):**

```bash
git clone https://github.com/tubeagentkit/youtube-transcript-skills.git
cp -r youtube-transcript-skills/skills/youtube-transcript ~/.claude/skills/
```

> **Not a developer?** Paste this into Claude, Cursor, or any AI agent that supports Agent Skills:
>
> ```
> Install the youtube-transcript skill from this GitHub repo:
> https://github.com/tubeagentkit/youtube-transcript-skills
> I want to get YouTube transcripts, search YouTube, and browse channels from you directly.
> Set everything up for me, including getting an API key.
> ```
>
> The agent handles the rest — including signing you up for a free API key by email, no browser or dashboard visit needed.

---

## What You Can Do

Just install and ask. No config, no code — talk to your agent in plain English.

| Task | Example Prompt |
|---|---|
| **Get a transcript** | "Summarize this video: [URL]" |
| **Search YouTube** | "Find videos about machine learning" |
| **Find a channel** | "Search YouTube for MKBHD's channel" |
| **Browse a channel** | "What has @veritasium posted recently?" |
| **Get a channel's full upload history** | "List every video @TED has ever uploaded" |
| **Search inside a channel** | "Search MKBHD's channel for iPhone reviews" |
| **Get playlist contents** | "List all videos in this playlist: [URL]" |
| **Research a topic** | "Find and summarize the top 5 videos about quantum computing" |
| **Bulk transcripts** | "Get transcripts for every video in this playlist" |

---

## Getting an API Key — No Browser Required

Most agent-skill integrations make you open a browser, sign up, copy a key, and paste it back. This one doesn't have to.

Ask your agent for a transcript with no key configured, and it will:

1. Ask for the email you'd like to use — and tell you exactly what it's for before sending anything.
2. Send it to `getyoutubetranscript.com` to create a free account and email you a 6-digit verification code.
3. Once you give it the code, it gets back a real API key and starts using it — all without you leaving the conversation.

The key is shown once; your agent will ask before saving it anywhere persistent (like a shell profile). See [`skills/youtube-transcript/SKILL.md`](skills/youtube-transcript/SKILL.md) for the exact flow it follows, including the two API calls involved (`POST /api/v1/signup`, `POST /api/v1/signup/verify`).

Already have an account? Grab your key from the [dashboard](https://getyoutubetranscript.com/dashboard) instead — no card required either way.

---

## Available Endpoints

All of these are documented in [`SKILL.md`](skills/youtube-transcript/SKILL.md) and wrapped by a bundled script in [`scripts/`](skills/youtube-transcript/scripts/). Base URL: `https://getyoutubetranscript.com/api/v1`.

| Endpoint | Cost | What it does |
|---|---|---|
| `GET /transcript` | 1 credit | Full transcript + title/author/thumbnail for one video |
| `GET /search` | 1 credit/page | Search YouTube for videos or channels, paginated |
| `GET /resolve` | Free | Resolve a channel handle/URL/ID to its canonical channel ID |
| `GET /channel/latest` | Free | Channel metadata + its home tab's "Latest Videos" |
| `GET /channel/videos` | 1 credit/page | Every video a channel has ever uploaded, fully paginated |
| `GET /channel/search` | 1 credit/page | Search within one channel's videos, fully paginated |
| `GET /playlist` | 1 credit/page | Every video in a playlist, fully paginated |

---

## Pricing

| Plan | Price | Credits | Rate Limit |
|---|---|---|---|
| **Free** | $0 | 100 credits on signup | 60 req/min |
| **Monthly** | $5/month | 1,000 credits/month | 200 req/min |
| **Annual** | $4.50/mo ($54/yr) | 1,000 credits/month | 300 req/min |

- **1 credit = 1 successful request.** Failed calls are never charged.
- `resolve` and `channel/latest` are always free, regardless of plan.
- Top-ups: $2.50 per 1,000 credits (Monthly), $1.50 per 1,000 (Annual, 40% cheaper).
- [View pricing / manage billing →](https://getyoutubetranscript.com/dashboard)

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `401 MISSING_API_KEY` / `INVALID_API_KEY` | No key sent, or it's wrong/revoked | Confirm `YOUTUBE_TRANSCRIPT_API_KEY` is actually set in your agent's environment, and that it starts with `sk_live_` |
| `402 PAYMENT_REQUIRED` | Out of credits | Top up or upgrade at the [dashboard](https://getyoutubetranscript.com/dashboard) — don't retry the same call |
| `404 VIDEO_UNAVAILABLE` / `TRANSCRIPT_NOT_FOUND` / `TRANSCRIPT_DISABLED` | Video doesn't exist, is private, or has no captions | Confirm the video plays and shows captions in a real browser first |
| `404 LANGUAGE_NOT_AVAILABLE` | The video doesn't have a transcript in the language you asked for | Omit `language` to get whatever's available, or try a different one |
| `429 RATE_LIMITED` | Too many requests for your plan tier | Back off — don't hammer it in a retry loop |
| `503 UPSTREAM_UNAVAILABLE` / `UPSTREAM_TIMEOUT` | Transient upstream hiccup | Safe to retry once after a short delay |

Two more things worth knowing:

- **Signup email never arrives.** Check spam first. Disposable/throwaway email domains are rejected outright with a clear error — use a real address.
- **No per-line timestamps.** `GET /transcript` returns the full spoken text as one string, not a timestamped segment list. If you need timestamps, that's a real product limitation right now, not a bug — don't expect your agent to fabricate them.

---

## FAQ

**Do I need a Google YouTube Data API key?**
No. This replaces the need for a Google Cloud project, API key, and quota management entirely — signup here is free and instant.

**Which endpoint should I use for a whole channel's videos?**
`channel/latest` if you just want recent uploads (free). `channel/videos` if you want the complete upload history, paginated.

**Can I search inside just one channel, not all of YouTube?**
Yes — `channel/search` does exactly that, with the same pagination convention as everything else here.

**Is there an MCP server version of this too?**
Yes — see [tubeagentkit/youtube-mcp](https://github.com/tubeagentkit/youtube-mcp) for direct integration with Claude, ChatGPT, Cursor, and any other MCP-compatible client, including full OAuth 2.1 sign-in (no API key needed at all).

---

## Also available as a REST API

Building an app instead of an agent skill? The exact same backend is a plain JSON REST API — see [`SKILL.md`](skills/youtube-transcript/SKILL.md) for the full endpoint reference, or the [dashboard](https://getyoutubetranscript.com/dashboard) to get a key directly.

## Disclosure

getyoutubetranscript.com is an independent product and is not affiliated with or endorsed by YouTube or Google.

## Contributing

Issues and PRs welcome.

## License

MIT — see [LICENSE](./LICENSE).

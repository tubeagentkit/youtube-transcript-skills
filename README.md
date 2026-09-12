# YouTube Transcript Skill

An [Agent Skill](https://skills.sh) that teaches Claude, Cursor, and any other
Agent Skills-compatible AI tool how to fetch YouTube transcripts, search
YouTube, resolve channel handles, browse a channel's videos, search within a
channel, and pull playlist contents - all through the
[getyoutubetranscript.com](https://getyoutubetranscript.com) public API.

## Install

```bash
npx skills add tubeagentkit/youtube-transcript-skills --skill youtube-transcript
```

Or clone manually:

```bash
git clone https://github.com/tubeagentkit/youtube-transcript-skills.git
cp -r youtube-transcript-skills/skills/youtube-transcript ~/.claude/skills/
```

## What it does

Once installed, just ask your agent things like:

- "Get the transcript for this YouTube video: \<url\>"
- "Summarize this YouTube video"
- "Search YouTube for videos about \<topic\>"
- "What has \<channel\>'s @handle posted lately?"
- "Search \<channel\>'s videos for \<topic\>"
- "List the videos in this playlist"

The agent handles the rest - no code to write.

## API key

Every call needs a free [getyoutubetranscript.com](https://getyoutubetranscript.com)
API key (100 free credits, no card required). If you don't have one yet, just
ask your agent to set one up for you - it can register a key on your behalf
via a short email + verification-code flow. See
[skills/youtube-transcript/SKILL.md](skills/youtube-transcript/SKILL.md) for
the exact instructions your agent will follow.

## Links

- [getyoutubetranscript.com](https://getyoutubetranscript.com)
- [API docs](https://getyoutubetranscript.com/docs)
- [Dashboard](https://getyoutubetranscript.com/dashboard)

## License

MIT

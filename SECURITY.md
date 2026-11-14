# Security policy

## Reporting a vulnerability

Please report security issues privately by email to issac@getyoutubetranscript.com rather than in a public issue. Include the affected file or script, steps to reproduce, and the impact you see. We aim to reply within 3 working days.

## Scope

This repository contains the YouTube transcript Agent Skill: `SKILL.md` and small shell scripts that call the GetYouTubeTranscript API (`https://getyoutubetranscript.com`) with the API key you set in `YOUTUBE_TRANSCRIPT_API_KEY`. The scripts make no other network calls and store nothing on disk beyond what your agent writes.

Issues with the hosted API itself can be reported to the same address.

## Handling your API key

Keep `YOUTUBE_TRANSCRIPT_API_KEY` in your environment or your agent's secret store, never in a committed file. If a key leaks, revoke it from your dashboard at https://getyoutubetranscript.com/dashboard and create a new one.

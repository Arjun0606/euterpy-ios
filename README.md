# Euterpy iOS

The native iOS client for Euterpy — a music identity platform built on the principle that every entry should be a deliberate human act, not a sensor reading.

## Status

This is the **post-rebuild** codebase. The original v1 (5 commits, ~2k lines, 18 source files) is preserved on the [`archive/v1`](https://github.com/Arjun0606/euterpy-ios/tree/archive/v1) branch and is no longer the source of truth. The rewrite started in April 2026 and is happening in 7 numbered sessions:

| Session | Goal |
|---|---|
| 0 | Foundation: scaffolding, design tokens, Theme, Config |
| 1 | Components, Repository layer, Router, real auth, Fraunces font asset |
| 2 | Identity primitives — Stories, Lyric Pins, Lists, Charts |
| 3 | Social — Follow, Mark, Echo, Followers/Following/Mutuals, Curators badge, People search |
| 4 | Notifications + retention layer (On This Day, First Friday) + push |
| 5 | Discovery — Discover page, Curators page, Album / Song / Artist detail, Streaming links, Avatar upload |
| 6 | Native share cards via `ImageRenderer`, Annual preview, deep linking, polish, tests |

See [`Euterpy/Sources/ARCHITECTURE.md`](Euterpy/Sources/ARCHITECTURE.md) for the full architectural decisions.

## Architecture in one paragraph

Euterpy iOS is a fully-native SwiftUI client. Every pixel is iOS — typography (Fraunces), gestures, animations, haptics, navigation, all native. The app talks to two backends: **Supabase directly** for raw data (profiles, stories, lyric pins, lists — anything that's a CRUD operation against a Postgres table), and **the Euterpy web API** at `euterpy.com/api/*` for the literary/editorial layer (notification copy, curator status, On This Day memories, First Friday state, the Annual editorial composer). This hybrid model means the *voice* of the product lives in one place (the web codebase), but iOS feels native and runs at native speed for every interaction.

## Project layout

```
Euterpy/Sources/
  App/                  Entry point, Config, AppEnvironment
  Theme/                Colors, Typography, Spacing — design tokens
  Models/               Domain types (Profile, Story, LyricPin, ...)
  Repositories/         Data layer — one per table
  Services/             Auth, Music, WebAPI, Haptics, ImageRenderer
  Routing/              Route enum, Coordinator, deep link handler
  Components/           Reusable UI: Avatar, Eyebrow, MagazineHeader, etc
  Features/             One folder per feature
    Auth/, Home/, Profile/, Story/, LyricPin/, MusicList/, Chart/,
    GetToKnowMe/, Discover/, Curators/, People/, Notifications/,
    FirstFriday/, Annual/, Settings/
  Resources/Fonts/      Fraunces .ttf assets (added in Session 1)
```

## Running locally

You'll need an `.xcconfig` or build settings exposing three values via `Info.plist`:

- `SupabaseURL` — your Supabase project URL
- `SupabaseAnonKey` — your Supabase anonymous key (safe to ship; protected by RLS)
- `EuterpyWebBaseURL` — defaults to `https://euterpy.com` if unset

See `Euterpy/Sources/App/Config.swift` for the full setup.

## The constitution

Every feature in Euterpy iOS must answer **"who are you?"** not **"what have you heard?"**. We do not implement passive tracking, library imports, listening history, streaks, time-based daily prompts, or any feature that turns curation into consumption. If a proposed feature can't answer the identity question, we don't ship it.

This is not a restriction — it's the moat against every "Letterboxd for music" clone that tried to be a database first.

# Euterpy iOS — Architecture

This document explains the architectural decisions of the rebuild. It exists so that future contributors (including future me) can understand the system in 10 minutes without having to read every file.

If you change one of these decisions, update this document in the same commit. The "why" is more valuable than the "what."

---

## Hybrid backend model

iOS talks to **two backends**, on purpose:

### 1. Supabase (direct)

For everything that's **raw data** — a CRUD operation against a Postgres table. Profiles, stories, lyric pins, lists, charts, ratings, follows, marks, echoes, letters. iOS uses the Supabase Swift SDK directly via `SupabaseService`. RLS protects everything.

```swift
let stories = try await supabase
    .from("stories")
    .select("*")
    .eq("user_id", value: userId)
    .execute()
    .value
```

This is fast (no extra hop), simple (one SDK), and has full type safety via the Supabase SDK's Codable integration.

### 2. The Euterpy web API (`euterpy.com/api/*`)

For everything that's **computed, literary, or editorial** — anything where a *rule* lives, not just data. Specifically:

- `/api/notifications/render` — turns a notification row into the literary sentence ("kept your story", "carried your lyric into her own", etc) with the variant rotation
- `/api/curators/status/:userId` — returns the curator label or null based on the meritocratic thresholds
- `/api/memories/on-this-day` — walks lookback windows (1y / 6mo / 1mo / etc) and returns the strongest memory at the first hit
- `/api/first-friday/state` — returns whether today is First Friday + the next date
- `/api/annual/:userId/:year` — returns the full Annual data including the editorial paragraph
- `/api/songs/search`, `/api/albums/search`, `/api/albums/:id`, `/api/songs/:id` — Apple Music catalog data (already proxied through web)

**Why this hybrid?** Because the *voice* is the product. "Kept your story" / "Carried your lyric into her own" / "A voice the room follows" — these aren't strings in a database, they're the editorial DNA of the app. If iOS reimplements them in Swift, the moment we tweak the web's copy, iOS drifts. Within a month they'd have different voices and users would notice. Spotify can afford parallel implementations because they have hundreds of engineers and a strict spec process. We don't.

By having one TypeScript implementation of the rules and both clients call it, **drift is impossible by construction**. We update the editorial composer once, and both web and iOS show the new version on the next request.

The latency cost is invisible: notification rendering happens once when you open the bell, the Annual is loaded once a year, First Friday state is fetched once per app launch. None of this is in a hot loop.

---

## Layer responsibilities

```
┌──────────────────────────────────────────────────────────┐
│ Features/                  Screens. Composed from        │
│                            Components + Repositories.    │
├──────────────────────────────────────────────────────────┤
│ Components/                Reusable UI primitives.       │
│                            No data fetching, no logic.   │
├──────────────────────────────────────────────────────────┤
│ Repositories/              Data layer. One per table.    │
│                            Returns Models, never raw     │
│                            DB rows. Async/await.         │
├──────────────────────────────────────────────────────────┤
│ Services/                  Cross-cutting concerns:       │
│                            Auth, WebAPI, Music, Haptics, │
│                            ImageRenderer.                │
├──────────────────────────────────────────────────────────┤
│ Models/                    Pure structs. Codable.        │
│                            No SwiftUI, no async.         │
├──────────────────────────────────────────────────────────┤
│ Routing/                   Route enum + Coordinator.     │
│                            Deep link parser.             │
├──────────────────────────────────────────────────────────┤
│ Theme/                     Design tokens. Static enums.  │
│                            Colors, Typography, Spacing.  │
├──────────────────────────────────────────────────────────┤
│ App/                       Entry point, Config,          │
│                            AppEnvironment.               │
└──────────────────────────────────────────────────────────┘
```

**Key rule:** dependencies only flow downward. A View can use a Component, a Repository, and Theme. A Component can use Theme. A Repository can use Models, Services, and the Supabase SDK. A Model can use nothing but Foundation. **Never the reverse.**

---

## Why a Repository layer (not direct Supabase calls in views)

In v1, every view had its own `supabase.from("ratings").select(...).execute()` calls inline. This is fine for an MVP but it means:

1. The same query lives in three places, with subtle bugs in two of them
2. Caching is impossible because there's no central place to put it
3. Testing is impossible because views can't be mocked
4. Refactoring is dangerous because every change touches every view

The Repository layer solves all four. Every table has exactly one Repository. Views call Repository methods. Repositories own their queries, their caching policy (when we add caching), their error handling. Tests can swap the Repository for a mock.

```swift
final class StoriesRepository {
    func fetchByAuthor(_ userId: String) async throws -> [Story]
    func fetchById(_ id: String) async throws -> Story?
    func fetchAboutTarget(kind: String, appleId: String) async throws -> [Story]
    func create(_ draft: StoryDraft) async throws -> Story
    func update(_ story: Story) async throws -> Story
    func delete(_ id: String) async throws
}
```

---

## Theme tokens are the only path to consistency

Every screen reaches for `EuterpyColor.*`, `EuterpyTypography.*`, `EuterpySpacing.*`, `EuterpyRadius.*`. Hardcoded values are a code smell that should be flagged in review.

The reason is straightforward: in v1, every view had `font(.system(size: 28, weight: .regular, design: .serif))` scattered through it. There was no `editorialDisplay` named style. When the design needed to change, every view needed to change. The new system means we tune one constant in `Theme/Typography.swift` and every "editorial display" headline gets the new size automatically.

This is the same reason the web app uses Tailwind tokens and named classes instead of inline styles.

---

## Routing is centralized

A `Route` enum models every navigable destination. The `AppCoordinator` consumes routes and pushes them onto the right NavigationStack. Deep links from `euterpy.com/story/abc` parse into `Route.story("abc")` via `DeepLinkHandler`. Push notifications carry a `Route` payload that gets resolved on tap.

This means: any view can request "navigate to this story" without knowing where in the navigation hierarchy it lives. The coordinator figures it out. Push notifications, share sheets, and in-app links all flow through the same routing API.

---

## What we explicitly do NOT do

1. **No passive listening tracking.** No MusicKit "Now Playing" surveillance. Every entry on Euterpy is a deliberate human choice. This is the constitution.
2. **No library import.** Importing someone's 4,000-track Spotify library drags in 3,950 tracks they don't actually care about. The friction of manual addition is the *point* — it's what makes the things you add *mean* something.
3. **No streaks.** Duolingo-grade engagement coercion. We do not.
4. **No follower counts visible to visitors.** Cosmos.fm playbook: show the work, not the score.
5. **No verified accounts.** We killed this in the web app for a reason. Curator status is meritocratic and computed automatically from real portfolio counts.
6. **No editorial playlists by Euterpy itself.** If we ever editorialize, it's 1-2 times a year and each one feels like a grenade.
7. **No webview wrappers.** Every screen is real native SwiftUI. The Stats tab in v1 redirected to the web — we will never do that again.

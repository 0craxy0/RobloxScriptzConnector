# RobloxScriptzConnector

Executor-ready Luau utilities for the public RobloxScripts.com API.

## Layout

- `scripts/apps/` — complete, directly runnable applications.
- `scripts/loaders/` — short remote loaders for published applications.
- `scripts/modules/` — reusable API and action modules for new tools.

## Included application

`scripts/apps/RobloxScriptsApiBrowser.lua` opens a search GUI for the public API. It supports a free-text query, game name or PlaceId filter, a 1–50 result limit, sort selection, clipboard copying, and selected-result execution.

The interface uses a bento-style glass layout with restrained card-only parallax and localized reflective highlights. The window, controls, and results remain fixed.

The target executor must provide `game:HttpGet` and `loadstring`; clipboard buttons additionally require `setclipboard`.
Press **F8**, **Right Control**, or **End** to hide or reopen the existing browser GUI. The visible button hides it without destroying it.

To run the script, execute:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/0craxy0/RobloxScriptzConnector/refs/heads/main/scripts/loaders/RobloxScriptsApiBrowserLoader.lua"))()
```

## API

The implementation consumes `https://robloxscripts.com/api/v1/scripts`. The service is public, read-only, rate-limited, and returns executable loader strings. Review returned code before running it.

## Permanent loader

Keep the loader line once. It resolves `main` through GitHub's API and then fetches the application from the returned immutable commit SHA, avoiding stale raw-file caches.

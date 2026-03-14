# Slug Watcher

Slug Watcher is a multiplatform Flutter app for tracking online serialized publications across mobile and web. The goal is to make it easy to keep up with stories, comics, novels, and other serialized content by storing where you left off and keeping that data available across devices.

## Overview

The app is intended for readers who follow publications on many different sites and need a lightweight way to remember what they last read. Each tracked source records the publication name, its URL, the latest chapter read, and the last read date.

Google Authentication will be used for sign-in, and user data will be backed up and synchronized through Google Drive's `appDataFolder`. This keeps sync data private to the app while allowing the same reading state to be restored across supported platforms.

## Planned MVP Features

- Add a new source with a name, URL, and current chapter.
- Update a source's latest chapter read and automatically refresh the last read date.
- Manually edit the last read date when a correction is needed.
- Update a source's URL.
- Tap a URL to quickly copy it.
- Delete a source.

## Platform Direction

Slug Watcher is being built with Flutter so the same codebase can support:

- Mobile-first experiences on Android and iOS
- Web support for quick access from desktop and mobile browsers

The initial focus is on a clean cross-platform reading tracker rather than advanced discovery or scraping features.

## Sync and Authentication

- Google Auth provides account sign-in.
- Google Drive `appDataFolder` stores backup and sync data.
- Sync is intended to keep a user's tracked sources and reading progress consistent across devices.
- `appDataFolder` is app-private storage, not a user-facing Drive folder for manual file management.

## Repository Status

This repository is currently in an early stage. The README defines the intended product direction and MVP scope; implementation is still to come.

## Development

This project is expected to follow the standard Flutter structure:

- `lib/` for application code
- `test/` for automated tests
- `assets/` for bundled images or static data
- `android/`, `ios/`, and web/platform folders as the app is scaffolded

Common commands:

```sh
flutter pub get
flutter run
flutter test
flutter analyze
```

## Near-Term Goal

Build a simple, reliable tracker for serialized publications with cross-platform sync, minimal friction, and a small set of editing actions centered on keeping reading progress accurate.

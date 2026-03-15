# Slug Watcher

Slug Watcher is a multiplatform Flutter app for tracking online serialized publications across mobile and web. The goal is to make it easy to keep up with stories, comics, novels, and other serialized content by storing where you left off and keeping that data available across devices.

## Overview

The app is intended for readers who follow publications on many different sites and need a lightweight way to remember what they last read. Each tracked source records the publication name, its URL, the latest chapter read, and the last read date.

Google Authentication is used for sign-in, and user data will be backed up and synchronized through Google Drive's `appDataFolder`. This keeps sync data private to the app while allowing the same reading state to be restored across supported platforms.

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

## Google Sign-In Setup

Google authentication is now wired into the app shell. To finish platform setup, create OAuth clients in Google Cloud and register the app package and signing fingerprints you plan to use.

Web builds require a client ID:

```sh
flutter run -d chrome --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

If you also want a server client ID for tokens on Android, iOS, or web, pass it at launch time as well:

```sh
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=YOUR_SERVER_CLIENT_ID
```

Android notes:

- Keep the package name aligned with `com.sumeetv.slugwatcher` unless you also update your Google Cloud OAuth configuration.
- Register both debug and release SHA certificates for the Android OAuth client.

Web notes:

- Add your local dev origin and deployed origin to the authorized JavaScript origins list.
- The in-app status panel will show a configuration hint until `GOOGLE_WEB_CLIENT_ID` is provided.

## Sync and Authentication

- Google Auth provides account sign-in.
- Google Drive `appDataFolder` stores backup and sync data.
- Sync is intended to keep a user's tracked sources and reading progress consistent across devices.
- `appDataFolder` is app-private storage, not a user-facing Drive folder for manual file management.

## Repository Status

This repository is currently in an early stage. The README defines the intended product direction and MVP scope; implementation is still growing.

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

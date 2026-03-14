# Repository Guidelines

## Project Structure & Module Organization
Use the standard Flutter layout for this app. Keep application code in `lib/`, automated tests in `test/`, Android and iOS platform files in `android/` and `ios/`, and bundled images or static data in `assets/`. Organize Dart code by feature when the app grows, but keep shared models, services, and utilities easy to find under `lib/`.

## Build, Test, and Development Commands
Run `flutter pub get` after cloning or changing dependencies. Use `flutter run` to launch the app on a simulator or attached device. Run `flutter test` for unit and widget tests, and `flutter analyze` before opening a PR. Build release artifacts with `flutter build apk` for Android and `flutter build ios` for iOS.

## Coding Style & Naming Conventions
Follow standard Dart style: 2-space indentation, no trailing whitespace, and formatted code checked in. Run `dart format .` before submitting changes. Use `snake_case.dart` for file names, `PascalCase` for widgets and classes, and `camelCase` for variables and methods. Prefer small widgets and isolate network, auth, and backup logic into dedicated services.

## Testing Guidelines
Place tests under `test/` and name files with the `*_test.dart` pattern. Add unit tests for parsing, persistence, and sync logic, plus widget tests for important UI flows. New user-facing behavior, especially around Google sign-in and Drive backup/restore, should ship with coverage or a documented testing rationale.

## Commit & Pull Request Guidelines
Use Conventional Commits for new history, for example `feat: add series detail screen` or `fix: handle expired Google token`. Keep PRs focused. Include a short description, linked issue when relevant, test notes, and screenshots or recordings for visible UI changes.

## Security & Configuration Tips
Do not commit OAuth client secrets, signing files, or local environment overrides. Treat Google auth and Drive configuration as sensitive platform setup, and keep credentials in local config or secure CI secrets. Request only the minimum Google scopes needed for sign-in and backup.

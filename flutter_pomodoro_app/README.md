# flutter_pomodoro_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Local env generation
--------------------

This project uses a small build-time config `lib/env_config.dart` for safe
feature flags (for example, showing the debug FAB). To regenerate
`lib/env_config.dart` from a local `.env` file, run:

```bash
cd flutter_pomodoro_app
dart run tool/gen_env.dart
```

If you don't run the generator, a default `lib/env_config.dart` with safe
defaults will be used (it is checked into the repo for convenience). Avoid
committing secrets into `lib/env_config.dart`; use `.env` for any private
values and do *not* commit it.

Behavior note
-------------
The app will now always show a scripture overlay when the timer reaches the
end; if fetching from the remote scripture API fails (for example, missing
`SCRIPTURE_API_KEY`), the app will fall back to a bundled passage so the
overlay still appears for users.

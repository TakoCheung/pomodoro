# flutter_pomodoro_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:


For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,

Local env generation

### Random Scripture Picker (tests)

The scripture overlay uses a random verse ID (BOOK.CHAPTER.VERSE) from a curated list.
Tests can override randomness by injecting a deterministic `Random` or by passing specific
candidate IDs into the repository. No real network calls are needed in tests (HTTP is mocked).

Simulator validation screenshots are saved under `artifacts/ios/`, e.g. `scripture_random_picker.png`.

### Environment (.env)

- Copy `.env.example` to `.env` for local overrides.
- Keys:
	- `SCRIPTURE_API_KEY`: API key for the Scripture API. Required at runtime to fetch live passages and the Bible catalog. Tests mock HTTP and don't need it.
	- `BIBLE_ID` (optional): explicit Bible ID override. Normally not needed; the app maps from the selected Bible version using the fetched catalog or a static fallback.
- Build-time `lib/env_config.dart` may set safe defaults; `.env` overrides are read at runtime when available.
--------------------

This project uses a small build-time config `lib/env_config.dart` for safe
feature flags. To regenerate `lib/env_config.dart` from a local `.env` file, run:

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

Bible Versions
--------------
- Settings includes a "Bible Version" dropdown.
- The list is populated from the Scripture API catalog (`/v1/bibles`) and cached in SharedPreferences for fast subsequent loads. If the catalog isn't available, a small built-in fallback list is used.
- The selected display name is mapped to a Bible ID via the fetched catalog. Fallback order: fetched catalog → static map → `BIBLE_ID` env → default (`32664dc3288a28df-01`).
- Tests use provider overrides and a mocked catalog service; no real network calls.

Notifications
-------------
- The app schedules a local notification with a scripture snippet when a timer completes in the background. In the foreground, it shows the in-app scripture overlay to avoid double alerts.
- Android uses a single high-importance channel: `pomodoro_notifications`.
- iOS requests notification permission once (provisional supported by the scheduler adapter).
- The notification payload includes: `bibleId`, `passageId`, `reference`, `textSnippet` (≤140 chars, ellipsis when truncated).
- Tests use a fake scheduler and repository; no real notifications or network in tests.

Local notifications & background timers
--------------------------------------
- Set `ENABLE_LOCAL_NOTIFICATIONS=true` in your local `.env` to enable the concrete schedulers at runtime.
- When enabled, a platform notification is scheduled exactly at the timer end to wake the app if it is backgrounded.
- Timezone handling: the app initializes the timezone database and uses UTC for zoned scheduling to avoid tz.local issues on simulators.
- Deep-link payload: tapping the notification sends `{ "action": "open_timer" }` to open the scripture overlay and stop any in-app alarm banner.

Feature flags
-------------
- `ENABLE_NOTIFICATIONS_TOGGLE_UI` (default: false) — when `true`, shows a Notifications switch in Settings. Kept off by default to avoid golden/UI churn in CI; logic remains enabled regardless of the toggle visibility.

Tests & Coverage
----------------
- Run all tests and produce coverage artifacts:
	- `flutter test`
	- `flutter test --coverage`
	- Convert LCOV to CSV: `dart tool/lcov_to_csv.dart coverage/lcov.info > coverage/coverage.csv`
- Artifacts are written to:
	- `coverage/lcov.info`
	- `coverage/coverage.csv`
- Integration tests live under `integration_test/` and rely on provider overrides and fakes for stability.

Artifacts
---------
- iOS simulator validation screenshots are saved in `artifacts/ios/`, e.g. `notification_flow.png` and the end-to-end `_flow.png` produced by `integration_test/_flow_test.dart`.

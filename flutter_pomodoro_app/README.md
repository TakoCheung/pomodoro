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

- Copy `.env.sample` to `.env` for local overrides.
- Keys:
	- `SCRIPTURE_API_KEY`: API key for the Scripture API. Required at runtime to fetch live passages and the Bible catalog. Tests mock HTTP and don't need it.
	- `BIBLE_ID` (optional): explicit Bible ID override. Normally not needed; the app maps from the selected Bible version using the fetched catalog or a static fallback.
- Build-time `lib/env_config.dart` may set safe defaults; `.env` overrides are read at runtime when available.
- SECURITY: `.env` is gitignored at repo root; never commit real keys. CI uses a dummy `.env` from `.env.sample`.
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

Alarm sound, notifications, and haptics
---------------------------------------
- Settings now includes an "Alarm Sound" dropdown (Classic Bell, Gentle Chime, Beep) and a Preview button.
- Persisted preferences:
	- `settings.sound_id` (string; default `classic_bell`)
	- `settings.notifications_enabled` (bool; default true)
	- `settings.haptics_enabled` (bool; default true)
- Behavior:
	- Foreground completion shows an in-app alarm banner and plays a short in-app audio cue; if haptics are enabled and supported, they trigger too. No duplicate system notification is posted.
	- Background/app-killed completion posts a system notification with the selected sound (Android raw resource name); tapping deep-link opens the timer.
	- Do Not Disturb is respected (no bypass).
	- Idempotent completion handling (no duplicates).
- Platform notes:
	- Android uses `RawResourceAndroidNotificationSound(soundId)` when available.
	- iOS uses default sound for now via DarwinNotificationDetails; custom CAF mapping can be added later if desired.

Local notifications & background timers
--------------------------------------
- Set `ENABLE_LOCAL_NOTIFICATIONS=true` in your local `.env` to enable the concrete schedulers at runtime.

Audio assets (in-app preview)
- Generate demo sounds locally:
	- dart run tool/gen_sounds.dart
	- This writes .wav files to assets/audio/ and they are bundled by Flutter.
	- If assets change, run: flutter pub get (to refresh) and rebuild the app.

Notifications not showing?
- Ensure permissions are granted:
	- iOS: the app will prompt; you can re-enable in Settings > Notifications.
	- Android 13+: the app will request POST_NOTIFICATIONS at runtime.
- Channels are created at first use; try a clean reinstall if channels are misconfigured.
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
	- Convert LCOV to CSV: `dart run tool/lcov_to_csv.dart coverage/lcov.info coverage/coverage.csv`
- Artifacts are written to:
	- `coverage/lcov.info`
	- `coverage/coverage.csv`
- Integration tests live under `integration_test/` and rely on provider overrides and fakes for stability.

Settings staging & persistence
------------------------------
- The settings dialog now stages changes via a SettingsController. Nothing is written to SharedPreferences until Apply is pressed.
- Useful Keys in tests: `settings_panel`, `settings_close`, `settings_apply` (alias on Apply Next Session), `settings_scrim`, `settings_dirty_badge`, `settings_commit_state_summary`, and the toggles `settings_sound_toggle`, `settings_haptics_toggle`, `settings_notifications_toggle`.

Artifacts
---------
- iOS simulator validation screenshots are saved in `artifacts/ios/`, e.g. `notification_flow.png` and the end-to-end `_flow.png` produced by `integration_test/_flow_test.dart`.

Golden Tests (UI Snapshots)
---------------------------
The project includes golden (pixel) tests to lock visual regressions for key widgets, including the Cached Verses panel.

Cached Verses panel goldens generated:
- Light theme (non-empty / empty): `test/goldens/cached_verses_panel_light_non_empty.png`, `..._light_empty.png`
- Dark theme (non-empty / empty): `test/goldens/cached_verses_panel_dark_non_empty.png`, `..._dark_empty.png`
- Multi-width layout composite (320 / 480 / 640): `test/goldens/cached_verses_panel_multi_width.png`

Update or regenerate all panel goldens:
```bash
flutter test --update-goldens test/widgets/cached_verses_panel_golden_test.dart test/widgets/cached_verses_panel_multi_device_golden_test.dart
```

One-off regeneration (all goldens):
```bash
flutter test --update-goldens
```

Task Bar distribution golden
----------------------------
File: `test/widgets/task_bar_golden_test.dart`

Scenarios covered (stacked vertically in a single composite image):
- 1 action (settings gear centered)
- 2 actions (gear + one companion; symmetric slots)
- 3 actions (three contiguous center slots)
- 4 actions (outer gap maintained for symmetry pattern)
- 5 actions (all slots filled)

Baseline path: `test/goldens/task_bar_distribution.png`

First introduction workflow:
- The test is intentionally written to SKIP comparison (and pass) if the baseline file does not yet exist.
- Create the baseline by running:
	```bash
	flutter test --update-goldens test/widgets/task_bar_golden_test.dart
	```
- Commit the newly created `task_bar_distribution.png` so subsequent runs perform pixel diffing.

Why skip if missing? This avoids a permanent RED state on CI the moment the test lands, allowing a controlled follow‑up commit that introduces the baseline after review.

Adding new Task Bar scenarios:
1. Extend the `GoldenBuilder` with another `addScenario`.
2. Run with `--update-goldens` to regenerate.
3. Keep surface size math consistent (height budget is `(AppSizes.taskBarHeight + 48) * scenarioCount + 64`).

Design Tokens (Dimensions)
--------------------------
Centralized in `lib/design/app_dimensions.dart`:

Classes:
- `AppSpacing`: scale (xxs=4, xs=8, sm=12, md=16, lg=24, xl=32)
- `AppSizes`: component heights (`taskBarHeight`)
- `AppRadii`: radius scale (sm=4, md=8, lg=12)
- `AppInsets`: common `EdgeInsets` bundles (page, screenPadding, banner, chipTight, dialog)
- `Gaps`: pre-built `SizedBox` gaps for symmetric vertical/horizontal spacing

Rules:
- Only promote literals that appear 3+ times or convey semantic meaning.
- Prefer `AppInsets` for multi-edge padding; prefer `AppSpacing` for single‑axis spacing and `SizedBox(height: AppSpacing.xs)`.
- When adding new tokens, search for existing repeated literals first to prevent redundant scale entries.

Refactor Guidance:
- Replace repeated `const EdgeInsets.symmetric(horizontal: 16)` with `AppInsets.horizontalPage`.
- Use `AppSizes.taskBarHeight` instead of hard-coded 72.
- Avoid introducing near-duplicates (e.g. 10, 14) unless a compelling design reason exists; round to the established scale.

Extending tokens:
1. Add the constant.
2. Migrate at least two existing usages in the same PR (proves reuse).
3. Add/update any affected goldens with `--update-goldens`.

Linting (future idea): a custom_lint rule could flag magic numbers outside the allowed scale; not implemented yet.

Troubleshooting:
- If new goldens appear under a nested path like `test/widgets/test/goldens/`, a `.gitignore` prevents committing duplicates. Ensure you reference goldens using a relative `../goldens/...` path from widget test folders for consistency.
- Run with `--update-goldens` only when intentional visual changes occur; otherwise a CI diff will flag regressions.

Scripture Mapping (assets > prefs > network)
--------------------------------------------
- Load order for a given bibleId:
	1) If an asset exists at `assets/scripture_mapping/{bibleId}.json`, it is loaded and used.
		 On success, the JSON is also cached to SharedPreferences under `scripture_mapping_v1:{bibleId}`.
	2) Else, if SharedPreferences contains a cached mapping, it is used.
	3) Else, the mapping is fetched via the configured `ScriptureMappingService` (requires `SCRIPTURE_API_KEY`) and then cached to prefs.
- Assets are read-only at runtime. To pre-bundle a mapping, drop a JSON file at `assets/scripture_mapping/` and ensure `pubspec.yaml` includes that directory (this repo already does). Example fixture: `assets/scripture_mapping/TEST_BIBLE.json`.
- Tests override `assetBundleProvider`, `sharedPreferencesProvider`, and `scriptureMappingServiceProvider` for deterministic behavior with no real HTTP.

🚦 Universal Copilot TDD Executor (Flutter + Riverpod) — With Explicit Integration Testing

Copilot Goal
Autonomously make the Flutter app fully green and validated end-to-end for the feature I provide below, using strict TDD loops and final iOS simulator checks via ios-simulator-mcp.

Operation Mode
•	Fully agentic; do not wait for approvals.
•	Follow Red → Green → Refactor for every sub-behavior.
•	Keep edits minimal and focused; no unrelated features or broad refactors.
•	Constrain all edits to the project repo; preserve style/naming.

Context & Stack
Flutter • Riverpod (flutter_riverpod, hooks_riverpod) • http • flutter_dotenv • shared_preferences • Tests: flutter_test, golden_toolkit, integration_test, mocktail.
Prefer provider overrides for time/clock, randomness, env, and persistence in tests. No real network in tests—use mocks/fakes.

⸻

✅ Acceptance Criteria (applies to every feature)
•	Testing (Unit → Widget → Integration):
•	Add/adjust failing tests first that fully specify the feature.
•	Use provider overrides & mocks: no real network; no sleeps/long waits.
•	All tests pass locally; eliminate flakiness.
•	Line coverage must be generated on every change: run flutter test --coverage and export lcov to CSV/HTML artifacts. Save to coverage/lcov.info and coverage/coverage.csv (use existing tool/csv converter if present).
•	Integration Testing (explicit):
•	Implement integration_test/_flow_test.dart covering the end-to-end user flow.
•	Use Keys for selection, fake clocks, and provider overrides for env/prefs/services.
•	Save screenshots and logs to artifacts/ios/_flow.png (and logs to artifacts/logs/ if applicable).
•	iOS Simulator (via ios-simulator-mcp):
•	App launches on iPhone simulator.
•	Perform the feature-specific flow using provided Keys.
•	Assert expected widgets/state; capture screenshot to artifacts/ios/_flow.png.
•	Docs:
•	Update README.md if new env flags/usage or test instructions are introduced.
•	No scope creep: implement only what the tests demand.

⸻

🔄 TDD Working Agreement (repeat until feature is done)

For each tiny behavior:
1.	RED — Write/adjust failing tests
•	Unit for pure logic/state machines.
•	Widget for UI state/rendering.
•	Integration for end-to-end flow (navigation, dialogs, persistence).
•	Inject/override clock, RNG, env, prefs, repositories/services.
•	Mock HTTP with mocktail (retry/timeout/caching logic verified deterministically).
2.	GREEN — Implement the minimum
•	Change as little code as needed to satisfy the failing tests.
•	Avoid speculative abstractions.
3.	REFACTOR — Improve safely
•	Clean names, extract helpers, remove duplication—with all tests passing.
•	No behavior expansion without new failing tests.
4.	Run the whole suite
•	flutter test and flutter test integration_test (or flutter drive where driver is used).
•	Then run line coverage: flutter test --coverage; transform lcov.info to CSV via tool/lcov_to_csv.dart and store at coverage/coverage.csv.
•	Fix flakiness immediately (fake clocks > timers; direct triggers > waits).
5.	Checkpoint Output (concise)
•	Files changed (paths).
•	Tests added/updated.
•	Test run summary (counts & duration).

Repeat until all acceptance criteria are met.

⸻

🧪 Test Authoring Rules (always)
•	Unit tests: pure functions/state transitions; verify formatting, boundaries, retries/backoff.
•	Widget tests: Keys on all interactive/observed widgets; pump with fake time/clock.
•	Integration tests: real navigation + provider overrides; no network; stable selectors by Key.
•	Timing: inject fake clock / explicit triggers (e.g., triggerComplete()); never rely on real timeouts.
•	Persistence: in-memory or temp SharedPreferences; clear between tests.
•	Retries/Backoff: verify max retries & terminal failure deterministically via mocks.

⸻

🧩 Integration Testing — Structure & Conventions
•	Location: integration_test/_flow_test.dart
•	Harness:
•	Use IntegrationTestWidgetsFlutterBinding.ensureInitialized().
•	Wrap app boot with provider overrides (env/prefs/services/clock/RNG).
•	Ensure WidgetsFlutterBinding.ensureInitialized() where necessary for plugins.
•	Selectors: use Key(’…’) for all tappable/asserter widgets.
•	Clock control: inject fake clock or expose deterministic triggers to avoid pumpAndSettle flakiness.
•	Artifacts: save at least one screenshot → artifacts/ios/_flow.png. Also attach coverage artifacts (coverage/lcov.info, coverage/coverage.csv) for the run.
•	Isolation: reset prefs/mocks between tests; avoid shared state across tests.

⸻

📱 iOS Simulator Validation (generic flow)
•	Boot simulator (e.g., iPhone 15 Pro).
•	Wait for main title Key (e.g., Key(‘app_title’)).
•	Perform the feature-specific sequence using Keys from the Feature Slot.
•	Assert final UI state; save screenshot to artifacts/ios/_flow.png.

⸻

🧭 Guardrails & Prohibited Actions
•	No real HTTP calls in tests.
•	No arbitrary waits/sleeps; use fake time or direct triggers.
•	No large refactors or cross-cutting style changes.
•	Keep changes within the project; maintain existing naming/style.

⸻

📊 Final Output (always provide)
•	Test results summary (counts, pass time).
•	List of modified files with brief rationale.
•	iOS simulator validation steps executed and screenshot path.
•	Coverage summary (total line coverage 95%+, key package/file highlights) with paths to artifacts.
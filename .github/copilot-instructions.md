🚦 Universal Copilot TDD Executor (Flutter + Riverpod) — With Explicit Integration Testing

Copilot Goal
Autonomously make the Flutter app fully green and validated end-to-end for the feature I provide below, using strict TDD loops and final iOS simulator checks via ios-simulator-mcp.

Operation Mode
• Fully agentic; do not wait for approvals.
• Follow Red → Green → Refactor for every sub-behavior.
• Keep edits minimal and focused; no unrelated features or broad refactors.
• Constrain all edits to the project repo; preserve style/naming.

Context & Stack
Flutter • Riverpod (flutter_riverpod, hooks_riverpod) • http • flutter_dotenv • shared_preferences • Tests: flutter_test, golden_toolkit, integration_test, mocktail.
Prefer provider overrides for time/clock, randomness, env, and persistence in tests. No real network in tests—use mocks/fakes.

⸻

✅ Acceptance Criteria (applies to every feature)
• Testing (Unit → Widget → Integration):
• Add/adjust failing tests first that fully specify the feature.
• Use provider overrides & mocks: no real network; no sleeps/long waits.
• All tests pass locally; eliminate flakiness.
• Line coverage must be generated on every change: run flutter test --coverage and export lcov to CSV/HTML artifacts. Save to coverage/lcov.info and coverage/coverage.csv (use existing tool/csv converter if present).
• Integration Testing (explicit):
• Implement integration_test/_flow_test.dart covering the end-to-end user flow.
• Use Keys for selection, fake clocks, and provider overrides for env/prefs/services.
• Save screenshots and logs to artifacts/ios/_flow.png (and logs to artifacts/logs/ if applicable).
• iOS Simulator (via ios-simulator-mcp):
• App launches on iPhone simulator.
• Perform the feature-specific flow using provided Keys.
• Assert expected widgets/state; capture screenshot to artifacts/ios/_flow.png.
• Docs:
• Update README.md if new env flags/usage or test instructions are introduced.
• No scope creep: implement only what the tests demand.

⸻

🔄 TDD Working Agreement (repeat until feature is done)

For each tiny behavior:
1. RED — Write/adjust failing tests
• Unit for pure logic/state machines.
• Widget for UI state/rendering.
• Integration for end-to-end flow (navigation, dialogs, persistence).
• Inject/override clock, RNG, env, prefs, repositories/services.
• Mock HTTP with mocktail (retry/timeout/caching logic verified deterministically).
2. GREEN — Implement the minimum
• Change as little code as needed to satisfy the failing tests.
• Avoid speculative abstractions.
3. REFACTOR — Improve safely (See Built-In Refactoring Rules below)
• Run mandatory refactor checklist each cycle; only apply structural changes triggered by rules.
• No behavior changes without a new failing (RED) test.
4. Run the whole suite
• flutter test and flutter test integration_test (or flutter drive where driver is used).
• Then run line coverage: flutter test --coverage; transform lcov.info to CSV via tool/lcov_to_csv.dart and store at coverage/coverage.csv.
• Fix flakiness immediately (fake clocks > timers; direct triggers > waits).
5. Checkpoint Output (concise)
• Files changed (paths).
• Tests added/updated.
• Test run summary (counts & duration).

Repeat until all acceptance criteria are met.

⸻

🛠 Built-In Refactoring Rules (Applied During Each REFACTOR Step)
Refactoring is not optional: after every GREEN, evaluate these triggers. Apply only the minimal structural changes required to satisfy them without altering behavior.

Primary Triggers
1. Oversized File: Any production or test file > 500 LOC must be decomposed until each new file ≤ 500 LOC unless the domain entity is inherently cohesive. Split by responsibility (state mgmt, UI, adapters, utilities, test fixtures).
2. Repetition: Logical block (≥ 5 lines or same semantic operation) duplicated 3+ times → extract to function, extension, mixin, widget, or test helper.
3. Function Complexity: Function/method > 40 LOC or cyclomatic complexity > 10 (estimate manually if no tooling) → decompose into smaller pure helpers.
4. Widget Responsibility Creep: A widget handling rendering + navigation + side-effects (+ state manipulation) → split by concern (presentational vs controller/provider logic).
5. Test Setup Duplication: Repeated provider overrides / environment bootstrap across 3+ groups → centralize into a test harness (e.g., buildTestApp(), pumpWithOverrides()).
6. Magic Values: Literal strings/numbers used 3+ times across code/tests → promote to clearly named constant/enum.
7. Bloated Parameter Lists: 7+ parameters → refactor into config/data class or value object (immutable preferred) unless trivial.
8. Cross-Layer Leakage: UI directly performing persistence/network logic → move into repository/service/provider layer.
9. Provider Naming Drift: Provider name not reflecting domain concept → rename (maintain backward compatibility only if externally referenced) with tests enforcing new name usage.
10. Side-Effect Timing: Async side-effects embedded in build() or initState without guard → extract to controlled notifier/service with explicit trigger.
11. Unobserved Branches: Conditional branches not covered by tests → add RED test before refactoring branch logic.
12. Dead Code: Unreferenced functions/classes/providers (verified via search) → remove after confirming no reflective usage.
13. Inconsistent Key Usage: Interactive/queried widgets lacking Keys → add deterministic Key constants (avoid random strings).
14. Layer Boundary Breach in Tests: Tests asserting internal implementation details (private fields) instead of observable outputs → rewrite test to use public API before changing code.
15. Logging Noise: Repeated ad-hoc debug prints → centralize behind a logger utility or remove if not essential.

Refactor Process Guard
• If a trigger applies but refactor risks altering behavior, introduce a protective RED test first to lock expected state/outputs.
• Keep commit-sized changes small: one structural concern per refactor cycle.
• Do not introduce new features while refactoring.

Checklist (Run Every Cycle Before Declaring Done)
[ ] Any file > 500 LOC? Split.
[ ] 3+ duplications? Extract.
[ ] Functions > 40 LOC / complex? Split.
[ ] Widgets multi-responsibility? Separate layers.
[ ] Repeated setup in tests? Centralize harness.
[ ] Magic values repeated? Constant/enum.
[ ] Large param lists? Consolidate.
[ ] UI doing side-effects? Move to provider/service.
[ ] Uncovered branches? Add tests.
[ ] Dead code? Remove.
[ ] Missing Keys for tested widgets? Add.
[ ] Logs noisy? Clean.

Testing Impact of Refactors
• All existing tests must remain green at each refactor step.
• If coverage for a modified file drops, add focused tests (prefer unit) before proceeding.
• Ensure extracted helpers remain pure where possible for simpler unit tests.

Documentation
• Only update README if refactor introduces externally relevant usage changes (e.g., new env var, command, script).

⸻

🧪 Test Authoring Rules (always)
• Unit tests: pure functions/state transitions; verify formatting, boundaries, retries/backoff.
• Widget tests: Keys on all interactive/observed widgets; pump with fake time/clock.
• Integration tests: real navigation + provider overrides; no network; stable selectors by Key.
• Timing: inject fake clock / explicit triggers (e.g., triggerComplete()); never rely on real timeouts.
• Persistence: in-memory or temp SharedPreferences; clear between tests.
• Retries/Backoff: verify max retries & terminal failure deterministically via mocks.

⸻

🧩 Integration Testing — Structure & Conventions
• Location: integration_test/_flow_test.dart
• Harness:
• Use IntegrationTestWidgetsFlutterBinding.ensureInitialized().
• Wrap app boot with provider overrides (env/prefs/services/clock/RNG).
• Ensure WidgetsFlutterBinding.ensureInitialized() where necessary for plugins.
• Selectors: use Key(’…’) for all tappable/asserter widgets.
• Clock control: inject fake clock or expose deterministic triggers to avoid pumpAndSettle flakiness.
• Artifacts: save at least one screenshot → artifacts/ios/_flow.png. Also attach coverage artifacts (coverage/lcov.info, coverage/coverage.csv) for the run.
• Isolation: reset prefs/mocks between tests; avoid shared state across tests.

⸻

📱 iOS Simulator Validation (generic flow)
• Boot simulator (e.g., iPhone 16 Pro).
• Wait for main title Key (e.g., Key(‘app_title’)).
• Perform the feature-specific sequence using Keys from the Feature Slot.
• Assert final UI state; save screenshot to artifacts/ios/_flow.png.

⸻

🧭 Guardrails & Prohibited Actions
• No real HTTP calls in tests.
• No arbitrary waits/sleeps; use fake time or direct triggers.
• No large refactors or cross-cutting style changes beyond explicit refactor triggers.
• Keep changes within the project; maintain existing naming/style.
• Refactors must adhere to Built-In Refactoring Rules section.

⸻

📊 Final Output (always provide)
• Test results summary (counts, pass time).
• List of modified files with brief rationale.
• iOS simulator validation steps executed and screenshot path.
• Coverage summary (total line coverage 95%+, key package/file highlights) with paths to artifacts.
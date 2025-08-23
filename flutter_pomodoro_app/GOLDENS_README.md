Golden images

This project uses golden tests for a few screens. To generate/update goldens locally:

1. Run the gated golden test with the UPDATE_GOLDENS flag set to `1`:

```bash
# from flutter_pomodoro_app/
flutter test --update-goldens --platform=vm --define=UPDATE_GOLDENS=1 test/settings_screen_goldens.dart
```

2. Commit the generated images under `goldens/` and restore the golden tests (if you had them skipped).

Notes:
- Golden tests are disabled by default in CI. Use the environment flag only locally when intentionally updating approved images.
- If you want me to generate and commit goldens, I can, but I need permission to run and commit large binary files in the repo.

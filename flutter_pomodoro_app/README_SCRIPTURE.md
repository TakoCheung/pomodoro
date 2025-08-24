
Scripture feature (basic)

Setup

1. Create a `.env` file in `flutter_pomodoro_app/` with the following:

```
SCRIPTURE_API_KEY=your_api_key_here
```

2. Run tests (the unit/widget tests mock HTTP and do not require the key):

```
flutter test --coverage -r expanded
```

Notes
- The service uses `https://api.scripture.api.bible/v1/bibles/{bibleId}/passages/{passageId}`
- In production, wire `scriptureServiceProvider` to an instance created with the real `http.Client` and your API key.

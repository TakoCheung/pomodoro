
Scripture feature (basic)

Setup

1. Create a `.env` file in `flutter_pomodoro_app/` with the following:

```
SCRIPTURE_API_KEY=your_api_key_here
# For some keys, ESV (32664dc3288a28df-01) is not permitted; use the permitted Bible ID
# from your dashboard or the /bibles endpoint, e.g. de4e12af7f28f599-02
BIBLE_ID=de4e12af7f28f599-02
```

2. Run tests (the unit/widget tests mock HTTP and do not require the key):

```
flutter test --coverage -r expanded
```

Notes
- The service uses `https://api.scripture.api.bible/v1/bibles/{bibleId}/verses/{passageId}`
- If you see HTTP 403, your key likely lacks access to the requested Bible (e.g., 32664dc3288a28df-01). Set `BIBLE_ID` in `.env` to a permitted ID.
- In production, wire `scriptureServiceProvider` to an instance created with the real `http.Client` and your API key.

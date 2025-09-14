Audio assets for in-app alarm preview.

Generated via `dart run tool/gen_sounds.dart`.

Files:

This folder contains bundled alarm sounds in both .mp4 and .wav for cross-platform playback.

When using audioplayers with AssetSource, omit the leading `assets/` segment.
For example, for `assets/audio/beep.mp4` use `AssetSource('audio/beep.mp4')`.
These are primarily for in-app playback/preview. Android/iOS notification sounds use
platform-specific channels/resources (Android raw resources via channel; iOS default sound by now).

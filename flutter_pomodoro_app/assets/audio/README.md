Audio assets for in-app alarm preview.

Generated via `dart run tool/gen_sounds.dart`.

Files:
- classic_bell.wav (+ classic_bell.mp4 if ffmpeg available)
- gentle_chime.wav (+ gentle_chime.mp4)
- beep.wav (+ beep.mp4)

These are primarily for in-app playback/preview. Android/iOS notification sounds use
platform-specific channels/resources (Android raw resources via channel; iOS default sound by now).

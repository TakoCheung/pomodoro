const List<String> kAvailableSoundIds = <String>[
  'classic_bell',
  'gentle_chime',
  'beep',
];

String normalizeSoundId(String? id) {
  if (id == null || id.isEmpty) return 'classic_bell';
  return kAvailableSoundIds.contains(id) ? id : 'classic_bell';
}

/// Returns the in-app audio asset path for the given id.
String inAppAssetFor(String? id) {
  final s = normalizeSoundId(id);
  return 'assets/audio/$s.mp4';
}

/// Returns a platform notification sound id/file name base, falling back to default.
/// iOS expects `<id>.caf` bundled; Android expects a raw resource named `<id>`.
String platformSoundBase(String? id) => normalizeSoundId(id);

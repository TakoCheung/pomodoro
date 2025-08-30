/// Mapping of displayed Bible version names to API Bible IDs.
/// NOTE: Extend this map with more versions as needed. The default entry is
/// kept to maintain current behavior.
const Map<String, String> kBibleVersions = <String, String>{
  // English Standard Version (ESV)
  'ESV': '32664dc3288a28df-01',
  // Dummy for tests/demo; replace with a real Bible ID as needed.
  'Test (Dummy)': 'test-bible-id',
};

const String kDefaultBibleVersionName = 'ESV';
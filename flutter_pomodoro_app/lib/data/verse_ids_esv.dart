/// A curated set of valid ESV verse IDs for the Scripture API.
///
/// Notes:
/// - The complete list of verse IDs for a translation is large and not
///   included here to keep the repository lightweight. This list is a
///   representative sample suitable for demos and defaults. You can replace
///   or extend it at runtime by supplying your own list to the repository or
///   picker functions.
/// - IDs follow the documented format in the Scripture API:
///   https://docs.api.bible/tutorials/getting-a-specific-verse
///   Example: GEN.1.1 (Genesis 1:1), JOH.3.16 (John 3:16)
const List<String> esvVerseIds = [
  // Genesis
  'GEN.1.1', 'GEN.1.2', 'GEN.1.3', 'GEN.1.4', 'GEN.1.5',
  'GEN.1.27', 'GEN.1.31',
  // Exodus
  'EXO.20.1', 'EXO.20.2', 'EXO.20.3', 'EXO.20.12',
  // Psalms
  'PSA.23.1', 'PSA.23.2', 'PSA.23.3', 'PSA.23.4', 'PSA.23.5', 'PSA.23.6',
  'PSA.119.105',
  // Proverbs
  'PRO.3.5', 'PRO.3.6',
  // Isaiah
  'ISA.40.31',
  // John
  'JOH.1.1', 'JOH.1.14', 'JOH.3.16', 'JOH.14.6', 'JOH.11.35',
  // Romans
  'ROM.3.23', 'ROM.6.23', 'ROM.8.28', 'ROM.10.9',
  // 1 Corinthians
  '1CO.13.4', '1CO.13.5', '1CO.13.6', '1CO.13.7', '1CO.13.8',
  // Ephesians
  'EPH.2.8', 'EPH.2.9', 'EPH.2.10',
  // Philippians
  'PHI.4.6', 'PHI.4.7', 'PHI.4.13',
  // Hebrews
  'HEB.11.1',
  // James
  'JAS.1.5'
];

/// Known book codes used for basic verse-id validation. Not exhaustive.
const Set<String> knownBookCodes = {
  'GEN',
  'EXO',
  'LEV',
  'NUM',
  'DEU',
  'JOS',
  'JDG',
  'RUT',
  '1SA',
  '2SA',
  '1KI',
  '2KI',
  '1CH',
  '2CH',
  'EZR',
  'NEH',
  'EST',
  'JOB',
  'PSA',
  'PRO',
  'ECC',
  'SNG',
  'ISA',
  'JER',
  'LAM',
  'EZE',
  'DAN',
  'HOS',
  'JOL',
  'AMO',
  'OBA',
  'JON',
  'MIC',
  'NAM',
  'HAB',
  'ZEP',
  'HAG',
  'ZEC',
  'MAL',
  'MAT',
  'MRK',
  'LUK',
  'JOH',
  'ACT',
  'ROM',
  '1CO',
  '2CO',
  'GAL',
  'EPH',
  'PHI',
  'COL',
  '1TH',
  '2TH',
  '1TI',
  '2TI',
  'TIT',
  'PHM',
  'HEB',
  'JAS',
  '1PE',
  '2PE',
  '1JN',
  '2JN',
  '3JN',
  'JUD',
  'REV'
};

/// Quick validation of a verse ID: BOOK.CHAPTER.VERSE where BOOK is a known code
/// and CHAPTER/VERSE are positive integers.
bool isLikelyValidVerseId(String id) {
  final parts = id.split('.');
  if (parts.length != 3) return false;
  final book = parts[0];
  final chapter = int.tryParse(parts[1]);
  final verse = int.tryParse(parts[2]);
  if (!knownBookCodes.contains(book)) return false;
  if (chapter == null || verse == null) return false;
  return chapter > 0 && verse > 0;
}

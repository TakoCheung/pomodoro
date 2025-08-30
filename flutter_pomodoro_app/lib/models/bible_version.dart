class BibleVersion {
  final String id;
  final String name;
  final String abbreviation;
  final String abbreviationLocal;
  final String language;

  BibleVersion(
      {required this.id,
      required this.name,
      required this.abbreviation,
      required this.language,
      this.abbreviationLocal = ''});

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    final abbr = json['abbreviation'] as String? ?? '';
    final abbrLocal = json['abbreviationLocal'] as String? ?? '';
    return BibleVersion(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      abbreviation:
          abbr.isNotEmpty ? abbr : (abbrLocal.isNotEmpty ? abbrLocal : ''),
      abbreviationLocal: abbrLocal,
      language: (json['language'] is Map
          ? (json['language']['name'] as String? ?? '')
          : (json['language'] as String? ?? '')),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
        'abbreviationLocal': abbreviationLocal,
        'language': language,
      };

  String get label => abbreviationLocal.isNotEmpty
      ? abbreviationLocal
      : (abbreviation.isNotEmpty ? abbreviation : name);
  String get displayName =>
      abbreviation.isNotEmpty ? '$abbreviation — $name' : name;
}

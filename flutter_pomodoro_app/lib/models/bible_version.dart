class BibleVersion {
  final String id;
  final String name;
  final String abbreviation;
  final String language;

  BibleVersion({required this.id, required this.name, required this.abbreviation, required this.language});

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      abbreviation: json['abbreviation'] as String? ?? json['abbreviationLocal'] as String? ?? '',
      language: (json['language'] is Map ? (json['language']['name'] as String? ?? '') : (json['language'] as String? ?? '')),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'abbreviation': abbreviation,
        'language': language,
      };

  String get displayName => abbreviation.isNotEmpty ? '$abbreviation — $name' : name;
}

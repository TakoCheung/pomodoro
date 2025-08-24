class Passage {
  final String reference;
  final String text;
  final List<dynamic> verses;

  Passage({required this.reference, required this.text, List<dynamic>? verses}) : verses = verses ?? const [];

  factory Passage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final versesJson = data['verses'];
    return Passage(
      reference: data['reference'] as String? ?? '',
      text: data['content'] as String? ?? '',
      verses: versesJson is List ? versesJson : const [],
    );
  }
}

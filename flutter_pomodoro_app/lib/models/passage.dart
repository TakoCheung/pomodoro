import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class Passage {
  final String reference;
  final String text;
  final List<dynamic> verses;

  Passage({required this.reference, required this.text, List<dynamic>? verses}) : verses = verses ?? const [];

  factory Passage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final versesJson = data['verses'];
    final rawContent = data['content'] as String? ?? '';
    final cleaned = _cleanHtmlContent(rawContent);
    return Passage(
      reference: data['reference'] as String? ?? '',
      text: cleaned,
      verses: versesJson is List ? versesJson : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'content': text,
      'verses': verses,
    };
  }
}

/// Convert the API's HTML content into a plain text string appropriate for
/// the overlay. Removes verse number spans and strips tags while preserving
/// text content.
String _cleanHtmlContent(String html) {
  if (html.isEmpty) return '';
  final doc = html_parser.parse(html);
  // Remove verse number spans: <span class="v">27</span> and similar markers
  final toRemove = <dom.Element>[];
  for (final el in doc.querySelectorAll('span')) {
    final cls = el.attributes['class'] ?? '';
    if (cls.split(' ').contains('v')) {
      toRemove.add(el);
      continue;
    }
    // Also remove spans that are only numeric verse labels
    final trimmed = el.text.trim();
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      toRemove.add(el);
    }
  }
  for (final el in toRemove) {
    el.remove();
  }
  // Get text content; parser collapses tags to text
  final textContent = doc.body?.text ?? doc.documentElement?.text ?? '';
  // Normalize whitespace
  return textContent.replaceAll(RegExp(r'\s+'), ' ').trim();
}

class ScriptureRequest {
  final String bibleId;
  final String passageId;

  const ScriptureRequest({required this.bibleId, required this.passageId});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ScriptureRequest &&
            runtimeType == other.runtimeType &&
            bibleId == other.bibleId &&
            passageId == other.passageId;
  }

  @override
  int get hashCode => bibleId.hashCode ^ passageId.hashCode;
}

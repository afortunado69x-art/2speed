class Bookmark {
  final String id;
  final String bookId;
  final int wordIndex;       // position in word list
  final int charOffset;      // char offset in full text (for scroll mode)
  final String note;         // optional user annotation
  final DateTime createdAt;
  final String preview;      // first ~60 chars around the position

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.wordIndex,
    this.charOffset = 0,
    this.note = '',
    required this.createdAt,
    this.preview = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bookId': bookId,
    'wordIndex': wordIndex,
    'charOffset': charOffset,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'preview': preview,
  };

  factory Bookmark.fromMap(Map<String, dynamic> m) => Bookmark(
    id: m['id'],
    bookId: m['bookId'],
    wordIndex: m['wordIndex'] ?? 0,
    charOffset: m['charOffset'] ?? 0,
    note: m['note'] ?? '',
    createdAt: DateTime.parse(m['createdAt']),
    preview: m['preview'] ?? '',
  );

  Bookmark copyWith({String? note}) => Bookmark(
    id: id, bookId: bookId, wordIndex: wordIndex,
    charOffset: charOffset, createdAt: createdAt, preview: preview,
    note: note ?? this.note,
  );
}

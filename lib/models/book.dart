import 'dart:typed_data';

enum BookFormat { txt, fb2, epub, pdf, docx, html, rtf, mobi, unknown }

class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final BookFormat format;
  final int colorIndex;        // index into GrimTheme.bookColors
  final String symbol;         // decorative glyph on spine
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final int totalWords;
  final int currentWordIndex;
  final bool isFavorite;
  final Uint8List? coverImage;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.format,
    this.colorIndex = 0,
    this.symbol = '✦',
    required this.addedAt,
    this.lastOpenedAt,
    this.totalWords = 0,
    this.currentWordIndex = 0,
    this.isFavorite = false,
    this.coverImage,
  });

  double get progress =>
      totalWords == 0 ? 0.0 : currentWordIndex / totalWords;

  int get remainingWords =>
      (totalWords - currentWordIndex).clamp(0, totalWords);

  int estimatedMinutes(int wordsPerMinute) =>
      wordsPerMinute == 0 ? 0 : (remainingWords / wordsPerMinute).ceil();

  Book copyWith({
    String? title, String? author, int? currentWordIndex,
    bool? isFavorite, DateTime? lastOpenedAt, int? totalWords,
  }) => Book(
    id: id, filePath: filePath, format: format,
    colorIndex: colorIndex, symbol: symbol, addedAt: addedAt,
    coverImage: coverImage,
    title: title ?? this.title,
    author: author ?? this.author,
    currentWordIndex: currentWordIndex ?? this.currentWordIndex,
    isFavorite: isFavorite ?? this.isFavorite,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    totalWords: totalWords ?? this.totalWords,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'filePath': filePath,
    'format': format.name,
    'colorIndex': colorIndex,
    'symbol': symbol,
    'addedAt': addedAt.toIso8601String(),
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    'totalWords': totalWords,
    'currentWordIndex': currentWordIndex,
    'isFavorite': isFavorite ? 1 : 0,
  };

  factory Book.fromMap(Map<String, dynamic> m) => Book(
    id: m['id'],
    title: m['title'],
    author: m['author'] ?? '',
    filePath: m['filePath'],
    format: BookFormat.values.firstWhere(
      (f) => f.name == m['format'], orElse: () => BookFormat.unknown),
    colorIndex: m['colorIndex'] ?? 0,
    symbol: m['symbol'] ?? '✦',
    addedAt: DateTime.parse(m['addedAt']),
    lastOpenedAt: m['lastOpenedAt'] != null ? DateTime.parse(m['lastOpenedAt']) : null,
    totalWords: m['totalWords'] ?? 0,
    currentWordIndex: m['currentWordIndex'] ?? 0,
    isFavorite: (m['isFavorite'] ?? 0) == 1,
  );
}

class ReadingSession {
  final String id;
  final String bookId;
  final DateTime startedAt;
  final int durationSeconds;
  final int wordsRead;
  final int averageWpm;

  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.startedAt,
    required this.durationSeconds,
    required this.wordsRead,
    required this.averageWpm,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'bookId': bookId,
    'startedAt': startedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'wordsRead': wordsRead,
    'averageWpm': averageWpm,
  };

  factory ReadingSession.fromMap(Map<String, dynamic> m) => ReadingSession(
    id: m['id'], bookId: m['bookId'],
    startedAt: DateTime.parse(m['startedAt']),
    durationSeconds: m['durationSeconds'],
    wordsRead: m['wordsRead'],
    averageWpm: m['averageWpm'],
  );
}

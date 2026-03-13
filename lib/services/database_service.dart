import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseService {
  static final DatabaseService _i = DatabaseService._();
  factory DatabaseService() => _i;
  DatabaseService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'grimread.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE books(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            author TEXT,
            filePath TEXT NOT NULL,
            format TEXT NOT NULL,
            colorIndex INTEGER DEFAULT 0,
            symbol TEXT DEFAULT '✦',
            addedAt TEXT NOT NULL,
            lastOpenedAt TEXT,
            totalWords INTEGER DEFAULT 0,
            currentWordIndex INTEGER DEFAULT 0,
            isFavorite INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE sessions(
            id TEXT PRIMARY KEY,
            bookId TEXT NOT NULL,
            startedAt TEXT NOT NULL,
            durationSeconds INTEGER NOT NULL,
            wordsRead INTEGER NOT NULL,
            averageWpm INTEGER NOT NULL,
            FOREIGN KEY(bookId) REFERENCES books(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // ── Books ───────────────────────────────────────────────
  Future<List<Book>> getAllBooks() async {
    final d = await db;
    final rows = await d.query('books', orderBy: 'lastOpenedAt DESC, addedAt DESC');
    return rows.map(Book.fromMap).toList();
  }

  Future<List<Book>> getRecentBooks({int limit = 10}) async {
    final d = await db;
    final rows = await d.query('books',
        where: 'lastOpenedAt IS NOT NULL',
        orderBy: 'lastOpenedAt DESC', limit: limit);
    return rows.map(Book.fromMap).toList();
  }

  Future<List<Book>> getFavoriteBooks() async {
    final d = await db;
    final rows = await d.query('books',
        where: 'isFavorite = 1', orderBy: 'title ASC');
    return rows.map(Book.fromMap).toList();
  }

  Future<void> upsertBook(Book book) async {
    final d = await db;
    await d.insert('books', book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProgress(String bookId, int wordIndex) async {
    final d = await db;
    await d.update('books',
      {'currentWordIndex': wordIndex, 'lastOpenedAt': DateTime.now().toIso8601String()},
      where: 'id = ?', whereArgs: [bookId]);
  }

  Future<void> toggleFavorite(String bookId, bool value) async {
    final d = await db;
    await d.update('books', {'isFavorite': value ? 1 : 0},
        where: 'id = ?', whereArgs: [bookId]);
  }

  Future<void> deleteBook(String bookId) async {
    final d = await db;
    await d.delete('books', where: 'id = ?', whereArgs: [bookId]);
  }

  // ── Sessions ────────────────────────────────────────────
  Future<void> saveSession(ReadingSession s) async {
    final d = await db;
    await d.insert('sessions', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ReadingSession>> getRecentSessions({int limit = 20}) async {
    final d = await db;
    final rows = await d.query('sessions',
        orderBy: 'startedAt DESC', limit: limit);
    return rows.map(ReadingSession.fromMap).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final d = await db;
    final sessions = await d.rawQuery('SELECT * FROM sessions');
    final books = await d.query('books');

    if (sessions.isEmpty) {
      return {'avgWpm': 0, 'totalWords': 0, 'totalBooks': 0, 'streak': 0, 'sessions': []};
    }

    final totalWords = sessions.fold<int>(0, (s, r) => s + (r['wordsRead'] as int));
    final avgWpm = sessions.fold<int>(0, (s, r) => s + (r['averageWpm'] as int)) ~/ sessions.length;
    final completedBooks = books.where((b) {
      final tw = b['totalWords'] as int;
      final cw = b['currentWordIndex'] as int;
      return tw > 0 && cw >= tw * 0.95;
    }).length;

    // streak: count consecutive days with sessions
    final days = <String>{};
    for (final s in sessions) {
      final d = DateTime.parse(s['startedAt'] as String);
      days.add('${d.year}-${d.month}-${d.day}');
    }
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month}-${day.day}';
      if (days.contains(key)) streak++;
      else if (i > 0) break;
    }

    return {
      'avgWpm': avgWpm,
      'totalWords': totalWords,
      'totalBooks': completedBooks,
      'streak': streak,
      'sessions': sessions.map(ReadingSession.fromMap).toList(),
    };
  }
}

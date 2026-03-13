import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bookmark.dart';

class BookmarkService {
  static final BookmarkService _i = BookmarkService._();
  factory BookmarkService() => _i;
  BookmarkService._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'grimread_bookmarks.db');
    return openDatabase(path, version: 1, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE bookmarks(
          id TEXT PRIMARY KEY,
          bookId TEXT NOT NULL,
          wordIndex INTEGER NOT NULL,
          charOffset INTEGER DEFAULT 0,
          note TEXT DEFAULT '',
          createdAt TEXT NOT NULL,
          preview TEXT DEFAULT ''
        )
      ''');
      await db.execute('CREATE INDEX idx_bookid ON bookmarks(bookId)');
    });
  }

  Future<List<Bookmark>> forBook(String bookId) async {
    final d = await db;
    final rows = await d.query('bookmarks',
        where: 'bookId = ?', whereArgs: [bookId],
        orderBy: 'wordIndex ASC');
    return rows.map(Bookmark.fromMap).toList();
  }

  Future<void> add(Bookmark b) async {
    final d = await db;
    await d.insert('bookmarks', b.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(String id, String note) async {
    final d = await db;
    await d.update('bookmarks', {'note': note},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String id) async {
    final d = await db;
    await d.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> existsAt(String bookId, int wordIndex) async {
    final d = await db;
    final rows = await d.query('bookmarks',
        where: 'bookId = ? AND wordIndex = ?',
        whereArgs: [bookId, wordIndex], limit: 1);
    return rows.isNotEmpty;
  }

  Future<void> deleteAt(String bookId, int wordIndex) async {
    final d = await db;
    await d.delete('bookmarks',
        where: 'bookId = ? AND wordIndex = ?',
        whereArgs: [bookId, wordIndex]);
  }
}

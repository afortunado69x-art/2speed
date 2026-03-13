import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/bookmark.dart';
import '../services/database_service.dart';
import '../services/bookmark_service.dart';
import '../services/parser_service.dart';

enum ScrollReaderState { idle, loading, ready, error }

/// Controls the traditional scroll/page reading mode.
/// Manages full text, font settings, bookmarks, and scroll position.
class ScrollReaderController extends ChangeNotifier {
  // ── Parsed content ────────────────────────────────────────
  ScrollReaderState _state = ScrollReaderState.idle;
  String _fullText = '';
  List<String> _words = [];
  List<Chapter> _chapters = [];
  List<Bookmark> _bookmarks = [];
  Book? _book;
  String? _error;

  // ── Reading position ──────────────────────────────────────
  int _currentWordIndex = 0;

  // ── Display settings ──────────────────────────────────────
  double _fontSize = 17.0;
  double _lineHeight = 1.75;
  String _fontFamily = 'IMFellEnglish'; // gothic body font
  bool _nightMode = true;               // always dark for gothic theme
  double _marginH = 22.0;              // horizontal margin
  bool _showChapterHeaders = true;

  // ── Getters ───────────────────────────────────────────────
  ScrollReaderState get state      => _state;
  String            get fullText   => _fullText;
  List<String>      get words      => _words;
  List<Chapter>     get chapters   => _chapters;
  List<Bookmark>    get bookmarks  => _bookmarks;
  Book?             get book       => _book;
  String?           get error      => _error;
  int               get currentWordIndex => _currentWordIndex;
  double            get fontSize   => _fontSize;
  double            get lineHeight => _lineHeight;
  String            get fontFamily => _fontFamily;
  bool              get nightMode  => _nightMode;
  double            get marginH    => _marginH;
  bool              get showChapterHeaders => _showChapterHeaders;
  double            get progress   =>
      _words.isEmpty ? 0.0 : _currentWordIndex / _words.length;

  // ── Load ──────────────────────────────────────────────────
  Future<void> loadBook(Book book) async {
    _state  = ScrollReaderState.loading;
    _book   = book;
    _error  = null;
    notifyListeners();

    try {
      final parsed = await BookParserService().parse(book.filePath, book.format);
      _words    = parsed.words;
      _chapters = parsed.chapters;
      _fullText = _buildDisplayText(parsed);
      _currentWordIndex = book.currentWordIndex.clamp(0, (_words.length - 1).clamp(0, 999999));
      _bookmarks = await BookmarkService().forBook(book.id);
      _state = ScrollReaderState.ready;
    } catch (e) {
      _error = e.toString();
      _state = ScrollReaderState.error;
    }
    notifyListeners();
  }

  /// Rebuild readable text from parsed book, injecting chapter titles
  String _buildDisplayText(ParsedBook parsed) {
    if (!_showChapterHeaders || parsed.chapters.length <= 1) {
      return parsed.words.join(' ');
    }
    final buf = StringBuffer();
    int wi = 0;
    for (final ch in parsed.chapters) {
      if (ch.startWordIndex > wi) {
        buf.write(parsed.words.sublist(wi, ch.startWordIndex).join(' '));
        buf.write('\n\n');
      }
      buf.write('\n\n${ch.title}\n\n');
      wi = ch.startWordIndex;
    }
    if (wi < parsed.words.length) {
      buf.write(parsed.words.sublist(wi).join(' '));
    }
    return buf.toString();
  }

  // ── Position tracking ─────────────────────────────────────
  void updatePosition(int wordIndex) {
    if (wordIndex == _currentWordIndex) return;
    _currentWordIndex = wordIndex.clamp(0, (_words.length - 1).clamp(0, 999999));
    notifyListeners();
    DatabaseService().updateProgress(_book!.id, _currentWordIndex);
  }

  void jumpToChapter(Chapter ch) {
    updatePosition(ch.startWordIndex);
    notifyListeners();
  }

  // ── Bookmarks ─────────────────────────────────────────────
  bool isBookmarked(int wordIndex) =>
      _bookmarks.any((b) => b.wordIndex == wordIndex);

  Future<void> toggleBookmark(int wordIndex, {String preview = ''}) async {
    if (_book == null) return;
    final exists = await BookmarkService().existsAt(_book!.id, wordIndex);
    if (exists) {
      await BookmarkService().deleteAt(_book!.id, wordIndex);
    } else {
      final bm = Bookmark(
        id: '${_book!.id}_$wordIndex',
        bookId: _book!.id,
        wordIndex: wordIndex,
        preview: preview.length > 80 ? preview.substring(0, 80) : preview,
        createdAt: DateTime.now(),
      );
      await BookmarkService().add(bm);
    }
    _bookmarks = await BookmarkService().forBook(_book!.id);
    notifyListeners();
  }

  Future<void> addNote(String bookmarkId, String note) async {
    await BookmarkService().updateNote(bookmarkId, note);
    _bookmarks = await BookmarkService().forBook(_book!.id);
    notifyListeners();
  }

  Future<void> deleteBookmark(String id) async {
    await BookmarkService().delete(id);
    _bookmarks = await BookmarkService().forBook(_book!.id);
    notifyListeners();
  }

  // ── Display settings ─────────────────────────────────────
  void setFontSize(double v) { _fontSize = v.clamp(12, 28); notifyListeners(); }
  void setLineHeight(double v) { _lineHeight = v.clamp(1.2, 2.5); notifyListeners(); }
  void setMargin(double v) { _marginH = v.clamp(10, 50); notifyListeners(); }
  void cycleFontFamily() {
    const fonts = ['im_fell_english', 'cinzel', 'serif', 'monospace'];
    final i = fonts.indexOf(_fontFamily);
    _fontFamily = fonts[(i + 1) % fonts.length];
    notifyListeners();
  }

  @override
  void dispose() {
    if (_book != null && _words.isNotEmpty) {
      DatabaseService().updateProgress(_book!.id, _currentWordIndex);
    }
    super.dispose();
  }
}

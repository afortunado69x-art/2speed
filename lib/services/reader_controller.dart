import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/parser_service.dart';
import '../services/database_service.dart';

enum ReaderState { idle, loading, playing, paused, finished }

class ReaderController extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────
  ReaderState _state = ReaderState.idle;
  List<String> _words = [];
  List<Chapter> _chapters = [];
  int _currentIndex = 0;
  int _wpm = 300;
  bool _pauseOnPunctuation = true;
  bool _showOrp = true;
  Book? _book;

  // ── Session tracking ─────────────────────────────────────
  DateTime? _sessionStart;
  int _sessionWordsRead = 0;
  Timer? _timer;

  // ── Getters ──────────────────────────────────────────────
  ReaderState get state => _state;
  List<String> get words => _words;
  List<Chapter> get chapters => _chapters;
  int get currentIndex => _currentIndex;
  int get wpm => _wpm;
  bool get pauseOnPunctuation => _pauseOnPunctuation;
  bool get showOrp => _showOrp;
  Book? get book => _book;

  String get currentWord =>
      _words.isEmpty ? '' : _words[_currentIndex.clamp(0, _words.length - 1)];

  double get progress =>
      _words.isEmpty ? 0.0 : _currentIndex / _words.length;

  int get remainingMinutes {
    if (_wpm == 0 || _words.isEmpty) return 0;
    return ((_words.length - _currentIndex) / _wpm).ceil();
  }

  int get orpIndex => BookParserService.orp(currentWord);

  Chapter? get currentChapter {
    Chapter? cur;
    for (final ch in _chapters) {
      if (ch.startWordIndex <= _currentIndex) cur = ch;
      else break;
    }
    return cur;
  }

  // ── Load book ─────────────────────────────────────────────
  Future<void> loadBook(Book book) async {
    _state = ReaderState.loading;
    _book = book;
    notifyListeners();

    final parsed = await BookParserService().parse(book.filePath, book.format);
    _words    = parsed.words;
    _chapters = parsed.chapters;
    _currentIndex = book.currentWordIndex.clamp(0, (_words.length - 1).clamp(0, 999999));
    _state = ReaderState.paused;
    notifyListeners();
  }

  // ── Playback ──────────────────────────────────────────────
  void play() {
    if (_words.isEmpty || _state == ReaderState.playing) return;
    _state = ReaderState.playing;
    _sessionStart ??= DateTime.now();
    _scheduleNext();
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _state = _currentIndex >= _words.length - 1
        ? ReaderState.finished : ReaderState.paused;
    _saveProgress();
    notifyListeners();
  }

  void togglePlay() {
    if (_state == ReaderState.playing) pause();
    else play();
  }

  void _scheduleNext() {
    _timer?.cancel();
    if (_currentIndex >= _words.length - 1) {
      _state = ReaderState.finished;
      _saveSession();
      notifyListeners();
      return;
    }
    final word = currentWord;
    final basMs = (60000 / _wpm).round();
    final mult  = _pauseOnPunctuation ? BookParserService.punctuationMultiplier(word) : 1.0;
    final delay = (basMs * mult).round();

    _timer = Timer(Duration(milliseconds: delay), () {
      _currentIndex++;
      _sessionWordsRead++;
      notifyListeners();
      if (_state == ReaderState.playing) _scheduleNext();
    });
  }

  void stepForward()  { _timer?.cancel(); if (_currentIndex < _words.length-1) { _currentIndex++; notifyListeners(); if (_state == ReaderState.playing) _scheduleNext(); } }
  void stepBackward() { _timer?.cancel(); if (_currentIndex > 0) { _currentIndex--; notifyListeners(); if (_state == ReaderState.playing) _scheduleNext(); } }
  void skipForward()  { _timer?.cancel(); _currentIndex = (_currentIndex + 15).clamp(0, _words.length-1); notifyListeners(); if (_state == ReaderState.playing) _scheduleNext(); }
  void skipBackward() { _timer?.cancel(); _currentIndex = (_currentIndex - 15).clamp(0, _words.length-1); notifyListeners(); if (_state == ReaderState.playing) _scheduleNext(); }

  void jumpToChapter(Chapter ch) {
    final wasPlaying = _state == ReaderState.playing;
    pause();
    _currentIndex = ch.startWordIndex.clamp(0, _words.length-1);
    notifyListeners();
    if (wasPlaying) play();
  }

  void jumpToWord(int index) {
    _currentIndex = index.clamp(0, _words.length-1);
    notifyListeners();
  }

  // ── Settings ─────────────────────────────────────────────
  void setWpm(int wpm) {
    _wpm = wpm.clamp(50, 1500);
    if (_state == ReaderState.playing) { _timer?.cancel(); _scheduleNext(); }
    notifyListeners();
  }

  void setPauseOnPunctuation(bool v) { _pauseOnPunctuation = v; notifyListeners(); }
  void setShowOrp(bool v) { _showOrp = v; notifyListeners(); }

  // ── Persistence ──────────────────────────────────────────
  Future<void> _saveProgress() async {
    if (_book == null) return;
    await DatabaseService().updateProgress(_book!.id, _currentIndex);
  }

  Future<void> _saveSession() async {
    if (_book == null || _sessionStart == null || _sessionWordsRead == 0) return;
    final dur = DateTime.now().difference(_sessionStart!).inSeconds;
    final avgWpm = dur > 0 ? (_sessionWordsRead / dur * 60).round() : _wpm;
    await DatabaseService().saveSession(ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: _book!.id,
      startedAt: _sessionStart!,
      durationSeconds: dur,
      wordsRead: _sessionWordsRead,
      averageWpm: avgWpm,
    ));
    _sessionStart = null;
    _sessionWordsRead = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveSession();
    super.dispose();
  }
}

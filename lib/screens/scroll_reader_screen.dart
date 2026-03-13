import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/book.dart';
import '../models/bookmark.dart';
import '../services/scroll_reader_controller.dart';
import '../services/parser_service.dart';
import '../theme.dart';
import '../widgets/bookmarks_panel.dart';
import '../widgets/chapter_drawer.dart';
import '../widgets/reader_settings_sheet.dart';
import 'reader_screen.dart';

class ScrollReaderScreen extends StatefulWidget {
  final Book book;
  const ScrollReaderScreen({super.key, required this.book});

  @override
  State<ScrollReaderScreen> createState() => _ScrollReaderScreenState();
}

class _ScrollReaderScreenState extends State<ScrollReaderScreen>
    with SingleTickerProviderStateMixin {
  late final ScrollReaderController _ctrl;
  final ScrollController _scrollCtrl = ScrollController();

  bool _showUI = true;
  bool _showBookmarkFeedback = false;
  late AnimationController _uiAnim;
  late Animation<double> _uiFade;

  // Track which word is approximately at screen center
  int _visibleWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollReaderController();
    _ctrl.addListener(() { if (mounted) setState(() {}); });

    _uiAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _uiFade = CurvedAnimation(parent: _uiAnim, curve: Curves.easeInOut);
    _uiAnim.value = 1.0;

    _ctrl.loadBook(widget.book);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    // Estimate current word from scroll position
    if (_ctrl.words.isEmpty) return;
    final maxScroll = _scrollCtrl.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final frac = (_scrollCtrl.offset / maxScroll).clamp(0.0, 1.0);
    _visibleWordIndex = (frac * _ctrl.words.length).round();
    _ctrl.updatePosition(_visibleWordIndex);
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) _uiAnim.forward(); else _uiAnim.reverse();
  }

  void _openBookmarks() {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerRight,
        child: BookmarksPanel(
          bookmarks: _ctrl.bookmarks,
          onJump: (bm) { _jumpToWord(bm.wordIndex); Navigator.of(context).pop(); },
          onDelete: (bm) => _ctrl.deleteBookmark(bm.id),
          onAddNote: (bm, note) => _ctrl.addNote(bm.id, note),
        ),
      ),
    ));
  }

  void _openChapters() {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => Align(
        alignment: Alignment.centerLeft,
        child: ChapterDrawer(
          chapters: _ctrl.chapters,
          currentChapter: _ctrl.chapters.isNotEmpty
              ? _nearestChapter(_visibleWordIndex) : null,
          onSelect: (ch) {
            _ctrl.jumpToChapter(ch);
            _jumpToWord(ch.startWordIndex);
          },
        ),
      ),
    ));
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ReaderSettingsSheet(ctrl: _ctrl),
    );
  }

  void _jumpToWord(int wordIndex) {
    if (_ctrl.words.isEmpty) return;
    final frac = wordIndex / _ctrl.words.length;
    final target = frac * (_scrollCtrl.position.maxScrollExtent);
    _scrollCtrl.animateTo(target,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic);
  }

  void _addBookmark() {
    // Get preview text around current position
    final wi = _visibleWordIndex;
    final words = _ctrl.words;
    final start = (wi - 5).clamp(0, words.length);
    final end = (wi + 15).clamp(0, words.length);
    final preview = words.sublist(start, end).join(' ');
    _ctrl.toggleBookmark(wi, preview: preview);

    setState(() => _showBookmarkFeedback = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showBookmarkFeedback = false);
    });
  }

  Chapter? _nearestChapter(int wordIndex) {
    Chapter? best;
    for (final ch in _ctrl.chapters) {
      if (ch.startWordIndex <= wordIndex) best = ch;
      else break;
    }
    return best;
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _ctrl.dispose();
    _uiAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: Stack(children: [

        // ── Parchment texture background ──────────────────────
        Positioned.fill(child: IgnorePointer(child: CustomPaint(
          painter: _ParchmentPainter()))),

        // ── Main reading content ──────────────────────────────
        GestureDetector(
          onTap: _toggleUI,
          onLongPress: _addBookmark,
          child: _buildContent(),
        ),

        // ── Top bar ───────────────────────────────────────────
        Positioned(top: 0, left: 0, right: 0,
          child: FadeTransition(opacity: _uiFade, child: _TopBar(
            ctrl: _ctrl,
            book: widget.book,
            onBack: () => Navigator.of(context).pop(),
            onChapters: _openChapters,
          ))),

        // ── Bottom toolbar ────────────────────────────────────
        Positioned(bottom: 0, left: 0, right: 0,
          child: FadeTransition(opacity: _uiFade, child: _BottomBar(
            ctrl: _ctrl,
            onBookmarks: _openBookmarks,
            onSettings: _openSettings,
            onBookmark: _addBookmark,
            isBookmarked: _ctrl.isBookmarked(_visibleWordIndex),
          ))),

        // ── Bookmark toast ────────────────────────────────────
        if (_showBookmarkFeedback)
          Positioned(
            bottom: 90, left: 0, right: 0,
            child: Center(child: _BookmarkToast(
              added: _ctrl.isBookmarked(_visibleWordIndex)))),

        // ── Loading overlay ───────────────────────────────────
        if (_ctrl.state == ScrollReaderState.loading)
          const Positioned.fill(child: _LoadingVeil()),

        // ── Error ─────────────────────────────────────────────
        if (_ctrl.state == ScrollReaderState.error)
          Positioned.fill(child: _ErrorVeil(error: _ctrl.error ?? '')),
      ]),
    );
  }

  Widget _buildContent() {
    if (_ctrl.state != ScrollReaderState.ready) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, __) => SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          _ctrl.marginH,
          MediaQuery.of(context).padding.top + 72,
          _ctrl.marginH,
          MediaQuery.of(context).padding.bottom + 100,
        ),
        child: _GothicText(ctrl: _ctrl, bookmarks: _ctrl.bookmarks),
      ),
    );
  }
}

// ── Rich gothic text renderer ─────────────────────────────────
class _GothicText extends StatelessWidget {
  final ScrollReaderController ctrl;
  final List<Bookmark> bookmarks;

  const _GothicText({required this.ctrl, required this.bookmarks});

  @override
  Widget build(BuildContext context) {
    // Build spans: inject bookmark markers inline
    final bmWordIndices = bookmarks.map((b) => b.wordIndex).toSet();
    final words = ctrl.words;
    final spans = <InlineSpan>[];

    int i = 0;
    while (i < words.length) {
      // Bookmark marker
      if (bmWordIndices.contains(i)) {
        spans.add(WidgetSpan(child: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text('❧',
            style: TextStyle(
              fontSize: ctrl.fontSize * 0.7,
              color: GrimTheme.crimson.withOpacity(0.7))),
        )));
      }

      // Chapter break
      final chapterHere = ctrl.chapters.where((c) => c.startWordIndex == i).firstOrNull;
      if (chapterHere != null && ctrl.showChapterHeaders && i > 0) {
        spans.add(const TextSpan(text: '\n\n'));
        spans.add(WidgetSpan(child: _ChapterTitle(title: chapterHere.title)));
        spans.add(const TextSpan(text: '\n\n'));
      }

      spans.add(TextSpan(text: words[i]));
      if (i < words.length - 1) spans.add(const TextSpan(text: ' '));
      i++;
    }

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          // For google_fonts families, fontFamily is auto-applied via theme
          // For system fonts (serif/monospace), use fontFamily directly
          fontFamily: (ctrl.fontFamily == 'serif' || ctrl.fontFamily == 'monospace')
              ? ctrl.fontFamily : null,
          fontSize: ctrl.fontSize,
          height: ctrl.lineHeight,
          color: GrimTheme.bone,
          letterSpacing: 0.2,
        ),
        children: spans,
      ),
      textAlign: TextAlign.justify,
    );
  }
}

// ── Chapter title widget ──────────────────────────────────────
class _ChapterTitle extends StatelessWidget {
  final String title;
  const _ChapterTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(children: [
      Container(height: 1, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent, GrimTheme.gold.withOpacity(0.4), Colors.transparent]))),
      const SizedBox(height: 16),
      Text(title, style: GrimTheme.cinzel(size: 16, weight: FontWeight.w600, color: GrimTheme.gold),
          textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text('✦', style: TextStyle(fontSize: 12, color: GrimTheme.tarnished.withOpacity(0.6))),
      const SizedBox(height: 16),
      Container(height: 1, decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent, GrimTheme.gold.withOpacity(0.25), Colors.transparent]))),
    ]),
  );
}

// ── Top bar ───────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final ScrollReaderController ctrl;
  final Book book;
  final VoidCallback onBack, onChapters, onRsvp;

  const _TopBar({required this.ctrl, required this.book,
    required this.onBack, required this.onChapters, required this.onRsvp});

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.black.withOpacity(0.92),
    padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 6, 16, 10),
    child: Column(children: [
      Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Row(children: [
            Text('←', style: GrimTheme.cinzel(size: 16, color: GrimTheme.gold)),
            const SizedBox(width: 6),
            Text('Library', style: GrimTheme.cinzel(size: 9, spacing: 1.5, color: GrimTheme.dust)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book.title, style: GrimTheme.cinzel(size: 12, color: GrimTheme.bone),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (book.author.isNotEmpty)
            Text(book.author,
              style: GrimTheme.fell(size: 10, italic: true, color: GrimTheme.mist),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        GestureDetector(
          onTap: onChapters,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text('❧', style: TextStyle(
              fontSize: 18, color: GrimTheme.tarnished.withOpacity(0.7))),
          ),
        ),
        GestureDetector(
          onTap: onRsvp,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: GrimTheme.gold.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(children: [
              Text('⚡', style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text('RSVP', style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.dust)),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 8),
      // Progress bar
      ClipRRect(
        borderRadius: BorderRadius.circular(1),
        child: LinearProgressIndicator(
          value: ctrl.progress,
          minHeight: 2,
          backgroundColor: GrimTheme.ash,
          valueColor: const AlwaysStoppedAnimation(GrimTheme.crimson),
        ),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${(ctrl.progress * 100).round()}%',
          style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.mist)),
        Text('${ctrl.words.length} words',
          style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.mist)),
      ]),
    ]),
  );
}

// ── Bottom toolbar ────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final ScrollReaderController ctrl;
  final VoidCallback onBookmarks, onSettings, onBookmark;
  final bool isBookmarked;

  const _BottomBar({required this.ctrl, required this.onBookmarks,
    required this.onSettings, required this.onBookmark, required this.isBookmarked});

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.black.withOpacity(0.92),
    padding: EdgeInsets.fromLTRB(16, 10, 16,
        MediaQuery.of(context).padding.bottom + 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _ToolBtn(icon: '❧', label: 'Chapters', onTap: onBookmarks),
      _ToolBtn(
        icon: isBookmarked ? '✦' : '✧',
        label: isBookmarked ? 'Marked' : 'Mark',
        onTap: onBookmark,
        active: isBookmarked,
      ),
      _ToolBtn(icon: '📖', label: 'Bookmarks', onTap: onBookmarks),
      _ToolBtn(icon: '⚙', label: 'Appearance', onTap: onSettings),
    ]),
  );
}

class _ToolBtn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final bool active;

  const _ToolBtn({required this.icon, required this.label,
    required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: TextStyle(
          fontSize: 18,
          color: active ? GrimTheme.gold : GrimTheme.dust)),
        const SizedBox(height: 3),
        Text(label, style: GrimTheme.cinzel(size: 7, spacing: 0.5,
          color: active ? GrimTheme.gold : GrimTheme.mist)),
      ]),
    ),
  );
}

// ── Bookmark toast ────────────────────────────────────────────
class _BookmarkToast extends StatelessWidget {
  final bool added;
  const _BookmarkToast({required this.added});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: GrimTheme.stone,
      border: Border.all(color: GrimTheme.gold.withOpacity(0.3)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(added ? '✦' : '✧',
        style: TextStyle(fontSize: 14,
          color: added ? GrimTheme.gold : GrimTheme.mist)),
      const SizedBox(width: 8),
      Text(added ? 'Bookmark added' : 'Bookmark removed',
        style: GrimTheme.cinzel(size: 10, spacing: 1,
          color: added ? GrimTheme.gold : GrimTheme.mist)),
    ]),
  );
}

// ── Loading veil ──────────────────────────────────────────────
class _LoadingVeil extends StatelessWidget {
  const _LoadingVeil();

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.void_,
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('☩', style: TextStyle(
        fontSize: 48, color: GrimTheme.blood.withOpacity(0.5),
        shadows: [Shadow(color: GrimTheme.blood.withOpacity(0.4), blurRadius: 20)])),
      const SizedBox(height: 20),
      Text('Opening the tome...', style: GrimTheme.fell(size: 14, italic: true, color: GrimTheme.dust)),
      const SizedBox(height: 16),
      SizedBox(width: 120, child: LinearProgressIndicator(
        backgroundColor: GrimTheme.ash,
        valueColor: const AlwaysStoppedAnimation(GrimTheme.blood),
        minHeight: 2)),
    ])),
  );
}

// ── Error veil ────────────────────────────────────────────────
class _ErrorVeil extends StatelessWidget {
  final String error;
  const _ErrorVeil({required this.error});

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.void_,
    padding: const EdgeInsets.all(32),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('⛧', style: TextStyle(fontSize: 40, color: GrimTheme.blood.withOpacity(0.6))),
      const SizedBox(height: 16),
      Text('The tome could not be opened',
        style: GrimTheme.cinzel(size: 14, color: GrimTheme.bone), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(error, style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist),
          textAlign: TextAlign.center),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: GrimTheme.gold.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(2)),
          child: Text('Return to Library',
            style: GrimTheme.cinzel(size: 10, spacing: 1.5, color: GrimTheme.dust)),
        ),
      ),
    ])),
  );
}

// ── Parchment texture background painter ─────────────────────
class _ParchmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Very subtle vertical stripe texture like old parchment
    final paint = Paint()
      ..color = const Color(0x03C8A040)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Subtle top and bottom vignette
    final vigPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF080608).withOpacity(0.4),
          Colors.transparent,
          Colors.transparent,
          const Color(0xFF080608).withOpacity(0.4),
        ],
        stops: const [0, 0.12, 0.88, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vigPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

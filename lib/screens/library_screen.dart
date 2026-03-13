import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/parser_service.dart';
import '../theme.dart';
import '../widgets/gothic_widgets.dart';
import '../widgets/book_widget.dart';
import '../l10n/app_localizations.dart';
import 'reader_screen.dart';
import 'scroll_reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> _recent = [];
  List<Book> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recent = await DatabaseService().getRecentBooks();
    final favs   = await DatabaseService().getFavoriteBooks();
    if (mounted) setState(() { _recent = recent; _favorites = favs; _loading = false; });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'fb2', 'epub', 'pdf', 'docx', 'html', 'rtf', 'mobi'],
    );
    if (result == null || result.files.isEmpty) return;

    final file   = result.files.first;
    final path   = file.path!;
    final format = BookParserService().detectFormat(path);
    final parsed = await BookParserService().parse(path, format);

    final book = Book(
      id:          DateTime.now().millisecondsSinceEpoch.toString(),
      title:       parsed.title,
      author:      parsed.author,
      filePath:    path,
      format:      format,
      colorIndex:  (_recent.length + _favorites.length) % GrimTheme.bookColors.length,
      addedAt:     DateTime.now(),
      totalWords:  parsed.words.length,
    );

    await DatabaseService().upsertBook(book);
    _load();
  }

  void _openBook(Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReadModeSheet(
        onRsvp: () {
          Navigator.pop(context);
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, a, __) => ReaderScreen(book: book),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          )).then((_) => _load());
        },
        onScroll: () {
          Navigator.pop(context);
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, a, __) => ScrollReaderScreen(book: book),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          )).then((_) => _load());
        },
        book: book,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_loading) return const Center(child: CircularProgressIndicator(color: GrimTheme.gold));

    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: Stack(children: [
        // Background glow
        Positioned(top: 0, left: 0, right: 0, child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1),
              radius: 1.2,
              colors: [GrimTheme.blood.withOpacity(0.12), Colors.transparent])),
        )),
        Column(children: [
          GothicAppBar(
            title: l.appName,
            subtitle: '∴ Tome of Speed Reading ∴',
            actions: [
              Text('☩', style: TextStyle(
                fontSize: 26, color: GrimTheme.blood.withOpacity(0.7),
                shadows: [Shadow(color: GrimTheme.blood.withOpacity(0.6), blurRadius: 14)])),
              const SizedBox(width: 16),
            ],
          ),
          Expanded(child: CustomScrollView(
            slivers: [
              // Recently opened shelf
              if (_recent.isNotEmpty) ...[
                SliverToBoxAdapter(child: GothicDivider(label: l.recentlyOpened)),
                SliverToBoxAdapter(child: WoodenShelf(books: [
                  ..._recent.map((b) => BookSpine(book: b, onTap: () => _openBook(b))),
                  AddTomeButton(onTap: _pickFile, label: l.addTome),
                ])),
              ],

              // Favorites shelf
              if (_favorites.isNotEmpty) ...[
                SliverToBoxAdapter(child: GothicDivider(label: l.sacredTexts)),
                SliverToBoxAdapter(child: WoodenShelf(books: [
                  ..._favorites.map((b) => BookSpine(book: b, onTap: () => _openBook(b))),
                ])),
              ],

              // Empty state
              if (_recent.isEmpty && _favorites.isEmpty)
                SliverFillRemaining(child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('☩', style: TextStyle(fontSize: 48, color: GrimTheme.blood.withOpacity(0.4))),
                    const SizedBox(height: 16),
                    Text('Your grimoire awaits', style: GrimTheme.cinzel(size: 14, color: GrimTheme.dust)),
                    const SizedBox(height: 8),
                    Text('Add your first tome below', style: GrimTheme.fell(size: 12, italic: true, color: GrimTheme.mist)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: GrimTheme.gold.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text('Open a scroll', style: GrimTheme.cinzel(size: 11, spacing: 2, color: GrimTheme.gold)),
                      ),
                    )
                  ],
                ))),

              // Accepted formats
              SliverToBoxAdapter(child: GothicDivider(label: l.acceptedScrolls)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Wrap(spacing: 6, runSpacing: 6,
                  children: ['TXT', 'FB2', 'EPUB', 'PDF', 'DOCX', 'HTML', 'RTF', 'MOBI']
                    .map((f) => FormatChip(label: f)).toList()),
              )),
            ],
          )),
        ]),
        const GothicCorners(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: GrimTheme.blood,
        foregroundColor: GrimTheme.bone,
        tooltip: 'Add tome',
        child: const Text('✚', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// ── Reading mode picker bottom sheet ─────────────────────────
class _ReadModeSheet extends StatelessWidget {
  final Book book;
  final VoidCallback onRsvp, onScroll;

  const _ReadModeSheet({required this.book, required this.onRsvp, required this.onScroll});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GrimTheme.deep,
        border: Border(top: BorderSide(color: GrimTheme.gold.withOpacity(0.2))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(child: Container(
          width: 36, height: 3, margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: GrimTheme.mist.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2)))),

        // Title
        Text(book.title,
          style: GrimTheme.cinzel(size: 14, color: GrimTheme.bone),
          textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('Choose reading mode', style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist)),
        const SizedBox(height: 24),

        // Mode cards
        Row(children: [
          Expanded(child: _ModeCard(
            icon: '⚡',
            title: 'RSVP',
            subtitle: 'Word-by-word\nspeed reading',
            onTap: onRsvp,
            accent: GrimTheme.blood,
          )),
          const SizedBox(width: 12),
          Expanded(child: _ModeCard(
            icon: '📜',
            title: 'Scroll',
            subtitle: 'Traditional\nparchment reading',
            onTap: onScroll,
            accent: GrimTheme.tarnished,
          )),
        ]),
      ]),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback onTap;
  final Color accent;

  const _ModeCard({required this.icon, required this.title,
    required this.subtitle, required this.onTap, required this.accent});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
        color: accent.withOpacity(0.06),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.08), Colors.transparent]),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 10),
        Text(title, style: GrimTheme.cinzel(size: 14, color: GrimTheme.bone)),
        const SizedBox(height: 6),
        Text(subtitle,
          style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist),
          textAlign: TextAlign.center),
      ]),
    ),
  );
}

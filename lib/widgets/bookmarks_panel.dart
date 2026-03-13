import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../theme.dart';
import '../widgets/gothic_widgets.dart';

class BookmarksPanel extends StatefulWidget {
  final List<Bookmark> bookmarks;
  final ValueChanged<Bookmark> onJump;
  final ValueChanged<Bookmark> onDelete;
  final Function(Bookmark, String) onAddNote;

  const BookmarksPanel({
    super.key,
    required this.bookmarks,
    required this.onJump,
    required this.onDelete,
    required this.onAddNote,
  });

  @override
  State<BookmarksPanel> createState() => _BookmarksPanelState();
}

class _BookmarksPanelState extends State<BookmarksPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.82,
        color: GrimTheme.deep,
        child: Column(children: [
          // Header
          Container(
            color: GrimTheme.black,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 14),
            child: Row(children: [
              Text('☩', style: TextStyle(
                fontSize: 20, color: GrimTheme.blood.withOpacity(0.7))),
              const SizedBox(width: 10),
              Expanded(child: Text('Bookmarks',
                style: GrimTheme.cinzel(size: 14, color: GrimTheme.bone))),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('✕', style: GrimTheme.cinzel(size: 14, color: GrimTheme.dust)),
              ),
            ]),
          ),
          // Gold divider
          Container(height: 1,
            decoration: BoxDecoration(gradient: LinearGradient(colors: [
              Colors.transparent, GrimTheme.gold.withOpacity(0.4),
              GrimTheme.blood.withOpacity(0.3), Colors.transparent]))),

          if (widget.bookmarks.isEmpty)
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('❧', style: TextStyle(fontSize: 36, color: GrimTheme.mist.withOpacity(0.4))),
              const SizedBox(height: 12),
              Text('No bookmarks yet', style: GrimTheme.fell(size: 13, italic: true, color: GrimTheme.dust)),
              const SizedBox(height: 6),
              Text('Long-press any paragraph\nto mark your place',
                textAlign: TextAlign.center,
                style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist)),
            ])))
          else
            Expanded(child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.bookmarks.length,
              separatorBuilder: (_, __) => Container(
                height: 1, color: GrimTheme.gold.withOpacity(0.06)),
              itemBuilder: (_, i) => _BookmarkTile(
                bookmark: widget.bookmarks[i],
                onJump: () => widget.onJump(widget.bookmarks[i]),
                onDelete: () => widget.onDelete(widget.bookmarks[i]),
                onNote: (n) => widget.onAddNote(widget.bookmarks[i], n),
              ),
            )),
        ]),
      ),
    );
  }
}

class _BookmarkTile extends StatefulWidget {
  final Bookmark bookmark;
  final VoidCallback onJump;
  final VoidCallback onDelete;
  final ValueChanged<String> onNote;

  const _BookmarkTile({
    required this.bookmark,
    required this.onJump,
    required this.onDelete,
    required this.onNote,
  });

  @override
  State<_BookmarkTile> createState() => _BookmarkTileState();
}

class _BookmarkTileState extends State<_BookmarkTile> {
  bool _expanded = false;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteCtrl.text = widget.bookmark.note;
  }

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onJump,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _expanded ? GrimTheme.stone.withOpacity(0.5) : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Ribbon icon
            Container(
              width: 28, height: 38,
              decoration: BoxDecoration(
                color: GrimTheme.blood,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4)),
              ),
              child: const Center(child: Text('✦',
                style: TextStyle(fontSize: 10, color: GrimTheme.parchment))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Preview text
              Text(
                widget.bookmark.preview.isNotEmpty
                    ? widget.bookmark.preview
                    : 'Position ${widget.bookmark.wordIndex}',
                style: GrimTheme.fell(size: 12, color: GrimTheme.bone),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(_formatDate(widget.bookmark.createdAt),
                style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.mist)),
            ])),
            // Expand toggle
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_expanded ? '▲' : '▼',
                  style: GrimTheme.cinzel(size: 10, color: GrimTheme.dust)),
              ),
            ),
          ]),

          // Expanded note area
          if (_expanded) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: GrimTheme.gold.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(3),
                color: GrimTheme.shadow_.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: TextField(
                controller: _noteCtrl,
                style: GrimTheme.fell(size: 12, color: GrimTheme.bone),
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add a note...',
                  hintStyle: GrimTheme.fell(size: 12, italic: true, color: GrimTheme.mist),
                ),
                onChanged: widget.onNote,
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _ActionBtn(label: 'Jump to page', icon: '→', onTap: widget.onJump),
              const SizedBox(width: 8),
              _ActionBtn(label: 'Delete', icon: '✕', onTap: widget.onDelete,
                  color: GrimTheme.blood),
            ]),
          ],
        ]),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${d.day}.${d.month}.${d.year}';
  }
}

class _ActionBtn extends StatelessWidget {
  final String label, icon;
  final VoidCallback onTap;
  final Color? color;
  const _ActionBtn({required this.label, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: (color ?? GrimTheme.gold).withOpacity(0.25)),
        borderRadius: BorderRadius.circular(2),
        color: (color ?? GrimTheme.gold).withOpacity(0.06),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: GrimTheme.cinzel(size: 9, color: color ?? GrimTheme.gold)),
        const SizedBox(width: 5),
        Text(label, style: GrimTheme.cinzel(size: 8, spacing: 0.5, color: color ?? GrimTheme.dust)),
      ]),
    ),
  );
}

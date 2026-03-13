import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme.dart';

const List<String> _symbols = ['⛧', '✦', '❧', '⚜', '☽', '♱', '⁂'];

class BookSpine extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const BookSpine({
    super.key,
    required this.book,
    this.onTap,
    this.width = 46,
    this.height = 88,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = GrimTheme.bookColors[book.colorIndex % GrimTheme.bookColors.length];
    final darkColor = HSLColor.fromColor(baseColor).withLightness(
      (HSLColor.fromColor(baseColor).lightness * 0.6).clamp(0.0, 1.0)).toColor();
    final symbol = _symbols[book.colorIndex % _symbols.length];

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) => Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width, height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseColor, darkColor],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(2, 2)),
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(1, 0)),
              ],
            ),
            child: Stack(children: [
              // spine shadow on left edge
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
                ),
              ),
              // highlight on top edge
              Positioned(top: 0, left: 5, right: 0, child: Container(
                height: 2, color: Colors.white.withOpacity(0.08))),
              // content
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 4, 5),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(symbol, style: TextStyle(
                    fontSize: 10, color: GrimTheme.gold.withOpacity(0.7))),
                  Expanded(child: Center(child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(book.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GrimTheme.cinzel(size: 6, color: Colors.white.withOpacity(0.85))),
                  ))),
                  // progress indicator dot
                  if (book.progress > 0 && book.progress < 0.99)
                    Container(
                      width: 4, height: 4, decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: GrimTheme.gold)),
                ]),
              ),
              // gilded foil line detail
              Positioned(top: 14, bottom: 14, right: 0, child: Container(
                width: 1, color: GrimTheme.gold.withOpacity(0.15))),
            ]),
          ),
        ),
      ),
    );
  }
}

class AddTomeButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const AddTomeButton({super.key, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 46, height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: GrimTheme.gold.withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(5),
        color: GrimTheme.gold.withOpacity(0.03),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('✚', style: GrimTheme.cinzel(size: 18, color: GrimTheme.gold.withOpacity(0.35))),
        const SizedBox(height: 4),
        Text(label,
          textAlign: TextAlign.center,
          style: GrimTheme.cinzel(size: 6, spacing: 1, color: GrimTheme.dust)),
      ]),
    ),
  );
}

// ── Wooden shelf widget ───────────────────────────────────────
class WoodenShelf extends StatelessWidget {
  final List<Widget> books;

  const WoodenShelf({super.key, required this.books});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: [
      // shelf back & books
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1008), Color(0xFF0A0803)]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          border: Border.all(color: const Color(0xFF6444140).withOpacity(0.3)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: books.map((b) => Padding(
              padding: const EdgeInsets.only(right: 5),
              child: b,
            )).toList(),
          ),
        ),
      ),
      // plank
      Container(
        height: 14, margin: const EdgeInsets.symmetric(horizontal: -1),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF3D2810), Color(0xFF1F1205)]),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
          border: Border.all(color: const Color(0xFF644414).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(child: Container(
          height: 1, margin: const EdgeInsets.symmetric(horizontal: 12),
          color: GrimTheme.gold.withOpacity(0.12))),
      ),
    ]),
  );
}

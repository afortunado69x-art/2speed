import 'package:flutter/material.dart';
import '../theme.dart';

// ── Gothic divider with ornament ────────────────────────────
class GothicDivider extends StatelessWidget {
  final String label;
  const GothicDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
    child: Row(children: [
      Text(label, style: GrimTheme.cinzel(size: 8, spacing: 3, color: GrimTheme.tarnished)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            GrimTheme.gold.withOpacity(0.25), Colors.transparent])))),
    ]),
  );
}

// ── Gothic top bar ───────────────────────────────────────────
class GothicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  const GothicAppBar({super.key, required this.title, this.subtitle = '', this.actions, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.black,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
    child: Row(children: [
      if (leading != null) ...[leading!, const SizedBox(width: 12)],
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(title, style: GrimTheme.runeFont(size: 28)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: GrimTheme.cinzel(size: 9, spacing: 3, color: GrimTheme.dust)),
      ])),
      if (actions != null) ...actions!,
    ]),
  );
}

// ── Corner decoration ───────────────────────────────────────
class GothicCorners extends StatelessWidget {
  const GothicCorners({super.key});

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Stack(children: [
      _corner(0, 0, BorderSide.none, false),
      _corner(0, null, BorderSide.none, true),
      _corner(null, 0, BorderSide.none, false),
      _corner(null, null, BorderSide.none, true),
    ]),
  );

  Widget _corner(double? top, double? right, BorderSide none, bool flipX) =>
      Positioned(
        top: top, bottom: top == null ? 0 : null,
        left: flipX ? null : 0, right: flipX ? 0 : null,
        child: Transform.flip(
          flipX: flipX, flipY: top == null,
          child: SizedBox(width: 36, height: 36,
            child: CustomPaint(painter: _CornerPainter())),
        ),
      );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GrimTheme.gold.withOpacity(0.28)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(6, 6), const Offset(24, 6), paint);
    canvas.drawLine(const Offset(6, 6), const Offset(6, 24), paint);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ── Gothic nav bar ───────────────────────────────────────────
class GothicBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GothicNavItem> items;

  const GothicBottomNav({super.key, required this.currentIndex, required this.onTap, required this.items});

  @override
  Widget build(BuildContext context) => Container(
    color: GrimTheme.black,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(height: 1, color: GrimTheme.gold.withOpacity(0.1)),
      Row(children: List.generate(items.length, (i) {
        final active = i == currentIndex;
        return Expanded(child: GestureDetector(
          onTap: () => onTap(i),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(children: [
              if (active) Container(height: 1,
                decoration: BoxDecoration(gradient: LinearGradient(
                  colors: [Colors.transparent, GrimTheme.gold, Colors.transparent]))),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(items[i].icon, style: const TextStyle(fontSize: 17)),
              ),
              const SizedBox(height: 3),
              Text(items[i].label, style: GrimTheme.cinzel(size: 7, spacing: 1.5,
                color: active ? GrimTheme.gold : GrimTheme.mist)),
            ]),
          ),
        ));
      })),
      SizedBox(height: MediaQuery.of(context).padding.bottom),
    ]),
  );
}

class GothicNavItem {
  final String icon;
  final String label;
  const GothicNavItem({required this.icon, required this.label});
}

// ── Gothic toggle switch ─────────────────────────────────────
class GothicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GothicToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44, height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: value ? GrimTheme.blood.withOpacity(0.5) : GrimTheme.ash,
        border: Border.all(
          color: value ? GrimTheme.scarlet.withOpacity(0.4) : GrimTheme.gold.withOpacity(0.15)),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(3),
          width: 18, height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? GrimTheme.scarlet : GrimTheme.dust,
            boxShadow: value ? [BoxShadow(
              color: GrimTheme.scarlet.withOpacity(0.5), blurRadius: 8)] : [],
          ),
        ),
      ),
    ),
  );
}

// ── Setting row ──────────────────────────────────────────────
class SettingRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget trailing;

  const SettingRow({super.key, required this.title, this.subtitle, required this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GrimTheme.fell(size: 13)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: GrimTheme.fell(size: 10, italic: true, color: GrimTheme.mist)),
        ]
      ])),
      trailing,
    ]),
  );
}

// ── Format chip ──────────────────────────────────────────────
class FormatChip extends StatelessWidget {
  final String label;
  const FormatChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: GrimTheme.blood.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(2),
      color: GrimTheme.blood.withOpacity(0.08),
    ),
    child: Text(label, style: GrimTheme.cinzel(size: 8, spacing: 2, color: GrimTheme.crimson)),
  );
}

// ── Stat card ─────────────────────────────────────────────────
class StatStone extends StatelessWidget {
  final String symbol;
  final String value;
  final String unit;
  final String label;

  const StatStone({super.key, required this.symbol, required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF1A1008), Color(0xFF0F0A04)]),
      border: Border.all(color: GrimTheme.gold.withOpacity(0.12)),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(symbol, style: const TextStyle(fontSize: 14, color: GrimTheme.tarnished)),
      const SizedBox(height: 8),
      Text(value, style: GrimTheme.cinzel(size: 26, color: GrimTheme.gold)),
      Text(unit, style: GrimTheme.cinzel(size: 8, spacing: 2, color: GrimTheme.mist)),
      const SizedBox(height: 6),
      Text(label, style: GrimTheme.fell(size: 10, italic: true, color: GrimTheme.dust)),
    ]),
  );
}

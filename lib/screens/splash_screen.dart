import 'package:flutter/material.dart';
import '../theme.dart';

/// Animated gothic splash shown on first app launch
/// Fades in cross + title, then transitions to library
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _textCtrl;

  late Animation<double> _glowAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _glowAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut));
    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn));
    _textAnim  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _glowCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    // Fade out
    await _glowCtrl.reverse();
    _fadeCtrl.reverse();
    await Future.delayed(const Duration(milliseconds: 400));
    widget.onComplete();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrimTheme.black,
      body: Stack(children: [
        // ── Radial blood glow ────────────────────────
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 0.8,
                  colors: [
                    GrimTheme.blood.withOpacity(0.18 * _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Gold corner ornaments ────────────────────
        AnimatedBuilder(
          animation: _fadeAnim,
          builder: (_, child) => Opacity(opacity: _fadeAnim.value * 0.4, child: child),
          child: const _CornerFrame(),
        ),

        // ── Center content ───────────────────────────
        Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Cross icon
          AnimatedBuilder(
            animation: _fadeAnim,
            builder: (_, child) => Opacity(opacity: _fadeAnim.value, child: child),
            child: const _GothicCross(size: 120),
          ),

          const SizedBox(height: 32),

          // App name
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _textAnim,
              child: Column(children: [
                Text('GrimRead', style: GrimTheme.runeFont(size: 48)),
                const SizedBox(height: 8),
                Text('∴ Tome of Speed Reading ∴',
                    style: GrimTheme.cinzel(size: 10, spacing: 3, color: GrimTheme.dust)),
              ]),
            ),
          ),

          const SizedBox(height: 60),

          // Loading dots
          AnimatedBuilder(
            animation: _textAnim,
            builder: (_, __) => Opacity(
              opacity: _textAnim.value,
              child: const _LoadingDots(),
            ),
          ),
        ])),
      ]),
    );
  }
}

class _GothicCross extends StatelessWidget {
  final double size;
  const _GothicCross({required this.size});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size * 1.3,
    child: CustomPaint(painter: _CrossPainter()),
  );
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final glow  = Paint()
      ..style = PaintingStyle.stroke
      ..color = GrimTheme.crimson.withOpacity(0.3)
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final cw = size.width * 0.12;
    final ch = size.height * 0.55;
    final hw = size.width * 0.45;
    final hh = cw;
    final hy = cy - ch * 0.1;

    // Glow effect
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch), glow);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, hy), width: hw * 2, height: hh * 2), glow);

    // Cross body
    paint.color = GrimTheme.blood;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch),
      Radius.circular(cw / 2));
    canvas.drawRRect(rrect, paint);

    final hrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, hy), width: hw * 2, height: hh * 2),
      Radius.circular(hh));
    canvas.drawRRect(hrect, paint);

    // Gold diamond
    paint.color = GrimTheme.gold;
    final dc = cw * 0.8;
    final path = Path()
      ..moveTo(cx, hy - dc * 2)
      ..lineTo(cx + dc, hy)
      ..lineTo(cx, hy + dc * 2)
      ..lineTo(cx - dc, hy)
      ..close();
    canvas.drawPath(path, paint);

    // Gold top ornament dot
    paint.color = GrimTheme.gold.withOpacity(0.5);
    canvas.drawCircle(Offset(cx, cy - ch / 2 - 14), 4, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final t = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
        final pulse = (t < 0.5 ? t * 2 : (1 - t) * 2);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 5, height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GrimTheme.gold.withOpacity(0.15 + pulse * 0.6),
          ),
        );
      }),
    ),
  );
}

class _CornerFrame extends StatelessWidget {
  const _CornerFrame();

  @override
  Widget build(BuildContext context) {
    const len = 50.0;
    const thick = 2.0;
    final color = GrimTheme.gold.withOpacity(0.35);

    return Stack(children: [
      // TL
      Positioned(top: 32, left: 32, child: _Corner(color: color, len: len, thick: thick, flipX: false, flipY: false)),
      // TR
      Positioned(top: 32, right: 32, child: _Corner(color: color, len: len, thick: thick, flipX: true, flipY: false)),
      // BL
      Positioned(bottom: 48, left: 32, child: _Corner(color: color, len: len, thick: thick, flipX: false, flipY: true)),
      // BR
      Positioned(bottom: 48, right: 32, child: _Corner(color: color, len: len, thick: thick, flipX: true, flipY: true)),
    ]);
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final double len, thick;
  final bool flipX, flipY;
  const _Corner({required this.color, required this.len, required this.thick, required this.flipX, required this.flipY});

  @override
  Widget build(BuildContext context) => Transform.flip(
    flipX: flipX, flipY: flipY,
    child: SizedBox(width: len, height: len,
      child: CustomPaint(painter: _CornerLinePainter(color: color, thick: thick))),
  );
}

class _CornerLinePainter extends CustomPainter {
  final Color color;
  final double thick;
  const _CornerLinePainter({required this.color, required this.thick});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = color..strokeWidth = thick..strokeCap = StrokeCap.square;
    canvas.drawLine(const Offset(0, 0), Offset(s.width, 0), p);
    canvas.drawLine(const Offset(0, 0), Offset(0, s.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

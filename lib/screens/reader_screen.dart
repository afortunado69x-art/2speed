import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../services/reader_controller.dart';
import '../services/parser_service.dart';
import '../theme.dart';
import '../widgets/gothic_widgets.dart';
import '../l10n/app_localizations.dart';
import 'scroll_reader_screen.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with TickerProviderStateMixin {
  late final ReaderController _ctrl;
  late final AnimationController _wordAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _ctrl = ReaderController();
    _ctrl.addListener(() { if (mounted) setState(() {}); });
    _wordAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _ctrl.loadBook(widget.book);
    _ctrl.addListener(_onWordChange);
  }

  void _onWordChange() {
    _wordAnim.forward(from: 0);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _ctrl.removeListener(_onWordChange);
    _ctrl.dispose();
    _wordAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isPlaying = _ctrl.state == ReaderState.playing;

    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: Stack(children: [
        // Blood-red glow when playing
        if (isPlaying)
          Positioned.fill(child: IgnorePointer(child: AnimatedOpacity(
            opacity: 0.06, duration: const Duration(milliseconds: 600),
            child: Container(decoration: const BoxDecoration(
              gradient: RadialGradient(colors: [GrimTheme.crimson, Colors.transparent]))),
          ))),

        SafeArea(child: Column(children: [
          // ── Header ──────────────────────────────────────────
          Container(
            color: GrimTheme.black,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(children: [
                    Text('←', style: GrimTheme.cinzel(size: 16, color: GrimTheme.gold)),
                    const SizedBox(width: 8),
                    Text(l.returnToLib, style: GrimTheme.cinzel(size: 9, spacing: 2, color: GrimTheme.dust)),
                  ]),
                ),
                // ── Mode toggle: RSVP ↔ Scroll ──────────────
                GestureDetector(
                  onTap: () {
                    _ctrl.pause();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => ScrollReaderScreen(book: widget.book)));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: GrimTheme.gold.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(children: [
                      Text('📜', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Text('Scroll', style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.dust)),
                    ]),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(widget.book.title,
                style: GrimTheme.cinzel(size: 14, weight: FontWeight.w600)),
              if (widget.book.author.isNotEmpty)
                Text(widget.book.author,
                  style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist)),
            ]),
          ),

          // ── Chapter strip ────────────────────────────────────
          if (_ctrl.chapters.isNotEmpty)
            Container(
              height: 36,
              color: GrimTheme.gold.withOpacity(0.04),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _ctrl.chapters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final ch = _ctrl.chapters[i];
                  final active = _ctrl.currentChapter == ch;
                  return GestureDetector(
                    onTap: () => _ctrl.jumpToChapter(ch),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: active ? GrimTheme.gold.withOpacity(0.4) : GrimTheme.gold.withOpacity(0.12)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(ch.title.length > 12 ? ch.title.substring(0, 12) : ch.title,
                        style: GrimTheme.cinzel(size: 8, spacing: 1,
                          color: active ? GrimTheme.gold : GrimTheme.dust)),
                    ),
                  );
                },
              ),
            ),

          // ── Speed control ────────────────────────────────────
          Container(
            color: GrimTheme.gold.withOpacity(0.04),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              Text(l.pace, style: GrimTheme.cinzel(size: 8, spacing: 2, color: GrimTheme.dust)),
              const SizedBox(width: 12),
              Expanded(child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 1.5, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                child: Slider(
                  value: _ctrl.wpm.toDouble(),
                  min: 100, max: 1500, divisions: 28,
                  onChanged: (v) => _ctrl.setWpm(v.round()),
                ),
              )),
              const SizedBox(width: 8),
              Text('${_ctrl.wpm} ${l.wpm}',
                style: GrimTheme.cinzel(size: 13, color: GrimTheme.gold)),
            ]),
          ),
          Container(height: 1, color: GrimTheme.gold.withOpacity(0.08)),

          // ── RSVP Chamber ─────────────────────────────────────
          Expanded(child: _RSVPDisplay(ctrl: _ctrl, anim: _wordAnim)),

          // ── Controls ─────────────────────────────────────────
          _ControlBar(ctrl: _ctrl),
        ])),

        const GothicCorners(),
      ]),
    );
  }
}

// ── RSVP display widget ───────────────────────────────────────
class _RSVPDisplay extends StatelessWidget {
  final ReaderController ctrl;
  final AnimationController anim;

  const _RSVPDisplay({required this.ctrl, required this.anim});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final word = ctrl.currentWord;
    final orp  = ctrl.showOrp ? BookParserService.orp(word) : -1;

    return Container(
      color: GrimTheme.void_,
      child: Stack(children: [
        // ambient glow
        Center(child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              GrimTheme.blood.withOpacity(0.04), Colors.transparent])),
        )),

        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // ornament top
          Text('· · · ∴ · · ·', style: GrimTheme.cinzel(
            size: 10, spacing: 8, color: GrimTheme.gold.withOpacity(0.2))),
          const SizedBox(height: 12),

          // vertical guide line top
          Container(width: 1, height: 28,
            color: GrimTheme.blood.withOpacity(0.35)),

          // word frame
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: GrimTheme.gold.withOpacity(0.08)),
              color: Colors.black.withOpacity(0.25),
            ),
            child: AnimatedBuilder(
              animation: anim,
              builder: (_, child) => Opacity(
                opacity: (1 - anim.value * 0.4).clamp(0.0, 1.0),
                child: child),
              child: _WordText(word: word, orpIndex: orp),
            ),
          ),

          // vertical guide line bottom
          Container(width: 1, height: 28, color: GrimTheme.blood.withOpacity(0.35)),

          const SizedBox(height: 20),

          // progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: LinearProgressIndicator(
                  value: ctrl.progress,
                  minHeight: 2,
                  backgroundColor: GrimTheme.gold.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation(GrimTheme.crimson),
                ),
              ),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${l.wordOf} ${ctrl.currentIndex + 1} / ${ctrl.words.length}',
                  style: GrimTheme.cinzel(size: 9, spacing: 1, color: GrimTheme.mist)),
                Text('~${ctrl.remainingMinutes} ${l.remaining}',
                  style: GrimTheme.cinzel(size: 9, spacing: 1, color: GrimTheme.mist)),
              ]),
            ]),
          ),

          const SizedBox(height: 16),
          Text('· ⁂ ·', style: GrimTheme.cinzel(
            size: 10, spacing: 6, color: GrimTheme.gold.withOpacity(0.15))),
        ]),
      ]),
    );
  }
}

class _WordText extends StatelessWidget {
  final String word;
  final int orpIndex;

  const _WordText({required this.word, required this.orpIndex});

  @override
  Widget build(BuildContext context) {
    if (word.isEmpty) return const SizedBox.shrink();
    if (orpIndex < 0 || orpIndex >= word.length) {
      return Text(word, style: GrimTheme.fell(size: 44, color: GrimTheme.bone));
    }

    return RichText(
      text: TextSpan(
        style: GrimTheme.fell(size: 44, color: GrimTheme.bone),
        children: [
          TextSpan(text: word.substring(0, orpIndex)),
          TextSpan(text: word[orpIndex], style: TextStyle(
            color: GrimTheme.crimson,
            shadows: [Shadow(color: GrimTheme.crimson.withOpacity(0.7), blurRadius: 12)])),
          TextSpan(text: word.substring(orpIndex + 1)),
        ],
      ),
    );
  }
}

// ── Control bar ───────────────────────────────────────────────
class _ControlBar extends StatelessWidget {
  final ReaderController ctrl;
  const _ControlBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isPlaying = ctrl.state == ReaderState.playing;

    return Container(
      color: GrimTheme.black,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Ctrl(icon: '⏮', onTap: ctrl.skipBackward),
        const SizedBox(width: 10),
        _Ctrl(icon: '◀', onTap: ctrl.stepBackward),
        const SizedBox(width: 10),
        _PlayBtn(isPlaying: isPlaying, onTap: ctrl.togglePlay),
        const SizedBox(width: 10),
        _Ctrl(icon: '▶', onTap: ctrl.stepForward),
        const SizedBox(width: 10),
        _Ctrl(icon: '⏭', onTap: ctrl.skipForward),
      ]),
    );
  }
}

class _Ctrl extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  const _Ctrl({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GrimTheme.gold.withOpacity(0.05),
        border: Border.all(color: GrimTheme.gold.withOpacity(0.15)),
      ),
      child: Center(child: Text(icon, style: GrimTheme.cinzel(size: 13, color: GrimTheme.dust))),
    ),
  );
}

class _PlayBtn extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayBtn({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 54, height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [GrimTheme.blood, Color(0xFF5A0A0A)]),
        border: Border.all(color: GrimTheme.scarlet.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GrimTheme.blood.withOpacity(isPlaying ? 0.6 : 0.3),
            blurRadius: isPlaying ? 24 : 12),
        ],
      ),
      child: Center(child: Text(isPlaying ? '⏸' : '▶',
        style: TextStyle(fontSize: 20, color: GrimTheme.bone))),
    ),
  );
}

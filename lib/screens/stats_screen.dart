import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme.dart';
import '../widgets/gothic_widgets.dart';
import '../l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await DatabaseService().getStats();
    if (mounted) setState(() { _stats = s; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: Stack(children: [
        Column(children: [
          GothicAppBar(title: 'Annals', subtitle: l.chroniclesOfReading),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: GrimTheme.gold)))
          else
            Expanded(child: SingleChildScrollView(child: Column(children: [
              // Stat stones grid
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GridView.count(
                  crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8,
                  childAspectRatio: 1.4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatStone(symbol: '⚡', value: '${_stats['avgWpm'] ?? 0}', unit: l.wpm, label: l.average),
                    StatStone(symbol: '📜', value: _formatCount(_stats['totalWords'] ?? 0), unit: l.wordsRead, label: l.wordsRead),
                    StatStone(symbol: '📚', value: '${_stats['totalBooks'] ?? 0}', unit: l.tomes, label: l.completed),
                    StatStone(symbol: '☽', value: '${_stats['streak'] ?? 0}', unit: '', label: l.dayVigil),
                  ],
                ),
              ),

              GothicDivider(label: l.recentSessions),

              // Session history
              ...(_stats['sessions'] as List? ?? []).take(15).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
                  child: Row(children: [
                    Container(
                      width: 36, height: 48,
                      decoration: BoxDecoration(
                        color: GrimTheme.shadow_,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                      ),
                      child: const Center(child: Text('📖', style: TextStyle(fontSize: 16))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.bookId, style: GrimTheme.fell(size: 12)),
                      const SizedBox(height: 3),
                      Text(
                        '${_formatDate(s.startedAt)} · ${(s.durationSeconds / 60).ceil()} min',
                        style: GrimTheme.cinzel(size: 8, spacing: 1, color: GrimTheme.mist)),
                    ])),
                    Text('${s.averageWpm}', style: GrimTheme.cinzel(size: 14, color: GrimTheme.gold)),
                  ]),
                );
              }),

              if ((_stats['sessions'] as List? ?? []).isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    Text('☽', style: TextStyle(fontSize: 36, color: GrimTheme.mist.withOpacity(0.4))),
                    const SizedBox(height: 12),
                    Text('No sessions yet', style: GrimTheme.fell(size: 13, italic: true, color: GrimTheme.dust)),
                    Text('Begin reading to see your chronicles', style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.mist)),
                  ]),
                ),

              const SizedBox(height: 24),
            ]))),
        ]),
        const GothicCorners(),
      ]),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

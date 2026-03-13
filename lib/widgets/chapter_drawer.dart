import 'package:flutter/material.dart';
import '../services/parser_service.dart';
import '../theme.dart';

class ChapterDrawer extends StatelessWidget {
  final List<Chapter> chapters;
  final Chapter? currentChapter;
  final ValueChanged<Chapter> onSelect;

  const ChapterDrawer({
    super.key,
    required this.chapters,
    this.currentChapter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      color: GrimTheme.deep,
      child: Column(children: [
        // Header
        Container(
          color: GrimTheme.black,
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 14),
          child: Row(children: [
            Text('❧', style: TextStyle(fontSize: 18, color: GrimTheme.tarnished)),
            const SizedBox(width: 10),
            Expanded(child: Text('Contents',
              style: GrimTheme.cinzel(size: 14, color: GrimTheme.bone))),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text('✕', style: GrimTheme.cinzel(size: 14, color: GrimTheme.dust)),
            ),
          ]),
        ),
        Container(height: 1, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent, GrimTheme.gold.withOpacity(0.35),
            GrimTheme.blood.withOpacity(0.25), Colors.transparent]))),

        Expanded(child: chapters.isEmpty
            ? Center(child: Text('No chapters detected',
                style: GrimTheme.fell(size: 13, italic: true, color: GrimTheme.dust)))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: chapters.length,
                separatorBuilder: (_, __) =>
                    Container(height: 1, color: GrimTheme.gold.withOpacity(0.05)),
                itemBuilder: (_, i) {
                  final ch = chapters[i];
                  final active = ch == currentChapter;
                  return GestureDetector(
                    onTap: () {
                      onSelect(ch);
                      Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      color: active
                          ? GrimTheme.blood.withOpacity(0.12)
                          : Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      child: Row(children: [
                        // Chapter number indicator
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: active
                                  ? GrimTheme.gold.withOpacity(0.5)
                                  : GrimTheme.gold.withOpacity(0.12)),
                            color: active
                                ? GrimTheme.blood.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: Center(child: Text('${i + 1}',
                            style: GrimTheme.cinzel(size: 9,
                              color: active ? GrimTheme.gold : GrimTheme.mist))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Text(ch.title,
                          style: GrimTheme.fell(size: 13,
                            color: active ? GrimTheme.bone : GrimTheme.pale))),
                        if (active)
                          Text('◀', style: GrimTheme.cinzel(
                            size: 9, color: GrimTheme.gold.withOpacity(0.5))),
                      ]),
                    ),
                  );
                },
              )),
      ]),
    );
  }
}

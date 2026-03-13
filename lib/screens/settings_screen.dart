import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../widgets/gothic_widgets.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  const SettingsScreen({super.key, required this.onLocaleChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rsvp = true;
  bool _orp = true;
  bool _punct = true;
  bool _scroll = false;
  double _fontSize = 44;
  String _lang = 'ru';

  static const _langs = [
    ('🇷🇺', 'RU', 'ru'), ('🇬🇧', 'EN', 'en'), ('🇩🇪', 'DE', 'de'), ('🇪🇸', 'ES', 'es'),
    ('🇵🇹', 'PT', 'pt'), ('🇮🇹', 'IT', 'it'), ('🇫🇷', 'FR', 'fr'), ('🇺🇦', 'UA', 'uk'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _rsvp     = p.getBool('rsvp') ?? true;
      _orp      = p.getBool('orp') ?? true;
      _punct    = p.getBool('punct') ?? true;
      _scroll   = p.getBool('scroll') ?? false;
      _fontSize = p.getDouble('fontSize') ?? 44;
      _lang     = p.getString('lang') ?? 'ru';
    });
  }

  Future<void> _save(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is double) await p.setDouble(key, value);
    if (value is String) await p.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: Stack(children: [
        Column(children: [
          GothicAppBar(title: 'Rites', subtitle: l.configureGrimoire),
          Expanded(child: SingleChildScrollView(child: Column(children: [

            // Language
            GothicDivider(label: l.tongue),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GridView.count(
                crossAxisCount: 4, crossAxisSpacing: 6, mainAxisSpacing: 6,
                childAspectRatio: 1.2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                children: _langs.map((lang) {
                  final active = _lang == lang.$3;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _lang = lang.$3);
                      _save('lang', lang.$3);
                      widget.onLocaleChanged(Locale(lang.$3));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: active ? GrimTheme.gold : GrimTheme.gold.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(3),
                        color: active ? GrimTheme.gold.withOpacity(0.07) : Colors.transparent,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(lang.$1, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(lang.$2, style: GrimTheme.cinzel(size: 9, spacing: 0.5,
                          color: active ? GrimTheme.gold : GrimTheme.dust)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Reading rituals
            GothicDivider(label: l.readingRituals),
            SettingRow(title: l.rsvpMode, subtitle: l.rsvpSub,
              trailing: GothicToggle(value: _rsvp, onChanged: (v) { setState(() => _rsvp = v); _save('rsvp', v); })),
            SettingRow(title: l.orpFocus, subtitle: l.orpSub,
              trailing: GothicToggle(value: _orp, onChanged: (v) { setState(() => _orp = v); _save('orp', v); })),
            SettingRow(title: l.punctPause, subtitle: l.punctSub,
              trailing: GothicToggle(value: _punct, onChanged: (v) { setState(() => _punct = v); _save('punct', v); })),
            SettingRow(title: 'Chapter Scroll', subtitle: 'Traditional parchment view',
              trailing: GothicToggle(value: _scroll, onChanged: (v) { setState(() => _scroll = v); _save('scroll', v); })),

            // Appearance
            GothicDivider(label: l.appearance),
            SettingRow(title: l.darkTheme, trailing: GothicToggle(value: true, onChanged: (_) {})),
            SettingRow(
              title: l.glyphSize, subtitle: l.glyphSub,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${_fontSize.round()}px',
                  style: GrimTheme.cinzel(size: 12, color: GrimTheme.gold)),
                const SizedBox(width: 8),
                SizedBox(width: 80, child: Slider(
                  value: _fontSize, min: 24, max: 64, divisions: 8,
                  onChanged: (v) { setState(() => _fontSize = v); _save('fontSize', v); },
                )),
              ]),
            ),

            // About
            GothicDivider(label: l.about),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Text('☩', style: TextStyle(
                  fontSize: 32, color: GrimTheme.blood.withOpacity(0.7),
                  shadows: [Shadow(color: GrimTheme.blood.withOpacity(0.5), blurRadius: 12)])),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('GrimRead', style: GrimTheme.cinzelDeco(size: 16, color: GrimTheme.gold)),
                  Text(l.allSoulsEdition,
                    style: GrimTheme.fell(size: 11, italic: true, color: GrimTheme.dust)),
                  Text('Version 1.0.0', style: GrimTheme.cinzel(size: 9, spacing: 1, color: GrimTheme.mist)),
                ]),
              ]),
            ),
            const SizedBox(height: 24),
          ]))),
        ]),
        const GothicCorners(),
      ]),
    );
  }
}

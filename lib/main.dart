import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
import 'widgets/gothic_widgets.dart';
import 'screens/library_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: GrimTheme.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const GrimReadApp());
}

class GrimReadApp extends StatefulWidget {
  const GrimReadApp({super.key});
  @override
  State<GrimReadApp> createState() => _GrimReadAppState();
}

class _GrimReadAppState extends State<GrimReadApp> {
  Locale _locale = const Locale('ru');
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('splash_seen') ?? false;
    if (seen) setState(() => _showSplash = false);
  }

  Future<void> _onSplashDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('splash_seen', true);
    if (mounted) setState(() => _showSplash = false);
  }

  void _setLocale(Locale l) => setState(() => _locale = l);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GrimRead',
      debugShowCheckedModeBanner: false,
      theme: GrimTheme.theme,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _showSplash
          ? SplashScreen(onComplete: _onSplashDone)
          : GrimShell(onLocaleChanged: _setLocale),
    );
  }
}

// ── Main shell with bottom nav ────────────────────────────────
class GrimShell extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  const GrimShell({super.key, required this.onLocaleChanged});

  @override
  State<GrimShell> createState() => _GrimShellState();
}

class _GrimShellState extends State<GrimShell> {
  int _tab = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const LibraryScreen(),
      const StatsScreen(),
      SettingsScreen(onLocaleChanged: widget.onLocaleChanged),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: GrimTheme.void_,
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: GothicBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: [
          GothicNavItem(icon: '📚', label: l.library),
          GothicNavItem(icon: '☽', label: l.annals),
          GothicNavItem(icon: '⚙', label: l.rites),
        ],
      ),
    );
  }
}

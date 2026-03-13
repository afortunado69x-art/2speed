import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('ru'), Locale('en'), Locale('de'),
    Locale('es'), Locale('pt'), Locale('it'),
    Locale('fr'), Locale('uk'),
  ];

  String get(String key) => _strings[locale.languageCode]?[key] ?? _strings['en']![key] ?? key;

  // Convenience getters
  String get appName        => get('appName');
  String get library        => get('library');
  String get read           => get('read');
  String get annals         => get('annals');
  String get rites          => get('rites');
  String get recentlyOpened => get('recentlyOpened');
  String get sacredTexts    => get('sacredTexts');
  String get acceptedScrolls=> get('acceptedScrolls');
  String get addTome        => get('addTome');
  String get pace           => get('pace');
  String get wpm            => get('wpm');
  String get wordOf         => get('wordOf');
  String get remaining      => get('remaining');
  String get minutes        => get('minutes');
  String get returnToLib    => get('returnToLib');
  String get chroniclesOfReading => get('chroniclesOfReading');
  String get avgSpeed       => get('avgSpeed');
  String get wordsRead      => get('wordsRead');
  String get tomes          => get('tomes');
  String get dayVigil       => get('dayVigil');
  String get recentSessions => get('recentSessions');
  String get configureGrimoire => get('configureGrimoire');
  String get tongue         => get('tongue');
  String get readingRituals => get('readingRituals');
  String get rsvpMode       => get('rsvpMode');
  String get rsvpSub        => get('rsvpSub');
  String get orpFocus       => get('orpFocus');
  String get orpSub         => get('orpSub');
  String get punctPause     => get('punctPause');
  String get punctSub       => get('punctSub');
  String get appearance     => get('appearance');
  String get darkTheme      => get('darkTheme');
  String get glyphSize      => get('glyphSize');
  String get glyphSub       => get('glyphSub');
  String get about          => get('about');
  String get allSoulsEdition=> get('allSoulsEdition');
  String get completed      => get('completed');
  String get average        => get('average');
  String get streak         => get('streak');

  static const Map<String, Map<String, String>> _strings = {
    'ru': {
      'appName': 'GrimRead', 'library': 'Тома', 'read': 'Читать',
      'annals': 'Анналы', 'rites': 'Обряды',
      'recentlyOpened': '∴ Недавно открытые ∴', 'sacredTexts': '∴ Избранные ∴',
      'acceptedScrolls': '∴ Форматы свитков ∴', 'addTome': 'Добавить\nтом',
      'pace': 'Темп', 'wpm': 'сл/мин', 'wordOf': 'Слово', 'remaining': 'мин осталось',
      'minutes': 'мин', 'returnToLib': 'Вернуться в библиотеку',
      'chroniclesOfReading': '∴ Хроники чтения ∴',
      'avgSpeed': 'Скорость', 'wordsRead': 'Слов прочитано',
      'tomes': 'Томов', 'dayVigil': 'Дней подряд',
      'recentSessions': '∴ Последние сессии ∴',
      'configureGrimoire': '∴ Настройте гримуар ∴',
      'tongue': '∴ Язык заклинаний ∴', 'readingRituals': '∴ Ритуалы чтения ∴',
      'rsvpMode': 'Режим RSVP', 'rsvpSub': 'Слово за словом',
      'orpFocus': 'Маркер ORP', 'orpSub': 'Красная точка фокуса',
      'punctPause': 'Пауза на знаках', 'punctSub': 'Замедление на запятых и точках',
      'appearance': '∴ Внешний вид ∴', 'darkTheme': 'Тёмная тема',
      'glyphSize': 'Размер глифа', 'glyphSub': 'Размер слова в режиме RSVP',
      'about': '∴ О гримуаре ∴', 'allSoulsEdition': 'Издание Всех Душ',
      'completed': 'Завершено', 'average': 'Среднее', 'streak': 'серия',
    },
    'en': {
      'appName': 'GrimRead', 'library': 'Tomes', 'read': 'Read',
      'annals': 'Annals', 'rites': 'Rites',
      'recentlyOpened': '∴ Recently Opened ∴', 'sacredTexts': '∴ Sacred Texts ∴',
      'acceptedScrolls': '∴ Accepted Scrolls ∴', 'addTome': 'Add\nTome',
      'pace': 'Pace', 'wpm': 'w/min', 'wordOf': 'Word', 'remaining': 'min remaining',
      'minutes': 'min', 'returnToLib': 'Return to Library',
      'chroniclesOfReading': '∴ Chronicles of Reading ∴',
      'avgSpeed': 'Avg Speed', 'wordsRead': 'Words Read',
      'tomes': 'Tomes', 'dayVigil': 'Day Vigil',
      'recentSessions': '∴ Recent Sessions ∴',
      'configureGrimoire': '∴ Configure Your Grimoire ∴',
      'tongue': '∴ Tongue of Incantation ∴', 'readingRituals': '∴ Reading Rituals ∴',
      'rsvpMode': 'RSVP Mode', 'rsvpSub': 'Word-by-word conjuration',
      'orpFocus': 'ORP Focus Mark', 'orpSub': 'Crimson recognition point',
      'punctPause': 'Punctuation Pause', 'punctSub': 'Breathe at sigils',
      'appearance': '∴ Appearance ∴', 'darkTheme': 'Dark Sanctum Theme',
      'glyphSize': 'Glyph Size', 'glyphSub': 'Size of incanted word',
      'about': '∴ About the Grimoire ∴', 'allSoulsEdition': 'All Souls Edition',
      'completed': 'Completed', 'average': 'Average', 'streak': 'streak',
    },
    'de': {
      'appName': 'GrimRead', 'library': 'Bände', 'read': 'Lesen',
      'annals': 'Annalen', 'rites': 'Riten',
      'recentlyOpened': '∴ Zuletzt Geöffnet ∴', 'sacredTexts': '∴ Heilige Texte ∴',
      'acceptedScrolls': '∴ Dateiformate ∴', 'addTome': 'Band\nhinzufügen',
      'pace': 'Tempo', 'wpm': 'W/Min', 'wordOf': 'Wort', 'remaining': 'Min verbleibend',
      'minutes': 'Min', 'returnToLib': 'Zurück zur Bibliothek',
      'chroniclesOfReading': '∴ Lese-Chroniken ∴',
      'avgSpeed': 'Ø Geschw.', 'wordsRead': 'Wörter gelesen',
      'tomes': 'Bände', 'dayVigil': 'Tage Streak',
      'recentSessions': '∴ Letzte Sitzungen ∴',
      'configureGrimoire': '∴ Grimoire Konfigurieren ∴',
      'tongue': '∴ Beschwörungssprache ∴', 'readingRituals': '∴ Leserituale ∴',
      'rsvpMode': 'RSVP-Modus', 'rsvpSub': 'Wort für Wort',
      'orpFocus': 'ORP-Fokus', 'orpSub': 'Roter Erkennungspunkt',
      'punctPause': 'Satzzeichenpause', 'punctSub': 'Verlangsamung bei Satzzeichen',
      'appearance': '∴ Erscheinungsbild ∴', 'darkTheme': 'Dunkles Thema',
      'glyphSize': 'Glyphengröße', 'glyphSub': 'Wortgröße im RSVP-Modus',
      'about': '∴ Über das Grimoire ∴', 'allSoulsEdition': 'Allerseelen-Edition',
      'completed': 'Abgeschlossen', 'average': 'Durchschnitt', 'streak': 'Serie',
    },
    'es': {
      'appName': 'GrimRead', 'library': 'Tomos', 'read': 'Leer',
      'annals': 'Anales', 'rites': 'Ritos',
      'recentlyOpened': '∴ Abiertos Recientemente ∴', 'sacredTexts': '∴ Textos Sagrados ∴',
      'acceptedScrolls': '∴ Formatos Aceptados ∴', 'addTome': 'Añadir\ntomo',
      'pace': 'Ritmo', 'wpm': 'p/min', 'wordOf': 'Palabra', 'remaining': 'min restantes',
      'minutes': 'min', 'returnToLib': 'Volver a la Biblioteca',
      'chroniclesOfReading': '∴ Crónicas de Lectura ∴',
      'avgSpeed': 'Velocidad media', 'wordsRead': 'Palabras leídas',
      'tomes': 'Tomos', 'dayVigil': 'Días seguidos',
      'recentSessions': '∴ Sesiones Recientes ∴',
      'configureGrimoire': '∴ Configurar el Grimorio ∴',
      'tongue': '∴ Lengua de Encantamiento ∴', 'readingRituals': '∴ Rituales de Lectura ∴',
      'rsvpMode': 'Modo RSVP', 'rsvpSub': 'Palabra por palabra',
      'orpFocus': 'Marca ORP', 'orpSub': 'Punto de reconocimiento carmesí',
      'punctPause': 'Pausa en puntuación', 'punctSub': 'Descanso en signos',
      'appearance': '∴ Apariencia ∴', 'darkTheme': 'Tema oscuro',
      'glyphSize': 'Tamaño de glifo', 'glyphSub': 'Tamaño de palabra en RSVP',
      'about': '∴ Acerca del Grimorio ∴', 'allSoulsEdition': 'Edición Todos los Santos',
      'completed': 'Completados', 'average': 'Promedio', 'streak': 'racha',
    },
    'pt': {
      'appName': 'GrimRead', 'library': 'Tomos', 'read': 'Ler',
      'annals': 'Anais', 'rites': 'Ritos',
      'recentlyOpened': '∴ Abertos Recentemente ∴', 'sacredTexts': '∴ Textos Sagrados ∴',
      'acceptedScrolls': '∴ Formatos Aceites ∴', 'addTome': 'Adicionar\ntomo',
      'pace': 'Ritmo', 'wpm': 'p/min', 'wordOf': 'Palavra', 'remaining': 'min restantes',
      'minutes': 'min', 'returnToLib': 'Voltar à Biblioteca',
      'chroniclesOfReading': '∴ Crónicas de Leitura ∴',
      'avgSpeed': 'Velocidade média', 'wordsRead': 'Palavras lidas',
      'tomes': 'Tomos', 'dayVigil': 'Dias seguidos',
      'recentSessions': '∴ Sessões Recentes ∴',
      'configureGrimoire': '∴ Configurar o Grimório ∴',
      'tongue': '∴ Língua de Encantamento ∴', 'readingRituals': '∴ Rituais de Leitura ∴',
      'rsvpMode': 'Modo RSVP', 'rsvpSub': 'Palavra por palavra',
      'orpFocus': 'Marca ORP', 'orpSub': 'Ponto de reconhecimento carmesim',
      'punctPause': 'Pausa em pontuação', 'punctSub': 'Pausa em vírgulas e pontos',
      'appearance': '∴ Aparência ∴', 'darkTheme': 'Tema escuro',
      'glyphSize': 'Tamanho do glifo', 'glyphSub': 'Tamanho da palavra em RSVP',
      'about': '∴ Sobre o Grimório ∴', 'allSoulsEdition': 'Edição Todos os Santos',
      'completed': 'Concluídos', 'average': 'Média', 'streak': 'sequência',
    },
    'it': {
      'appName': 'GrimRead', 'library': 'Tomi', 'read': 'Leggi',
      'annals': 'Annali', 'rites': 'Riti',
      'recentlyOpened': '∴ Aperti di Recente ∴', 'sacredTexts': '∴ Testi Sacri ∴',
      'acceptedScrolls': '∴ Formati Accettati ∴', 'addTome': 'Aggiungi\ntomo',
      'pace': 'Ritmo', 'wpm': 'p/min', 'wordOf': 'Parola', 'remaining': 'min rimanenti',
      'minutes': 'min', 'returnToLib': 'Torna alla Biblioteca',
      'chroniclesOfReading': '∴ Cronache di Lettura ∴',
      'avgSpeed': 'Velocità media', 'wordsRead': 'Parole lette',
      'tomes': 'Tomi', 'dayVigil': 'Giorni consecutivi',
      'recentSessions': '∴ Sessioni Recenti ∴',
      'configureGrimoire': '∴ Configura il Grimorio ∴',
      'tongue': '∴ Lingua dell\'Incantesimo ∴', 'readingRituals': '∴ Rituali di Lettura ∴',
      'rsvpMode': 'Modalità RSVP', 'rsvpSub': 'Parola per parola',
      'orpFocus': 'Segno ORP', 'orpSub': 'Punto di riconoscimento cremisi',
      'punctPause': 'Pausa alla punteggiatura', 'punctSub': 'Pausa a virgole e punti',
      'appearance': '∴ Aspetto ∴', 'darkTheme': 'Tema scuro',
      'glyphSize': 'Dimensione glifo', 'glyphSub': 'Dimensione parola in RSVP',
      'about': '∴ Informazioni sul Grimorio ∴', 'allSoulsEdition': 'Edizione Ognissanti',
      'completed': 'Completati', 'average': 'Media', 'streak': 'serie',
    },
    'fr': {
      'appName': 'GrimRead', 'library': 'Tomes', 'read': 'Lire',
      'annals': 'Annales', 'rites': 'Rites',
      'recentlyOpened': '∴ Ouverts Récemment ∴', 'sacredTexts': '∴ Textes Sacrés ∴',
      'acceptedScrolls': '∴ Formats Acceptés ∴', 'addTome': 'Ajouter\nun tome',
      'pace': 'Cadence', 'wpm': 'm/min', 'wordOf': 'Mot', 'remaining': 'min restantes',
      'minutes': 'min', 'returnToLib': 'Retour à la Bibliothèque',
      'chroniclesOfReading': '∴ Chroniques de Lecture ∴',
      'avgSpeed': 'Vitesse moy.', 'wordsRead': 'Mots lus',
      'tomes': 'Tomes', 'dayVigil': 'Jours consécutifs',
      'recentSessions': '∴ Sessions Récentes ∴',
      'configureGrimoire': '∴ Configurer le Grimoire ∴',
      'tongue': '∴ Langue d\'Incantation ∴', 'readingRituals': '∴ Rituels de Lecture ∴',
      'rsvpMode': 'Mode RSVP', 'rsvpSub': 'Mot par mot',
      'orpFocus': 'Marqueur ORP', 'orpSub': 'Point de reconnaissance cramoisi',
      'punctPause': 'Pause à la ponctuation', 'punctSub': 'Ralentissement aux virgules',
      'appearance': '∴ Apparence ∴', 'darkTheme': 'Thème sombre',
      'glyphSize': 'Taille du glyphe', 'glyphSub': 'Taille du mot en mode RSVP',
      'about': '∴ À Propos du Grimoire ∴', 'allSoulsEdition': 'Édition Toussaint',
      'completed': 'Complétés', 'average': 'Moyenne', 'streak': 'série',
    },
    'uk': {
      'appName': 'GrimRead', 'library': 'Томи', 'read': 'Читати',
      'annals': 'Аннали', 'rites': 'Обряди',
      'recentlyOpened': '∴ Нещодавно відкриті ∴', 'sacredTexts': '∴ Вибране ∴',
      'acceptedScrolls': '∴ Формати свитків ∴', 'addTome': 'Додати\nтом',
      'pace': 'Темп', 'wpm': 'сл/хв', 'wordOf': 'Слово', 'remaining': 'хв залишилось',
      'minutes': 'хв', 'returnToLib': 'Повернутися до бібліотеки',
      'chroniclesOfReading': '∴ Хроніки читання ∴',
      'avgSpeed': 'Швидкість', 'wordsRead': 'Слів прочитано',
      'tomes': 'Томів', 'dayVigil': 'Днів поспіль',
      'recentSessions': '∴ Останні сесії ∴',
      'configureGrimoire': '∴ Налаштуйте грімуар ∴',
      'tongue': '∴ Мова заклять ∴', 'readingRituals': '∴ Ритуали читання ∴',
      'rsvpMode': 'Режим RSVP', 'rsvpSub': 'Слово за словом',
      'orpFocus': 'Маркер ORP', 'orpSub': 'Червона точка фокусу',
      'punctPause': 'Пауза на знаках', 'punctSub': 'Сповільнення на комах і крапках',
      'appearance': '∴ Зовнішній вигляд ∴', 'darkTheme': 'Темна тема',
      'glyphSize': 'Розмір гліфа', 'glyphSub': 'Розмір слова у режимі RSVP',
      'about': '∴ Про грімуар ∴', 'allSoulsEdition': 'Видання Всіх Душ',
      'completed': 'Завершено', 'average': 'Середнє', 'streak': 'серія',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

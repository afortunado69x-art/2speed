# GrimRead — Gothic Speed Reader App

> **Flutter source code** · Android & iOS · CodeCanyon Item

A premium gothic-themed RSVP speed reading application with a medieval library interface. Inspired by classic speed-reader programs (Reader 32, Spreeder), redesigned with a dark, atmospheric aesthetic for modern mobile platforms.

---

## Screenshots

| Library | Reader (RSVP) | Statistics | Settings |
|---------|--------------|------------|----------|
| Gothic bookshelf with wooden planks | Word-by-word with ORP focus | Illuminated stat stones | 8-language selector |

---

## Features

### Core Reading Engine
- **RSVP Mode** — Rapid Serial Visual Presentation: one word at a time, 50–1500 words/minute
- **ORP Focus Mark** — Optimal Recognition Point: highlights the focal letter in crimson so your eye locks instantly
- **Smart punctuation pauses** — automatically slows at `.` `,` `;` `:` `?` `!` for natural comprehension
- **Long-word delay** — extra pause on words longer than 10 characters
- **Chapter navigation** — jump between detected chapters instantly
- **Bookmarks & progress** — auto-saves position on exit

### Gothic Library
- **Wooden bookshelf UI** — 3D book spines with gilded details, oak planks, candlelight glow
- **7 book colour themes** — crimson, navy, forest, plum, tarnished gold, slate, brown leather
- **Animated entrance** — books float up as they load
- **Favorite shelves** — curate your sacred texts separately

### File Format Support
| Format | Parser |
|--------|--------|
| TXT    | Native Dart |
| FB2    | XML parser (full metadata + chapters) |
| HTML   | Tag stripper |
| EPUB   | epub_view package |
| PDF    | syncfusion_flutter_pdf |
| DOCX   | Archive + XML extraction |
| RTF    | Control-word stripper |
| MOBI   | Native bridge (placeholder ready) |

### Statistics & Analytics
- Words per minute tracking per session
- Daily reading streak (consecutive days)
- Total words consumed lifetime
- Completed books count
- Full session history with duration & WPM

### 8 Languages (Full i18n)
| Code | Language |
|------|----------|
| ru   | Русский |
| en   | English |
| de   | Deutsch |
| es   | Español |
| pt   | Português |
| it   | Italiano |
| fr   | Français |
| uk   | Українська |

All UI strings translated. Language switches instantly without restart.

---

## Technical Stack

```
Flutter 3.10+  (Dart 3.0+)
Architecture:  Clean Architecture · MVVM pattern
State:         ChangeNotifier + ValueNotifier
Database:      SQLite via sqflite
Navigation:    Navigator 2.0 compatible
Fonts:         Cinzel Decorative · Cinzel · IM Fell English · UnifrakturMaguntia
```

### Package Dependencies
| Package | Purpose |
|---------|---------|
| `sqflite` | Local database for books & sessions |
| `file_picker` | Cross-platform file import |
| `epub_view` | EPUB parsing & rendering |
| `syncfusion_flutter_pdf` | PDF text extraction |
| `shared_preferences` | Settings persistence |
| `google_fonts` | Runtime font loading fallback |
| `permission_handler` | Storage permissions |
| `path_provider` | Platform file paths |

---

## Project Structure

```
lib/
├── main.dart                 # App entry, shell navigation
├── theme.dart                # Gothic color palette & typography
├── models/
│   └── book.dart             # Book & ReadingSession models
├── services/
│   ├── database_service.dart # SQLite CRUD operations
│   ├── parser_service.dart   # Multi-format text extraction
│   └── reader_controller.dart# RSVP engine (ChangeNotifier)
├── screens/
│   ├── library_screen.dart   # Bookshelf UI
│   ├── reader_screen.dart    # RSVP reader UI
│   ├── stats_screen.dart     # Analytics UI
│   └── settings_screen.dart  # Preferences UI
├── widgets/
│   ├── gothic_widgets.dart   # Shared gothic components
│   └── book_widget.dart      # Book spine & shelf widgets
└── l10n/
    └── app_localizations.dart# All 8 language strings
```

---

## Installation & Setup

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode

### Steps

```bash
# 1. Clone / extract the project
cd grimread

# 2. Install dependencies
flutter pub get

# 3. Download Gothic fonts (free, OFL license)
#    Place in assets/fonts/:
#    - CinzelDecorative-Regular.ttf    (fonts.google.com/specimen/Cinzel+Decorative)
#    - CinzelDecorative-Bold.ttf
#    - CinzelDecorative-Black.ttf
#    - Cinzel-Regular.ttf              (fonts.google.com/specimen/Cinzel)
#    - Cinzel-SemiBold.ttf
#    - Cinzel-Bold.ttf
#    - IMFellEnglish-Regular.ttf       (fonts.google.com/specimen/IM+Fell+English)
#    - IMFellEnglish-Italic.ttf
#    - UnifrakturMaguntia-Book.ttf     (fonts.google.com/specimen/UnifrakturMaguntia)

# 4. Run on Android
flutter run --release

# 5. Run on iOS
cd ios && pod install && cd ..
flutter run --release
```

### Syncfusion PDF License
For PDF support, register a free community license at:
https://www.syncfusion.com/products/communitylicense

Add to `main.dart` before `runApp()`:
```dart
SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY');
```

---

## Customization Guide

### Change color theme
Edit `lib/theme.dart` — all colors defined as `static const Color` at the top.

### Add a new language
1. Open `lib/l10n/app_localizations.dart`
2. Add your locale to `supportedLocales`
3. Add a new entry to `_strings` map with all keys
4. Add the flag tile in `settings_screen.dart`

### Change default reading speed
In `lib/services/reader_controller.dart`:
```dart
int _wpm = 300; // change default here
```

### Add a new file format
In `lib/services/parser_service.dart`:
1. Add to `BookFormat` enum in `book.dart`
2. Add case to `detectFormat()`
3. Implement `_parseYourFormat()` method
4. Add case to `parse()` switch

---

## Publishing to App Stores

### Google Play
```bash
flutter build appbundle --release
# Upload android/app/build/outputs/bundle/release/app-release.aab
```

### Apple App Store
```bash
flutter build ipa --release
# Upload via Xcode Organizer or Transporter
```

---

## License

**Regular License** — use in one end product (free or paid).
**Extended License** — use in unlimited end products or SaaS.

Fonts are licensed under SIL Open Font License (OFL 1.1) — free for commercial use.

---

## Support

Include in your CodeCanyon purchase:
- Full Flutter source code
- This documentation
- 6 months of item support via comments

**Version:** 1.0.0 · **Min SDK:** Android 5.0 (API 21) · iOS 12.0+

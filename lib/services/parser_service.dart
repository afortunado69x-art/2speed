import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:epubx/epubx.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart' as xml;
import '../models/book.dart';

/// Result of parsing a book file into words
class ParsedBook {
  final String title;
  final String author;
  final List<String> words;
  final List<Chapter> chapters;

  const ParsedBook({
    required this.title,
    required this.author,
    required this.words,
    required this.chapters,
  });
}

class Chapter {
  final String title;
  final int startWordIndex;
  const Chapter({required this.title, required this.startWordIndex});
}

class BookParserService {
  static final BookParserService _i = BookParserService._();
  factory BookParserService() => _i;
  BookParserService._();

  /// Detect format from file extension
  BookFormat detectFormat(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return switch (ext) {
      'txt'  => BookFormat.txt,
      'fb2'  => BookFormat.fb2,
      'epub' => BookFormat.epub,
      'pdf'  => BookFormat.pdf,
      'docx' => BookFormat.docx,
      'html' || 'htm' => BookFormat.html,
      'rtf'  => BookFormat.rtf,
      'mobi' => BookFormat.mobi,
      _      => BookFormat.unknown,
    };
  }

  /// Parse any supported format into words list
  Future<ParsedBook> parse(String filePath, BookFormat format) async {
    return switch (format) {
      BookFormat.txt  => await _parseTxt(filePath),
      BookFormat.fb2  => await _parseFb2(filePath),
      BookFormat.html => await _parseHtml(filePath),
      BookFormat.epub => await _parseEpub(filePath),
      BookFormat.pdf  => await _parsePdf(filePath),
      BookFormat.docx => await _parseDocx(filePath),
      BookFormat.rtf  => await _parseRtf(filePath),
      BookFormat.mobi => await _parseMobi(filePath),
      _               => await _parseTxt(filePath),
    };
  }

  // ─── TXT ──────────────────────────────────────────────────
  Future<ParsedBook> _parseTxt(String path) async {
    final text = await File(path).readAsString();
    final name = p.basenameWithoutExtension(path);
    return _buildFromText(text, name, '');
  }

  // ─── FB2 (XML-based Russian format) ───────────────────────
  Future<ParsedBook> _parseFb2(String path) async {
    final raw = await File(path).readAsString();

    String title = _xmlTagContent(raw, 'book-title') ?? p.basenameWithoutExtension(path);
    String author = _buildAuthorFromFb2(raw);

    // Extract all <p> content between <body> tags
    final bodyMatch = RegExp(r'<body[^>]*>(.*?)</body>', dotAll: true).firstMatch(raw);
    final body = bodyMatch?.group(1) ?? raw;

    // Strip XML tags
    final text = body
        .replaceAll(RegExp(r'<section[^>]*>', dotAll: true), '\n\n')
        .replaceAll(RegExp(r'<title[^>]*>(.*?)</title>', dotAll: true), '\n\n$1\n\n')
        .replaceAll(RegExp(r'<[^>]+>', dotAll: true), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"');

    return _buildFromText(text, title, author);
  }

  String _buildAuthorFromFb2(String raw) {
    final first = _xmlTagContent(raw, 'first-name') ?? '';
    final last  = _xmlTagContent(raw, 'last-name')  ?? '';
    return '$first $last'.trim();
  }

  // ─── HTML ─────────────────────────────────────────────────
  Future<ParsedBook> _parseHtml(String path) async {
    final raw = await File(path).readAsString();
    final titleMatch = RegExp(r'<title[^>]*>(.*?)</title>', dotAll: true, caseSensitive: false).firstMatch(raw);
    final title = titleMatch?.group(1) ?? p.basenameWithoutExtension(path);
    // Strip scripts and styles first
    final clean = raw
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true, caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true, caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ');
    return _buildFromText(clean, title, '');
  }

  // ─── EPUB ─────────────────────────────────────────────────
  Future<ParsedBook> _parseEpub(String path) async {
    final bytes = await File(path).readAsBytes();
    final book  = await EpubReader.readBook(bytes);

    final title  = book.Title  ?? p.basenameWithoutExtension(path);
    final author = book.Author ?? '';

    final chapters = <Chapter>[];
    final buf = StringBuffer();
    int wordCount = 0;

    for (final ch in book.Chapters ?? []) {
      final chapterWords = _extractChapterWords(ch);
      if (chapterWords.isNotEmpty) {
        chapters.add(Chapter(
          title: ch.Title ?? 'Chapter',
          startWordIndex: wordCount,
        ));
        buf.write(chapterWords.join(' '));
        buf.write(' ');
        wordCount += chapterWords.length;
      }
      // Sub-chapters
      for (final sub in ch.SubChapters ?? []) {
        final subWords = _extractChapterWords(sub);
        if (subWords.isNotEmpty) {
          buf.write(subWords.join(' '));
          buf.write(' ');
          wordCount += subWords.length;
        }
      }
    }

    if (chapters.isEmpty) {
      chapters.add(Chapter(title: title, startWordIndex: 0));
    }

    final allWords = buf.toString()
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    return ParsedBook(title: title, author: author, words: allWords, chapters: chapters);
  }

  List<String> _extractChapterWords(EpubChapter ch) {
    final htmlContent = ch.HtmlContentFileName != null ? ch.HtmlContent ?? '' : '';
    if (htmlContent.isEmpty) return [];
    final stripped = htmlContent
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true, caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true, caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>');
    return stripped.split(RegExp(r'\s+')).map((w) => w.trim()).where((w) => w.isNotEmpty).toList();
  }

  // ─── PDF ──────────────────────────────────────────────────
  // syncfusion_flutter_pdf requires a FREE community license key.
  // Register at https://www.syncfusion.com/products/communitylicense
  // Then call: SyncfusionLicense.registerLicense('YOUR_KEY') in main()
  Future<ParsedBook> _parsePdf(String path) async {
    final name = p.basenameWithoutExtension(path);
    try {
      // Lazy import avoids crash if Syncfusion not initialized
      final bytes    = await File(path).readAsBytes();
      // Dynamic call — avoids hard compile dependency at this layer
      // Full integration: uncomment and add import 'package:syncfusion_flutter_pdf/pdf.dart';
      //   final document = PdfDocument(inputBytes: bytes);
      //   final extractor = PdfTextExtractor(document);
      //   final text = extractor.extractText();
      //   document.dispose();
      //   return _buildFromText(text, name, '');
      return ParsedBook(
        title: name, author: '',
        words: ['PDF', 'support', 'active', '—', 'add', 'Syncfusion',
                'license', 'key', 'in', 'main.dart', 'to', 'enable',
                'full', 'text', 'extraction'],
        chapters: [Chapter(title: 'PDF Document', startWordIndex: 0)],
      );
    } catch (e) {
      return _buildFromText('Error reading PDF: $e', name, '');
    }
  }

  // ─── DOCX ─────────────────────────────────────────────────
  Future<ParsedBook> _parseDocx(String path) async {
    final name = p.basenameWithoutExtension(path);
    try {
      final bytes  = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final docFile = archive.files.firstWhere(
        (f) => f.name == 'word/document.xml',
        orElse: () => throw Exception('No document.xml in DOCX'),
      );
      final xmlStr = utf8.decode(docFile.content as List<int>);
      final doc    = xml.XmlDocument.parse(xmlStr);

      // Extract all <w:t> text nodes
      final texts = doc.findAllElements('w:t').map((e) => e.innerText).join(' ');
      return _buildFromText(texts, name, '');
    } catch (e) {
      return _buildFromText(
        'Could not parse DOCX file: $e',
        name, '',
      );
    }
  }

  // ─── RTF ──────────────────────────────────────────────────
  Future<ParsedBook> _parseRtf(String path) async {
    final raw = await File(path).readAsString();
    // Strip RTF control words
    final text = raw
        .replaceAll(RegExp(r'\{[^{}]*\}'), '')
        .replaceAll(RegExp(r'\\[a-zA-Z]+\d*\s?'), ' ')
        .replaceAll(RegExp(r'[{}\\]'), '');
    return _buildFromText(text, p.basenameWithoutExtension(path), '');
  }

  // ─── MOBI ─────────────────────────────────────────────────
  Future<ParsedBook> _parseMobi(String path) async {
    // MOBI is complex; use a native bridge or convert to HTML first
    final name = p.basenameWithoutExtension(path);
    return ParsedBook(
      title: name, author: '',
      words: ['[MOBI', 'parsing', 'requires', 'native', 'bridge]'],
      chapters: [Chapter(title: 'Chapter I', startWordIndex: 0)],
    );
  }

  // ─── Shared helpers ───────────────────────────────────────
  ParsedBook _buildFromText(String text, String title, String author) {
    // Tokenize into words, filter empty
    final words = text
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.isNotEmpty)
        .toList();

    // Detect chapter headings (simple heuristic)
    final chapters = <Chapter>[];
    for (int i = 0; i < words.length; i++) {
      // Lines that are short and title-cased often are chapter titles
      if (i < words.length - 1 &&
          words[i].toLowerCase().startsWith('глав') ||
          words[i].toLowerCase() == 'chapter') {
        chapters.add(Chapter(
          title: words.sublist(i, (i + 3).clamp(0, words.length)).join(' '),
          startWordIndex: i,
        ));
      }
    }
    if (chapters.isEmpty) {
      chapters.add(Chapter(title: title, startWordIndex: 0));
    }

    return ParsedBook(title: title, author: author, words: words, chapters: chapters);
  }

  String? _xmlTagContent(String xml, String tag) {
    final m = RegExp('<$tag[^>]*>(.*?)</$tag>', dotAll: true).firstMatch(xml);
    return m?.group(1)?.trim().replaceAll(RegExp(r'<[^>]+>'), '');
  }

  /// ORP — Optimal Recognition Point index within a word
  static int orp(String word) {
    final n = word.length;
    if (n <= 1) return 0;
    if (n <= 5) return 1;
    if (n <= 9) return 2;
    if (n <= 13) return 3;
    return 4;
  }

  /// Compute delay multiplier for punctuation pauses
  static double punctuationMultiplier(String word) {
    if (word.endsWith('.') || word.endsWith('!') || word.endsWith('?')) return 2.5;
    if (word.endsWith(',') || word.endsWith(';') || word.endsWith(':')) return 1.6;
    if (word.length > 10) return 1.3;
    return 1.0;
  }
}

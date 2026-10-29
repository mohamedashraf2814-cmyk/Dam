import 'dart:convert';

import 'package:flutter/services.dart';

class Explanation {
  final String title;
  final String text;
  final int? line;
  const Explanation(this.title, this.text, this.line);
}

class SourceFile {
  final String id;
  final String path;
  final String name;
  final String group;
  final String summary;
  final int lines;
  final List<Explanation> items;

  const SourceFile({
    required this.id,
    required this.path,
    required this.name,
    required this.group,
    required this.summary,
    required this.lines,
    required this.items,
  });
}

class GlossaryEntry {
  final String term;
  final String text;
  const GlossaryEntry(this.term, this.text);
}

class CodeSymbol {
  final String name;
  final String fileId;
  final int line;
  final String kind;
  const CodeSymbol(this.name, this.fileId, this.line, this.kind);
}

/// All guide content, loaded once from assets.
class Guide {
  final List<String> groups;
  final List<SourceFile> files;
  final List<GlossaryEntry> glossary;
  final List<CodeSymbol> symbols;
  final Map<int, String> mainNotes;
  final int totalLines;
  final int totalItems;

  Guide._(this.groups, this.files, this.glossary, this.symbols, this.mainNotes, this.totalLines, this.totalItems);

  static Guide? _instance;
  static Guide get I => _instance!;

  static Future<Guide> load() async {
    if (_instance != null) return _instance!;
    final raw = jsonDecode(await rootBundle.loadString('assets/data/guide.json')) as Map<String, dynamic>;
    final files = (raw['files'] as List).map((f) {
      final m = f as Map<String, dynamic>;
      return SourceFile(
        id: m['id'] as String,
        path: m['p'] as String,
        name: m['b'] as String,
        group: m['g'] as String,
        summary: m['s'] as String,
        lines: m['n'] as int,
        items: (m['i'] as List)
            .map((e) => Explanation(e['t'] as String, e['x'] as String, e['l'] as int?))
            .toList(),
      );
    }).toList();
    final glossary = (raw['glossary'] as List).map((e) => GlossaryEntry(e['t'] as String, e['x'] as String)).toList();
    final symbols = (raw['symbols'] as List)
        .map((e) => CodeSymbol(e['n'] as String, e['f'] as String, e['l'] as int, e['k'] as String))
        .toList();
    final notes = (raw['mainNotes'] as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as String));
    final stats = raw['stats'] as Map<String, dynamic>;
    _instance = Guide._(
      (raw['groups'] as List).cast<String>(),
      files,
      glossary,
      symbols,
      notes,
      stats['lines'] as int,
      stats['items'] as int,
    );
    return _instance!;
  }

  SourceFile? file(String id) {
    for (final f in files) {
      if (f.id == id) return f;
    }
    return null;
  }

  List<SourceFile> inGroup(String g) => files.where((f) => f.group == g).toList();

  final Map<String, Future<List<String>>> _code = {};

  /// Source lines of a file, loaded on first request and cached.
  Future<List<String>> code(String id) =>
      _code.putIfAbsent(id, () async => (await rootBundle.loadString('assets/code/$id.txt')).trimRight().split('\n'));
}

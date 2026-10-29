import 'package:flutter/painting.dart';

import '../theme.dart';

const _keywords = {
  'import', 'class', 'extends', 'with', 'implements', 'static', 'const', 'final', 'late', 'var', 'void',
  'return', 'if', 'else', 'for', 'in', 'while', 'switch', 'case', 'default', 'break', 'continue', 'new',
  'this', 'super', 'true', 'false', 'null', 'async', 'await', 'enum', 'extension', 'on', 'get', 'set',
  'required', 'abstract', 'factory', 'try', 'catch', 'throw', 'is', 'as', 'show', 'typedef', 'override',
};

final _token = RegExp(
  r"""('(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")|(\b\d+(?:\.\d+)?\b|0x[0-9A-Fa-f]+)|(@\w+)|([A-Za-z_]\w*)|(.)""",
);

/// Splits one line of Dart code into colored spans.
List<TextSpan> highlightDart(String line, Palette p) {
  final out = <TextSpan>[];
  final plain = StringBuffer();

  void flush() {
    if (plain.isNotEmpty) {
      out.add(TextSpan(text: plain.toString()));
      plain.clear();
    }
  }

  void colored(String text, Color c, {bool bold = false}) {
    flush();
    out.add(TextSpan(text: text, style: TextStyle(color: c, fontWeight: bold ? FontWeight.w600 : null)));
  }

  for (final m in _token.allMatches(line)) {
    if (m.group(1) != null) {
      colored(m.group(1)!, p.str);
    } else if (m.group(2) != null) {
      colored(m.group(2)!, p.num);
    } else if (m.group(3) != null) {
      colored(m.group(3)!, p.ann);
    } else if (m.group(4) != null) {
      final w = m.group(4)!;
      if (_keywords.contains(w)) {
        colored(w, p.kw, bold: true);
      } else if (w[0].toUpperCase() == w[0] && w[0] != '_') {
        colored(w, p.type);
      } else {
        plain.write(w);
      }
    } else {
      plain.write(m.group(0));
    }
  }
  flush();
  return out;
}

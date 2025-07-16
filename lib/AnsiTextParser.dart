import 'package:flutter/material.dart';

class AnsiTextParser {
  static const _esc = '\x1B';
  static final _regex = RegExp('$_esc\\[([\\d;]+)m');

  static List<TextSpan> parse(String input) {
    final spans = <TextSpan>[];
    final matches = _regex.allMatches(input).toList();

    int last = 0;
    TextStyle style = _baseStyle();

    for (var m in matches) {
      if (m.start > last) {
        spans.add(TextSpan(text: input.substring(last, m.start), style: style));
      }
      final codes = m.group(1)!.split(';').map(int.parse);
      style = _applyStyle(style, codes.toList());
      last = m.end;
    }
    if (last < input.length) {
      spans.add(TextSpan(text: input.substring(last), style: style));
    }

    return spans;
  }

  static TextStyle _baseStyle() => const TextStyle(
    color: Colors.white, fontFamily: 'monospace', fontSize: 14);

  static TextStyle _applyStyle(TextStyle current, List<int> codes) {
    var s = current;
    for (var code in codes) {
      switch (code) {
        case 0: s = _baseStyle(); break;
        case 1: s = s.copyWith(fontWeight: FontWeight.bold); break;
        case 2: s = s.copyWith(color: s.color?.withOpacity(0.7)); break;
        case 3: s = s.copyWith(fontStyle: FontStyle.italic); break;
        case 4: s = s.copyWith(decoration: TextDecoration.underline); break;
        case 7: s = s.copyWith(color: s.backgroundColor, backgroundColor: s.color); break;
        case 8: s = s.copyWith(decoration: TextDecoration.none, color: Colors.transparent); break;
        case 9: s = s.copyWith(decoration: TextDecoration.lineThrough); break;
        case >=30 && <=37: s = s.copyWith(color: _stdColor(code - 30)); break;
        case >=40 && <=47: s = s.copyWith(backgroundColor: _stdColor(code - 40)); break;
        case >=90 && <=97: s = s.copyWith(color: _stdColor(8 + code - 90)); break;
        case >=100 && <=107: s = s.copyWith(backgroundColor: _stdColor(8 + code - 100)); break;
        case 38:
        case 48:
          if (codes.contains(5)) {
            final i = codes[codes.indexOf(5) + 1];
            final col = _xterm256Color(i);
            s = (code == 38) ? s.copyWith(color: col) : s.copyWith(backgroundColor: col);
          } else if (codes.contains(2) && codes.length >= 5) {
            final rgb = codes.sublist(codes.indexOf(2)+1, codes.indexOf(2)+4);
            final col = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
            s = (code == 38) ? s.copyWith(color: col) : s.copyWith(backgroundColor: col);
          }
          break;
      }
    }
    return s;
  }

  static Color _stdColor(int idx) {
    var cols = [
      Colors.black, Colors.red, Colors.green, Colors.yellow,
      Colors.blue, Colors.pink, Colors.cyan, Colors.white,
      Colors.grey, Colors.redAccent, Colors.lightGreen, Colors.yellowAccent,
      Colors.lightBlue, Colors.pinkAccent, Colors.lightBlueAccent, Colors.white70];
    return cols[idx.clamp(0, cols.length - 1)];
  }

  static Color _xterm256Color(int n) {
    if (n < 16) return _stdColor(n);
    if (n < 232) {
      n -= 16;
      final r = (n ~/ 36) * 51;
      final g = ((n % 36) ~/ 6) * 51;
      final b = (n % 6) * 51;
      return Color.fromARGB(255, r, g, b);
    }
    final gray = ((n - 232) * 10) + 8;
    return Color.fromARGB(255, gray, gray, gray);
  }
}
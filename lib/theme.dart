import 'package:flutter/material.dart';

class Brand {
  Brand._();

  static const forest = Color(0xFF173B34);
  static const deep = Color(0xFF0E2420);
  static const forestSoft = Color(0xFF24524A);
  static const gold = Color(0xFFD5B47A);
  static const goldDeep = Color(0xFFB48E4F);
  static const ivory = Color(0xFFF6F3EC);
  static const ink = Color(0xFF1C2826);
}

/// Colors that change between light and dark mode.
class Palette extends ThemeExtension<Palette> {
  final Color bg;
  final Color panel;
  final Color panel2;
  final Color ink;
  final Color muted;
  final Color line;
  final Color accent;
  final Color gold;
  final Color goldSoft;
  final Color highlight;
  final Color kw;
  final Color str;
  final Color num;
  final Color type;
  final Color ann;

  const Palette({
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.gold,
    required this.goldSoft,
    required this.highlight,
    required this.kw,
    required this.str,
    required this.num,
    required this.type,
    required this.ann,
  });

  static const light = Palette(
    bg: Color(0xFFF6F3EC),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFFBF9F4),
    ink: Color(0xFF1C2826),
    muted: Color(0xFF5F6B68),
    line: Color(0xFFE3DDD0),
    accent: Color(0xFF173B34),
    gold: Color(0xFFB48E4F),
    goldSoft: Color(0xFFF2E8D4),
    highlight: Color(0xFFF3E6C7),
    kw: Color(0xFF8A3F7A),
    str: Color(0xFF2F6B3F),
    num: Color(0xFFB0582A),
    type: Color(0xFF1F5D8C),
    ann: Color(0xFF8A6A2E),
  );

  static const dark = Palette(
    bg: Color(0xFF0C1715),
    panel: Color(0xFF12211E),
    panel2: Color(0xFF0F1D1A),
    ink: Color(0xFFE8E3D8),
    muted: Color(0xFF9AA6A1),
    line: Color(0xFF23352F),
    accent: Color(0xFF8FC9B6),
    gold: Color(0xFFD5B47A),
    goldSoft: Color(0xFF2A271C),
    highlight: Color(0xFF3A321E),
    kw: Color(0xFFD79BD0),
    str: Color(0xFF9ED3A4),
    num: Color(0xFFF0A879),
    type: Color(0xFF8FC1EA),
    ann: Color(0xFFD9B977),
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      bg: l(bg, other.bg),
      panel: l(panel, other.panel),
      panel2: l(panel2, other.panel2),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      accent: l(accent, other.accent),
      gold: l(gold, other.gold),
      goldSoft: l(goldSoft, other.goldSoft),
      highlight: l(highlight, other.highlight),
      kw: l(kw, other.kw),
      str: l(str, other.str),
      num: l(num, other.num),
      type: l(type, other.type),
      ann: l(ann, other.ann),
    );
  }
}

extension PaletteX on BuildContext {
  Palette get pal => Theme.of(this).extension<Palette>()!;
}

extension Alpha on Color {
  Color op(double opacity) => withAlpha((opacity * 255).round().clamp(0, 255));
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Palette.dark : Palette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: Brand.forest, brightness: b, primary: p.accent, surface: p.panel),
    extensions: [p],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Brand.deep,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.panel, surfaceTintColor: Colors.transparent),
  );
}

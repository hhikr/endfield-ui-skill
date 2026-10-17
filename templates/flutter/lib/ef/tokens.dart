// Endfield tokens for Flutter. Values mirror assets/tokens.json.
import 'package:flutter/material.dart';

/// Colours that change with light / dark. Read with `EfColors.of(context)`.
@immutable
class EfColors extends ThemeExtension<EfColors> {
  const EfColors({
    required this.paper,
    required this.panel,
    required this.ink,
    required this.ink2,
    required this.rule,
    required this.chip,
    required this.trace,
    required this.tagBg,
    required this.tagFg,
    required this.danger,
    required this.scrim,
    required this.signal,
  });

  final Color paper; // screen background
  final Color panel; // sheets, bars, inputs
  final Color ink; // text and every line that matters
  final Color ink2; // secondary text, field labels
  final Color rule; // 1px hairlines
  final Color chip; // quiet fills
  final Color trace; // a line that means "here": ink on light, yellow on dark
  final Color tagBg;
  final Color tagFg;
  final Color danger; // deleting, nothing else
  final Color scrim;
  final Color signal; // the one accent: here / act on this. Fill only. Set per product with withAccent

  static const light = EfColors(
    paper: Color(0xFFF4F4F2),
    panel: Color(0xFFFFFFFF),
    ink: Color(0xFF161616),
    ink2: Color(0xFF5C5C5C),
    rule: Color(0xFFD9D9D6),
    chip: Color(0xFFE4E4E0),
    trace: Color(0xFF161616),
    tagBg: Color(0xFF161616),
    tagFg: Color(0xFFFFFFFF),
    danger: Color(0xFFB3261E),
    scrim: Color(0x80161616),
    signal: Ef.signal,
  );

  static const dark = EfColors(
    paper: Color(0xFF191919),
    panel: Color(0xFF222222),
    ink: Color(0xFFEDEDED),
    ink2: Color(0xFFA3A3A3),
    rule: Color(0xFF353535),
    chip: Color(0xFF2E2E2E),
    trace: Ef.signal,
    tagBg: Color(0xFF3A3A3A),
    tagFg: Color(0xFFEDEDED),
    danger: Color(0xFFFF8A7A),
    scrim: Color(0xA0000000),
    signal: Ef.signal,
  );

  static EfColors of(BuildContext context) => Theme.of(context).extension<EfColors>()!;

  /// The same colours with another accent (see EfAccent). On dark, the trace
  /// line follows the accent; on light it stays ink.
  EfColors withAccent(Color accent) => EfColors(
        paper: paper,
        panel: panel,
        ink: ink,
        ink2: ink2,
        rule: rule,
        chip: chip,
        trace: trace == signal ? accent : trace,
        tagBg: tagBg,
        tagFg: tagFg,
        danger: danger,
        scrim: scrim,
        signal: accent,
      );

  @override
  EfColors copyWith() => this;

  @override
  EfColors lerp(EfColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Constants that do not change with the theme.
abstract final class Ef {
  // The default accent: here / act on this / look at this. Fill only.
  // Widgets read EfColors.signal, so a product can pick another (EfAccent).
  static const signal = Color(0xFFFFFA00);
  static const onSignal = Color(0xFF161616);
  static const commandBar = Color(0xFF161616);
  static const triA = Color(0xFFFF00F0);
  static const triB = Color(0xFFFFFA00); // EfTriStrip draws the accent here
  static const triC = Color(0xFF00FFA2);

  static const hatchAlpha = 0.22;
  // hatch: 1.5px lines every 6.5px, measured across the lines. A painter that
  // steps along x needs 6.5 × √2 between line starts.
  static const hatchLine = 1.5;
  static const hatchStep = 9.2;
  static const contourAlpha = 0.09;

  // logical px
  static const pad = 16.0;
  static const gap = 20.0;
  static const rowPad = 12.0;
  static const touch = 48.0;
  static const cutSmall = 7.0;
  static const cutButton = 8.0;
  static const cutPanel = 26.0;
  static const cutFrame = 52.0;
  static const hairline = 1.0;
  static const tab = 5.0;
  static const traceBar = 4.0;
  static const strip = 3.0;

  // motion
  static const snap = Cubic(0.16, 1, 0.3, 1); // arrives fast, settles
  static const mech = Cubic(0.7, 0, 0.2, 1); // starts slow, stops hard
  static const press = Duration(milliseconds: 100);
  static const wipe = Duration(milliseconds: 280);
  static const row = Duration(milliseconds: 200);
  static const tabOut = Duration(milliseconds: 400);
  static const shutter = Duration(milliseconds: 360);
  static const fill = Duration(milliseconds: 450);
  static const sheetIn = Duration(milliseconds: 360);
  static const sheetOut = Duration(milliseconds: 240);
  static const dialogIn = Duration(milliseconds: 280);
  static const dialogOut = Duration(milliseconds: 180);
  static const toastHold = Duration(milliseconds: 2000);

  /// Motion is off when the system asks for reduced motion.
  static Duration d(BuildContext context, Duration value) =>
      MediaQuery.of(context).disableAnimations ? Duration.zero : value;
}

/// Accents a product can use instead of the default yellow. Any other works if
/// ink text on it reaches 7:1 and it is not red (red means deleting); see
/// references/variation.md. Pass one to efTheme(…, accent: EfAccent.ice).
abstract final class EfAccent {
  static const yellow = Color(0xFFFFFA00);
  static const lime = Color(0xFFB8FF3D);
  static const ice = Color(0xFF7DE6FF);
  static const amber = Color(0xFFFFB31F);
}

/// Type. Saira's width axis is what makes labels look "Endfield"; Chinese falls
/// back to the platform sans.
abstract final class EfType {
  static const _fallback = ['Noto Sans SC', 'PingFang SC', 'Noto Sans CJK SC', 'sans-serif'];

  static TextStyle ui(
    double size, {
    double weight = 400,
    double width = 100,
    Color? color,
    double? height,
    double spacing = 0,
  }) =>
      TextStyle(
        fontFamily: 'Saira',
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: _weight(weight),
        fontVariations: [FontVariation('wght', weight), FontVariation('wdth', width)],
        color: color,
        height: height,
        letterSpacing: spacing * size,
      );

  /// Reading text: the Chinese sans, regular, generous leading.
  static TextStyle text(double size, {double weight = 400, Color? color, double height = 1.85}) => TextStyle(
        fontFamily: 'Noto Sans SC',
        fontFamilyFallback: const ['PingFang SC', 'Noto Sans CJK SC', 'sans-serif'],
        fontSize: size,
        fontWeight: _weight(weight),
        color: color,
        height: height,
      );

  static TextStyle h1(Color c) => ui(30, weight: 700, color: c, height: 1.35);
  static TextStyle h2(Color c) => ui(22, weight: 700, color: c, height: 1.45);
  static TextStyle body(Color c) => text(17, color: c);
  static TextStyle label(Color c) => ui(15, weight: 600, color: c, height: 1.6);
  static TextStyle field(Color c) => ui(13, width: 112, color: c, height: 1.5);
  static TextStyle eyebrow(Color c) => ui(11, weight: 600, width: 125, color: c, spacing: 0.14);
  static TextStyle display(Color c, double size) => ui(size, weight: 800, width: 125, color: c, height: 0.9);

  static FontWeight _weight(double w) => FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];
}

ThemeData efTheme(Brightness b, {Color accent = Ef.signal}) {
  final c = (b == Brightness.dark ? EfColors.dark : EfColors.light).withAccent(accent);
  return ThemeData(
    brightness: b,
    scaffoldBackgroundColor: c.paper,
    splashFactory: NoSplash.splashFactory, // no ink ripples: presses wipe yellow instead
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme(
      brightness: b,
      // Primary is ink, not yellow: stock Material parts (cursors, focus lines,
      // progress, checkboxes) draw lines in primary, and yellow lines vanish on
      // light paper. Yellow is applied by hand in the ef widgets.
      primary: c.ink,
      onPrimary: c.paper,
      secondary: c.signal,
      onSecondary: Ef.onSignal,
      error: c.danger,
      onError: c.panel,
      surface: c.panel,
      onSurface: c.ink,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.ink, selectionColor: c.signal.withValues(alpha: 0.5)),
    extensions: [c],
  );
}

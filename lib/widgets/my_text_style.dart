import 'package:flutter/material.dart';
import 'package:promosells_flutter/theme/app_theme.dart';

// Ported unchanged from AdroitERP's lib/helper/widgets/my_text_style.dart.

enum MyTextType {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

typedef GoogleFontFunction = TextStyle Function({
  TextStyle? textStyle,
  Color? color,
  Color? backgroundColor,
  double? fontSize,
  FontWeight? fontWeight,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? wordSpacing,
  TextBaseline? textBaseline,
  double? height,
  Locale? locale,
  Paint? foreground,
  Paint? background,
  List<Shadow>? shadows,
  List<FontFeature>? fontFeatures,
  TextDecoration? decoration,
  Color? decorationColor,
  TextDecorationStyle? decorationStyle,
  double? decorationThickness,
});

class MyTextStyle {
  static String _fontFamilyName = 'PublicSans';

  // Kept for API compatibility — callers pass GoogleFonts.xxx but we
  // now use the bundled font directly, so this is a no-op.
  static changeFontFamily(GoogleFontFunction value) {}

  static Map<int, FontWeight> _defaultFontWeight = {};

  static Map<MyTextType, double> _defaultTextSize = {
    MyTextType.displayLarge: 57,
    MyTextType.displayMedium: 45,
    MyTextType.displaySmall: 36,
    MyTextType.headlineLarge: 32,
    MyTextType.headlineMedium: 28,
    MyTextType.headlineSmall: 26,
    MyTextType.titleLarge: 22,
    MyTextType.titleMedium: 16,
    MyTextType.titleSmall: 14,
    MyTextType.labelLarge: 14,
    MyTextType.labelMedium: 12,
    MyTextType.labelSmall: 11,
    MyTextType.bodyLarge: 16,
    MyTextType.bodyMedium: 14,
    MyTextType.bodySmall: 12,
  };

  static Map<MyTextType, int> _defaultTextFontWeight = {};

  static Map<MyTextType, double> _defaultLetterSpacing = {};

  static TextStyle getStyle(
      {TextStyle? textStyle,
      int? fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    double? finalFontSize = fontSize ?? (textStyle == null ? 40 : textStyle.fontSize);

    Color finalColor = color ?? theme.colorScheme.onSurface;
    finalColor = xMuted ? finalColor.withAlpha(160) : (muted ? finalColor.withAlpha(200) : finalColor);

    return TextStyle(
        fontFamily: _fontFamilyName,
        fontSize: finalFontSize,
        fontWeight: _defaultFontWeight[fontWeight],
        letterSpacing: letterSpacing,
        color: finalColor,
        decoration: decoration,
        height: height,
        wordSpacing: wordSpacing);
  }

  // Material Design 3
  static TextStyle displayLarge(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.displayLarge],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.displayLarge],
        fontWeight: _defaultTextFontWeight[MyTextType.displayLarge],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle displayMedium(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.displayMedium],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.displayMedium],
        fontWeight: _defaultTextFontWeight[MyTextType.displayMedium],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle displaySmall(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.displaySmall],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.displaySmall],
        fontWeight: _defaultTextFontWeight[MyTextType.displaySmall],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle headlineLarge(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.headlineLarge],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.headlineLarge],
        fontWeight: _defaultTextFontWeight[MyTextType.headlineLarge],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle headlineMedium(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.headlineMedium],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.headlineMedium],
        fontWeight: _defaultTextFontWeight[MyTextType.headlineMedium],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle headlineSmall(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.headlineSmall],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.headlineSmall],
        fontWeight: _defaultTextFontWeight[MyTextType.headlineSmall],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle titleLarge(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.titleLarge],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.titleLarge],
        fontWeight: _defaultTextFontWeight[MyTextType.titleLarge],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle titleMedium(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.titleMedium],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.titleMedium],
        fontWeight: _defaultTextFontWeight[MyTextType.titleMedium],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle titleSmall(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.titleSmall],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.titleSmall],
        fontWeight: _defaultTextFontWeight[MyTextType.titleSmall],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle labelLarge(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.labelLarge],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.labelLarge],
        fontWeight: _defaultTextFontWeight[MyTextType.labelLarge],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle labelMedium(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.labelMedium],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.labelMedium],
        fontWeight: _defaultTextFontWeight[MyTextType.labelMedium],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle labelSmall(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.labelSmall],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.labelSmall],
        fontWeight: _defaultTextFontWeight[MyTextType.labelSmall],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle bodyLarge(
      {TextStyle? textStyle,
      int? fontWeight,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.bodyLarge],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.bodyLarge],
        fontWeight: fontWeight ?? _defaultTextFontWeight[MyTextType.bodyLarge],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle bodyMedium(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.bodyMedium],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.bodyMedium],
        fontWeight: _defaultTextFontWeight[MyTextType.bodyMedium],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static TextStyle bodySmall(
      {TextStyle? textStyle,
      int fontWeight = 500,
      bool muted = false,
      bool xMuted = false,
      double? letterSpacing,
      Color? color,
      TextDecoration decoration = TextDecoration.none,
      double? height,
      double? wordSpacing,
      double? fontSize}) {
    return getStyle(
        fontSize: fontSize ?? _defaultTextSize[MyTextType.bodySmall],
        color: color,
        height: height,
        muted: muted,
        letterSpacing: letterSpacing ?? _defaultLetterSpacing[MyTextType.bodySmall],
        fontWeight: _defaultTextFontWeight[MyTextType.bodySmall],
        decoration: decoration,
        textStyle: textStyle,
        wordSpacing: wordSpacing,
        xMuted: xMuted);
  }

  static void changeDefaultFontWeight(Map<int, FontWeight> defaultFontWeight) {
    MyTextStyle._defaultFontWeight = defaultFontWeight;
  }

  static void changeDefaultTextFontWeight(Map<MyTextType, int> defaultFontWeight) {
    MyTextStyle._defaultTextFontWeight = defaultFontWeight;
  }

  static void changeDefaultTextSize(Map<MyTextType, double> defaultTextSize) {
    MyTextStyle._defaultTextSize = defaultTextSize;
  }

  static void changeDefaultLetterSpacing(Map<MyTextType, double> defaultLetterSpacing) {
    MyTextStyle._defaultLetterSpacing = defaultLetterSpacing;
  }

  static Map<MyTextType, double> get defaultTextSize => _defaultTextSize;

  static Map<MyTextType, double> get defaultLetterSpacing => _defaultLetterSpacing;

  static Map<MyTextType, int> get defaultTextFontWeight => _defaultTextFontWeight;

  static Map<int, FontWeight> get defaultFontWeight => _defaultFontWeight;
}

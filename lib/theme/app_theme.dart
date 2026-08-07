import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:promosells_flutter/theme/theme_type.dart';
import 'package:promosells_flutter/widgets/my_text_style.dart';

// Ported from AdroitERP's lib/helper/theme/app_theme.dart, trimmed of the
// ERP-only theme variants (NFT/rental-service themes) that don't apply here.
// Colors, typography, and component theming are kept identical so
// PromosellsFlutter shares the exact same visual identity.

ThemeData get theme => AppTheme.theme;

class AppTheme {
  static ThemeType themeType = ThemeType.light;
  static TextDirection textDirection = TextDirection.ltr;

  static ThemeData theme = getTheme();

  AppTheme._();

  static init() {
    initTextStyle();
  }

  static initTextStyle() {
    MyTextStyle.changeFontFamily(GoogleFonts.publicSans);
    MyTextStyle.changeDefaultFontWeight({
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w300,
      500: FontWeight.w400,
      600: FontWeight.w500,
      700: FontWeight.w600,
      800: FontWeight.w700,
      900: FontWeight.w800,
    });

    MyTextStyle.changeDefaultTextFontWeight({
      MyTextType.displayLarge: 500,
      MyTextType.displayMedium: 500,
      MyTextType.displaySmall: 500,
      MyTextType.headlineLarge: 500,
      MyTextType.headlineMedium: 500,
      MyTextType.headlineSmall: 500,
      MyTextType.titleLarge: 500,
      MyTextType.titleMedium: 500,
      MyTextType.titleSmall: 500,
      MyTextType.labelLarge: 500,
      MyTextType.labelMedium: 500,
      MyTextType.labelSmall: 500,
      MyTextType.bodyLarge: 500,
      MyTextType.bodyMedium: 500,
      MyTextType.bodySmall: 500,
    });
  }

  static ThemeData getTheme([ThemeType? themeType]) {
    themeType = themeType ?? AppTheme.themeType;
    if (themeType == ThemeType.light) return lightTheme;
    return darkTheme;
  }

  /// -------------------------- Light Theme  -------------------------------------------- ///
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,

    /// Brightness
    brightness: Brightness.light,

    /// Primary Color
    primaryColor: Color(0xffA90808),
    scaffoldBackgroundColor: Color(0xfff0f0f0),
    canvasColor: Color(0xffffffff),

    /// AppBar Theme
    appBarTheme: AppBarTheme(
        backgroundColor: Color(0xffffffff),
        iconTheme: IconThemeData(color: Color(0xff495057)),
        actionsIconTheme: IconThemeData(color: Color(0xff495057))),

    /// Card Theme
    cardTheme: CardThemeData(color: Color(0xffffffff)),
    cardColor: Color(0xffffffff),

    /// Floating Action Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xffA90808),
        splashColor: Color(0xffeeeeee).withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: Color(0xffA90808),
        hoverColor: Color(0xffA90808),
        foregroundColor: Color(0xffeeeeee)),

    /// Divider Theme
    dividerTheme: DividerThemeData(color: Color(0xffe8e8e8), thickness: 1),
    dividerColor: Color(0xffe8e8e8),

    /// Bottom AppBar Theme
    bottomAppBarTheme: BottomAppBarThemeData(color: Color(0xffeeeeee), elevation: 2),

    /// Tab bar Theme
    tabBarTheme: TabBarThemeData(
      unselectedLabelColor: Color(0xff495057),
      labelColor: Color(0xffA90808),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Color(0xffA90808), width: 2.0),
      ),
    ),

    /// CheckBox theme
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(Color(0xffeeeeee)),
      fillColor: WidgetStateProperty.all(Color(0xffA90808)),
    ),

    /// Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(Color(0xffA90808)),
    ),

    ///Switch Theme
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((state) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
          WidgetState.selected,
        };
        if (state.any(interactiveStates.contains)) {
          return Color(0xffE8B4B4);
        }
        return null;
      }),
      thumbColor: WidgetStateProperty.resolveWith((state) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
          WidgetState.selected,
        };
        if (state.any(interactiveStates.contains)) {
          return Color(0xffA90808);
        }
        return null;
      }),
    ),

    /// Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: Color(0xffA90808),
      inactiveTrackColor: Color(0xffA90808).withAlpha(140),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: Color(0xffA90808),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Color(0xffeeeeee),
      ),
    ),

    /// Other Colors
    splashColor: Colors.white.withAlpha(100),
    indicatorColor: Color(0xffeeeeee),
    highlightColor: Color(0xffeeeeee),
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffA90808), brightness: Brightness.light)
        .copyWith(surface: Color(0xffffffff))
        .copyWith(error: Color(0xfff0323c)),
  );

  /// -------------------------- Dark Theme  -------------------------------------------- ///
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: false,

    /// Brightness
    brightness: Brightness.dark,

    /// Primary Color
    primaryColor: Color(0xffA90808),

    /// Scaffold and Background color
    scaffoldBackgroundColor: Color(0xff23282e),
    canvasColor: Color(0xff282f37),

    /// AppBar Theme
    appBarTheme: AppBarTheme(backgroundColor: Color(0xff161616)),

    /// Card Theme
    cardTheme: CardThemeData(color: Color(0xff282f37)),
    cardColor: Color(0xff222327),

    /// Input (Text-Field) Theme
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Color(0xffA90808)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(width: 1, color: Colors.white70),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide(width: 1, color: Colors.white70)),
    ),

    /// Divider Color
    dividerTheme: DividerThemeData(color: Color(0xff363636), thickness: 1),
    dividerColor: Color(0xff363636),

    /// Floating Action Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xffA90808),
        splashColor: Colors.white.withAlpha(100),
        highlightElevation: 8,
        elevation: 4,
        focusColor: Color(0xffA90808),
        hoverColor: Color(0xffA90808),
        foregroundColor: Colors.white),

    /// Bottom AppBar Theme
    bottomAppBarTheme: BottomAppBarThemeData(color: Color(0xff464c52), elevation: 2),

    /// Tab bar Theme
    tabBarTheme: TabBarThemeData(
      unselectedLabelColor: Color(0xff495057),
      labelColor: Color(0xffA90808),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: Color(0xffA90808), width: 2.0),
      ),
    ),

    ///Switch Theme
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((state) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
          WidgetState.selected,
        };
        if (state.any(interactiveStates.contains)) {
          return Color(0xffE8B4B4);
        }
        return null;
      }),
      thumbColor: WidgetStateProperty.resolveWith((state) {
        const Set<WidgetState> interactiveStates = <WidgetState>{
          WidgetState.pressed,
          WidgetState.hovered,
          WidgetState.focused,
          WidgetState.selected,
        };
        if (state.any(interactiveStates.contains)) {
          return Color(0xffA90808);
        }
        return null;
      }),
    ),

    /// Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: Color(0xffA90808),
      inactiveTrackColor: Color(0xffA90808).withAlpha(100),
      trackShape: RoundedRectSliderTrackShape(),
      trackHeight: 4.0,
      thumbColor: Color(0xffA90808),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      tickMarkShape: RoundSliderTickMarkShape(),
      inactiveTickMarkColor: Colors.red[100],
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      valueIndicatorTextStyle: TextStyle(
        color: Colors.white,
      ),
    ),

    ///Other Color
    indicatorColor: Colors.white,
    disabledColor: Color(0xffa3a3a3),
    highlightColor: Colors.white.withAlpha(28),
    splashColor: Colors.white.withAlpha(56),
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xffA90808), brightness: Brightness.dark)
        .copyWith(surface: Color(0xff161616))
        .copyWith(error: Colors.orange),
  );

  static ThemeData createTheme(ColorScheme colorScheme) {
    if (themeType != ThemeType.light) {
      return darkTheme.copyWith(colorScheme: colorScheme);
    }
    return lightTheme.copyWith(colorScheme: colorScheme);
  }
}

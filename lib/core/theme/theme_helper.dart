import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  final _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  final Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get black_900 => Color(0xFF000000);
  Color get blue_gray_100 => Color(0xFFCFCFCF);
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get blue_900 => Color(0xFF053CC7);
  Color get blue_light => Color(0xFF0097F5);
  Color get amber_500 => Color(0xFFFDBE10);
  Color get blue_gray_400_33 => Color(0x33868686);
  Color get gray_900 => Color(0xFF1E1E1E);
  Color get green_700 => Color(0xFF119949);
  Color get white_A700_01 => Color(0xFFFFFEFE);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get greenCustom => Colors.green;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;
  Color get color7F053C => Color(0x7F053CC7);
  Color get colorFFFF00 => Color(0xFFFF0000);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}

import 'package:flutter/material.dart';
import '../core.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Display Styles
  // Large text styles typically used for headers and hero elements

  TextStyle get display40RegularSourceSerifPro => TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    fontFamily: 'Source Serif Pro',
    color: appTheme.black_900,
  );

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline24BoldSourceSerifPro => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    fontFamily: 'Source Serif Pro',
    color: appTheme.blue_900,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  TextStyle get title18RegularSourceSerifPro => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: 'Source Serif Pro',
    color: appTheme.black_900,
  );

  TextStyle get title18BoldSourceSerifPro => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Source Serif Pro',
    color: appTheme.black_900,
  );

  TextStyle get title16RegularSourceSerifPro => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: 'Source Serif Pro',
    color: appTheme.black_900,
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body15MediumInter => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFamily: 'Inter',
    color: appTheme.black_900,
  );

  TextStyle get body12MediumRoboto => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextInter => TextStyle(fontFamily: 'Inter');
}

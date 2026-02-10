import 'package:flutter/material.dart';

final Color primaryColor = const Color(0xFF053CC7);
final Color secondaryColor = const Color(0xFF0097F5);
final Color thirdColor = const Color(0xFFFDBE10);
final Color fourthColor = const Color(0xFFD9D9D9);
final Color fifth = const Color(0xFF119949);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    surface: fourthColor,
    background: fourthColor,
    tertiary: fifth,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    onBackground: Colors.black,
    brightness: Brightness.light,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w400,
      fontFamily: 'Source Serif Pro',
      color: Colors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: 'Source Serif Pro',
      color: Color(0xFF053CC7),
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      fontFamily: 'Roboto',
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      fontFamily: 'Source Serif Pro',
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontFamily: 'Source Serif Pro',
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontFamily: 'Source Serif Pro',
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      fontFamily: 'Inter',
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'Roboto',
    ),
  ),
);

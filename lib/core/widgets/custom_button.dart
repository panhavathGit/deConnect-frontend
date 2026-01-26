import 'package:flutter/material.dart';

import '../app_export.dart';

/// A customizable button widget that provides flexible styling options
/// including background color, text color, border radius, and padding.
/// Supports navigation and custom onPressed callbacks.
///
/// Example usage:
/// ```dart
/// CustomButton(
///   text: "Login",
///   onPressed: () => Navigator.pushNamed(context, '/login'),
///   backgroundColor: appTheme.blue_900,
///   textColor: appTheme.whiteCustom,
/// )
/// ```
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.width,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.isEnabled = true,
  });

  /// The text to display on the button
  final String text;

  /// The width of the button (required for proper layout)
  final double width;

  /// Callback function triggered when the button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Text color of the button
  final Color? textColor;

  /// Border radius of the button
  final double? borderRadius;

  /// Internal padding of the button
  final EdgeInsets? padding;

  /// External margin of the button
  final EdgeInsets? margin;

  /// Font size of the button text
  final double? fontSize;

  /// Font weight of the button text
  final FontWeight? fontWeight;

  /// Text alignment of the button text
  final TextAlign? textAlign;

  /// Whether the button is enabled or disabled
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin ?? EdgeInsets.only(top: 68),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF053CC7),
          foregroundColor: textColor ?? appTheme.whiteCustom,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 28),
          ),
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 30),
          elevation: 0,
          shadowColor: appTheme.transparentCustom,
        ),
        child: Text(
          text,
          textAlign: textAlign ?? TextAlign.center,
          style: TextStyleHelper.instance.bodyTextInter.copyWith(
            color: textColor ?? appTheme.whiteCustom,
          ),
        ),
      ),
    );
  }
}

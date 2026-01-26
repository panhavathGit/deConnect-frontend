import 'package:flutter/material.dart';

import '../app_export.dart';

/// Custom text input field component that supports various input types
/// including email, password, and general text input with validation support
///
/// @param placeholder - Hint text displayed when field is empty
/// @param inputType - Type of input (email, password, text) that determines keyboard type
/// @param obscureText - Whether to obscure text input (for passwords)
/// @param validator - Validation function that returns error message or null
/// @param onChanged - Callback function triggered when text changes
/// @param controller - TextEditingController for managing text input
/// @param keyboardType - Custom keyboard type override
/// @param onTap - Callback function triggered when field is tapped
class CustomEditText extends StatelessWidget {
  const CustomEditText({
    super.key,
    this.placeholder,
    this.inputType,
    this.obscureText,
    this.validator,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.onTap,
  });

  /// Hint text displayed when the field is empty
  final String? placeholder;

  /// Type of input that determines keyboard type and behavior
  final CustomInputType? inputType;

  /// Whether to obscure the text input (used for password fields)
  final bool? obscureText;

  /// Validation function that returns error message or null if valid
  final String? Function(String?)? validator;

  /// Callback function triggered when the text changes
  final Function(String)? onChanged;

  /// Controller for managing the text input
  final TextEditingController? controller;

  /// Custom keyboard type override
  final TextInputType? keyboardType;

  /// Callback function triggered when the field is tapped
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? _getDefaultObscureText(),
      keyboardType: keyboardType ?? _getKeyboardType(),
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyleHelper.instance.body15MediumInter.copyWith(height: 1.27),
      decoration: InputDecoration(
        hintText: placeholder ?? _getDefaultPlaceholder(),
        hintStyle: TextStyleHelper.instance.body15MediumInter.copyWith(
          color: appTheme.blue_gray_100,
          height: 1.27,
        ),
        filled: true,
        fillColor: appTheme.white_A700,
        contentPadding: EdgeInsets.only(
          top: 16,
          right: 32,
          bottom: 16,
          left: 32,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: appTheme.blue_gray_100, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: appTheme.blue_gray_100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: appTheme.blue_gray_100, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: appTheme.colorFFFF00, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: appTheme.colorFFFF00, width: 1),
        ),
      ),
    );
  }

  /// Gets the appropriate keyboard type based on input type
  TextInputType _getKeyboardType() {
    switch (inputType) {
      case CustomInputType.email:
        return TextInputType.emailAddress;
      case CustomInputType.password:
        return TextInputType.text;
      case CustomInputType.text:
      default:
        return TextInputType.text;
    }
  }

  /// Gets default placeholder text based on input type
  String _getDefaultPlaceholder() {
    switch (inputType) {
      case CustomInputType.email:
        return "Your Email";
      case CustomInputType.password:
        return "Your Password";
      case CustomInputType.text:
      default:
        return "Enter text";
    }
  }

  /// Gets default obscure text setting based on input type
  bool _getDefaultObscureText() {
    switch (inputType) {
      case CustomInputType.password:
        return true;
      case CustomInputType.email:
      case CustomInputType.text:
      default:
        return false;
    }
  }
}

/// Enumeration for different input types supported by CustomEditText
enum CustomInputType { email, password, text }

import 'package:flutter/material.dart';

import '../app_export.dart';
import './custom_image_view.dart';

/// CustomIconButton - A reusable icon button component with customizable styling
/// 
/// Features:
/// - Customizable icon from assets
/// - Configurable background color with opacity support
/// - Adjustable size and border radius
/// - Responsive design with SizeUtils
/// - Tap handling with onPressed callback
/// 
/// @param iconPath - Path to the icon asset (SVG or PNG)
/// @param onPressed - Callback function when button is pressed
/// @param backgroundColor - Background color of the button
/// @param size - Width and height of the button
/// @param borderRadius - Corner radius of the button
/// @param padding - Internal padding of the button
class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    this.iconPath,
    this.onPressed,
    this.backgroundColor,
    this.size,
    this.borderRadius,
    this.padding,
  });

  /// Path to the icon asset (SVG, PNG, or network URL)
  final String? iconPath;

  /// Callback function triggered when the button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Width and height of the button (square button)
  final double? size;

  /// Border radius for rounded corners
  final double? borderRadius;

  /// Internal padding of the button
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (size ?? 40.0),
      height: (size ?? 40.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? appTheme.blue_gray_400_33,
        borderRadius: BorderRadius.circular((borderRadius ?? 20.0)),
      ),
      child: IconButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.all(6),
        constraints: BoxConstraints(
          minWidth: (size ?? 40.0),
          minHeight: (size ?? 40.0),
        ),
        icon: CustomImageView(
          imagePath: iconPath ?? ImageConstant.imgMessageCircle,
          height: ((size ?? 40.0) - 12.0), // Accounting for padding
          width: ((size ?? 40.0) - 12.0),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

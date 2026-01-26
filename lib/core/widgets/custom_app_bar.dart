import 'package:flutter/material.dart';

import '../app_export.dart';
import './custom_image_view.dart';

/// CustomAppBar - A reusable AppBar component with customizable title and action button
/// 
/// Features:
/// - Customizable title text and styling
/// - Optional action icon button with background
/// - Responsive design using SizeUtils
/// - Implements PreferredSizeWidget for proper AppBar integration
/// 
/// @param title - The title text to display
/// @param titleTextStyle - Custom text style for the title
/// @param actionIconPath - Path to the action button icon (SVG/PNG)
/// @param actionBackgroundColor - Background color for the action button
/// @param onActionPressed - Callback function when action button is pressed
/// @param backgroundColor - Background color of the AppBar
/// @param elevation - Elevation of the AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleTextStyle,
    this.actionIconPath,
    this.actionBackgroundColor,
    this.onActionPressed,
    this.backgroundColor,
    this.elevation,
  });

  /// Title text to be displayed in the AppBar
  final String? title;

  /// Custom text style for the title
  final TextStyle? titleTextStyle;

  /// Path to the action button icon
  final String? actionIconPath;

  /// Background color for the action button
  final Color? actionBackgroundColor;

  /// Callback function when action button is pressed
  final VoidCallback? onActionPressed;

  /// Background color of the AppBar
  final Color? backgroundColor;

  /// Elevation of the AppBar
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? appTheme.transparentCustom,
      elevation: elevation ?? 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title Text
            Text(
              title ?? "DeConnect",
              style:
                  titleTextStyle ??
                  TextStyleHelper.instance.headline24BoldSourceSerifPro
                      .copyWith(height: 1.29),
            ),

            // Action Icon Button
            if (actionIconPath != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: actionBackgroundColor ?? Color(0x33868686),
                ),
                child: IconButton(
                  onPressed: onActionPressed,
                  padding: EdgeInsets.all(6),
                  icon: CustomImageView(
                    imagePath: actionIconPath!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}

import 'package:flutter/material.dart';

import '../app_export.dart';
import './custom_image_view.dart';

/// CustomBottomBar - A customizable bottom navigation bar component
/// 
/// Features:
/// - Support for active/inactive states with different styling
/// - Rounded top corners with semi-transparent background
/// - Customizable icons and labels for each navigation item
/// - Tap handling with callback function
/// 
/// @param bottomBarItemList - List of bottom bar items with icons and labels
/// @param onChanged - Callback function triggered when item is tapped
/// @param selectedIndex - Currently selected item index (default: 0)
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.bottomBarItemList,
    required this.onChanged,
    this.selectedIndex = 0,
  });

  /// List of bottom bar items with their properties
  final List<CustomBottomBarItem> bottomBarItemList;

  /// Current selected index of the bottom bar
  final int selectedIndex;

  /// Callback function triggered when a bottom bar item is tapped
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appTheme.color7F053C, // Semi-transparent blue background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(bottomBarItemList.length, (index) {
            final isSelected = selectedIndex == index;
            final item = bottomBarItemList[index];

            return InkWell(
              onTap: () {
                onChanged(index);
              },
              child: _buildBottomBarItem(item, isSelected),
            );
          }),
        ),
      ),
    );
  }

  /// Builds individual bottom bar item widget
  Widget _buildBottomBarItem(CustomBottomBarItem item, bool isSelected) {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: appTheme.blue_900,
              borderRadius: BorderRadius.circular(22),
            )
          : null,
      padding: isSelected
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 2)
          : EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImageView(
            imagePath: item.icon ?? '',
            height: item.isCircular == true ? 30 : 24,
            width: item.isCircular == true ? 30 : 24,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 2),
          Text(
            item.title ?? '',
            style: TextStyleHelper.instance.body12MediumRoboto.copyWith(
              color: isSelected ? Color(0xFFFFFFFF) : appTheme.blue_900,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item data model for custom bottom bar
class CustomBottomBarItem {
  CustomBottomBarItem({
    this.icon,
    this.title,
    this.routeName,
    this.isCircular = false,
  });

  /// Path to the icon (SVG or other image format)
  final String? icon;

  /// Title text shown below the icon
  final String? title;

  /// Route name for navigation
  final String? routeName;

  /// Whether the icon should be displayed as circular
  final bool isCircular;
}

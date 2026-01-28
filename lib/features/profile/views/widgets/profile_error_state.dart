// lib/features/profile/views/widgets/profile_error_state.dart
import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';

class ProfileErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ProfileErrorState({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: appTheme.colorFFFF00,
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage ?? 'Something went wrong',
              style: TextStyleHelper.instance.body15MediumInter,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.blue_900,
              foregroundColor: appTheme.white_A700,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}
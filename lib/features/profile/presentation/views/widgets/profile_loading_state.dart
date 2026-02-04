// lib/features/profile/views/widgets/profile_loading_state.dart
import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';

class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: appTheme.blue_900,
      ),
    );
  }
}
// lib/features/profile/views/widgets/profile_loading_state.dart
import 'package:flutter/material.dart';

class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: CircularProgressIndicator(
        color: colors.primary,
      ),
    );
  }
}

// // lib/features/profile/views/widgets/profile_card.dart
// import 'package:flutter/material.dart';
// import '../../../../../core/app_export.dart';
// import '../../../../../core/widgets/custom_image_view.dart';
// import '../../../../auth/data/models/user_model.dart';
// import '../../../data/models/profile_status.dart';

// class ProfileCard extends StatelessWidget {
//   final User user;
//   final ProfileStats stats;
//   final VoidCallback? onEditProfile;
//   final VoidCallback? onSettings;
//   final VoidCallback? onLogout;

//   const ProfileCard({
//     super.key,
//     required this.user,
//     required this.stats,
//     this.onEditProfile,
//     this.onSettings,
//     this.onLogout,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: appTheme.white_A700,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: appTheme.greyCustom.withOpacity(0.1),
//             spreadRadius: 5,
//             blurRadius: 15,
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildProfileHeader(),
//           Divider(height: 40, color: appTheme.blue_gray_100),
//           _buildMenuTile(
//             Icons.person_outline,
//             'Edit Profile',
//             onTap: onEditProfile,
//           ),
//           _buildMenuTile(
//             Icons.settings_outlined,
//             'Settings',
//             onTap: onSettings,
//           ),
//           _buildMenuTile(
//             Icons.logout,
//             'Log Out',
//             isDestructive: true,
//             onTap: onLogout,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     return Row(
//       children: [
//         _buildAvatar(),
//         SizedBox(width: 15),
//         Expanded(
//           child: _buildUserInfo(),
//         ),
//       ],
//     );
//   }

//   Widget _buildAvatar() {
//     return Container(
//       width: 70,
//       height: 70,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: appTheme.blue_gray_100,
//       ),
//       child: user.avatarUrl != null
//           ? ClipOval(
//               child: CustomImageView(
//                 imagePath: user.avatarUrl,
//                 fit: BoxFit.cover,
//               ),
//             )
//           : Icon(
//               Icons.person,
//               size: 40,
//               color: appTheme.greyCustom,
//             ),
//     );
//   }

//   Widget _buildUserInfo() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           user.name,
//           style: TextStyleHelper.instance.title18BoldSourceSerifPro,
//         ),
//         SizedBox(height: 4),
//         Text(
//           user.email,
//           style: TextStyleHelper.instance.body15MediumInter.copyWith(
//             color: appTheme.greyCustom,
//           ),
//         ),
//         if (user.bio != null && user.bio!.isNotEmpty) ...[
//           SizedBox(height: 8),
//           Text(
//             user.bio!,
//             style: TextStyleHelper.instance.body12MediumRoboto,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildMenuTile(
//     IconData icon,
//     String title, {
//     bool isDestructive = false,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(
//         icon,
//         color: isDestructive ? appTheme.colorFFFF00 : appTheme.gray_900,
//       ),
//       title: Text(
//         title,
//         style: TextStyleHelper.instance.body15MediumInter.copyWith(
//           color: isDestructive ? appTheme.colorFFFF00 : appTheme.gray_900,
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         size: 16,
//         color: appTheme.greyCustom,
//       ),
//       onTap: onTap,
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_image_view.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../data/models/profile_status.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final ProfileStats stats;
  final VoidCallback? onEditProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const ProfileCard({
    super.key,
    required this.user,
    required this.stats,
    this.onEditProfile,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileHeader(context),
          Divider(height: 40, color: colors.onSurface.withOpacity(0.2)),
          _buildMenuTile(
            context,
            Icons.person_outline,
            'Edit Profile',
            onTap: onEditProfile,
          ),
          _buildMenuTile(
            context,
            Icons.settings_outlined,
            'Settings',
            onTap: onSettings,
          ),
          _buildMenuTile(
            context,
            Icons.logout,
            'Log Out',
            isDestructive: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        _buildAvatar(context),
        const SizedBox(width: 15),
        Expanded(child: _buildUserInfo(context)),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.onSurface.withOpacity(0.1),
      ),
      child: user.avatarUrl != null
          ? ClipOval(
              child: CustomImageView(
                imagePath: user.avatarUrl,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.person,
              size: 40,
              color: colors.onSurface.withOpacity(0.4),
            ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            user.bio!,
            style: textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tileColor =
        isDestructive ? colors.error : colors.onSurface;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: tileColor),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(color: tileColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colors.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }
}

// lib/features/chat/presentation/widgets/attachment_picker_sheet.dart
import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';
import '../../../../../core/config/chat_config.dart';

class AttachmentPickerSheet extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final VoidCallback onPickImages;
  final VoidCallback onPickFiles;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onRecordVideo;

  const AttachmentPickerSheet({
    super.key,
    required this.isDark,
    required this.isMobile,
    required this.onPickImages,
    required this.onPickFiles,
    this.onTakePhoto,
    this.onRecordVideo,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.photo_library, color: appTheme.blue_900),
            title: Text(
              'Images',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              'Up to ${ChatConfig.maxImages} images',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
            onTap: onPickImages,
          ),
          ListTile(
            leading: Icon(Icons.attach_file, color: appTheme.blue_900),
            title: Text(
              'Files',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              'Up to ${ChatConfig.maxFiles} files, ${ChatConfig.maxFileSizeMB}MB each',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
            onTap: onPickFiles,
          ),
          if (isMobile) ...[
            if (onTakePhoto != null)
              ListTile(
                leading: Icon(Icons.camera_alt, color: appTheme.blue_900),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: onTakePhoto,
              ),
            if (onRecordVideo != null)
              ListTile(
                leading: Icon(Icons.videocam, color: appTheme.blue_900),
                title: Text(
                  'Record Video',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: onRecordVideo,
              ),
          ],
          ListTile(
            leading: Icon(
              Icons.close,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
            title: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required bool isDark,
    required bool isMobile,
    required VoidCallback onPickImages,
    required VoidCallback onPickFiles,
    VoidCallback? onTakePhoto,
    VoidCallback? onRecordVideo,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) => AttachmentPickerSheet(
        isDark: isDark,
        isMobile: isMobile,
        onPickImages: onPickImages,
        onPickFiles: onPickFiles,
        onTakePhoto: onTakePhoto,
        onRecordVideo: onRecordVideo,
      ),
    );
  }
}
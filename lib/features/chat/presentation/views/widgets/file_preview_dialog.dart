// lib/features/chat/presentation/widgets/file_preview_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/app_export.dart';
import '../../../../../core/utils/file_utils.dart';

class FilePreviewDialog extends StatelessWidget {
  final List<File> files;
  final bool isImage;
  final bool isVideo;
  final bool isDark;
  final Function(String? caption) onSend;

  const FilePreviewDialog({
    super.key,
    required this.files,
    required this.isImage,
    this.isVideo = false,
    required this.isDark,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final captionController = TextEditingController();

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTitle(),
            const SizedBox(height: 16),
            _buildPreview(),
            const SizedBox(height: 16),
            if (files.length == 1) _buildCaptionField(captionController),
            if (files.length == 1) const SizedBox(height: 16),
            if (files.length > 1) _buildFileCount(),
            _buildActions(context, captionController),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final fileType = isVideo ? 'Video' : isImage ? 'Image' : 'File';
    return Text(
      'Send ${files.length} $fileType${files.length > 1 ? 's' : ''}',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPreview() {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: files.length == 1
            ? _buildSinglePreview(files.first)
            : _buildGridPreview(),
      ),
    );
  }

  Widget _buildSinglePreview(File file) {
    if (isImage) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVideo ? Icons.videocam : FileUtils.getFileIcon(file.path),
              size: 48,
              color: appTheme.blue_900,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                FileUtils.getFileName(file.path),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPreview() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: files.length > 9 ? 9 : files.length,
      itemBuilder: (context, index) {
        if (index == 8 && files.length > 9) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            child: Center(
              child: Text(
                '+${files.length - 8}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }

        final file = files[index];
        if (isImage) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(file, fit: BoxFit.cover),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FileUtils.getFileIcon(file.path),
                size: 24,
                color: appTheme.blue_900,
              ),
              const SizedBox(height: 4),
              Text(
                FileUtils.getFileName(file.path),
                style: TextStyle(
                  fontSize: 8,
                  color: isDark ? Colors.white : Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaptionField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: 'Add a caption (optional)',
        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: appTheme.blue_900),
        ),
      ),
    );
  }

  Widget _buildFileCount() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        '${files.length} files selected',
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(
      BuildContext context, TextEditingController captionController) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
              side: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final caption =
                  files.length == 1 ? captionController.text.trim() : null;
              onSend(caption);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.blue_900,
            ),
            child: Text(
              'Send${files.length > 1 ? " (${files.length})" : ""}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required List<File> files,
    required bool isImage,
    bool isVideo = false,
    required bool isDark,
    required Function(String? caption) onSend,
  }) {
    showDialog(
      context: context,
      builder: (context) => FilePreviewDialog(
        files: files,
        isImage: isImage,
        isVideo: isVideo,
        isDark: isDark,
        onSend: onSend,
      ),
    );
  }
}
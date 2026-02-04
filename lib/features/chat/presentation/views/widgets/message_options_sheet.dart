// lib/features/chat/presentation/widgets/message_options_sheet.dart
import 'package:flutter/material.dart';
import '../../../data/models/message_model.dart';

class MessageOptionsSheet extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isDark;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;

  const MessageOptionsSheet({
    super.key,
    required this.message,
    required this.isMe,
    required this.isDark,
    this.onEdit,
    this.onDelete,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          if (isMe && !message.isDeleted) ...[
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text(
                  'Edit',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: onEdit,
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: onDelete,
              ),
          ],
          if (message.content.isNotEmpty && !message.isDeleted && onCopy != null)
            ListTile(
              leading: Icon(
                Icons.copy,
                color: isDark ? Colors.white : Colors.black,
              ),
              title: Text(
                'Copy',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: onCopy,
            ),
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
    required ChatMessage message,
    required bool isMe,
    required bool isDark,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onCopy,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) => MessageOptionsSheet(
        message: message,
        isMe: isMe,
        isDark: isDark,
        onEdit: onEdit,
        onDelete: onDelete,
        onCopy: onCopy,
      ),
    );
  }
}
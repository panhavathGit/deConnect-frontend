// lib/features/chat/presentation/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/app_export.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/utils/file_utils.dart';
import '../../../../../core/utils/text_parser.dart';
import '../../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isDark;
  final VoidCallback onLongPress;
  final VoidCallback? onImageTap;
  final VoidCallback? onFileTap;
  final Function(String)? onUrlTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isDark,
    required this.onLongPress,
    this.onImageTap,
    this.onFileTap,
    this.onUrlTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return _buildDeletedMessage();
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe && message.senderName != null) _buildSenderName(),
              _buildMessageContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedMessage() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              'This message was deleted',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        message.senderName!,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Container(
      padding: message.hasMedia
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? appTheme.blue_900
            : (isDark ? Colors.grey[800] : Colors.grey[200]),
        borderRadius: BorderRadius.circular(16).copyWith(
          bottomRight: isMe ? const Radius.circular(4) : null,
          bottomLeft: !isMe ? const Radius.circular(4) : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.hasImage) _buildImageContent(),
          if (message.hasDocument) _buildDocumentContent(),
          // if (message.hasMedia && !message.isMediaOnly)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          //     child: Text(
          //       message.content,
          //       style: TextStyle(
          //         color: isMe
          //             ? Colors.white
          //             : (isDark ? Colors.white : Colors.black87),
          //         fontSize: 15,
          //       ),
          //     ),
          //   ),
          
          if (message.hasMedia && !message.isMediaOnly)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  color: isMe
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                ),
              ),
            ),


          if (!message.hasMedia)
            // TextParser.buildRichText(
            //   message.content,
            //   isMe: isMe,
            //   isDark: isDark,
            //   linkColor: isMe ? Colors.lightBlueAccent : appTheme.blue_900,
            //   onUrlTap: onUrlTap ?? (_) {},
            // ),
            GestureDetector(
              onLongPress: onLongPress, // Keep existing long press for options
              child: TextParser.buildRichText(
                message.content,
                isMe: isMe,
                isDark: isDark,
                linkColor: isMe ? Colors.lightBlueAccent : appTheme.blue_900,
                onUrlTap: onUrlTap ?? (_) {},
              ),
            ),
          _buildMessageFooter(),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    return GestureDetector(
      onTap: onImageTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (c, u) => Container(
            width: 200,
            height: 200,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (c, u, e) => Container(
            width: 200,
            height: 200,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    return GestureDetector(
      onTap: onFileTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.2)
              : (isDark ? Colors.grey[700] : Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              FileUtils.getFileIconFromType(message.mediaType ?? 'file'),
              size: 40,
              color: isMe ? Colors.white : appTheme.blue_900,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.displayFileName,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to open',
                    style: TextStyle(
                      color: isMe
                          ? Colors.white70
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageFooter() {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        right: message.hasMedia ? 8 : 0,
        bottom: message.hasMedia ? 4 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isEdited)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'edited',
                style: TextStyle(
                  color: isMe
                      ? Colors.white54
                      : (isDark ? Colors.grey[500] : Colors.black38),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Text(
            DateFormatter.formatTime(message.createdAt),
            style: TextStyle(
              color: isMe
                  ? Colors.white70
                  : (isDark ? Colors.grey[400] : Colors.black54),
              fontSize: 11,
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              message.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: message.isRead ? Colors.lightBlueAccent : Colors.white70,
            ),
          ],
        ],
      ),
    );
  }
}
// lib/features/chat/data/models/message_model.dart
// UPDATED: Edit, Delete, Read Receipts, File Types

class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final String? mediaUrl;
  final String? mediaType;  // 'image', 'pdf', 'document', 'video', 'audio', 'file'
  final String? fileName;   // Original file name
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;
  
  // Read receipts
  final bool isRead;
  final DateTime? readAt;
  
  // Edit functionality
  final bool isEdited;
  final DateTime? editedAt;
  
  // Delete functionality (soft delete)
  final bool isDeleted;
  final DateTime? deletedAt;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    this.mediaUrl,
    this.mediaType,
    this.fileName,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
    this.isRead = false,
    this.readAt,
    this.isEdited = false,
    this.editedAt,
    this.isDeleted = false,
    this.deletedAt,
  });

  // Check if message has any media
  bool get hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;
  
  // Check if media is an image
  bool get hasImage => hasMedia && (mediaType == 'image' || _isImageUrl(mediaUrl!));
  
  // Check if media is a document (PDF, DOC, etc.)
  bool get hasDocument => hasMedia && !hasImage;
  
  // Check if message is media only (no text)
  bool get isMediaOnly => hasMedia && content.isEmpty;
  
  // For backward compatibility
  bool get isImageOnly => isMediaOnly && hasImage;

  // Detect if URL is an image
  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') || 
           lower.contains('.jpeg') || 
           lower.contains('.png') || 
           lower.contains('.gif') || 
           lower.contains('.webp') ||
           lower.contains('.bmp');
  }

  // Get display name for file
  String get displayFileName {
    if (fileName != null && fileName!.isNotEmpty) {
      return fileName!;
    }
    if (mediaUrl != null) {
      final uri = Uri.parse(mediaUrl!);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return Uri.decodeComponent(segments.last);
      }
    }
    return 'File';
  }

  // Get file extension
  String get fileExtension {
    final name = displayFileName.toLowerCase();
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1);
    }
    return '';
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    String? senderName;
    String? senderAvatar;
    
    if (json['profiles'] != null) {
      senderName = json['profiles']['username'] ?? json['profiles']['full_name'];
      senderAvatar = json['profiles']['avatar_url'];
    }

    // Determine media type from URL or stored value
    String? mediaType = json['media_type'];
    final mediaUrl = json['media_url'];
    
    if (mediaType == null && mediaUrl != null) {
      final lower = mediaUrl.toString().toLowerCase();
      if (lower.contains('.jpg') || lower.contains('.jpeg') || 
          lower.contains('.png') || lower.contains('.gif') || 
          lower.contains('.webp')) {
        mediaType = 'image';
      } else if (lower.contains('.pdf')) {
        mediaType = 'pdf';
      } else if (lower.contains('.doc') || lower.contains('.docx')) {
        mediaType = 'document';
      } else if (lower.contains('.xls') || lower.contains('.xlsx')) {
        mediaType = 'spreadsheet';
      } else if (lower.contains('.ppt') || lower.contains('.pptx')) {
        mediaType = 'presentation';
      } else if (lower.contains('.mp4') || lower.contains('.mov') || lower.contains('.webm')) {
        mediaType = 'video';
      } else if (lower.contains('.mp3') || lower.contains('.wav') || lower.contains('.ogg')) {
        mediaType = 'audio';
      } else {
        mediaType = 'file';
      }
    }

    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      content: json['content'] ?? '',
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      fileName: json['file_name'],
      createdAt: DateTime.parse(json['created_at']),
      senderName: senderName,
      senderAvatar: senderAvatar,
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      isEdited: json['is_edited'] ?? false,
      editedAt: json['edited_at'] != null ? DateTime.parse(json['edited_at']) : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'file_name': fileName,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'is_deleted': isDeleted,
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
  
  // Create a copy with updated fields
  ChatMessage copyWith({
    String? content,
    bool? isRead,
    DateTime? readAt,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      content: content ?? this.content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      fileName: fileName,
      createdAt: createdAt,
      senderName: senderName,
      senderAvatar: senderAvatar,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
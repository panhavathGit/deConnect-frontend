// lib/features/chat/presentation/views/chat_room_page.dart
import 'package:onboarding_project/core/app_export.dart';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import '../../chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String? otherUserId;
  final String? initialLastSeenText;
  final bool initialIsOnline;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
    this.otherUserId,
    this.initialLastSeenText,
    this.initialIsOnline = false,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ChatRoomViewModel _viewModel;
  late FilePickerService _filePickerService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;
  bool _showEmojiPicker = false;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  // @override
  // void initState() {
  //   super.initState();
  //   _filePickerService = FilePickerService();
    
  //   final chatRepository = context.read<ChatListViewModel>().repository;
  //   _viewModel = ChatRoomViewModel(
  //     repository: chatRepository,
  //     roomId: widget.roomId,
  //     otherUserId: widget.otherUserId,
  //     initialLastSeenText: widget.initialLastSeenText,
  //     initialIsOnline: widget.initialIsOnline,
  //   );

  //   _messageController.addListener(_onTextChanged);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!_initialized) {
  //       _initialized = true;
  //       _viewModel.loadMessages();
  //     }
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   _filePickerService = FilePickerService();

  //   final chatRepository = context.read<ChatListViewModel>().repository;
  //   _viewModel = ChatRoomViewModel(
  //     repository: chatRepository,
  //     roomId: widget.roomId,
  //     otherUserId: widget.otherUserId,
  //     initialLastSeenText: widget.initialLastSeenText,
  //     initialIsOnline: widget.initialIsOnline,
  //   );

  //   // Update current room for notification filtering
  //   _setCurrentRoom(widget.roomId);

  //   _messageController.addListener(_onTextChanged);
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (!_initialized) {
  //       _initialized = true;
  //       _viewModel.loadMessages();
  //     }
  //   });
  // }

//   @override
// void initState() {
//   super.initState();
//   _filePickerService = FilePickerService();

//   final chatRepository = context.read<ChatListViewModel>().repository;
//   _viewModel = ChatRoomViewModel(
//     repository: chatRepository,
//     roomId: widget.roomId,
//     otherUserId: widget.otherUserId,
//     initialLastSeenText: widget.initialLastSeenText,
//     initialIsOnline: widget.initialIsOnline,
//   );

//   // ✅ Update current room after first frame
//   WidgetsBinding.instance.addPostFrameCallback((_) async {
//     await _setCurrentRoom(widget.roomId); // set current room in DB
//   });

//   _messageController.addListener(_onTextChanged);

//   // Load messages after first frame
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (!_initialized) {
//       _initialized = true;
//       _viewModel.loadMessages();
//     }
//   });
// }

@override
void initState() {
  super.initState();

  _filePickerService = FilePickerService();

  final chatRepository = context.read<ChatListViewModel>().repository;

  _viewModel = ChatRoomViewModel(
    repository: chatRepository,
    roomId: widget.roomId,
    otherUserId: widget.otherUserId,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _setCurrentRoom(widget.roomId);

    if (!_initialized) {
      _initialized = true;
      await _viewModel.loadMessages();
    }
  });

  _messageController.addListener(_onTextChanged);
}




@override
void dispose() {
  _messageController.removeListener(_onTextChanged);
  _messageController.dispose();
  _scrollController.dispose();

  // ✅ Clear current room when leaving
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _setCurrentRoom(null);
  });

  _viewModel.dispose();
  super.dispose();
}

  //   @override
  // void dispose() {
  //   _messageController.removeListener(_onTextChanged);
  //   _messageController.dispose();
  //   _scrollController.dispose();

  //   // Clear current room
  //   _setCurrentRoom(null);

  //   _viewModel.dispose();
  //   super.dispose();
  // }

  // Future<void> _setCurrentRoom(String? roomId) async {
  //   try {
  //     await SupabaseService.client
  //         .from('users')
  //         .update({'current_room_id': roomId})
  //         .eq('id', _viewModel.currentUserId);
  //   } catch (e) {
  //     debugPrint('Failed to update current room: $e');
  //   }
  // }

  // void _onTextChanged() {
  //   if (_messageController.text.isNotEmpty) {
  //     _viewModel.onTyping();
  //   }
  // }


/// Update current_room_id in Supabase for the current user

Future<void> _setCurrentRoom(String? roomId) async {
  try {
    if (_viewModel.currentUserId == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final response = await SupabaseService.client
        .from('user_devices')  // ✅ Correct table
        .update({'current_room_id': roomId})
        .eq('user_id', _viewModel.currentUserId)
        .eq('fcm_token', token);  // ✅ Update only current device

    if (response.error != null) {
      debugPrint('Failed to update current room: ${response.error!.message}');
    } else {
      debugPrint('current_room_id updated to: $roomId for device $token');
    }
  } catch (e) {
    debugPrint('Exception updating current room: $e');
  }
}

void _onTextChanged() {
  if (_messageController.text.isNotEmpty) {
    _viewModel.onTyping();
  }
}

  // @override
  // void dispose() {
  //   _messageController.removeListener(_onTextChanged);
  //   _messageController.dispose();
  //   _scrollController.dispose();
  //   _viewModel.dispose();
  //   super.dispose();
  // }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: ChatConfig.scrollAnimationDuration,
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendTextMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    
    _messageController.clear();
    final success = await _viewModel.sendMessage(content);
    
    if (success) {
      _scrollToBottom();
    } else if (mounted) {
      _showSnackBar(_viewModel.errorMessage ?? 'Failed to send', Colors.red);
    }
  }

  // File handling methods
  Future<void> _handlePickImages() async {
    Navigator.pop(context);
    try {
      final files = await _filePickerService.pickMultipleImages(
        maxImages: ChatConfig.maxImages,
      );
      if (files.isNotEmpty && mounted) {
        FilePreviewDialog.show(
          context,
          files: files,
          isImage: true,
          isDark: false,
          onSend: (caption) => _sendMultipleFiles(files, caption: caption),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _handlePickFiles() async {
    Navigator.pop(context);
    try {
      final files = await _filePickerService.pickMultipleFiles(
        maxFiles: ChatConfig.maxFiles,
        maxFileSizeBytes: ChatConfig.maxFileSizeBytes,
      );
      if (files.isNotEmpty && mounted) {
        FilePreviewDialog.show(
          context,
          files: files,
          isImage: false,
          isDark: false,
          onSend: (caption) => _sendMultipleFiles(files, caption: caption),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _handleTakePhoto() async {
    Navigator.pop(context);
    try {
      final file = await _filePickerService.takePhoto();
      if (file != null && mounted) {
        FilePreviewDialog.show(
          context,
          files: [file],
          isImage: true,
          isDark: false,
          onSend: (caption) => _sendMultipleFiles([file], caption: caption),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _handleRecordVideo() async {
    Navigator.pop(context);
    try {
      final file = await _filePickerService.recordVideo();
      if (file != null && mounted) {
        FilePreviewDialog.show(
          context,
          files: [file],
          isImage: false,
          isVideo: true,
          isDark: false,
          onSend: (caption) => _sendMultipleFiles([file], caption: caption),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _sendMultipleFiles(List<File> files, {String? caption}) async {
    int successCount = 0;
    for (int i = 0; i < files.length; i++) {
      final success = await _viewModel.sendFileMessage(
        files[i],
        caption: i == 0 ? caption : null,
      );
      if (success) successCount++;
    }
    
    if (mounted) {
      _scrollToBottom();
      final message = successCount == files.length
          ? 'Sent $successCount file${successCount > 1 ? 's' : ''} successfully!'
          : 'Sent $successCount, failed ${files.length - successCount}';
      final color =
          successCount == files.length ? Colors.green : Colors.orange;
      _showSnackBar(message, color);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showSnackBar('Could not open link', Colors.red);
    }
  }

  Future<void> _openFile(String url) async {
    try {
      final uri = Uri.parse(url);
      
      // Try external application first
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to platform default
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
      }
    } catch (e) {
      debugPrint('Error opening file: $e');
      if (mounted) {
        _showSnackBar('Could not open file. Error: ${e.toString()}', Colors.red);
      }
    }
  }

  void _viewFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageView(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const isDark = false;
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(child: _buildMessageList(isDark)),
            _buildTypingIndicatorSection(isDark),
            _buildUploadProgress(isDark),
            _buildMessageInput(isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    const isDark = false;
    
    return AppBar(
      title: Consumer<ChatRoomViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.roomName,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              // DISABLED: Online/Last seen status
              AnimatedSwitcher(
                duration: ChatConfig.typingAnimationDuration,
                child: viewModel.isOtherUserTyping
                    ? Row(
                        key: const ValueKey('typing'),
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          AnimatedTypingDots(),
                          SizedBox(width: 6),
                          Text(
                            'typing...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
                    // DISABLED: Last seen/online status display
                    // : viewModel.otherUserStatus.isNotEmpty
                    //     ? Text(
                    //         key: const ValueKey('lastseen'),
                    //         viewModel.otherUserStatus,
                    //         style: TextStyle(
                    //           color: viewModel.isOtherUserOnline
                    //               ? Colors.greenAccent
                    //               : Colors.white70,
                    //           fontSize: 13,
                    //         ),
                    //       )
                    //     : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          );
        },
      ),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () async {
            // Check if current user is admin and get avatar URL
            bool isAdmin = false;
            String? avatarUrl;
            try {
              final memberResponse = await SupabaseService.client
                  .from('room_members')
                  .select('is_admin')
                  .eq('room_id', widget.roomId)
                  .eq('user_id', _viewModel.currentUserId)
                  .single();
              isAdmin = memberResponse['is_admin'] ?? false;

              final roomResponse = await SupabaseService.client
                  .from('chat_rooms')
                  .select('avatar_url')
                  .eq('id', widget.roomId)
                  .single();
              avatarUrl = roomResponse['avatar_url'];
            } catch (e) {
              debugPrint('Error fetching group info: $e');
            }

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupInfoPage(
                  roomId: widget.roomId,
                  roomName: widget.roomName,
                  avatarUrl: avatarUrl,
                  isAdmin: isAdmin,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(bool isDark) {
    return Consumer<ChatRoomViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.messages.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: appTheme.blue_900),
          );
        }

        if (viewModel.status == ChatRoomStatus.error) {
          return _buildErrorView(viewModel);
        }

        if (viewModel.messages.isEmpty) {
          return _buildEmptyView(isDark);
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.messages.length,
          itemBuilder: (context, index) {
            final message = viewModel.messages[index];
            final isMe = message.senderId == viewModel.currentUserId;
            final showDateSeparator = index == viewModel.messages.length - 1 ||
                DateFormatter.shouldShowDateSeparator(
                  message.createdAt,
                  viewModel.messages[index + 1].createdAt,
                );

            return Column(
              children: [
                MessageBubble(
                  message: message,
                  isMe: isMe,
                  isDark: isDark,
                  onLongPress: () => _showMessageOptions(message, isMe),
                  onImageTap: () => _viewFullImage(message.mediaUrl!),
                  onFileTap: () => _openFile(message.mediaUrl!),
                  onUrlTap: _openUrl,
                ),
                if (showDateSeparator)
                  DateSeparator(dateTime: message.createdAt, isDark: isDark),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildErrorView(ChatRoomViewModel viewModel) {
    const isDark = false;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            viewModel.errorMessage ?? 'Failed',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.loadMessages(),
            style: ElevatedButton.styleFrom(backgroundColor: appTheme.blue_900),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicatorSection(bool isDark) {
    return Consumer<ChatRoomViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isOtherUserTyping && viewModel.typingUsers.length > 1) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            color: isDark ? const Color(0xFF121212) : Colors.white,
            child: Row(
              children: [
                TypingIndicator(isDark: isDark),
                const SizedBox(width: 8),
                Text(
                  '${viewModel.typingUsers.join(", ")} are typing...',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUploadProgress(bool isDark) {
    return Consumer<ChatRoomViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isUploadingImage) {
          return Container(
            padding: const EdgeInsets.all(12),
            color: isDark
                ? appTheme.blue_900.withValues(alpha: 0.2)
                : Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: appTheme.blue_900,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading...',
                  style: TextStyle(color: appTheme.blue_900),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: appTheme.blue_900),
                  onPressed: () => AttachmentPickerSheet.show(
                    context,
                    isDark: isDark,
                    isMobile: _isMobile,
                    onPickImages: _handlePickImages,
                    onPickFiles: _handlePickFiles,
                    onTakePhoto: _isMobile ? _handleTakePhoto : null,
                    onRecordVideo: _isMobile ? _handleRecordVideo : null,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                    color: appTheme.blue_900,
                  ),
                  onPressed: () {
                    setState(() => _showEmojiPicker = !_showEmojiPicker);
                    if (_showEmojiPicker) FocusScope.of(context).unfocus();
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onTap: () {
                      if (_showEmojiPicker) {
                        setState(() => _showEmojiPicker = false);
                      }
                    },
                    onSubmitted: (_) => _sendTextMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ChatRoomViewModel>(
                  builder: (context, viewModel, child) => CircleAvatar(
                    backgroundColor: appTheme.blue_900,
                    child: viewModel.isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.white, size: 20),
                            onPressed: _sendTextMessage,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showEmojiPicker) _buildEmojiPicker(isDark),
      ],
    );
  }

  Widget _buildEmojiPicker(bool isDark) {
    return SizedBox(
      height: 280,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
        },
        onBackspacePressed: () {
          final text = _messageController.text;
          if (text.isNotEmpty) {
            final characters = text.characters.toList();
            characters.removeLast();
            _messageController.text = characters.join();
            _messageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _messageController.text.length),
            );
          }
        },
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            indicatorColor: appTheme.blue_900,
            iconColor: isDark ? Colors.grey[400]! : Colors.grey,
            iconColorSelected: appTheme.blue_900,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessage message, bool isMe) {
    MessageOptionsSheet.show(
      context,
      message: message,
      isMe: isMe,
      isDark: false,
      onEdit: () {
        Navigator.pop(context);
        _showEditDialog(message);
      },
      onDelete: () {
        Navigator.pop(context);
        _showDeleteDialog(message);
      },
      onCopy: () => Navigator.pop(context),
    );
  }

  void _showEditDialog(ChatMessage message) {
    const isDark = false;
    final controller = TextEditingController(text: message.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Edit Message',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter new message',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.editMessage(
                message.id,
                controller.text.trim(),
              );
              if (mounted && !success) {
                _showSnackBar('Failed to edit message', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: appTheme.blue_900,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(ChatMessage message) {
    const isDark = false;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Delete Message',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to delete this message? This cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.deleteMessage(message.id);
              if (mounted && !success) {
                _showSnackBar('Failed to delete message', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
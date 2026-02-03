// lib/features/chat/views/chat_room_page.dart

import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../core/app_export.dart';
// import '../../../core/providers/theme_provider.dart';
import '../viewmodels/chat_room_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';
import '../data/models/message_model.dart';
import 'group_info_page.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;
  // NEW: For last seen feature
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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _initialized = false;
  bool _showEmojiPicker = false; 

  static const int maxImages = 100;
  static const int maxFiles = 20;
  static const int maxFileSizeMB = 150;
  static const int maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;

  bool get _isDesktop => !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
  bool get _isMobile => !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  @override
  void initState() {
    super.initState();
    _viewModel = ChatRoomViewModel(
      repository: ChatRepositoryImpl(remoteDataSource: ChatRemoteDataSourceImpl()),
      roomId: widget.roomId,
      otherUserId: widget.otherUserId,
      initialLastSeenText: widget.initialLastSeenText,
      initialIsOnline: widget.initialIsOnline,
    );
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _viewModel.loadMessages();
      }
    });
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty) {
      _viewModel.onTyping();
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.errorMessage ?? 'Failed to send'), backgroundColor: Colors.red),
      );
    }
  }

  // ============================================================
  // DATE SEPARATOR HELPERS
  // ============================================================
  String _getDateLabel(DateTime dateTime) {
    final now = DateTime.now();
    final localDate = dateTime.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(localDate.year, localDate.month, localDate.day);
    final difference = today.difference(messageDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(localDate);
    } else if (localDate.year == now.year) {
      return DateFormat('d MMMM').format(localDate);
    } else {
      return DateFormat('d MMMM yyyy').format(localDate);
    }
  }

  bool _shouldShowDateSeparator(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;

    final currentDate = messages[index].createdAt.toLocal();
    final previousDate = messages[index + 1].createdAt.toLocal();

    return currentDate.day != previousDate.day ||
        currentDate.month != previousDate.month ||
        currentDate.year != previousDate.year;
  }

  Widget _buildDateSeparator(DateTime dateTime, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getDateLabel(dateTime),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ATTACHMENT PICKER (Images, Files, Camera, Video)
  // ============================================================
  void _showAttachmentPicker() {
    // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: appTheme.blue_900),
              title: Text('Images', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              subtitle: Text('Up to $maxImages images', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
              onTap: () { Navigator.pop(context); _pickMultipleImages(); },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: appTheme.blue_900),
              title: Text('Files', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              subtitle: Text('Up to $maxFiles files, ${maxFileSizeMB}MB each', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
              onTap: () { Navigator.pop(context); _pickMultipleFiles(); },
            ),
            if (_isMobile) ...[
              ListTile(
                leading: Icon(Icons.camera_alt, color: appTheme.blue_900),
                title: Text('Take a Photo', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () { Navigator.pop(context); _takePhoto(); },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: appTheme.blue_900),
                title: Text('Record Video', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () { Navigator.pop(context); _recordVideo(); },
              ),
            ],
            ListTile(
              leading: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey),
              title: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMultipleImages() async {
    try {
      if (_isDesktop) {
        const XTypeGroup imageGroup = XTypeGroup(label: 'Images', extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp']);
        final files = await openFiles(acceptedTypeGroups: [imageGroup]);
        if (files.isNotEmpty && mounted) {
          _showMultipleFilesPreview(files.take(maxImages).map((f) => File(f.path)).toList(), isImage: true);
        }
      } else {
        final images = await _imagePicker.pickMultiImage(maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
        if (images.isNotEmpty && mounted) {
          _showMultipleFilesPreview(images.take(maxImages).map((f) => File(f.path)).toList(), isImage: true);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickMultipleFiles() async {
    try {
      const XTypeGroup allGroup = XTypeGroup(
        label: 'All Files',
        extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt', 'csv', 'zip', 'mp3', 'wav', 'mp4', 'mov'],
      );
      final files = await openFiles(acceptedTypeGroups: [allGroup]);
      if (files.isNotEmpty && mounted) {
        final validFiles = <File>[];
        for (final xfile in files.take(maxFiles)) {
          final file = File(xfile.path);
          final size = await file.length();
          if (size <= maxFileSizeBytes) validFiles.add(file);
        }
        if (validFiles.isNotEmpty) _showMultipleFilesPreview(validFiles, isImage: false);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.camera, maxWidth: 1920, maxHeight: 1920, imageQuality: 85);
      if (image != null && mounted) _showMultipleFilesPreview([File(image.path)], isImage: true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _recordVideo() async {
    try {
      final video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null && mounted) {
        _showMultipleFilesPreview([File(video.path)], isImage: false, isVideo: true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showMultipleFilesPreview(List<File> files, {required bool isImage, bool isVideo = false}) {
    // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;

    final captionController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
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
              Text(
                'Send ${files.length} ${isVideo ? 'Video' : isImage ? 'Image' : 'File'}${files.length > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: files.length == 1 ? _buildSinglePreview(files.first, isImage, isVideo, isDark) : _buildGridPreview(files, isImage, isDark),
                ),
              ),
              const SizedBox(height: 16),
              if (files.length == 1)
                TextField(
                  controller: captionController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Add a caption (optional)',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: appTheme.blue_900),
                    ),
                  ),
                ),
              if (files.length == 1) const SizedBox(height: 16),
              if (files.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('${files.length} files selected', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
                ),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _sendMultipleFiles(files, caption: files.length == 1 ? captionController.text.trim() : null);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: appTheme.blue_900),
                    child: Text('Send${files.length > 1 ? " (${files.length})" : ""}', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSinglePreview(File file, bool isImage, bool isVideo, bool isDark) {
    if (isImage) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.grey[800] : Colors.grey[200],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
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
            Icon(isVideo ? Icons.videocam : _getFileIcon(file.path), size: 48, color: appTheme.blue_900),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                file.path.split('/').last,
                style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black),
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

  Widget _buildGridPreview(List<File> files, bool isImage, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: files.length > 9 ? 9 : files.length,
      itemBuilder: (context, index) {
        if (index == 8 && files.length > 9) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            child: Center(child: Text('+${files.length - 8}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))),
          );
        }
        final file = files[index];
        if (isImage) return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, fit: BoxFit.cover));
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getFileIcon(file.path), size: 24, color: appTheme.blue_900),
              const SizedBox(height: 4),
              Text(
                file.path.split('/').last,
                style: TextStyle(fontSize: 8, color: isDark ? Colors.white : Colors.black),
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

  IconData _getFileIcon(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'zip': case 'rar': case '7z': return Icons.folder_zip;
      case 'mp3': case 'wav': case 'ogg': return Icons.audio_file;
      case 'mp4': case 'webm': case 'mov': case '3gp': return Icons.video_file;
      default: return Icons.insert_drive_file;
    }
  }

  Future<void> _sendMultipleFiles(List<File> files, {String? caption}) async {
    int successCount = 0;
    for (int i = 0; i < files.length; i++) {
      final success = await _viewModel.sendFileMessage(files[i], caption: i == 0 ? caption : null);
      if (success) successCount++;
    }
    if (mounted) {
      _scrollToBottom();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(successCount == files.length ? 'Sent $successCount file${successCount > 1 ? 's' : ''} successfully!' : 'Sent $successCount, failed ${files.length - successCount}'),
        backgroundColor: successCount == files.length ? Colors.green : Colors.orange,
      ));
    }
  }

  // ============================================================
  // EDIT MESSAGE
  // ============================================================
  void _showEditDialog(ChatMessage message) {
     // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;

    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Edit Message', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Enter new message',
            hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.editMessage(message.id, controller.text.trim());
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to edit message'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: appTheme.blue_900),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE MESSAGE
  // ============================================================
  void _showDeleteDialog(ChatMessage message) {
    // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Delete Message', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: Text(
          'Are you sure you want to delete this message? This cannot be undone.',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _viewModel.deleteMessage(message.id);
              if (mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete message'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE OPTIONS (Long press)
  // ============================================================
  void _showMessageOptions(ChatMessage message, bool isMe) {
     // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (isMe && !message.isDeleted) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text('Edit', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () { Navigator.pop(context); _showEditDialog(message); },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () { Navigator.pop(context); _showDeleteDialog(message); },
              ),
            ],
            if (message.content.isNotEmpty && !message.isDeleted)
              ListTile(
                leading: Icon(Icons.copy, color: isDark ? Colors.white : Colors.black),
                title: Text('Copy', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: Icon(Icons.close, color: isDark ? Colors.grey[400] : Colors.grey),
              title: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _viewFullImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (c, u) => const CircularProgressIndicator(color: Colors.white),
                errorWidget: (c, u, e) => const Icon(Icons.error, color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open file'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
     // final isDark = context.read<ThemeProvider>().isDarkMode;
    final isDark = false;
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        // ============================================================
        // APPBAR WITH TYPING / LAST SEEN (LIKE TELEGRAM)
        // ============================================================
        appBar: AppBar(
          title: Consumer<ChatRoomViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.roomName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  // Show typing indicator OR last seen status
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: viewModel.isOtherUserTyping
                        ? Row(
                            key: const ValueKey('typing'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildAppBarTypingDots(),
                              const SizedBox(width: 6),
                              const Text(
                                'typing...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          )
                        : viewModel.otherUserStatus.isNotEmpty
                            ? Text(
                                key: const ValueKey('lastseen'),
                                viewModel.otherUserStatus,
                                style: TextStyle(
                                  color: viewModel.isOtherUserOnline
                                      ? Colors.greenAccent
                                      : Colors.white70,
                                  fontSize: 13,
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              );
            },
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : appTheme.blue_900,
          foregroundColor: Colors.white,
          // ADD THIS ACTIONS PARAMETER
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                // You'll need to import the GroupInfoPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupInfoPage(
                      roomId: widget.roomId,
                      roomName: widget.roomName,
                      avatarUrl: null, // You can pass this if available
                      isAdmin: false, // You'll need to pass the actual admin status
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatRoomViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.isLoading && viewModel.messages.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: appTheme.blue_900));
                  }

                  if (viewModel.status == ChatRoomStatus.error) {
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

                  if (viewModel.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: isDark ? Colors.grey[400] : Colors.grey),
                          const SizedBox(height: 16),
                          Text('No messages yet', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMe = message.senderId == viewModel.currentUserId;
                      final showDateSeparator = _shouldShowDateSeparator(viewModel.messages, index);

                      return Column(
                        children: [
                          _buildMessageBubble(message, isMe, isDark),
                          if (showDateSeparator)
                            _buildDateSeparator(message.createdAt, isDark),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // Typing Indicator (bottom - optional, keep for group chats)
            Consumer<ChatRoomViewModel>(
              builder: (context, viewModel, _) {
                // Only show bottom typing indicator if there are multiple typing users (group chat)
                if (viewModel.isOtherUserTyping && viewModel.typingUsers.length > 1) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment: Alignment.centerLeft,
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    child: Row(
                      children: [
                        _buildTypingDots(isDark),
                        const SizedBox(width: 8),
                        Text(
                          '${viewModel.typingUsers.join(", ")} are typing...',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Upload Progress
            Consumer<ChatRoomViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isUploadingImage) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: isDark ? appTheme.blue_900.withValues(alpha: 0.2) : Colors.blue[50],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: appTheme.blue_900)),
                        const SizedBox(width: 12),
                        Text('Uploading...', style: TextStyle(color: appTheme.blue_900)),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            _buildMessageInput(isDark),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED TYPING DOTS FOR APPBAR (Like Telegram)
  // ============================================================
  Widget _buildAppBarTypingDots() {
    return SizedBox(
      width: 24,
      height: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) => _AnimatedTypingDot(delay: index * 150)),
      ),
    );
  }

  Widget _buildTypingDots(bool isDark) {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey[400] : Colors.grey)!.withValues(alpha: 0.3 + (0.7 * value)),
              shape: BoxShape.circle,
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, bool isDark) {
    if (message.isDeleted) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                'This message was deleted',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: () => _showMessageOptions(message, isMe),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe && message.senderName != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    message.senderName!,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                ),
              Container(
                padding: message.hasMedia ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? appTheme.blue_900 : (isDark ? Colors.grey[800] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomRight: isMe ? const Radius.circular(4) : null,
                    bottomLeft: !isMe ? const Radius.circular(4) : null,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.hasImage)
                      GestureDetector(
                        onTap: () => _viewFullImage(message.mediaUrl!),
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
                      ),
                    if (message.hasDocument)
                      GestureDetector(
                        onTap: () => _openFile(message.mediaUrl!),
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.white.withValues(alpha: 0.2) : (isDark ? Colors.grey[700] : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getFileIconFromType(message.mediaType ?? 'file'),
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
                                        color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
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
                                        color: isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (message.hasMedia && !message.isMediaOnly)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: Text(
                          message.content,
                          style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15),
                        ),
                      ),
                    if (!message.hasMedia)
                      _buildRichText(message.content, isMe, isDark),
                    // Time + Edited + Read Receipt
                    Padding(
                      padding: EdgeInsets.only(top: 4, right: message.hasMedia ? 8 : 0, bottom: message.hasMedia ? 4 : 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.isEdited)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                'edited',
                                style: TextStyle(
                                  color: isMe ? Colors.white54 : (isDark ? Colors.grey[500] : Colors.black38),
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Text(
                            _formatTime(message.createdAt),
                            style: TextStyle(
                              color: isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.black54),
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: message.isRead 
                                  ? Colors.lightBlueAccent  // Blue double check when read
                                  : Colors.white70,         // White/grey when not read
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFileIconFromType(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'document': return Icons.description;
      case 'spreadsheet': return Icons.table_chart;
      case 'presentation': return Icons.slideshow;
      case 'video': return Icons.video_file;
      case 'audio': return Icons.audio_file;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildMessageInput(bool isDark) {
  return Column(
    children: [
      // Message Input Bar
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 4, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Attachment Button
              IconButton(
                icon: Icon(Icons.attach_file, color: appTheme.blue_900),
                onPressed: _showAttachmentPicker,
              ),
              // NEW: Emoji Button
              IconButton(
                icon: Icon(
                  _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined,
                  color: appTheme.blue_900,
                ),
                onPressed: () {
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                  if (_showEmojiPicker) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
              // Text Field
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onTap: () {
                    // Hide emoji picker when keyboard opens
                    if (_showEmojiPicker) {
                      setState(() {
                        _showEmojiPicker = false;
                      });
                    }
                  },
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
              const SizedBox(width: 8),
              // Send Button
              Consumer<ChatRoomViewModel>(
                builder: (context, viewModel, child) => CircleAvatar(
                  backgroundColor: appTheme.blue_900,
                  child: viewModel.isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendTextMessage),
                ),
              ),
            ],
          ),
        ),
      ),
      // Emoji Picker (shown when _showEmojiPicker is true)
      if (_showEmojiPicker)
        SizedBox(
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
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                recentsLimit: 28,
                loadingIndicator: const SizedBox.shrink(),
                buttonMode: ButtonMode.MATERIAL,
              ),
              skinToneConfig: const SkinToneConfig(),
              categoryViewConfig: CategoryViewConfig(
                initCategory: Category.RECENT,
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                indicatorColor: appTheme.blue_900,
                iconColor: isDark ? Colors.grey[400]! : Colors.grey,
                iconColorSelected: appTheme.blue_900,
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
              ),
              bottomActionBarConfig: BottomActionBarConfig(
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                buttonColor: isDark ? Colors.grey[400]! : Colors.grey,
                buttonIconColor: isDark ? Colors.white : Colors.black,
              ),
              searchViewConfig: SearchViewConfig(
                backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                buttonIconColor: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
    ],
  );
}


  Widget _buildRichText(String text, bool isMe, bool isDark) {
    final urlRegex = RegExp(
      r'https?://[^\s<>"{}|\\^\[\]`]+',
      caseSensitive: false,
    );
    final matches = urlRegex.allMatches(text);
    if (matches.isEmpty) {
      return Text(text, style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15));
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15),
        ));
      }
      final url = match.group(0)!;
      spans.add(WidgetSpan(
        child: GestureDetector(
          onTap: () => _openUrl(url),
          child: Text(
            url,
            style: TextStyle(
              color: isMe ? Colors.lightBlueAccent : appTheme.blue_900,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: isMe ? Colors.lightBlueAccent : appTheme.blue_900,
            ),
          ),
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87), fontSize: 15),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================
// ANIMATED TYPING DOT WIDGET (For smooth animation like Telegram)
// ============================================================
class _AnimatedTypingDot extends StatefulWidget {
  final int delay;
  const _AnimatedTypingDot({required this.delay});

  @override
  State<_AnimatedTypingDot> createState() => _AnimatedTypingDotState();
}

class _AnimatedTypingDotState extends State<_AnimatedTypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _animation.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

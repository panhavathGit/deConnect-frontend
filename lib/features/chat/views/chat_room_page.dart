// lib/features/chat/views/chat_room_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../core/app_export.dart';
import '../viewmodels/chat_room_viewmodel.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../data/datasources/chat_remote_data_source.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ChatRoomViewModel _viewModel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatRoomViewModel(
      repository: ChatRepositoryImpl(
        remoteDataSource: ChatRemoteDataSourceImpl(),
      ),
      roomId: widget.roomId,
    );

    // ✅ Load messages ONCE in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _viewModel.loadMessages();
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) async {
    await _viewModel.sendMessage(message.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.roomName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF053CC7),
          foregroundColor: Colors.white,
        ),
        body: Consumer<ChatRoomViewModel>(
          builder: (context, viewModel, _) {
            debugPrint('🔍 ChatRoom Status: ${viewModel.status}, Loading: ${viewModel.isLoading}, Messages: ${viewModel.messages.length}');

            if (viewModel.isLoading && viewModel.messages.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF053CC7),
                ),
              );
            }

            if (viewModel.status == ChatRoomStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        viewModel.errorMessage ?? 'Failed to load messages',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.loadMessages(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Convert ChatMessage to flutter_chat_types Message
            final chatMessages = viewModel.messages.map((msg) {
              final isCurrentUser = msg.senderId == viewModel.currentUserId;

              return types.TextMessage(
                author: types.User(
                  id: msg.senderId,
                  firstName: msg.senderName ?? 'User',
                  imageUrl: msg.senderAvatar,
                ),
                createdAt: msg.createdAt.millisecondsSinceEpoch,
                id: msg.id,
                text: msg.content,
                status: isCurrentUser ? types.Status.sent : null,
              );
            }).toList();

            return Chat(
              messages: chatMessages,
              onSendPressed: _handleSendPressed,
              user: types.User(
                id: viewModel.currentUserId,
                firstName: 'You',
              ),
              theme: DefaultChatTheme(
                backgroundColor: Colors.white,
                primaryColor: const Color(0xFF053CC7),
                secondaryColor: const Color(0xFFF5F5F5),
                inputBackgroundColor: const Color(0xFFF5F5F5),
                inputTextColor: Colors.black,
                inputBorderRadius: BorderRadius.circular(24),
                messageBorderRadius: 20,
                sentMessageBodyTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                receivedMessageBodyTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
              showUserAvatars: false,  // ✅ Disable avatars to fix the floating circles
              showUserNames: false,    // ✅ Disable to prevent rendering issues
              emptyState: const Center(
                child: Text(
                  'No messages here yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
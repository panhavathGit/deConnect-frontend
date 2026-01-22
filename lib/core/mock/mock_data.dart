class MockUser {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;

  MockUser({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
  });
}

class MockMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MockMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class MockRoom {
  final String id;
  final String name;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final List<String> memberIds;

  MockRoom({
    required this.id,
    required this.name,
    this.lastMessage,
    this.lastMessageTime,
    required this.memberIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'member_ids': memberIds,
    };
  }
}

class MockData {
  // Current logged in user
  static final currentUser = MockUser(
    id: 'user-1',
    email: 'test@example.com',
    username: 'TestUser',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
  );

  // Other users
  static final users = [
    MockUser(
      id: 'user-2',
      email: 'john@example.com',
      username: 'John Doe',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    MockUser(
      id: 'user-3',
      email: 'jane@example.com',
      username: 'Jane Smith',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    MockUser(
      id: 'user-4',
      email: 'bob@example.com',
      username: 'Bob Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    MockUser(
      id: 'user-5',
      email: 'alice@example.com',
      username: 'Alice Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
  ];

  // Feed posts
  static final posts = [
    {
      'id': 'post-1',
      'content': 'Just finished an amazing Flutter project! 🚀 The MVVM architecture really helps keep things organized.',
      'user_id': 'user-2',
      'username': 'John Doe',
      'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'likes': 42,
    },
    {
      'id': 'post-2',
      'content': 'Looking for recommendations on state management solutions. What do you all prefer - Provider, Riverpod, or Bloc?',
      'user_id': 'user-3',
      'username': 'Jane Smith',
      'created_at': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      'likes': 28,
    },
    {
      'id': 'post-3',
      'content': 'Hot take: Dark mode should be the default for all apps. Fight me! 😎',
      'user_id': 'user-4',
      'username': 'Bob Wilson',
      'created_at': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      'likes': 156,
    },
    {
      'id': 'post-4',
      'content': 'Check out this cool animation I made with Flutter! The performance is incredible even on older devices.',
      'user_id': 'user-5',
      'username': 'Alice Johnson',
      'created_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      'likes': 89,
    },
    {
      'id': 'post-5',
      'content': 'Pro tip: Always use const constructors when possible. It can significantly improve your app\'s performance!',
      'user_id': 'user-2',
      'username': 'John Doe',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'likes': 67,
    },
    {
      'id': 'post-6',
      'content': 'Just deployed my first app to the App Store! 🎉 The journey was challenging but so rewarding.',
      'user_id': 'user-3',
      'username': 'Jane Smith',
      'created_at': DateTime.now().subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
      'likes': 234,
    },
    {
      'id': 'post-7',
      'content': 'Anyone else spending their weekend debugging layout issues? Just me? 😅',
      'user_id': 'user-4',
      'username': 'Bob Wilson',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'likes': 112,
    },
    {
      'id': 'post-8',
      'content': 'The new Flutter 3.0 features are absolutely game-changing. Can\'t wait to implement them in production!',
      'user_id': 'user-5',
      'username': 'Alice Johnson',
      'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'likes': 178,
    },
  ];

  // Chat rooms
  static final rooms = [
    MockRoom(
      id: 'room-1',
      name: 'John Doe',
      lastMessage: 'Hey! How are you doing?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
      memberIds: ['user-1', 'user-2'],
    ),
    MockRoom(
      id: 'room-2',
      name: 'Jane Smith',
      lastMessage: 'Did you see my latest post?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      memberIds: ['user-1', 'user-3'],
    ),
    MockRoom(
      id: 'room-3',
      name: 'Bob Wilson',
      lastMessage: 'Thanks for the help earlier!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
      memberIds: ['user-1', 'user-4'],
    ),
    MockRoom(
      id: 'room-4',
      name: 'Alice Johnson',
      lastMessage: 'Let\'s catch up soon 😊',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      memberIds: ['user-1', 'user-5'],
    ),
  ];

  // Messages for different rooms
  static final Map<String, List<MockMessage>> messagesByRoom = {
    'room-1': [
      MockMessage(
        id: 'msg-1',
        roomId: 'room-1',
        senderId: 'user-2',
        content: 'Hey! How are you doing?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      MockMessage(
        id: 'msg-2',
        roomId: 'room-1',
        senderId: 'user-1',
        content: 'I\'m great! Just working on this Flutter app.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
      ),
      MockMessage(
        id: 'msg-3',
        roomId: 'room-1',
        senderId: 'user-2',
        content: 'Nice! What features are you building?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      MockMessage(
        id: 'msg-4',
        roomId: 'room-1',
        senderId: 'user-1',
        content: 'A social feed and chat system with MVVM architecture.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 23)),
      ),
      MockMessage(
        id: 'msg-5',
        roomId: 'room-1',
        senderId: 'user-2',
        content: 'Sounds awesome! Let me know if you need any help.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
    'room-2': [
      MockMessage(
        id: 'msg-6',
        roomId: 'room-2',
        senderId: 'user-3',
        content: 'Did you see my latest post?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MockMessage(
        id: 'msg-7',
        roomId: 'room-2',
        senderId: 'user-1',
        content: 'Yes! Great question about state management.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
      ),
      MockMessage(
        id: 'msg-8',
        roomId: 'room-2',
        senderId: 'user-3',
        content: 'Thanks! I\'m leaning towards Riverpod.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
      ),
    ],
    'room-3': [
      MockMessage(
        id: 'msg-9',
        roomId: 'room-3',
        senderId: 'user-1',
        content: 'Did that solution work for you?',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      MockMessage(
        id: 'msg-10',
        roomId: 'room-3',
        senderId: 'user-4',
        content: 'Yes! It worked perfectly.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      ),
      MockMessage(
        id: 'msg-11',
        roomId: 'room-3',
        senderId: 'user-4',
        content: 'Thanks for the help earlier!',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'room-4': [
      MockMessage(
        id: 'msg-12',
        roomId: 'room-4',
        senderId: 'user-5',
        content: 'Hey! Long time no talk!',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      MockMessage(
        id: 'msg-13',
        roomId: 'room-4',
        senderId: 'user-1',
        content: 'I know! We should definitely catch up.',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      ),
      MockMessage(
        id: 'msg-14',
        roomId: 'room-4',
        senderId: 'user-5',
        content: 'Let\'s catch up soon 😊',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };
}

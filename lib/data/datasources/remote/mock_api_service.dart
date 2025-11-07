import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/entities/chat_preview.dart';

class MockApiService {
  static const _uuid = Uuid();
  final Random _random = Random();

  // Mock users database
  static final List<User> _mockUsers = [
    const User(
      id: '1',
      name: 'John Smith',
      email: 'john@example.com',
      avatarUrl: null,
      isOnline: true,
      status: 'How are you today?',
    ),
    const User(
      id: '2',
      name: 'Team Spruce',
      email: 'team@example.com',
      avatarUrl: null,
      isOnline: true,
      status: 'Don\'t miss to attend the meeting.',
    ),
    const User(
      id: '3',
      name: 'Alex Wright',
      email: 'alex@example.com',
      avatarUrl: null,
      isOnline: true,
      status: 'Active now',
    ),
    const User(
      id: '4',
      name: 'Jenny Jenks',
      email: 'jenny@example.com',
      avatarUrl: null,
      isOnline: false,
      status: 'How are you today?',
    ),
    const User(
      id: '5',
      name: 'Matthew Bruno',
      email: 'matthew@example.com',
      avatarUrl: null,
      isOnline: true,
      status: 'Have a good day',
    ),
  ];

  // Mock messages database
  static final Map<String, List<Message>> _mockMessages = {};

  // Current logged-in user
  User? _currentUser;

  // Simulated typing indicator
  final _typingController = StreamController<Map<String, bool>>.broadcast();
  Stream<Map<String, bool>> get typingStream => _typingController.stream;

  // Initialize mock messages
  MockApiService() {
    _initializeMockMessages();
  }

  void _initializeMockMessages() {
    // Messages with Alex Wright
    _mockMessages['3'] = [
      Message(
        id: '1',
        senderId: '3',
        receiverId: 'current',
        content: 'Hey Alex! How\'s it going?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        senderName: 'Alex Wright',
      ),
      Message(
        id: '2',
        senderId: 'current',
        receiverId: '3',
        content: 'Great! You?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: '3',
        senderId: '3',
        receiverId: 'current',
        content: 'Good! I just wanted to say good job on the design!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: true,
        senderName: 'Alex Wright',
      ),
      Message(
        id: '4',
        senderId: 'current',
        receiverId: '3',
        content: 'Thanks!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: true,
      ),
      Message(
        id: '5',
        senderId: '3',
        receiverId: 'current',
        content: 'Glad you like it!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: true,
        senderName: 'Alex Wright',
      ),
      Message(
        id: '6',
        senderId: 'current',
        receiverId: '3',
        content: 'Have a great weekend!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
    ];

    // Messages with John Smith
    _mockMessages['1'] = [
      Message(
        id: '7',
        senderId: '1',
        receiverId: 'current',
        content: 'Hi there! How are you today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isRead: false,
        senderName: 'John Smith',
      ),
    ];

    // Messages with Team Spruce
    _mockMessages['2'] = [
      Message(
        id: '8',
        senderId: '2',
        receiverId: 'current',
        content: 'Don\'t miss to attend the meeting.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isRead: false,
        senderName: 'Team Spruce',
      ),
    ];
  }

  /// Authentication
  Future<User> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Mock login - accept any email with password length >= 6
    _currentUser = User(
      id: 'current',
      name: 'You',
      email: email,
      isOnline: true,
      status: 'Active now',
    );

    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  User? getCurrentUser() => _currentUser;

  /// Chat previews for home screen
  Future<List<ChatPreview>> getChatPreviews() async {
    await Future.delayed(const Duration(seconds: 1));

    return _mockUsers.map((user) {
      final messages = _mockMessages[user.id] ?? [];
      final lastMessage = messages.isNotEmpty
          ? messages.last
          : Message(
        id: '',
        senderId: user.id,
        receiverId: 'current',
        content: 'No messages yet',
        timestamp: DateTime.now(),
      );

      final unreadCount = messages
          .where((m) => m.senderId == user.id && !m.isRead)
          .length;

      return ChatPreview(
        user: user,
        lastMessage: lastMessage.content,
        lastMessageTime: lastMessage.timestamp,
        unreadCount: unreadCount,
        isOnline: user.isOnline,
      );
    }).toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  /// Get messages for a specific chat
  Future<List<Message>> getMessages(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockMessages[userId] ?? []);
  }

  /// Send a new message
  Future<Message> sendMessage({
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final message = Message(
      id: _uuid.v4(),
      senderId: 'current',
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    if (_mockMessages[receiverId] == null) {
      _mockMessages[receiverId] = [];
    }
    _mockMessages[receiverId]!.add(message);

    // Simulate auto-reply after a delay (30% chance)
    if (_random.nextDouble() < 0.3) {
      _simulateAutoReply(receiverId);
    }

    return message;
  }

  /// Simulate typing indicator
  void startTyping(String userId) {
    _typingController.add({userId: true});

    // Auto-stop typing after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _typingController.add({userId: false});
    });
  }

  void stopTyping(String userId) {
    _typingController.add({userId: false});
  }

  /// Mark messages as read
  Future<void> markAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final messages = _mockMessages[userId];
    if (messages != null) {
      for (var i = 0; i < messages.length; i++) {
        if (messages[i].senderId == userId) {
          messages[i] = messages[i].copyWith(isRead: true);
        }
      }
    }
  }

  /// Simulate auto-reply from other users
  void _simulateAutoReply(String userId) {
    final user = _mockUsers.firstWhere((u) => u.id == userId);
    final responses = [
      'Thanks!',
      'Got it!',
      'Sure thing!',
      'Sounds good!',
      '👍',
      'Will do!',
      'Awesome!',
    ];

    // Show typing indicator
    Future.delayed(const Duration(seconds: 2), () {
      startTyping(userId);
    });

    // Send reply
    Future.delayed(const Duration(seconds: 5), () {
      final reply = Message(
        id: _uuid.v4(),
        senderId: userId,
        receiverId: 'current',
        content: responses[_random.nextInt(responses.length)],
        type: MessageType.text,
        timestamp: DateTime.now(),
        isRead: false,
        senderName: user.name,
      );

      _mockMessages[userId]!.add(reply);
      stopTyping(userId);
    });
  }

  void dispose() {
    _typingController.close();
  }
}
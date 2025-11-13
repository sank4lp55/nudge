
import 'package:nudge/domain/entities/message.dart';

abstract class ChatListEvent {}

class LoadChatListEvent extends ChatListEvent {}

class RefreshChatListEvent extends ChatListEvent {}

class UpdateChatPreviewEvent extends ChatListEvent {
  final String userId;
  final String lastMessage;
  final DateTime timestamp;

  UpdateChatPreviewEvent({
    required this.userId,
    required this.lastMessage,
    required this.timestamp,
  });
}

// NEW: Event for when a message is received (for real-time updates)
class MessageReceivedInListEvent extends ChatListEvent {
  final Message message;

  MessageReceivedInListEvent(this.message);
}
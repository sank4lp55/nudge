import '../entities/chat_preview.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<ChatPreview>> getChatPreviews();
  Future<List<Message>> getMessages(String userId);
  Future<Message> sendMessage({
    required String receiverId,
    required String content,
  });
  Future<void> markAsRead(String userId);
  Stream<Map<String, bool>> get typingStream;
  void startTyping(String userId);
  void stopTyping(String userId);
  Stream<Message> get messageStream;
}
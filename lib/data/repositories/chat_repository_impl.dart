import 'package:nudge/data/datasources/remote/mock_api_service.dart';
import 'package:nudge/domain/repositories/chat_repositories.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/chat_preview.dart';

class ChatRepositoryImpl implements ChatRepository {
  final MockApiService _apiService;

  ChatRepositoryImpl(this._apiService);

  @override
  Stream<Map<String, bool>> get typingStream => _apiService.typingStream;

  @override
  Stream<Message> get messageStream => _apiService.messageStream;

  @override
  Future<List<ChatPreview>> getChatPreviews() async {
    return await _apiService.getChatPreviews();
  }

  @override
  Future<List<Message>> getMessages(String userId) async {
    return await _apiService.getMessages(userId);
  }

  @override
  Future<Message> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    return await _apiService.sendMessage(
      receiverId: receiverId,
      content: content,
    );
  }

  @override
  Future<void> markAsRead(String userId) async {
    await _apiService.markAsRead(userId);
  }

  @override
  void startTyping(String userId) {
    _apiService.startTyping(userId);
  }

  @override
  void stopTyping(String userId) {
    _apiService.stopTyping(userId);
  }
}
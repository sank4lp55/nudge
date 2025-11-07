import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_preview.dart';
import '../../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatPreviewsLoaded extends ChatState {
  final List<ChatPreview> chatPreviews;

  const ChatPreviewsLoaded(this.chatPreviews);

  @override
  List<Object?> get props => [chatPreviews];
}

class MessagesLoaded extends ChatState {
  final List<Message> messages;
  final String userId;
  final Map<String, bool> typingStatus;

  const MessagesLoaded({
    required this.messages,
    required this.userId,
    this.typingStatus = const {},
  });

  MessagesLoaded copyWith({
    List<Message>? messages,
    String? userId,
    Map<String, bool>? typingStatus,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      userId: userId ?? this.userId,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }

  @override
  List<Object?> get props => [messages, userId, typingStatus];
}

class MessageSending extends ChatState {
  final List<Message> messages;
  final String userId;

  const MessageSending({
    required this.messages,
    required this.userId,
  });

  @override
  List<Object?> get props => [messages, userId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

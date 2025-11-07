import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatPreviewsEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String userId;

  const LoadMessagesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SendMessageEvent extends ChatEvent {
  final String receiverId;
  final String content;

  const SendMessageEvent({
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [receiverId, content];
}

class MarkAsReadEvent extends ChatEvent {
  final String userId;

  const MarkAsReadEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StartTypingEvent extends ChatEvent {
  final String userId;

  const StartTypingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StopTypingEvent extends ChatEvent {
  final String userId;

  const StopTypingEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class TypingStatusChangedEvent extends ChatEvent {
  final Map<String, bool> typingStatus;

  const TypingStatusChangedEvent(this.typingStatus);

  @override
  List<Object?> get props => [typingStatus];
}
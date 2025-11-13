abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String userId;

  LoadMessagesEvent(this.userId);
}

class SendMessageEvent extends ChatEvent {
  final String receiverId;
  final String content;

  SendMessageEvent({
    required this.receiverId,
    required this.content,
  });
}

class MarkAsReadEvent extends ChatEvent {
  final String userId;

  MarkAsReadEvent(this.userId);
}

class StartTypingEvent extends ChatEvent {
  final String userId;

  StartTypingEvent(this.userId);
}

class StopTypingEvent extends ChatEvent {
  final String userId;

  StopTypingEvent(this.userId);
}

class TypingStatusChangedEvent extends ChatEvent {
  final Map<String, bool> typingStatus;

  TypingStatusChangedEvent(this.typingStatus);
}

class MessageReceivedEvent extends ChatEvent {
  final dynamic message;

  MessageReceivedEvent(this.message);
}
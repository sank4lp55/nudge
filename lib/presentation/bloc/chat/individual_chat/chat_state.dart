import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<dynamic> messages; // Replace with your Message model
  final String userId;
  final Map<String, bool> typingStatus;

  MessagesLoaded({
    required this.messages,
    required this.userId,
    this.typingStatus = const {},
  });

  MessagesLoaded copyWith({
    List<dynamic>? messages,
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
  final List<dynamic> messages;
  final String userId;

  MessageSending({
    required this.messages,
    required this.userId,
  });

  @override
  List<Object?> get props => [messages, userId];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
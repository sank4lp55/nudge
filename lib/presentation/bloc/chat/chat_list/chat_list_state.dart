import 'package:equatable/equatable.dart';

abstract class ChatListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<dynamic> chatPreviews; // Replace with your ChatPreview model

  ChatListLoaded(this.chatPreviews);

  @override
  List<Object?> get props => [chatPreviews];
}

class ChatListError extends ChatListState {
  final String message;

  ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nudge/domain/repositories/chat_repositories.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _typingSubscription;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadChatPreviewsEvent>(_onLoadChatPreviews);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<StartTypingEvent>(_onStartTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<TypingStatusChangedEvent>(_onTypingStatusChanged);

    // Listen to typing indicator stream
    _typingSubscription = _chatRepository.typingStream.listen((typingStatus) {
      add(TypingStatusChangedEvent(typingStatus));
    });
  }

  Future<void> _onLoadChatPreviews(
      LoadChatPreviewsEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoading());

    try {
      final chatPreviews = await _chatRepository.getChatPreviews();
      emit(ChatPreviewsLoaded(chatPreviews));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    emit(ChatLoading());

    try {
      final messages = await _chatRepository.getMessages(event.userId);
      emit(MessagesLoaded(messages: messages, userId: event.userId));

      // Mark messages as read
      add(MarkAsReadEvent(event.userId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<ChatState> emit,
      ) async {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;

      emit(MessageSending(
        messages: currentState.messages,
        userId: event.receiverId,
      ));

      try {
        final newMessage = await _chatRepository.sendMessage(
          receiverId: event.receiverId,
          content: event.content,
        );

        final updatedMessages = [...currentState.messages, newMessage];
        emit(MessagesLoaded(
          messages: updatedMessages,
          userId: event.receiverId,
          typingStatus: currentState.typingStatus,
        ));
      } catch (e) {
        emit(MessagesLoaded(
          messages: currentState.messages,
          userId: event.receiverId,
          typingStatus: currentState.typingStatus,
        ));
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsReadEvent event,
      Emitter<ChatState> emit,
      ) async {
    try {
      await _chatRepository.markAsRead(event.userId);
    } catch (e) {
      // Silently fail, not critical
    }
  }

  void _onStartTyping(
      StartTypingEvent event,
      Emitter<ChatState> emit,
      ) {
    _chatRepository.startTyping(event.userId);
  }

  void _onStopTyping(
      StopTypingEvent event,
      Emitter<ChatState> emit,
      ) {
    _chatRepository.stopTyping(event.userId);
  }

  void _onTypingStatusChanged(
      TypingStatusChangedEvent event,
      Emitter<ChatState> emit,
      ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      emit(currentState.copyWith(typingStatus: event.typingStatus));
    }
  }

  @override
  Future<void> close() {
    _typingSubscription?.cancel();
    return super.close();
  }
}
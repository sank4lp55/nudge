import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nudge/domain/repositories/chat_repositories.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _messageSubscription;
  String? _currentUserId; // Track which user we're chatting with

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<StartTypingEvent>(_onStartTyping);
    on<StopTypingEvent>(_onStopTyping);
    on<TypingStatusChangedEvent>(_onTypingStatusChanged);
    on<MessageReceivedEvent>(_onMessageReceived);

    // Listen to typing indicator stream
    _typingSubscription = _chatRepository.typingStream.listen((typingStatus) {
      add(TypingStatusChangedEvent(typingStatus));
    });

    // Listen to new messages stream
    _messageSubscription = _chatRepository.messageStream.listen((message) {
      // Only add message if it's for the current chat
      if (_currentUserId != null &&
          (message.senderId == _currentUserId ||
              message.receiverId == _currentUserId)) {
        add(MessageReceivedEvent(message));
      }
    });
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event,
      Emitter<ChatState> emit,
      ) async {
    _currentUserId = event.userId; // Track current user
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

      // Don't emit MessageSending - just optimistically add the message
      try {
        final newMessage = await _chatRepository.sendMessage(
          receiverId: event.receiverId,
          content: event.content,
        );

        // Only update if we're still in the same chat
        if (state is MessagesLoaded &&
            (state as MessagesLoaded).userId == event.receiverId) {
          final updatedMessages = [...currentState.messages, newMessage];
          emit(MessagesLoaded(
            messages: updatedMessages,
            userId: event.receiverId,
            typingStatus: currentState.typingStatus,
          ));
        }
      } catch (e) {
        // Keep current state on error
        emit(currentState);
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

  void _onMessageReceived(
      MessageReceivedEvent event,
      Emitter<ChatState> emit,
      ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;

      // Check if message is already in the list (avoid duplicates)
      final messageExists = currentState.messages.any((m) => m.id == event.message.id);

      if (!messageExists) {
        final updatedMessages = [...currentState.messages, event.message];
        emit(currentState.copyWith(messages: updatedMessages));
      }
    }
  }

  @override
  Future<void> close() {
    _typingSubscription?.cancel();
    _messageSubscription?.cancel();
    _currentUserId = null;
    return super.close();
  }
}
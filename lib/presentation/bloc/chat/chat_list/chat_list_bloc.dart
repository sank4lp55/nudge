import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nudge/domain/entities/chat_preview.dart';
import 'package:nudge/domain/repositories/chat_repositories.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  StreamSubscription? _messageSubscription;

  ChatListBloc(this._chatRepository) : super(ChatListInitial()) {
    on<LoadChatListEvent>(_onLoadChatList);
    on<RefreshChatListEvent>(_onRefreshChatList);
    on<UpdateChatPreviewEvent>(_onUpdateChatPreview);
    on<MessageReceivedInListEvent>(_onMessageReceivedInList);

    // Listen to new messages to update chat previews in real-time
    _messageSubscription = _chatRepository.messageStream.listen((message) {
      add(MessageReceivedInListEvent(message));
    });
  }

  Future<void> _onLoadChatList(
    LoadChatListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    // Only show loading if we don't have data yet
    if (state is! ChatListLoaded) {
      emit(ChatListLoading());
    }

    try {
      final chatPreviews = await _chatRepository.getChatPreviews();
      emit(ChatListLoaded(chatPreviews));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onRefreshChatList(
    RefreshChatListEvent event,
    Emitter<ChatListState> emit,
  ) async {
    // Don't show loading state during refresh
    try {
      final chatPreviews = await _chatRepository.getChatPreviews();
      emit(ChatListLoaded(chatPreviews));
    } catch (e) {
      // Keep the current state if refresh fails
      if (state is! ChatListLoaded) {
        emit(ChatListError(e.toString()));
      }
    }
  }

  void _onUpdateChatPreview(
    UpdateChatPreviewEvent event,
    Emitter<ChatListState> emit,
  ) {
    if (state is ChatListLoaded) {
      final currentState = state as ChatListLoaded;
      final updatedPreviews = currentState.chatPreviews.map((preview) {
        if (preview.user.id == event.userId) {
          return preview.copyWith(
            lastMessage: event.lastMessage,
            lastMessageTime: event.timestamp,
          );
        }
        return preview;
      }).toList();

      // Sort: most recent first, unread prioritized
      _sortChatPreviews(updatedPreviews);

      emit(ChatListLoaded(updatedPreviews));
    }
  }

  void _onMessageReceivedInList(
    MessageReceivedInListEvent event,
    Emitter<ChatListState> emit,
  ) {
    if (state is ChatListLoaded) {
      final currentState = state as ChatListLoaded;
      final message = event.message;

      // Determine which user this message is associated with
      final userId = message.senderId == 'current'
          ? message.receiverId
          : message.senderId;

      // Update the chat preview for this user
      final updatedPreviews = currentState.chatPreviews.map((preview) {
        if (preview.user.id == userId) {
          // Update unread count only if message is from other user
          final newUnreadCount = message.senderId == 'current'
              ? preview.unreadCount
              : preview.unreadCount + 1;

          return preview.copyWith(
            lastMessage: message.content,
            lastMessageTime: message.timestamp,
            unreadCount: newUnreadCount,
          );
        }
        return preview;
      }).toList();

      // Sort: most recent first, unread prioritized
      _sortChatPreviews(updatedPreviews);

      emit(ChatListLoaded(updatedPreviews));
    }
  }

  // Helper method for simple time-based sorting
  void _sortChatPreviews(List<dynamic> previews) {
    previews.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

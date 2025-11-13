import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nudge/presentation/widgets/chat_list_item.dart';
import 'package:nudge/presentation/widgets/empty_state_widget.dart';
import 'package:nudge/presentation/widgets/error_state_widget.dart';
import '../bloc/chat/chat_list/chat_list_bloc.dart';
import '../bloc/chat/chat_list/chat_list_event.dart';
import '../bloc/chat/chat_list/chat_list_state.dart';
import 'chat_screen.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(LoadChatListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  if (state is ChatListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryPurple,
                      ),
                    );
                  }

                  if (state is ChatListError) {
                    return ErrorState(
                      message: state.message,
                      onRetry: () {
                        context.read<ChatListBloc>().add(LoadChatListEvent());
                      },
                    );
                  }

                  if (state is ChatListLoaded) {
                    if (state.chatPreviews.isEmpty) {
                      return const EmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ChatListBloc>().add(
                          RefreshChatListEvent(),
                        );
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      color: AppTheme.primaryPurple,
                      backgroundColor: AppTheme.cardBackground,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: state.chatPreviews.length,
                        itemBuilder: (context, index) {
                          final chat = state.chatPreviews[index];
                          return ModernChatListItem(
                            chat: chat,
                            onTap: () {
                              // Navigate to ChatScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(user: chat.user),
                                ),
                              ).then((_) {
                                // Refresh the chat list when coming back
                                // This will fetch updated unread counts from the repository
                                context.read<ChatListBloc>().add(
                                  RefreshChatListEvent(),
                                );
                              });
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.messageBackground.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          _buildIconButton(
            icon: Icons.search_rounded,
            onPressed: () {
              // TODO: Implement search
            },
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: Icons.more_vert_rounded,
            onPressed: () {
              // TODO: Implement menu options
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.messageBackground.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

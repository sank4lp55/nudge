// Modern Chat List Item with press animation
import 'package:flutter/material.dart';
import 'package:nudge/core/theme/app_theme.dart';
import 'package:nudge/presentation/widgets/user_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class ModernChatListItem extends StatefulWidget {
  final dynamic chat;
  final VoidCallback onTap;

  const ModernChatListItem({
    required this.chat,
    required this.onTap,
  });

  @override
  State<ModernChatListItem> createState() => ModernChatListItemState();
}

class ModernChatListItemState extends State<ModernChatListItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppTheme.messageBackground.withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Avatar with online indicator
              _buildAvatar(),
              const SizedBox(width: 14),

              // Chat details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChatHeader(context),
                    const SizedBox(height: 6),
                    _buildChatPreview(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Hero(
          tag: 'avatar_${widget.chat.user.name}',
          child: UserAvatar(
            name: widget.chat.user.name,
            size: 56,
          ),
        ),
        if (widget.chat.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFF00D66B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.darkBackground,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.chat.user.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(
            widget.chat.lastMessageTime,
            locale: 'en_short',
          ),
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChatPreview(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.chat.lastMessage,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.chat.unreadCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
            child: Center(
              child: Text(
                widget.chat.unreadCount > 99
                    ? '99+'
                    : widget.chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
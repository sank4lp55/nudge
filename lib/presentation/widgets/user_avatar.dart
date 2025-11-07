import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
  });

  Color _getColorFromName(String name) {
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Green
      const Color(0xFFEF4444), // Red
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
    ];

    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppTheme.cardBackground,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColorFromName(name),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getInitials(name),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

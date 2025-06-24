import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class UserAvatar extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;
  final dynamic user; // 外部からユーザーを渡すことも可能
  final bool showBorder;

  const UserAvatar({
    super.key,
    this.size = 40,
    this.onTap,
    this.user,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = user ?? ref.watch(currentUserProvider);

    if (currentUser == null) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(
          Icons.account_circle_outlined,
          size: size,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ) : Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: _buildAvatarContent(context, currentUser),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, dynamic user) {
    final photoURL = user is AppUser ? user.photoURL : user.photoURL;
    if (photoURL != null && photoURL.isNotEmpty) {
      return Image.network(
        photoURL,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(context, user);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    return _buildFallbackAvatar(context, user);
  }

  Widget _buildFallbackAvatar(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final initials = _getInitials(user);

    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  String _getInitials(dynamic user) {
    final displayName = user is AppUser ? user.displayName : user.displayName;
    final email = user is AppUser ? user.email : user.email;

    if (displayName != null && displayName.isNotEmpty) {
      final nameParts = displayName.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
    }

    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }

    return '?';
  }
}

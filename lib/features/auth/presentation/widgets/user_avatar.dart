import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../providers/auth_providers.dart';

class UserAvatar extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
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
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: _buildAvatarContent(context, user),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, AppUser user) {
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      return Image.network(
        user.photoURL!,
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

  Widget _buildFallbackAvatar(BuildContext context, AppUser user) {
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

  String _getInitials(AppUser user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      final nameParts = user.displayName!.trim().split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
    }
    
    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
    }
    
    return '?';
  }
}
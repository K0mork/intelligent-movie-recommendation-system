import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';

class AnonymousSignInButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AnonymousSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authController = ref.read(authControllerProvider.notifier);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: isLoading
            ? null
            : onPressed ?? () => authController.signInAnonymously(),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : Icon(
                Icons.person_outline,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
        label: Text(
          'ゲストとして続行',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
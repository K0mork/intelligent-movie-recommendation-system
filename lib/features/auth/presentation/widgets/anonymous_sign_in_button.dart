import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../../../../core/widgets/loading_state_widget.dart';

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
      height: 56,
      child: ElevatedButton.icon(
        onPressed:
            isLoading
                ? null
                : onPressed ?? () => authController.signInAnonymously(),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon:
            isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: LoadingStateWidget.inline(),
                )
                : Icon(
                  Icons.explore,
                  size: 20,
                  color: theme.colorScheme.onPrimary,
                ),
        label: Text(
          'ゲストとして映画を探す',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../../../../core/widgets/loading_state_widget.dart';

class GoogleSignInButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({super.key, this.onPressed, this.isLoading = false});

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
                : onPressed ?? () => authController.signInWithGoogle(),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
        icon:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: LoadingStateWidget.inline(),
                )
                : Icon(Icons.login, size: 20, color: theme.colorScheme.primary),
        label: Text(
          'Googleでサインイン',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/sign_in_page.dart';
import '../providers/auth_providers.dart';
import '../../../../core/widgets/loading_state_widget.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // ユーザーがサインインしている場合は子ウィジェットを表示
        if (user != null) {
          return child;
        }
        // サインインしていない場合はサインイン画面を表示
        return const SignInPage();
      },
      loading: () => const Scaffold(
        body: LoadingStateWidget.fullScreen(),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '認証エラーが発生しました',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 認証状態を再読み込み
                  ref.invalidate(authStateProvider);
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
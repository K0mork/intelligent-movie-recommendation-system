import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/sign_in_page.dart';

/// Firebase設定がない場合のデモ用認証ラッパー
class DemoAuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const DemoAuthWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<DemoAuthWrapper> createState() => _DemoAuthWrapperState();
}

class _DemoAuthWrapperState extends ConsumerState<DemoAuthWrapper> {
  bool _isSignedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Firebase設定チェックをシミュレート
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _demoSignIn() {
    setState(() {
      _isSignedIn = true;
    });
  }

  void _demoSignOut() {
    setState(() {
      _isSignedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('アプリを初期化中...'),
            ],
          ),
        ),
      );
    }

    if (!_isSignedIn) {
      return DemoSignInPage(onSignIn: _demoSignIn);
    }

    return DemoHomeWrapper(
      onSignOut: _demoSignOut,
      child: widget.child,
    );
  }
}

class DemoSignInPage extends StatelessWidget {
  final VoidCallback onSignIn;

  const DemoSignInPage({
    super.key,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // ロゴとタイトル
              Icon(
                Icons.movie_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              Text(
                'Movie Recommendation System',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                '映画の世界をAIと一緒に探検しよう',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // デモサインインボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: onSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  icon: Icon(
                    Icons.account_circle,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                  label: Text(
                    'デモサインイン（Firebase設定なし）',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
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
              ),

              const SizedBox(height: 32),

              // 説明テキスト
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'これはデモ版です',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase設定が完了していないため、認証機能は動作しません。UIとナビゲーションのデモをお楽しみください。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoHomeWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onSignOut;

  const DemoHomeWrapper({
    super.key,
    required this.child,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
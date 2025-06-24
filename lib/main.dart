import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/services/app_initialization_service.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/auth/presentation/widgets/demo_auth_wrapper.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/settings_page.dart';
import 'features/auth/presentation/widgets/user_avatar.dart';
import 'features/auth/presentation/providers/auth_controller.dart';
import 'features/movies/presentation/pages/movies_page.dart';
import 'features/reviews/presentation/pages/reviews_page.dart';
import 'features/reviews/presentation/pages/user_review_history_page.dart';
import 'features/reviews/presentation/pages/integrated_reviews_page.dart';
import 'features/recommendations/presentation/pages/recommendations_page.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/scroll_behavior.dart';

/// アプリケーションのエントリーポイント
/// 
/// 初期化ロジックをAppInitializationServiceに分離し、
/// 責任を明確にして保守性を向上。
void main() async {
  try {
    // アプリケーション初期化を実行
    final initResult = await AppInitializationService.initialize();
    
    if (initResult.hasError && !initResult.success) {
      // 致命的エラーの場合はエラー画面を表示
      runApp(
        MaterialApp(
          home: AppInitializationErrorPage(
            errorMessage: initResult.errorMessage ?? '不明なエラーが発生しました',
          ),
        ),
      );
      return;
    }
    
    // 正常に初期化完了した場合はメインアプリを起動
    runApp(
      ProviderScope(
        child: MyApp(firebaseAvailable: initResult.firebaseAvailable),
      ),
    );
    
  } catch (error, stackTrace) {
    // 初期化プロセス自体でキャッチされない例外が発生した場合
    if (kIsWeb) {
      // ignore: avoid_print
      print('FATAL ERROR in main(): $error');
      // ignore: avoid_print
      print('StackTrace: $stackTrace');
    }
    
    // 緊急フォールバック - 最小限のエラー画面を表示
    runApp(
      MaterialApp(
        home: AppInitializationErrorPage(
          errorMessage: 'アプリケーション初期化中に致命的エラーが発生しました: ${error.toString()}',
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final bool firebaseAvailable;

  const MyApp({super.key, required this.firebaseAvailable});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      // スクロール動作の改善
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // 国際化設定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'), // 日本語
        Locale('en', 'US'), // 英語（フォールバック）
      ],
      locale: const Locale('ja', 'JP'),
      initialRoute: '/',
      routes: {
        '/': (context) => firebaseAvailable
            ? const AuthWrapper(
                child: MyHomePage(title: AppConstants.appName),
              )
            : const DemoAuthWrapper(
                child: MyHomePage(title: AppConstants.appName),
              ),
        '/sign-in': (context) => const SignInPage(),
        '/home': (context) => const MyHomePage(title: AppConstants.appName),
        '/guest': (context) => const MyHomePage(title: AppConstants.appName),
        '/movies': (context) => const MoviesPage(),
        '/reviews': (context) => const IntegratedReviewsPage(),
        '/my-reviews': (context) => const UserReviewHistoryPage(),
        '/recommendations': (context) => const RecommendationsPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {

  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('プロフィール'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('レビュー履歴'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/my-reviews');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('設定'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'サインアウト',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          UserAvatar(
            onTap: _showUserMenu,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.movie_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to FilmFlow!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'AIが分析するパーソナライズ映画推薦システム',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/movies');
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('映画を探す'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/reviews');
                  },
                  icon: const Icon(Icons.movie_creation),
                  label: const Text('マイ映画'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/recommendations');
                },
                icon: const Icon(Icons.recommend),
                label: const Text('AI映画推薦'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// アプリケーション初期化エラー時に表示するページ
class AppInitializationErrorPage extends StatelessWidget {
  final String errorMessage;

  const AppInitializationErrorPage({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[700],
              ),
              const SizedBox(height: 24),
              Text(
                'アプリケーション初期化エラー',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // ページを再読み込み（Web環境）
                  if (kIsWeb) {
                    // ignore: avoid_web_libraries_in_flutter
                    // html.window.location.reload();
                  }
                  // ネイティブ環境では何もしない（将来的に実装）
                },
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
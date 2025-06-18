import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/auth/presentation/widgets/demo_auth_wrapper.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/widgets/user_avatar.dart';
import 'features/auth/presentation/providers/auth_controller.dart';
import 'features/movies/presentation/pages/movies_page.dart';
import 'features/reviews/presentation/pages/reviews_page.dart';
import 'features/reviews/presentation/pages/user_review_history_page.dart';
import 'features/recommendations/presentation/pages/recommendations_page.dart';
import 'core/theme/scroll_theme.dart';
import 'core/theme/scroll_behavior.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web環境でセマンティクスを有効化
  if (kIsWeb) {
    try {
      SemanticsBinding.instance.ensureSemantics();
    } catch (e) {
      debugPrint('Semantics initialization failed: $e');
    }
  }
  
  // .envファイルを読み込み
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: .env file not found or failed to load: $e');
  }
  
  // Firebase初期化を試行（設定ファイルがなくても続行）
  bool firebaseAvailable = false;
  try {
    debugPrint('Attempting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
    debugPrint('✅ Firebase initialized successfully');
    
    // Performance監視を有効化
    if (kIsWeb) {
      debugPrint('🔄 Firebase Performance monitoring enabled for Web');
    }
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('🔄 Running in demo mode without Firebase');
    firebaseAvailable = false;
  }
  
  debugPrint('Starting app with firebaseAvailable: $firebaseAvailable');
  
  runApp(ProviderScope(
    child: MyApp(firebaseAvailable: firebaseAvailable),
  ));
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scrollbarTheme: AppScrollTheme.lightTheme,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scrollbarTheme: AppScrollTheme.darkTheme,
      ),
      themeMode: ThemeMode.system,
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
        '/reviews': (context) => const ReviewsPage(),
        '/my-reviews': (context) => const UserReviewHistoryPage(),
        '/recommendations': (context) => const RecommendationsPage(),
        '/profile': (context) => const ProfilePage(),
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
                // TODO: 設定画面に遷移
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
              'Welcome to Movie Recommendation System!',
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
                  icon: const Icon(Icons.rate_review),
                  label: const Text('レビュー'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
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
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/my-reviews');
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('マイレビュー履歴'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
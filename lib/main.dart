import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/widgets/auth_wrapper.dart';
import 'features/auth/presentation/widgets/demo_auth_wrapper.dart';
import 'features/auth/presentation/pages/sign_in_page.dart';
import 'features/auth/presentation/widgets/user_avatar.dart';
import 'features/auth/presentation/providers/auth_controller.dart';
import 'features/movies/presentation/pages/movies_page.dart';
import 'core/theme/scroll_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Web環境でセマンティクスを有効化
  if (kIsWeb) {
    SemanticsBinding.instance.ensureSemantics();
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
    // Firebase初期化をより安全に行う
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in demo mode without Firebase');
    firebaseAvailable = false;
  }
  
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
      scrollBehavior: _AppScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(8.0),
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          interactive: true,
          radius: const Radius.circular(4.0),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.black45;
            }
            return Colors.black26;
          }),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(8.0),
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          interactive: true,
          radius: const Radius.circular(4.0),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white54;
            }
            return Colors.white38;
          }),
        ),
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
        '/movies': (context) => const MoviesPage(),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
                // TODO: プロフィール画面に遷移
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text('カウンターデモ:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/movies');
              },
              icon: const Icon(Icons.explore),
              label: const Text('映画を探す'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (kIsWeb) {
      // Webプラットフォーム（Mac Safari含む）でのスクロール物理特性
      return const ClampingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (kIsWeb) {
      return Scrollbar(
        controller: details.controller,
        thumbVisibility: false,
        trackVisibility: false,
        thickness: 8.0,
        radius: const Radius.circular(4.0),
        interactive: true,
        child: child,
      );
    }
    return super.buildScrollbar(context, child, details);
  }
}
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/explore/providers/explore_provider.dart';
import 'features/home_farmer/providers/farmer_home_provider.dart';
import 'features/home_farmer/providers/student_provider.dart';
import 'features/home_instructor/providers/instructor_home_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom ErrorWidget builder so errors are immediately visible and debuggable
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('💥 [FlutterError] Exception: ${details.exceptionAsString()}');
    debugPrint('💥 [FlutterError] Stack: ${details.stack}');
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Render Error in Section',
                    style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exceptionAsString(),
                    style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  // Set initial system UI overlay style with dark icons for light background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase and Notification Service
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize(
      onNotificationClick: (message) {
        // Handle notification tap — navigate based on message.data if needed
        debugPrint('🔔 [App] Notification tapped: ${message.data}');
      },
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IGrowApp(),
    ),
  );
}

class IGrowApp extends ConsumerStatefulWidget {
  const IGrowApp({super.key});

  @override
  ConsumerState<IGrowApp> createState() => _IGrowAppState();
}

class _IGrowAppState extends ConsumerState<IGrowApp> {
  late final AppLifecycleListener _lifecycleListener;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onAppResume() {
    final now = DateTime.now();
    if (_lastSyncTime != null && now.difference(_lastSyncTime!).inSeconds < 5) {
      return; // 5-second debounce
    }
    _lastSyncTime = now;
    debugPrint('🔄 [Lifecycle] App resumed: triggering cross-platform sync...');

    // Invalidate instructor providers
    ref.invalidate(instructorCoursesProvider);
    ref.invalidate(instructorStatsProvider);
    ref.invalidate(instructorQaProvider);
    ref.invalidate(instructorReviewsProvider);

    // Invalidate student & explore providers
    ref.invalidate(studentEnrollmentsProvider);
    ref.invalidate(featuredCoursesProvider);
    ref.invalidate(exploreCoursesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);
    final langCode = ref.watch(languageProvider);

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? const Color(0xFF101913) : const Color(0xFFF7FAF5),
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: MaterialApp.router(
        title: 'iAgrow',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode, // Adapts to system preference or user choice
        locale: Locale(langCode),
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

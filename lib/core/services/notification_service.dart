import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_strings.dart';
import '../network/token_storage.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';

/// Top-level background message handler for FCM.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
/// This runs in a separate Dart isolate — no access to UI or app state.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Re-initialize Firebase in this background isolate
  await Firebase.initializeApp();

  developer.log(
    'FCM Background message received: ${message.messageId}',
    name: 'NotificationService',
  );

  if (kDebugMode) {
    print('🔔 FCM Background Message: ${message.notification?.title} - ${message.notification?.body}');
    print('📦 FCM Background Data: ${message.data}');
  }

  // ─── IMPORTANT: Show local notification for data-only messages ───────────
  // When a FCM "data-only" message arrives (no notification payload),
  // Android will NOT auto-display anything — we must show it manually.
  // For "notification" messages (where message.notification != null),
  // Android OS automatically displays the notification using the default channel.
  // If we also call plugin.show(), Android creates a DUPLICATE notification banner!
  if (message.notification != null) {
    if (kDebugMode) {
      print('ℹ️ [BackgroundHandler] Notification payload already handled by Android OS. Skipping local duplicate.');
    }
    return;
  }

  final rawTitle = message.data['title'] ?? message.data['header'];
  final rawBody  = message.data['body'] ?? message.data['message'] ?? message.data['content'] ?? message.data['description'];

  // Check for localized keys in notification or data payload
  final titleLocKey = message.notification?.titleLocKey ?? message.data['title_loc_key'] ?? message.data['title_key'];
  final bodyLocKey = message.notification?.bodyLocKey ?? message.data['body_loc_key'] ?? message.data['message_key'];
  final titleLocArgs = message.notification?.titleLocArgs;
  final bodyLocArgs = message.notification?.bodyLocArgs;

  final resolved = await NotificationService.resolveNotificationText(
    title: rawTitle?.toString(),
    body: rawBody?.toString(),
    titleLocKey: titleLocKey?.toString(),
    bodyLocKey: bodyLocKey?.toString(),
    titleLocArgs: titleLocArgs,
    bodyLocArgs: bodyLocArgs,
    data: message.data,
  );

  final title = (resolved.title.trim().isNotEmpty)
      ? resolved.title.trim()
      : (message.data.isNotEmpty ? (rawTitle?.toString() ?? 'iAgrow Notification') : null);
  final body = resolved.body.trim();

  // Guard: Never show an empty notification card with blank body and generic fallback title
  if (title != null && (title != 'iAgrow Notification' || body.isNotEmpty)) {
    try {
      // Initialize local notifications plugin in this background isolate
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');

      // flutter_local_notifications v22+ requires named parameters
      await plugin.initialize(
        settings: const InitializationSettings(android: androidInit),
      );

      // Safe positive 32-bit integer ID to prevent overflow and collision
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await plugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important real-time notifications.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      developer.log('Failed to show background notification: $e', name: 'NotificationService');
    }
  }
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important real-time notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _downloadChannel = AndroidNotificationChannel(
    'download_channel', // id
    'File Downloads', // title
    description: 'This channel is used for certificate and file download status alerts.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isInitialized = false;

  /// Cache of recently displayed notification deduplication keys with timestamps
  /// to guard against duplicate push deliveries within a 10-second window.
  final Map<String, int> _recentNotificationTimestamps = {};

  /// Pending route from a push notification tap received while the app
  /// was cold-starting or during splash animation. Consumed once home loads.
  static String? pendingLaunchRoute;

  /// Centralized notification tap redirection
  static void handleNotificationTap(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (kDebugMode) {
      print('🚀 [NotificationService] Routing notification tap with data: $data');
    }

    String? targetRoute;

    final type = (data['type'] ?? data['entity_type'] ?? data['model'] ?? data['notification_type'] ?? '').toString().toUpperCase();
    final rawScreen = (data['screen'] ?? data['route'] ?? data['path'] ?? '').toString().trim();

    // 1. Check for Q&A notification (Student asked question or reply)
    if (type.contains('QA') || type.contains('QUESTION') || data.containsKey('question_id') || rawScreen == 'qa') {
      targetRoute = '/instructor/qa';
    }

    // 2. Check for Community Post / Comment notification
    final postId = data['post_id'] ?? data['postId'] ?? (type.contains('POST') || type.contains('COMMENT') ? (data['id'] ?? data['entity_id']) : null);
    final isCommunity = type.contains('COMMENT') ||
        type.contains('POST') ||
        type.contains('COMMUNITY') ||
        data.containsKey('post_id') ||
        data.containsKey('postId') ||
        rawScreen == 'community' ||
        (data['title']?.toString().toLowerCase().contains('comment') ?? false) ||
        (data['body']?.toString().toLowerCase().contains('commented') ?? false);

    if (targetRoute == null && isCommunity) {
      targetRoute = postId != null && postId.toString().isNotEmpty
          ? '/community?postId=${postId.toString()}'
          : '/community';
    }

    // 3. Check for Support Ticket notification
    final isSupport = type.contains('TICKET') || type.contains('SUPPORT') || data.containsKey('ticket_id') || rawScreen == 'support_tickets';
    if (targetRoute == null && isSupport) {
      targetRoute = '/support?tab=my-tickets';
    }

    // 4. Check for Course notification (Approval, Rejection, New Course, Announcement)
    final courseId = data['course_id'] ?? data['courseId'] ?? data['course'] ?? data['course_slug'] ?? (type.contains('COURSE') ? (data['id'] ?? data['entity_id']) : null);
    if (targetRoute == null && (type == 'COURSE_APPROVED' || type == 'APPROVED' || type == 'COURSE_REJECTED' || type == 'REJECTED' || type == 'PROCESSING' || rawScreen == 'instructor_courses')) {
      targetRoute = RouteNames.instructorUploads;
    } else if (targetRoute == null && courseId != null && courseId.toString().trim().isNotEmpty) {
      if (rawScreen == 'course_player') {
        targetRoute = '/farmer/course/${courseId.toString().trim()}';
      } else {
        targetRoute = '/farmer/course/${courseId.toString().trim()}';
      }
    }

    // 5. Check for E-Book notification
    final ebookId = data['ebook_id'] ?? data['ebookId'] ?? data['ebook'] ?? data['ebook_slug'] ?? (type.contains('EBOOK') ? (data['id'] ?? data['entity_id']) : null);
    if (targetRoute == null && ebookId != null && ebookId.toString().trim().isNotEmpty) {
      targetRoute = '/farmer/ebook/${ebookId.toString().trim()}';
    } else if (targetRoute == null && (type.contains('EBOOK') || (data['title']?.toString().toLowerCase().contains('ebook') ?? false))) {
      final ebookTitle = data['ebook_title'] ?? data['title'];
      if (ebookTitle != null && ebookTitle.toString().trim().isNotEmpty) {
        var cleanTitle = ebookTitle.toString().replaceAll(RegExp(r'^(?:New\s+E-Book:\s*|New\s+Ebook:\s*)', caseSensitive: false), '').trim();
        cleanTitle = cleanTitle.replaceAll(RegExp(r'\.{2,}$'), '').trim();
        targetRoute = '/explore?tab=ebooks&search=${Uri.encodeComponent(cleanTitle)}';
      } else {
        targetRoute = '/explore?tab=ebooks';
      }
    }

    // 6. Check for Enrollment notifications
    if (targetRoute == null && (type == 'NEW_ENROLLMENT' || type == 'NEW_EBOOK_SALE' || rawScreen == 'instructor_dashboard')) {
      targetRoute = RouteNames.instructorHome;
    } else if (targetRoute == null && (type == 'ENROLLMENT_SUCCESS' || rawScreen == 'my_learning')) {
      targetRoute = RouteNames.farmerLearning;
    }

    // 7. Fallback to direct route if specifically provided and not just the generic 'notifications' string
    if (targetRoute == null && rawScreen.isNotEmpty) {
      if (rawScreen == 'notifications') {
        targetRoute = RouteNames.notifications;
      } else {
        targetRoute = rawScreen.startsWith('/') ? rawScreen : '/$rawScreen';
      }
    }

    if (targetRoute == null) return;

    final navContext = rootNavigatorKey.currentContext;
    if (navContext != null) {
      final currentRoute = GoRouterState.of(navContext).matchedLocation;
      if (currentRoute == RouteNames.splash || currentRoute == '/') {
        if (kDebugMode) {
          print('⏳ [NotificationService] App is currently on splash ($currentRoute). Stashing pendingLaunchRoute = $targetRoute');
        }
        pendingLaunchRoute = targetRoute;
      } else {
        if (kDebugMode) {
          print('🚀 [NotificationService] Navigating directly to $targetRoute');
        }
        navContext.push(targetRoute);
      }
    } else {
      if (kDebugMode) {
        print('⏳ [NotificationService] No Navigator context yet. Stashing pendingLaunchRoute = $targetRoute');
      }
      pendingLaunchRoute = targetRoute;
    }
  }

  /// When true, course draft creation notifications are deferred until all media uploads reach 100%.
  static bool isCourseDraftUploading = false;
  static RemoteMessage? pendingCourseDraftNotification;

  static void markCourseUploadStarted() {
    isCourseDraftUploading = true;
    pendingCourseDraftNotification = null;
  }

  static Future<void> markCourseUploadFinished() async {
    isCourseDraftUploading = false;
    final pending = pendingCourseDraftNotification;
    pendingCourseDraftNotification = null;
    if (pending != null) {
      await instance._showForegroundNotification(pending);
    }
  }

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initialize({
    Function(RemoteMessage message)? onNotificationClick,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Request Notification Permissions
      await _requestPermission();

      // 3. Initialize Local Notifications for Foreground display
      await _initializeLocalNotifications(onNotificationClick);

      // 4. Create Android Notification Channel
      await _createNotificationChannel();

      // 5. Configure Foreground Notification Presentation Options for iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 6. Setup Listeners (Foreground & Background clicks)
      _setupMessageListeners(onNotificationClick);

      // 7. Auto init and get & log FCM Token with retry
      await _messaging.setAutoInitEnabled(true);
      
      // Fetch token in background with retry so it doesn't block app startup
      getFcmToken();

      // Listen for token refresh — always await to ensure backend gets the latest token
      _messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          print('\n==================== [FCM TOKEN REFRESHED] ====================');
          print(newToken);
          print('===============================================================\n');
        }
        try {
          final accessToken = await TokenStorage().getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            // Use customToken directly — do NOT call getFreshFcmToken() here to avoid loop
            await registerFCMToken(accessToken, customToken: newToken);
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [NotificationService] Failed to sync refreshed token: $e');
          }
        }
      });

      _isInitialized = true;
      developer.log('NotificationService initialized successfully.', name: 'NotificationService');
    } catch (e, stackTrace) {
      developer.log('Failed to initialize NotificationService: $e', error: e, stackTrace: stackTrace, name: 'NotificationService');
    }
  }

  /// Request User Permission for Push Notifications
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('🔔 FCM Authorization Status: ${settings.authorizationStatus}');
    }
    return settings;
  }

  /// Initialize Flutter Local Notifications plugin
  Future<void> _initializeLocalNotifications(
    Function(RemoteMessage message)? onNotificationClick,
  ) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (kDebugMode) {
          print('🔔 Local notification clicked with payload: ${response.payload}');
        }
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          if (payload.endsWith('.pdf')) {
            try {
              final file = File(payload);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                final pageFormat = (!kIsWeb && Platform.isIOS)
                    ? const PdfPageFormat(
                        595.28,
                        420.94, // 70.7% scaling to match portrait viewport
                        marginAll: 0,
                      )
                    : PdfPageFormat.a4.landscape;

                await Printing.layoutPdf(
                  format: pageFormat,
                  dynamicLayout: false,
                  forceCustomPrintPaper: true,
                  onLayout: (_) async => bytes,
                  name: file.uri.pathSegments.last,
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ Could not open downloaded PDF from notification: $e');
              }
            }
          } else {
            try {
              Map<String, dynamic> data = {};
              if (payload.startsWith('{') && payload.endsWith('}')) {
                data = jsonDecode(payload);
              }
              NotificationService.handleNotificationTap(data);
            } catch (e) {
              if (kDebugMode) {
                print('⚠️ Failed to parse local notification payload: $e');
              }
            }
          }
        }
      },
    );
  }

  /// Create Android Notification Channels
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    await androidPlugin?.createNotificationChannel(_downloadChannel);
  }

  /// Setup foreground, background, and terminated message listeners
  void _setupMessageListeners(
    Function(RemoteMessage message)? onNotificationClick,
  ) {
    // 1. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 FCM Foreground Message received:');
        print('   Title: ${message.notification?.title}');
        print('   Body:  ${message.notification?.body}');
        print('   Data:  ${message.data}');
      }

      // Show foreground notification heads-up banner
      // On iOS, setForegroundNotificationPresentationOptions(alert: true) already
      // displays notifications with a 'notification' payload. Only show local notification
      // on Android, or on iOS for data-only messages to prevent duplicate/double banners.
      if (Platform.isAndroid || message.notification == null) {
        _showForegroundNotification(message);
      }
    });

    // 2. Background Message Click Listener (App in background, opened via tap)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 FCM Notification opened app from background: ${message.data}');
      }
      onNotificationClick?.call(message);
    });

    // 3. Terminated State Listener (App launched by tapping notification)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (kDebugMode) {
          print('🔔 FCM Initial Message opened from terminated state: ${message.data}');
        }
        onNotificationClick?.call(message);
      }
    });

    // 4. Also check FlutterLocalNotifications launch details (for iOS notification center cold launch)
    _localNotifications.getNotificationAppLaunchDetails().then((NotificationAppLaunchDetails? details) {
      if (details != null && details.didNotificationLaunchApp) {
        final payload = details.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty && !payload.endsWith('.pdf')) {
          try {
            Map<String, dynamic> data = {};
            if (payload.startsWith('{') && payload.endsWith('}')) {
              data = jsonDecode(payload);
            }
            if (kDebugMode) {
              print('🔔 Local Notification launched app from terminated state: $data');
            }
            NotificationService.handleNotificationTap(data);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error parsing local notification launch payload: $e');
            }
          }
        }
      }
    });
  }

  /// Display a heads-up notification when app is in the foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    // Use notification title/body or fallback to data payload with safe non-empty defaults
    final rawTitle = notification?.title ?? message.data['title'];
    final rawBody  = notification?.body  ?? message.data['body'];

    final titleLocKey = notification?.titleLocKey ?? message.data['title_loc_key'] ?? message.data['title_key'];
    final bodyLocKey = notification?.bodyLocKey ?? message.data['body_loc_key'] ?? message.data['message_key'];
    final titleLocArgs = notification?.titleLocArgs;
    final bodyLocArgs = notification?.bodyLocArgs;

    final resolved = await NotificationService.resolveNotificationText(
      title: rawTitle?.toString(),
      body: rawBody?.toString(),
      titleLocKey: titleLocKey?.toString(),
      bodyLocKey: bodyLocKey?.toString(),
      titleLocArgs: titleLocArgs,
      bodyLocArgs: bodyLocArgs,
      data: message.data,
    );

    final title = (resolved.title.trim().isNotEmpty)
        ? resolved.title.trim()
        : 'iAgrow Notification';
    final body = resolved.body.trim();

    // Defer premature course creation push notification while video/media upload is active
    final lowerTitle = title.toLowerCase();
    final lowerBody = body.toLowerCase();

    // ─── Deduplication Guard ──────────────────────────────────────────────
    // Guard against identical notifications received within 8 seconds
    // (e.g. when backend fires multiple signals or user has multiple device tokens).
    final now = DateTime.now().millisecondsSinceEpoch;
    final dedupeKey = '${message.messageId ?? ""}_${title.trim()}_${body.trim()}';
    if (_recentNotificationTimestamps.containsKey(dedupeKey)) {
      final prevTime = _recentNotificationTimestamps[dedupeKey] ?? 0;
      if (now - prevTime < 8000) {
        if (kDebugMode) {
          print('🛡️ [NotificationService] Deduplication Guard: Suppressed duplicate notification banner for "$title"');
        }
        return;
      }
    }
    _recentNotificationTimestamps[dedupeKey] = now;
    // Clean old keys if map exceeds 50 entries
    if (_recentNotificationTimestamps.length > 50) {
      _recentNotificationTimestamps.removeWhere((_, time) => now - time > 30000);
    }

    final isCourseCreationNotification = lowerTitle.contains('course created') ||
        lowerBody.contains('saved as a draft');
    if (isCourseCreationNotification && isCourseDraftUploading) {
      if (kDebugMode) {
        print('⏳ [NotificationService] Deferring premature "$title" notification until course assets reach 100% upload.');
      }
      pendingCourseDraftNotification = message;
      return;
    }

    try {
      // Safe positive 32-bit integer ID to prevent overflow and duplicate collision
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
            // Ensure heads-up banner shows even when screen is on
            fullScreenIntent: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      if (kDebugMode) {
        print('✅ [_showForegroundNotification] Successfully displayed notification #$notificationId: $title');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ [_showForegroundNotification] Failed to show notification: $e\n$st');
      }
    }
  }

  /// Displays a system download notification in the Android status bar when a certificate PDF is saved
  Future<void> showDownloadNotification({
    required String fileName,
    required String filePath,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await _localNotifications.show(
        id: notificationId,
        title: '📥 Certificate Downloaded',
        body: '$fileName has been saved to Downloads. Tap to open.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'download_channel',
            'File Downloads',
            channelDescription: 'This channel is used for certificate and file download status alerts.',
            icon: '@mipmap/launcher_icon',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: filePath,
      );
      if (kDebugMode) {
        print('✅ [showDownloadNotification] Displayed notification #$notificationId for $fileName');
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ [showDownloadNotification] Error: $e\n$st');
      }
    }
  }

  /// Get FCM Registration Token with retry support
  Future<String?> getFcmToken({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          if (kDebugMode) {
            print('\n==================== [FCM TOKEN] ====================');
            print(token);
            print('=====================================================\n');
          }
          return token;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ FCM Token attempt $attempt failed: $e');
        }
        if (attempt < maxRetries) {
          // Wait before retrying (exponential backoff / delay)
          await Future.delayed(Duration(seconds: 2 * attempt));
        }
      }
    }
    if (kDebugMode) {
      print('❌ Could not retrieve FCM Token after $maxRetries attempts.');
    }
    return null;
  }

  /// Subscribe to a Topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) {
      print('🔔 Subscribed to topic: $topic');
    }
  }

  /// Unsubscribe from a Topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) {
      print('🔔 Unsubscribed from topic: $topic');
    }
  }

  /// Delete FCM Registration Token on logout to unregister push notifications
  /// and clear all pending local notifications from the status bar tray.
  Future<void> deleteFcmToken() async {
    try {
      await _messaging.deleteToken();
      await _localNotifications.cancelAll();
      if (kDebugMode) {
        print('🔔 FCM Token deleted and all local notifications cleared on logout.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to delete FCM token on logout: $e');
      }
    }
  }

  /// Resolves multilingual notification text for push banners based on active app language.
  static Future<({String title, String body})> resolveNotificationText({
    String? title,
    String? body,
    String? titleLocKey,
    String? bodyLocKey,
    List<String>? titleLocArgs,
    List<String>? bodyLocArgs,
    Map<String, dynamic>? data,
  }) async {
    String lang = 'en';
    try {
      final prefs = await SharedPreferences.getInstance();
      lang = prefs.getString('app_user_language_code') ?? 'en';
    } catch (_) {}

    String resolvedTitle = title ?? '';
    String resolvedBody = body ?? '';

    // 1. Try local dictionary resolution with loc_key
    if (titleLocKey != null && titleLocKey.isNotEmpty) {
      final translated = AppStrings.tr(titleLocKey, languageCode: lang);
      if (translated != titleLocKey) {
        resolvedTitle = _interpolateLocKey(translated, titleLocArgs, data, lang);
      }
    }

    if (bodyLocKey != null && bodyLocKey.isNotEmpty) {
      final translated = AppStrings.tr(bodyLocKey, languageCode: lang);
      if (translated != bodyLocKey) {
        resolvedBody = _interpolateLocKey(translated, bodyLocArgs, data, lang);
      }
    }

    // 2. Try translations object in data payload if present
    if (data != null && data['translations'] != null) {
      try {
        dynamic trans = data['translations'];
        if (trans is String) {
          trans = jsonDecode(trans);
        }
        if (trans is Map && trans[lang] is Map) {
          final lMap = trans[lang] as Map;
          if (resolvedTitle.isEmpty || titleLocKey == null) {
            final t = lMap['title']?.toString();
            if (t != null && t.isNotEmpty) resolvedTitle = t;
          }
          if (resolvedBody.isEmpty || bodyLocKey == null) {
            final b = lMap['message']?.toString() ?? lMap['body']?.toString();
            if (b != null && b.isNotEmpty) resolvedBody = b;
          }
        }
      } catch (_) {}
    }

    return (
      title: resolvedTitle.isNotEmpty ? resolvedTitle : (title ?? 'iAgrow Notification'),
      body: resolvedBody.isNotEmpty ? resolvedBody : (body ?? ''),
    );
  }

  static String _interpolateLocKey(
    String template,
    List<String>? args,
    Map<String, dynamic>? data,
    String lang,
  ) {
    var result = template;
    // Replace positional args %s or {0}, {1}
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
        final val = AppStrings.formatDigits(args[i], languageCode: lang);
        result = result.replaceFirst('%s', val);
        result = result.replaceAll('{$i}', val);
      }
    }
    // Replace named params from data['params'] or data directly
    Map<String, dynamic>? params;
    if (data != null) {
      if (data['params'] is Map) {
        params = Map<String, dynamic>.from(data['params'] as Map);
      } else if (data['params'] is String) {
        try {
          params = jsonDecode(data['params'] as String) as Map<String, dynamic>;
        } catch (_) {}
      }
      params ??= data;
      params.forEach((k, v) {
        final val = AppStrings.formatDigits(v.toString(), languageCode: lang);
        result = result.replaceAll('{$k}', val);
      });
    }
    return result;
  }

  /// Synchronize user's preferred language with backend profile API
  /// (PATCH /api/v1/accounts/profile/ or /api/v1/auth/me/) so future push notifications and email alerts
  /// match the chosen language.
  static Future<void> syncPreferredLanguageWithBackend(String langCode) async {
    try {
      final tokenStorage = TokenStorage();
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) return;

      final endpoints = [
        'https://iagrow.zappcode.in/api/v1/accounts/profile/',
        'https://iagrow.zappcode.in/api/v1/auth/me/',
      ];

      for (final endpoint in endpoints) {
        try {
          final uri = Uri.parse(endpoint);
          final response = await http
              .patch(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $accessToken',
                  'Accept-Language': langCode,
                },
                body: jsonEncode({
                  'preferred_language': langCode,
                }),
              )
              .timeout(const Duration(seconds: 8));

          if (kDebugMode) {
            if (response.statusCode >= 200 && response.statusCode < 300) {
              print('✅ [NotificationService] Synchronized preferred_language: $langCode with backend profile via $endpoint.');
              break;
            } else {
              print('⚠️ [NotificationService] Sync preferred_language (${response.statusCode}) on $endpoint: ${response.body}');
            }
          }
        } catch (inner) {
          if (kDebugMode) {
            print('⚠️ [NotificationService] Exception on $endpoint: $inner');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [NotificationService] Exception syncing preferred_language: $e');
      }
    }
  }

  /// Force fresh token generation by deleting any existing instance token
  Future<String?> getFreshFcmToken() async {
    try {
      await _messaging.deleteToken();
      final freshToken = await _messaging.getToken();
      if (kDebugMode) {
        print('\n==================== [FRESH_TOKEN] ====================');
        print('FRESH_TOKEN: $freshToken');
        print('=======================================================\n');
      }
      return freshToken;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [NotificationService] Failed to delete and generate fresh token: $e');
      }
      return await getFcmToken();
    }
  }

  /// Register device FCM token with backend API.
  /// Executes with a safe timeout and internal error handling so it is completely
  /// non-blocking and will never degrade app performance or crash other features.
  Future<void> registerFCMToken(
    String accessToken, {
    String? customToken,
    bool forceRefresh = false,
  }) async {
    try {
      final token = customToken ??
          (forceRefresh
              ? await getFreshFcmToken()
              : await getFcmToken(maxRetries: 2));
      if (token == null || token.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [NotificationService] No FCM token available; skipping backend registration.');
        }
        return;
      }

      final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/auth/fcm-token/');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'fcm_token': token,
              'device_type': Platform.isIOS ? 'ios' : 'android',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print('✅ [NotificationService] FCM token registered with backend successfully!');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [NotificationService] Backend returned ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [NotificationService] Failed to register FCM token with backend: $e');
      }
    }
  }
}

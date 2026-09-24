import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../network/token_storage.dart';

/// Top-level background message handler for FCM.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('FCM Background message received: ${message.messageId}', name: 'NotificationService');
  if (kDebugMode) {
    print('🔔 FCM Background Message: ${message.notification?.title} - ${message.notification?.body}');
    print('📦 FCM Background Data: ${message.data}');
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

  bool _isInitialized = false;

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

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        if (kDebugMode) {
          print('\n==================== [FCM TOKEN REFRESHED] ====================');
          print(newToken);
          print('===============================================================\n');
        }
        try {
          final accessToken = await TokenStorage().getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            unawaited(registerFCMToken(accessToken, customToken: newToken));
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
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('🔔 Local notification clicked with payload: ${response.payload}');
        }
        // Handle payload / click navigation here if needed
      },
    );
  }

  /// Create Android Notification Channel
  Future<void> _createNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
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
      _showForegroundNotification(message);
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
  }

  /// Display a heads-up notification when app is in the foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    // Use notification title/body or fallback to data payload if title is null
    final title = notification?.title ?? message.data['title'] ?? 'New Notification';
    final body = notification?.body ?? message.data['body'] ?? '';

    await _localNotifications.show(
      id: notification.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: android?.smallIcon ?? '@mipmap/launcher_icon',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
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
  Future<void> deleteFcmToken() async {
    try {
      await _messaging.deleteToken();
      if (kDebugMode) {
        print('🔔 FCM Token deleted successfully on logout.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to delete FCM token on logout: $e');
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

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/api_models/notification_models.dart';
import '../../../data/models/user_role.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for NotificationRepository.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    appApi: ref.watch(appApiProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Reactive state notifier managing user notifications with live background polling.
class NotificationsNotifier extends StateNotifier<AsyncValue<List<ApiNotification>>> {
  NotificationsNotifier(this.ref, {this.sessionKey}) : super(const AsyncValue.loading()) {
    if (sessionKey != null) {
      loadNotifications();
      _startPolling();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  final Ref ref;
  final String? sessionKey;
  Timer? _pollingTimer;

  bool get _isStudent {
    final user = ref.read(authProvider).user;
    return user?.activeRole == UserRole.farmer;
  }

  /// Clears in-memory notifications cache and cancels active polling timers.
  void clear() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = const AsyncValue.data([]);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    if (sessionKey == null) return;

    // Poll every 30 seconds for student or 15s for instructor per Agrilearn specification
    final interval = _isStudent ? const Duration(seconds: 30) : const Duration(seconds: 15);
    _pollingTimer = Timer.periodic(interval, (_) {
      _pollQuietly();
    });
  }

  Future<void> _pollQuietly() async {
    if (!mounted || sessionKey == null) return;
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications(isStudent: _isStudent);
      if (items.isNotEmpty && mounted) {
        state = AsyncValue.data(items);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    super.dispose();
  }

  Future<void> loadNotifications() async {
    if (sessionKey == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications(isStudent: _isStudent);
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } catch (e, st) {
      debugPrint('❌ [NotificationsNotifier] loadNotifications error: $e');
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n).toList(),
    );

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(notificationId, isStudent: _isStudent);
    } catch (e) {
      debugPrint('⚠️ [NotificationsNotifier] markAsRead error: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.where((n) => n.id != notificationId).toList(),
    );

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAsRead(notificationId, isStudent: _isStudent);
    } catch (e) {
      debugPrint('⚠️ [NotificationsNotifier] deleteNotification error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((n) => n.copyWith(isRead: true)).toList(),
    );

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markAllAsRead(isStudent: _isStudent);
    } catch (e) {
      debugPrint('⚠️ [NotificationsNotifier] markAllAsRead error: $e');
    }
  }
}

/// Provider exposing reactive notification list.
/// Automatically resets and invalidates when user logs out or switches roles.
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<ApiNotification>>>((ref) {
  // Key off authenticated user ID and active role.
  // When user logs out (null), Riverpod cleanly disposes the previous notifier
  // and creates an unauthenticated notifier with empty state.
  // When user logs in as Instructor or Student, a fresh notifier is created
  // which immediately fetches the right role's notifications.
  final sessionKey = ref.watch(authProvider.select((state) {
    if (!state.isAuthenticated || state.user == null) return null;
    return '${state.user!.id}_${state.user!.activeRole.name}';
  }));

  return NotificationsNotifier(ref, sessionKey: sessionKey);
});

/// Provider computing count of unread notifications for badges.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final asyncVal = ref.watch(notificationsProvider);
  return asyncVal.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

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
  NotificationsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadNotifications();
    _startPolling();
  }

  final Ref ref;
  Timer? _pollingTimer;

  bool get _isStudent {
    final user = ref.read(authProvider).user;
    return user?.activeRole == UserRole.farmer;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Poll every 30 seconds for student or 15s for instructor per Agrilearn specification
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pollQuietly();
    });
  }

  Future<void> _pollQuietly() async {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications(isStudent: _isStudent);
      if (items.isNotEmpty) {
        state = AsyncValue.data(items);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.getNotifications(isStudent: _isStudent);
      state = AsyncValue.data(items);
    } catch (e, st) {
      debugPrint('❌ [NotificationsNotifier] loadNotifications error: $e');
      state = AsyncValue.error(e, st);
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
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<ApiNotification>>>((ref) {
  return NotificationsNotifier(ref);
});

/// Provider computing count of unread notifications for badges.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final asyncVal = ref.watch(notificationsProvider);
  return asyncVal.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

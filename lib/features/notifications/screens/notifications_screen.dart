import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/api_models/notification_models.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'APPROVED':
        return AppColors.primaryGreen;
      case 'REJECTED':
        return AppColors.error;
      case 'PROCESSING':
        return AppColors.skyBlue;
      case 'NEW_ENROLLMENT':
        return AppColors.accentOrange;
      case 'QA':
      case 'QUESTION':
      case 'ANSWER':
        return AppColors.accentOrange;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PROCESSING':
        return Icons.hourglass_top_rounded;
      case 'NEW_ENROLLMENT':
        return Icons.school_rounded;
      case 'QA':
      case 'QUESTION':
      case 'ANSWER':
        return Icons.forum_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  List<ApiNotification> _filterNotifications(List<ApiNotification> items, int tabIndex) {
    switch (tabIndex) {
      case 1: // Unread
        return items.where((n) => !n.isRead).toList();
      case 2: // Courses
        return items.where((n) {
          final t = n.notificationType.toUpperCase();
          final title = n.title.toLowerCase();
          return t.contains('COURSE') ||
              t == 'APPROVED' ||
              t == 'REJECTED' ||
              t == 'NEW_ENROLLMENT' ||
              title.contains('course');
        }).toList();
      case 3: // Q&A
        return items.where((n) {
          final t = n.notificationType.toUpperCase();
          final title = n.title.toLowerCase();
          final msg = n.message.toLowerCase();
          return t.contains('QA') ||
              title.contains('q&a') ||
              title.contains('question') ||
              title.contains('answer') ||
              msg.contains('replied');
        }).toList();
      case 0: // All
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            color: AppColors.primaryGreen,
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read ✓'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: isDark ? Colors.white60 : AppColors.inkSoft,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Courses'),
            Tab(text: 'Q&A'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
        color: AppColors.primaryGreen,
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    error.toString().replaceAll('Exception: ', ''),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (allNotifications) {
            final filtered = _filterNotifications(allNotifications, _tabController.index);

            if (filtered.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  EmptyState(
                    icon: _tabController.index == 1
                        ? Icons.mark_chat_read_outlined
                        : Icons.notifications_off_outlined,
                    title: _tabController.index == 1
                        ? 'No Unread Notifications'
                        : 'No Notifications Found',
                    subtitle: _tabController.index == 1
                        ? 'You are all caught up! Great job.'
                        : 'New course updates, announcements, and Q&A replies will appear here.',
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final color = _getNotificationColor(item.notificationType);
                final icon = _getNotificationIcon(item.notificationType);

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.done_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                  },
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (!item.isRead) {
                        ref.read(notificationsProvider.notifier).markAsRead(item.id);
                      }
                      if (item.course != null && item.course!.isNotEmpty) {
                        context.push('/farmer/course/${item.course}');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.isRead
                            ? (isDark ? AppColors.cardDark : Colors.white)
                            : (isDark
                                ? AppColors.primaryGreen.withValues(alpha: 0.12)
                                : AppColors.primaryGreen.withValues(alpha: 0.05)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isRead
                              ? (isDark ? AppColors.lineDark : AppColors.lineLight)
                              : AppColors.primaryGreen.withValues(alpha: 0.4),
                          width: item.isRead ? 1 : 1.5,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (!item.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(left: 6),
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentOrange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                                if (item.createdAt != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt!.toLocal()),
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : AppColors.inkSoft.withValues(alpha: 0.8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

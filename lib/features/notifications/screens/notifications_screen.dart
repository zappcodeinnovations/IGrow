import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/api_models/notification_models.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  // 0: All, 1: Unread, 2: Courses, 3: Q&A
  int _activeFilterIndex = 0;

  final List<String> _filters = const ['All', 'Unread', 'Courses', 'Q&A'];

  Color _getNotificationIconBg(String type, bool isDark) {
    switch (type.toUpperCase()) {
      case 'APPROVED':
      case 'NEW_ENROLLMENT':
      case 'PAYMENT':
        return isDark ? AppColors.editorialSecondaryFixedDim.withValues(alpha: 0.25) : AppColors.editorialSecondaryFixed;
      case 'REJECTED':
      case 'ERROR':
        return isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFFDAD6);
      case 'PROCESSING':
      case 'QA':
      case 'QUESTION':
      case 'ANSWER':
        return isDark ? Colors.white12 : AppColors.editorialSurfaceContainerHigh;
      default:
        return isDark ? Colors.white12 : AppColors.editorialSurfaceContainerLow;
    }
  }

  Color _getNotificationIconColor(String type, bool isDark) {
    switch (type.toUpperCase()) {
      case 'APPROVED':
      case 'NEW_ENROLLMENT':
      case 'PAYMENT':
        return isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary;
      case 'REJECTED':
      case 'ERROR':
        return Colors.redAccent;
      case 'QA':
      case 'QUESTION':
      case 'ANSWER':
        return isDark ? Colors.white : AppColors.editorialOnSurface;
      default:
        return isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'APPROVED':
      case 'PAYMENT':
        return Icons.credit_card_rounded;
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
        return Icons.auto_stories_rounded;
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
      backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              backgroundColor: isDark ? AppColors.editorialSurfaceDark : AppColors.editorialSurface,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go(RouteNames.farmerHome);
                      }
                    },
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      ),
                    ),
                  ),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : AppColors.editorialOnSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.editorialSecondaryFixedDim.withValues(alpha: 0.3)
                            : AppColors.editorialSecondaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '$unreadCount new',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.editorialSecondaryFixedDim
                              : AppColors.editorialOnSecondaryFixed,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: InkWell(
                      onTap: () {
                        ref.read(notificationsProvider.notifier).markAllAsRead();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All notifications marked as read ✓'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.done_all_rounded,
                              size: 16,
                              color: isDark ? AppColors.editorialSecondaryFixedDim : AppColors.editorialSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tr(ref, 'Mark read'),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _activeFilterIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _activeFilterIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.editorialPrimary)
                                : (isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLow),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tr(ref, _filters[index]),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
          color: AppColors.editorialPrimary,
          child: notificationsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.editorialPrimary),
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
                          style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.white : AppColors.editorialPrimary,
                            foregroundColor: isDark ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                          ),
                          onPressed: () => ref.read(notificationsProvider.notifier).loadNotifications(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (allNotifications) {
                  final filtered = _filterNotifications(allNotifications, _activeFilterIndex);

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        EmptyState(
                          icon: _activeFilterIndex == 1
                              ? Icons.mark_chat_read_outlined
                              : Icons.notifications_off_outlined,
                          title: _activeFilterIndex == 1
                              ? 'No Unread Notifications'
                              : 'No Notifications Found',
                          subtitle: _activeFilterIndex == 1
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
                      final iconBg = _getNotificationIconBg(item.notificationType, isDark);
                      final iconColor = _getNotificationIconColor(item.notificationType, isDark);
                      final icon = _getNotificationIcon(item.notificationType);

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(notificationsProvider.notifier).deleteNotification(item.id);
                        },
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            if (!item.isRead) {
                              ref.read(notificationsProvider.notifier).markAsRead(item.id);
                            }
                            if (item.course != null && item.course!.isNotEmpty) {
                              context.push('/farmer/course/${item.course}');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.editorialSurfaceContainerLowest,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.lineDark
                                    : (item.isRead
                                        ? AppColors.editorialOutlineVariant.withValues(alpha: 0.25)
                                        : AppColors.editorialSecondary.withValues(alpha: 0.35)),
                                width: item.isRead ? 1 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sculpted Category Icon Pod
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, color: iconColor, size: 20),
                                ),
                                const SizedBox(width: 12),
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
                                                color: isDark ? Colors.white : AppColors.editorialOnSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!item.isRead)
                                            Container(
                                              width: 7,
                                              height: 7,
                                              margin: const EdgeInsets.only(left: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.editorialSecondary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.message,
                                        style: TextStyle(
                                          color: isDark ? Colors.white70 : AppColors.editorialOnSurfaceVariant,
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white10 : AppColors.editorialSurfaceContainerLow,
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            child: Text(
                                              item.notificationType.replaceAll('_', ' '),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                                color: isDark ? Colors.white60 : AppColors.editorialOnSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          if (item.createdAt != null)
                                            Text(
                                              DateFormat('hh:mm a • dd MMM').format(item.createdAt!.toLocal()),
                                              style: TextStyle(
                                                color: isDark ? Colors.white38 : AppColors.editorialOnSurfaceVariant.withValues(alpha: 0.8),
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
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
          ),
        );
  }
}



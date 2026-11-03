import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_strings.dart';
import '../network/api_exception.dart';
import '../theme/app_colors.dart';

/// Checks if an error object corresponds to an offline, timeout, socket or network failure.
bool isOfflineOrNetworkError(dynamic error) {
  if (error == null) return false;
  if (error is ApiException && error.isNetwork) return true;
  final s = error.toString().toLowerCase();
  return s.contains('socket') ||
      s.contains('handshake') ||
      s.contains('network') ||
      s.contains('connection') ||
      s.contains('offline') ||
      s.contains('timeout') ||
      s.contains('host lookup') ||
      s.contains('clientexception') ||
      s.contains('failed host');
}

/// Returns a clean, user-friendly polite error message, masking raw socket exceptions.
String getUserFriendlyErrorMessage(dynamic error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (isOfflineOrNetworkError(error)) {
    return 'Unable to connect. Please check your internet connection.';
  }
  if (error is ApiException) {
    return error.message;
  }
  final s = error.toString().replaceAll('Exception: ', '').trim();
  if (s.isEmpty) return fallback;
  return s;
}

/// A standard, polite offline and error state widget used across the app (Instructor & Student).
class AppErrorState extends ConsumerWidget {
  const AppErrorState({
    super.key,
    this.error,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon,
    this.isSliver = false,
  });

  final dynamic error;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData? icon;
  final bool isSliver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOffline = isOfflineOrNetworkError(error);

    final resolvedIcon = icon ?? (isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded);
    final resolvedMessage = message ??
        (isOffline
            ? tr(ref, 'Unable to connect. Please check your internet connection.')
            : (error != null ? getUserFriendlyErrorMessage(error) : tr(ref, 'Something went wrong. Please try again.')));

    final widgetBody = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isOffline
                    ? Colors.orange.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                resolvedIcon,
                size: 36,
                color: isOffline ? Colors.orange : Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              resolvedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: isDark ? Colors.white70 : AppColors.inkSoft,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.editorialPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  tr(ref, retryLabel),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );

    if (isSliver) {
      return SliverToBoxAdapter(child: widgetBody);
    }
    return widgetBody;
  }
}


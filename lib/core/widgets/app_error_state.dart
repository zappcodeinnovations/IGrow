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
      s.contains('failed host') ||
      s.contains('no address associated with hostname') ||
      s.contains('network is unreachable') ||
      s.contains('errno = 7') ||
      s.contains('errno = 101') ||
      s.contains('errno = 111') ||
      s.contains('connection refused') ||
      s.contains('connection reset') ||
      s.contains('broken pipe') ||
      s.contains('software caused connection abort') ||
      s.contains('os error: no address');
}

/// Returns a clean, user-friendly polite error message, masking raw socket exceptions,
/// server stack traces, and technical API errors.
String getUserFriendlyErrorMessage(dynamic error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error == null) return fallback;

  if (isOfflineOrNetworkError(error)) {
    final s = error.toString().toLowerCase();
    if (s.contains('timeout')) {
      return 'Connection timed out. Please check your internet connection and try again.';
    }
    return kNoInternetMessage;
  }

  if (error is ApiException) {
    return _cleanTechnicalErrorString(error.message, fallback: fallback);
  }

  return _cleanTechnicalErrorString(error.toString(), fallback: fallback);
}

/// Helper that strips raw stack traces, URI dumps, JSON brackets, and technical class names.
String _cleanTechnicalErrorString(String raw, {String fallback = 'Something went wrong. Please try again.'}) {
  var s = raw.trim();

  // Strip leading Dart exception wrappers
  s = s.replaceFirst(RegExp(r'^(Exception|ApiException(\(\d+\))?|ClientException|SocketException|HttpException|FormatException):\s*', caseSensitive: false), '').trim();

  // If it still contains raw client / socket exception artifacts or URI details
  final lower = s.toLowerCase();
  if (lower.contains('failed host lookup') ||
      lower.contains('clientexception with socketexception') ||
      lower.contains('no address associated with hostname') ||
      lower.contains('network is unreachable') ||
      lower.contains('connection refused') ||
      lower.contains('os error:')) {
    return kNoInternetMessage;
  }

  if (lower.contains('timed out') || lower.contains('timeout')) {
    return 'Connection timed out. Please check your internet connection and try again.';
  }

  if (lower.contains('internal server error') ||
      lower.contains('502 bad gateway') ||
      lower.contains('503 service unavailable') ||
      lower.contains('504 gateway timeout') ||
      lower.contains('server error (500)') ||
      lower.contains('server error (502)') ||
      lower.contains('server error (503)')) {
    return 'Our server is temporarily unavailable. Please try again shortly.';
  }

  // Remove trailing uri=... if present
  s = s.replaceAll(RegExp(r',?\s*uri\s*=\s*https?://\S+', caseSensitive: false), '').trim();

  // Clean raw json map brackets if it was a dumped map string like {"detail": "..."}
  if (s.startsWith('{') && s.endsWith('}')) {
    final detailMatch = RegExp(r'''['"]detail['"]\s*:\s*['"]([^'"]+)['"]''').firstMatch(s);
    if (detailMatch != null) {
      s = detailMatch.group(1) ?? s;
    } else {
      final msgMatch = RegExp(r'''['"]message['"]\s*:\s*['"]([^'"]+)['"]''').firstMatch(s);
      if (msgMatch != null) {
        s = msgMatch.group(1) ?? s;
      }
    }
  }

  // Clean raw list brackets like ["Error text"]
  if (s.startsWith('["') && s.endsWith('"]')) {
    s = s.substring(2, s.length - 2);
  } else if (s.startsWith("['") && s.endsWith("']")) {
    s = s.substring(2, s.length - 2);
  }

  // If after cleaning it's empty or looks like raw code
  if (s.isEmpty) return fallback;
  if (s.length > 200 && (s.contains('\n') || s.contains('at ') || s.contains('package:'))) {
    return fallback;
  }

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
            ? tr(ref, 'No internet connection. Please try again later.')
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


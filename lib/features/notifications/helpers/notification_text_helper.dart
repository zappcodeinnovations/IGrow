import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krushi_siksha/core/localization/app_strings.dart';
import 'package:krushi_siksha/data/models/api_models/notification_models.dart';

/// Helper to resolve localized notification text dynamically based on the active language.
///
/// Follows the 3-tier fallback architecture:
/// 1. If local app dictionary contains [titleKey] / [messageKey], interpolates with [params].
/// 2. Else if [translations] dictionary from backend has an entry for the active language, uses that.
/// 3. Fallback to default [title] / [message].
class NotificationTextHelper {
  NotificationTextHelper._();

  static String getTitle(WidgetRef ref, ApiNotification notif) {
    final langCode = ref.watch(languageProvider);
    return getTitleWithLang(notif, langCode);
  }

  static String getBody(WidgetRef ref, ApiNotification notif) {
    final langCode = ref.watch(languageProvider);
    return getBodyWithLang(notif, langCode);
  }

  static String getTitleWithLang(ApiNotification notif, String langCode) {
    final currentLang = langCode.toLowerCase().trim();

    // 1. Try resolving using titleKey from app dictionary
    if (notif.titleKey != null && notif.titleKey!.isNotEmpty) {
      final key = notif.titleKey!;
      final translated = AppStrings.tr(key, languageCode: currentLang);
      if (translated != key) {
        return _interpolate(translated, notif.params, currentLang);
      }
    }

    // 1b. Smart fallback by notificationType or title keywords if backend omitted titleKey
    final nType = notif.notificationType.toUpperCase().trim();
    if (nType == 'WELCOME' || notif.title.toLowerCase().contains('welcome')) {
      final translated = AppStrings.tr('notif_welcome_title', languageCode: currentLang);
      if (translated != 'notif_welcome_title') return translated;
    } else if (nType == 'NEW_COURSE' || notif.title.toLowerCase().startsWith('new course') || notif.title.contains('New Course')) {
      final translated = AppStrings.tr('notif_new_course_title', languageCode: currentLang);
      if (translated != 'notif_new_course_title') return translated;
    } else if (nType == 'NEW_EBOOK' || notif.title.toLowerCase().contains('new e-book')) {
      final translated = AppStrings.tr('notif_new_ebook_title', languageCode: currentLang);
      if (translated != 'notif_new_ebook_title') return translated;
    } else if (nType == 'SUPPORT_TICKET') {
      final translated = AppStrings.tr('notif_support_ticket_title', languageCode: currentLang);
      if (translated != 'notif_support_ticket_title') {
        return _interpolate(translated, notif.params, currentLang);
      }
    }

    // 2. Try Backend Provided Translations Object
    if (notif.translations != null && notif.translations![currentLang] is Map) {
      final langMap = notif.translations![currentLang] as Map;
      final t = langMap['title']?.toString();
      if (t != null && t.isNotEmpty) {
        return t;
      }
    }

    // 3. Fallback to default title
    return notif.title;
  }

  static String getBodyWithLang(ApiNotification notif, String langCode) {
    final currentLang = langCode.toLowerCase().trim();

    // 1. Try resolving using messageKey from app dictionary
    if (notif.messageKey != null && notif.messageKey!.isNotEmpty) {
      final key = notif.messageKey!;
      final translated = AppStrings.tr(key, languageCode: currentLang);
      if (translated != key) {
        return _interpolate(translated, notif.params, currentLang);
      }
    }

    // 1b. Smart fallback by notificationType if backend omitted messageKey
    final nType = notif.notificationType.toUpperCase().trim();
    if (nType == 'WELCOME') {
      final key = notif.course != null ? 'notif_welcome_instructor_body' : 'notif_welcome_student_body';
      final translated = AppStrings.tr(key, languageCode: currentLang);
      if (translated != key) return translated;
    } else if (nType == 'NEW_COURSE') {
      final translated = AppStrings.tr('notif_new_course_body', languageCode: currentLang);
      if (translated != 'notif_new_course_body') {
        final courseTitle = notif.courseTitle ?? notif.params?['course_title'] ?? '';
        return _interpolate(translated, {'course_title': courseTitle}, currentLang);
      }
    } else if (nType == 'NEW_EBOOK') {
      final translated = AppStrings.tr('notif_new_ebook_body', languageCode: currentLang);
      if (translated != 'notif_new_ebook_body') {
        final ebookTitle = notif.ebookTitle ?? notif.params?['ebook_title'] ?? '';
        return _interpolate(translated, {'ebook_title': ebookTitle}, currentLang);
      }
    } else if (nType == 'SUPPORT_TICKET') {
      final translated = AppStrings.tr('notif_support_ticket_status_updated', languageCode: currentLang);
      if (translated != 'notif_support_ticket_status_updated') {
        return _interpolate(translated, notif.params, currentLang);
      }
    }

    // 2. Try Backend Provided Translations Object
    if (notif.translations != null && notif.translations![currentLang] is Map) {
      final langMap = notif.translations![currentLang] as Map;
      final m = langMap['message']?.toString();
      if (m != null && m.isNotEmpty) {
        return m;
      }
    }

    // 3. Fallback to default message
    return notif.message;
  }

  static String _interpolate(String template, Map<String, dynamic>? params, String langCode) {
    if (params == null || params.isEmpty) return template;
    var result = template;
    params.forEach((k, v) {
      final valStr = v != null ? AppStrings.formatDigits(v.toString(), languageCode: langCode) : '';
      result = result.replaceAll('{$k}', valStr);
    });
    return result;
  }
}


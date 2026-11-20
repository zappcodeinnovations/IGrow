import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/home_banner_model.dart';

/// Provider for student home screen scrolling banners from GET /api/v1/banners/
final homeBannersProvider = FutureProvider.autoDispose<List<HomeBannerItem>>((ref) async {
  try {
    final uri = Uri.parse('https://iagrow.zappcode.in/api/v1/banners/');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is List) {
        final list = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => HomeBannerItem.fromJson(item))
            .where((b) => b.isActive && b.imageUrl.isNotEmpty)
            .toList();
        list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        return list;
      }
    }
    return <HomeBannerItem>[];
  } catch (e) {
    debugPrint('⚠️ [homeBannersProvider] Error fetching banners: $e');
    return <HomeBannerItem>[];
  }
});

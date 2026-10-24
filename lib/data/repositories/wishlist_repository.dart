import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/network/token_storage.dart';
import '../models/api_models/wishlist_model.dart';

class WishlistRepository {
  WishlistRepository({required this.tokenStorage});

  final TokenStorage tokenStorage;
  static const String _baseUrl = 'https://iagrow.zappcode.in/api/v1';

  /// Get authenticated user's wishlist items (courses and ebooks).
  Future<List<ApiWishlistItem>> getWishlist() async {
    debugPrint('❤️ [WishlistRepository] getWishlist: fetching saved items');
    final token = await tokenStorage.getAccessToken();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/wishlist/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final items = decoded
              .map((e) => ApiWishlistItem.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint('✅ [WishlistRepository] getWishlist: loaded ${items.length} items');
          return items;
        }
      } else {
        debugPrint('⚠️ [WishlistRepository] getWishlist HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ [WishlistRepository] getWishlist error: $e');
    }

    return [];
  }

  /// Toggle item in wishlist (course or ebook).
  Future<WishlistToggleResult> toggleWishlist({
    String? courseId,
    String? ebookId,
  }) async {
    debugPrint('❤️ [WishlistRepository] toggleWishlist: courseId=$courseId, ebookId=$ebookId');
    final token = await tokenStorage.getAccessToken();

    final Map<String, dynamic> body = {};
    if (courseId != null && courseId.isNotEmpty) {
      body['course_id'] = courseId;
    }
    if (ebookId != null && ebookId.isNotEmpty) {
      body['ebook_id'] = ebookId;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/wishlist/toggle/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('❤️ [WishlistRepository] toggle status: ${response.statusCode}, body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final result = WishlistToggleResult.fromJson(decoded);
        debugPrint('✅ [WishlistRepository] toggle result: inWishlist=${result.inWishlist}');
        return result;
      } else if (response.statusCode == 500) {
        debugPrint('⚠️ [WishlistRepository] toggle returned HTTP 500. Attempting fallback removal...');
        final targetId = courseId ?? ebookId;
        if (targetId != null && targetId.isNotEmpty) {
          final removed = await removeFromWishlist(targetId);
          if (removed) {
            debugPrint('✅ [WishlistRepository] Fallback removeFromWishlist succeeded after 500');
            return const WishlistToggleResult(
              inWishlist: false,
              message: 'Removed from wishlist',
            );
          }
        }
        throw Exception('Failed to update wishlist (HTTP 500)');
      } else {
        debugPrint('⚠️ [WishlistRepository] toggle failed HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Failed to update wishlist (HTTP ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [WishlistRepository] toggleWishlist error: $e');
      rethrow;
    }
  }

  /// Remove item from wishlist by ID or target ID.
  Future<bool> removeFromWishlist(String idOrTargetId) async {
    debugPrint('❤️ [WishlistRepository] removeFromWishlist: id=$idOrTargetId');
    final token = await tokenStorage.getAccessToken();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/wishlist/$idOrTargetId/'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [WishlistRepository] removeFromWishlist SUCCESS');
        return true;
      } else {
        debugPrint('⚠️ [WishlistRepository] remove failed HTTP ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [WishlistRepository] removeFromWishlist error: $e');
      return false;
    }
  }
}

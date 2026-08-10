import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/network/api_exception.dart';
import '../../core/network/token_storage.dart';
import '../models/api_models/community_models.dart';

class CommunityRepository {
  final TokenStorage tokenStorage;
  final String baseUrl = 'https://iagrow.zappcode.in/api/v1/community';

  CommunityRepository({required this.tokenStorage});

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'Community Error (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      } catch (_) {}
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }
  }

  Future<List<CommunityPost>> getPosts() async {
    final uri = Uri.parse('$baseUrl/posts/');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 404) {
      // Backend not ready yet
      throw Exception('Backend API not ready yet. Please ask the backend team to deploy the Community endpoints.');
    }

    _handleError(response);

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? [];
    return results.map((json) => CommunityPost.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> likePost(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/like/');
    final response = await http.post(uri, headers: await _getHeaders());

    if (response.statusCode == 404) {
      throw Exception('Backend API not ready yet.');
    }

    _handleError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/comments/');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 404) {
      throw Exception('Backend API not ready yet.');
    }

    _handleError(response);

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? [];
    return results.map((json) => CommunityComment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CommunityComment> addComment(String postId, String content) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/comments/');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 404) {
      throw Exception('Backend API not ready yet.');
    }

    _handleError(response);

    final data = jsonDecode(response.body);
    return CommunityComment.fromJson(data);
  }
}

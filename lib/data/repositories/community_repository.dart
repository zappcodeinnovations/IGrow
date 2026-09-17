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
        if (data is Map) {
          if (data.containsKey('detail')) {
            errorMessage = data['detail'].toString();
          } else if (data.containsKey('error')) {
            errorMessage = data['error'].toString();
          } else {
            final firstValue = data.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              errorMessage = firstValue.first.toString();
            } else if (firstValue is String) {
              errorMessage = firstValue;
            }
          }
        }
      } catch (_) {}
      throw ApiException(statusCode: response.statusCode, message: errorMessage);
    }
  }

  Future<List<CommunityTopic>> getTopics() async {
    final uri = Uri.parse('$baseUrl/topics/');
    final response = await http.get(uri, headers: await _getHeaders());
    _handleError(response);

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? (data is List ? data : []);
    return results.map((json) => CommunityTopic.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<CommunityPost>> getPosts({String? topicId, String? search}) async {
    final queryParams = <String, String>{};
    if (topicId != null && topicId.isNotEmpty) {
      queryParams['topic_id'] = topicId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/posts/').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final response = await http.get(uri, headers: await _getHeaders());
    _handleError(response);

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? (data is List ? data : []);
    return results.map((json) => CommunityPost.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CommunityPost> createPost({
    required String title,
    required String content,
    String? topicId,
    String? imagePath,
  }) async {
    final token = await tokenStorage.getAccessToken();
    final uri = Uri.parse('$baseUrl/posts/');

    if (imagePath != null && imagePath.isNotEmpty) {
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      request.fields['title'] = title;
      request.fields['content'] = content;
      if (topicId != null && topicId.isNotEmpty) {
        request.fields['topic_id'] = topicId;
      }
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _handleError(response);
      final data = jsonDecode(response.body);
      return CommunityPost.fromJson(data as Map<String, dynamic>);
    } else {
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'content': content,
          if (topicId != null && topicId.isNotEmpty) 'topic_id': topicId,
        }),
      );
      _handleError(response);
      final data = jsonDecode(response.body);
      return CommunityPost.fromJson(data as Map<String, dynamic>);
    }
  }

  Future<Map<String, dynamic>> likePost(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/like/');
    final response = await http.post(uri, headers: await _getHeaders());
    _handleError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/comments/');
    final response = await http.get(uri, headers: await _getHeaders());
    _handleError(response);

    final data = jsonDecode(response.body);
    final results = data['results'] as List? ?? (data is List ? data : []);
    return results.map((json) => CommunityComment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<CommunityComment> addComment(String postId, String content, {String? parentId}) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/add-comment/');
    final response = await http.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode({
        'content': content,
        if (parentId != null && parentId.isNotEmpty) 'parent_id': parentId,
      }),
    );
    _handleError(response);

    final data = jsonDecode(response.body);
    return CommunityComment.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePost(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId/');
    final response = await http.delete(uri, headers: await _getHeaders());
    _handleError(response);
  }
}

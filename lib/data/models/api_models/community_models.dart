class CommunityAuthor {
  final String id;
  final String fullName;
  final bool isExpert;
  final String? avatarUrl;

  CommunityAuthor({
    required this.id,
    required this.fullName,
    required this.isExpert,
    this.avatarUrl,
  });

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) {
    return CommunityAuthor(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      isExpert: json['is_expert'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class CommunityPost {
  final String id;
  final CommunityAuthor author;
  final String content;
  final String tag;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.author,
    required this.content,
    required this.tag,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.createdAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String? ?? '',
      author: CommunityAuthor.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      content: json['content'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CommunityPost copyWith({
    String? id,
    CommunityAuthor? author,
    String? content,
    String? tag,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      tag: tag ?? this.tag,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommunityComment {
  final String id;
  final CommunityAuthor author;
  final String content;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as String? ?? '',
      author: CommunityAuthor.fromJson(json['author'] as Map<String, dynamic>? ?? {}),
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

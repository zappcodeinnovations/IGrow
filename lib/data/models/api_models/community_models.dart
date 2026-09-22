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
    final rawRole = (json['author_role'] ?? json['role'])?.toString();
    final rawName = (json['full_name'] ?? json['author_name'] ?? json['user_name'] ?? json['name'] ?? json['username'])?.toString();
    final rawId = (json['id'] ?? json['author_id'] ?? json['user_id'])?.toString() ?? '';
    final rawAvatar = (json['avatar_url'] ?? json['author_avatar'] ?? json['avatar'])?.toString();

    return CommunityAuthor(
      id: rawId,
      fullName: (rawName != null && rawName.isNotEmpty) ? rawName : 'User',
      isExpert: json['is_expert'] as bool? ?? (rawRole == 'INSTRUCTOR' || rawRole == 'ADMIN'),
      avatarUrl: rawAvatar,
    );
  }
}

class CommunityTopic {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String description;
  final int sortOrder;
  final int postCount;

  CommunityTopic({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.description,
    required this.sortOrder,
    required this.postCount,
  });

  factory CommunityTopic.fromJson(Map<String, dynamic> json) {
    return CommunityTopic(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String? ?? 'MessageSquare',
      description: json['description'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'icon': icon,
    'description': description,
    'sort_order': sortOrder,
    'post_count': postCount,
  };
}

class CommunityPost {
  final String id;
  final CommunityAuthor author;
  final CommunityTopic? topic;
  final String title;
  final String content;
  final String? image;
  final bool isPinned;
  final String tag;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityPost({
    required this.id,
    required this.author,
    this.topic,
    this.title = '',
    required this.content,
    this.image,
    this.isPinned = false,
    required this.tag,
    required this.likesCount,
    required this.commentsCount,
    required this.isLikedByMe,
    required this.createdAt,
    this.updatedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final authorMap = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : {
            'id': json['author_id'],
            'full_name': json['author_name'],
            'author_role': json['author_role'],
            'avatar_url': json['author_avatar'],
          };

    CommunityTopic? parsedTopic;
    if (json['topic'] is Map<String, dynamic>) {
      parsedTopic = CommunityTopic.fromJson(json['topic'] as Map<String, dynamic>);
    }

    final rawTag = parsedTopic?.name ?? json['tag'] as String? ?? '';

    return CommunityPost(
      id: json['id'] as String? ?? '',
      author: CommunityAuthor.fromJson(authorMap),
      topic: parsedTopic,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      tag: rawTag,
      likesCount: json['upvotes_count'] as int? ?? json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLikedByMe: json['is_liked'] as bool? ?? json['is_liked_by_me'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  CommunityPost copyWith({
    String? id,
    CommunityAuthor? author,
    CommunityTopic? topic,
    String? title,
    String? content,
    String? image,
    bool? isPinned,
    String? tag,
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      author: author ?? this.author,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      isPinned: isPinned ?? this.isPinned,
      tag: tag ?? this.tag,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommunityComment {
  final String id;
  final CommunityAuthor author;
  final String? parentId;
  final String content;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.author,
    this.parentId,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> authorMap;
    if (json['author'] is Map<String, dynamic>) {
      authorMap = json['author'] as Map<String, dynamic>;
    } else if (json['user'] is Map<String, dynamic>) {
      authorMap = json['user'] as Map<String, dynamic>;
    } else {
      authorMap = {
        'id': json['author_id'] ?? json['user_id'] ?? json['author'] ?? json['user'],
        'full_name': json['author_name'] ?? json['user_name'] ?? json['username'] ?? json['name'],
        'author_role': json['author_role'] ?? json['role'],
        'avatar_url': json['author_avatar'] ?? json['user_avatar'] ?? json['avatar'],
      };
    }

    final rawContent = json['content'] ?? json['comment'] ?? json['text'] ?? json['body'] ?? '';

    return CommunityComment(
      id: json['id']?.toString() ?? '',
      author: CommunityAuthor.fromJson(authorMap),
      parentId: json['parent']?.toString() ?? json['parent_id']?.toString(),
      content: rawContent.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

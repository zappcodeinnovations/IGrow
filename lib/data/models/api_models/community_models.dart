class CommunityAuthor {
  final String id;
  final String fullName;
  final bool isExpert;
  final String? avatarUrl;
  final String role;

  CommunityAuthor({
    required this.id,
    required this.fullName,
    required this.isExpert,
    this.avatarUrl,
    this.role = 'STUDENT',
  });

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) {
    final rawRole = (json['author_role'] ?? json['role'])?.toString() ?? 'STUDENT';
    final rawName = (json['full_name'] ?? json['author_name'] ?? json['user_name'] ?? json['name'] ?? json['username'])?.toString();
    final rawId = (json['id'] ?? json['author_id'] ?? json['user_id'])?.toString() ?? '';
    final rawAvatar = (json['avatar_url'] ?? json['author_avatar'] ?? json['avatar'])?.toString();

    return CommunityAuthor(
      id: rawId,
      fullName: (rawName != null && rawName.isNotEmpty) ? rawName : 'Farmer',
      isExpert: json['is_expert'] as bool? ?? (rawRole == 'INSTRUCTOR' || rawRole == 'ADMIN'),
      avatarUrl: rawAvatar,
      role: rawRole,
    );
  }

  CommunityAuthor copyWith({
    String? id,
    String? fullName,
    bool? isExpert,
    String? avatarUrl,
    String? role,
  }) {
    return CommunityAuthor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      isExpert: isExpert ?? this.isExpert,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
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

class CommunityHub {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String? coverBanner;
  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String state;
  final List<String> districts;
  final List<String> farmingTopics;
  final String rules;
  final int memberCount;
  final bool isMember;
  final DateTime createdAt;

  CommunityHub({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.coverBanner,
    this.instructorId = '',
    required this.instructorName,
    this.instructorAvatar,
    required this.state,
    required this.districts,
    required this.farmingTopics,
    required this.rules,
    required this.memberCount,
    required this.isMember,
    required this.createdAt,
  });

  factory CommunityHub.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return CommunityHub(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logo: json['logo']?.toString(),
      coverBanner: json['cover_banner']?.toString(),
      instructorId: (json['instructor'] ?? json['instructor_id'] ?? '').toString(),
      instructorName: (json['instructor_name'] ?? 'Agricultural Expert').toString(),
      instructorAvatar: json['instructor_avatar']?.toString(),
      state: (json['state'] ?? '').toString(),
      districts: parseList(json['districts']),
      farmingTopics: parseList(json['farming_topics']),
      rules: (json['rules'] ?? '').toString(),
      memberCount: json['member_count'] as int? ?? 0,
      isMember: json['is_member'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  CommunityHub copyWith({
    String? id,
    String? name,
    String? description,
    String? logo,
    String? coverBanner,
    String? instructorId,
    String? instructorName,
    String? instructorAvatar,
    String? state,
    List<String>? districts,
    List<String>? farmingTopics,
    String? rules,
    int? memberCount,
    bool? isMember,
    DateTime? createdAt,
  }) {
    return CommunityHub(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      coverBanner: coverBanner ?? this.coverBanner,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      state: state ?? this.state,
      districts: districts ?? this.districts,
      farmingTopics: farmingTopics ?? this.farmingTopics,
      rules: rules ?? this.rules,
      memberCount: memberCount ?? this.memberCount,
      isMember: isMember ?? this.isMember,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommunityPost {
  final String id;
  final CommunityAuthor author;
  final CommunityTopic? topic;
  final String? hubId;
  final String? hubName;
  final String postType; // 'GENERAL' | 'OFFLINE_SEMINAR' | 'ONLINE_MEETING' | 'COURSE_LAUNCH' | 'ADVISORY'
  final String title;
  final String content;
  final String? image;
  final String? courseId;
  final String? courseName;
  final DateTime? eventDate;
  final String? venueAddress;
  final String? link;
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
    this.hubId,
    this.hubName,
    this.postType = 'GENERAL',
    this.title = '',
    required this.content,
    this.image,
    this.courseId,
    this.courseName,
    this.eventDate,
    this.venueAddress,
    this.link,
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
            'id': (json['author'] != null && json['author'] is! Map)
                ? json['author']
                : (json['author_id'] ?? json['user_id']),
            'full_name': json['author_name'] ?? json['user_name'] ?? json['name'],
            'author_role': json['author_role'] ?? json['role'],
            'avatar_url': json['author_avatar'] ?? json['avatar'],
          };

    CommunityTopic? parsedTopic;
    if (json['topic'] is Map<String, dynamic>) {
      parsedTopic = CommunityTopic.fromJson(json['topic'] as Map<String, dynamic>);
    }

    final rawTag = parsedTopic?.name ?? json['tag'] as String? ?? '';
    final rawPostType = (json['post_type'] ?? 'GENERAL').toString().toUpperCase();

    DateTime? parsedEventDate;
    if (json['event_date'] != null) {
      parsedEventDate = DateTime.tryParse(json['event_date'].toString())?.toLocal();
    }

    return CommunityPost(
      id: json['id'] as String? ?? '',
      author: CommunityAuthor.fromJson(authorMap),
      topic: parsedTopic,
      hubId: json['hub']?.toString() ?? json['hub_id']?.toString(),
      hubName: json['hub_name']?.toString(),
      postType: rawPostType.isNotEmpty ? rawPostType : 'GENERAL',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      courseId: json['course']?.toString() ?? json['course_id']?.toString(),
      courseName: json['course_name']?.toString(),
      eventDate: parsedEventDate,
      venueAddress: json['venue_address']?.toString(),
      link: json['link']?.toString(),
      isPinned: json['is_pinned'] as bool? ?? false,
      tag: rawTag,
      likesCount: json['upvotes_count'] as int? ?? json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isLikedByMe: json['is_liked'] as bool? ?? json['is_liked_by_me'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())?.toLocal()
          : null,
    );
  }

  String? get formattedEventDateTime {
    if (eventDate == null) return null;
    final local = eventDate!.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year • $hour12:$minute $period';
  }

  CommunityPost copyWith({
    String? id,
    CommunityAuthor? author,
    CommunityTopic? topic,
    String? hubId,
    String? hubName,
    String? postType,
    String? title,
    String? content,
    String? image,
    String? courseId,
    String? courseName,
    DateTime? eventDate,
    String? venueAddress,
    String? link,
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
      hubId: hubId ?? this.hubId,
      hubName: hubName ?? this.hubName,
      postType: postType ?? this.postType,
      title: title ?? this.title,
      content: content ?? this.content,
      image: image ?? this.image,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      eventDate: eventDate ?? this.eventDate,
      venueAddress: venueAddress ?? this.venueAddress,
      link: link ?? this.link,
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
  final String authorRole;
  final String content;
  final DateTime createdAt;

  CommunityComment({
    required this.id,
    required this.author,
    this.parentId,
    this.authorRole = 'STUDENT',
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
    final role = (json['author_role'] ?? authorMap['author_role'] ?? 'STUDENT').toString();

    return CommunityComment(
      id: json['id']?.toString() ?? '',
      author: CommunityAuthor.fromJson(authorMap),
      parentId: json['parent']?.toString() ?? json['parent_id']?.toString(),
      authorRole: role,
      content: rawContent.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

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
  final bool isOwner;
  final bool isActive;
  final String disabledReason;
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
    this.districts = const [],
    this.farmingTopics = const [],
    this.rules = '',
    required this.memberCount,
    required this.isMember,
    this.isOwner = false,
    this.isActive = true,
    this.disabledReason = '',
    required this.createdAt,
  });

  factory CommunityHub.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

      String instId = '';
      String instName = 'Agricultural Expert';
      String? instAvatar;
      if (json['instructor'] is Map<String, dynamic>) {
        final iMap = json['instructor'] as Map<String, dynamic>;
        instId = (iMap['id'] ?? '').toString();
        instName = (iMap['full_name'] ?? iMap['name'] ?? 'Agricultural Expert').toString();
        instAvatar = (iMap['profile_image'] ?? iMap['avatar'])?.toString();
      } else {
        instId = (json['instructor'] ?? json['instructor_id'] ?? '').toString();
        instName = (json['instructor_name'] ?? 'Agricultural Expert').toString();
        instAvatar = json['instructor_avatar']?.toString();
      }

    final activeVal = json['is_active'];
    final bool active = activeVal == null ? true : (activeVal == true || activeVal == 1 || activeVal == 'true');
    final String reason = (json['disabled_reason'] ?? json['deactivated_reason'] ?? '').toString();

    return CommunityHub(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      logo: json['logo']?.toString(),
      coverBanner: json['cover_banner']?.toString(),
      instructorId: instId,
      instructorName: instName,
      instructorAvatar: instAvatar,
      state: (json['state'] ?? '').toString(),
      districts: parseList(json['districts']),
      farmingTopics: parseList(json['farming_topics']),
      rules: (json['rules'] ?? '').toString(),
      memberCount: (json['member_count'] ?? json['members_count'] ?? json['total_members']) is int
          ? (json['member_count'] ?? json['members_count'] ?? json['total_members']) as int
          : int.tryParse((json['member_count'] ?? json['members_count'] ?? json['total_members'])?.toString() ?? '') ?? 0,
      isMember: (json['is_member'] ?? json['is_joined'] ?? json['joined'] ?? json['has_joined']) == true ||
          (json['is_member'] ?? json['is_joined'] ?? json['joined'] ?? json['has_joined']) == 1 ||
          (json['is_member'] ?? json['is_joined'] ?? json['joined'] ?? json['has_joined']) == 'true',
      isOwner: json['is_owner'] == true || json['is_host'] == true,
      isActive: active,
      disabledReason: reason,
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
    bool? isOwner,
    bool? isActive,
    String? disabledReason,
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
      isOwner: isOwner ?? this.isOwner,
      isActive: isActive ?? this.isActive,
      disabledReason: disabledReason ?? this.disabledReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CommunityCourseEmbed {
  final String id;
  final String title;
  final String? price;
  final String? thumbnail;
  final String? status;

  CommunityCourseEmbed({
    required this.id,
    required this.title,
    this.price,
    this.thumbnail,
    this.status,
  });

  bool get isApproved =>
      status == null ||
      status!.toUpperCase() == 'APPROVED' ||
      status!.toUpperCase() == 'PUBLISHED';

  factory CommunityCourseEmbed.fromJson(Map<String, dynamic> json) {
    return CommunityCourseEmbed(
      id: (json['id'] ?? json['course_id'] ?? json['uuid'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? json['course_name'] ?? '').toString(),
      price: json['price']?.toString(),
      thumbnail: (json['thumbnail'] ?? json['image'] ?? json['cover_image'] ?? json['thumbnail_url'])?.toString(),
      status: (json['status'] ?? json['course_status'])?.toString(),
    );
  }
}

class CommunityPost {
  final String id;
  final CommunityAuthor author;
  final CommunityTopic? topic;
  final String? hubId;
  final String? hubName;
  final String postType; // 'POST' | 'ANNOUNCEMENT' | 'WEBINAR' | 'SEMINAR' (or legacy 'GENERAL' etc.)
  final String title;
  final String content;
  final String? image;
  final String? courseId;
  final String? courseName;
  final CommunityCourseEmbed? courseEmbed;
  final DateTime? eventDate;
  final String? venueAddress;
  final String? link;
  final bool isPinned;
  final String tag;
  final int viewsCount;
  final int reactionsCount;
  final String? userReaction; // 'LIKE' | 'LOVE' | 'CLAP' | 'HELPFUL' | 'IDEA' | 'FARM'
  final Map<String, int> reactionsBreakdown;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Granular counts for thumbs up (LIKE) and heart (LOVE)
  int get likeCount {
    final count = reactionsBreakdown['LIKE'] ??
        reactionsBreakdown['THUMBS_UP'] ??
        reactionsBreakdown['GROW'] ??
        reactionsBreakdown['LEAF'] ??
        reactionsBreakdown['FARM'];
    if (count != null) return count;
    // Fallback if breakdown not populated:
    if (userReaction == 'LIKE' || userReaction == 'FARM' || userReaction == 'GROW') {
      return reactionsCount > 0 ? reactionsCount : 1;
    }
    return 0;
  }

  int get loveCount {
    final count = reactionsBreakdown['LOVE'] ?? reactionsBreakdown['HEART'];
    if (count != null) return count;
    // Fallback if breakdown not populated:
    if (userReaction == 'LOVE' || userReaction == 'HEART') {
      return reactionsCount > 0 ? reactionsCount : 1;
    }
    return 0;
  }

  // Backward-compatible getters
  int get likesCount => reactionsCount;
  bool get isLikedByMe => userReaction != null;

  CommunityPost({
    required this.id,
    required this.author,
    this.topic,
    this.hubId,
    this.hubName,
    this.postType = 'POST',
    this.title = '',
    required this.content,
    this.image,
    this.courseId,
    this.courseName,
    this.courseEmbed,
    this.eventDate,
    this.venueAddress,
    this.link,
    this.isPinned = false,
    required this.tag,
    this.viewsCount = 0,
    int? reactionsCount,
    this.userReaction,
    Map<String, int>? reactionsBreakdown,
    int? likesCount,
    bool? isLikedByMe,
    required this.commentsCount,
    required this.createdAt,
    this.updatedAt,
  })  : reactionsCount = reactionsCount ?? likesCount ?? 0,
        reactionsBreakdown = reactionsBreakdown ?? const {};

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
    var rawPostType = (json['post_type'] ?? 'POST').toString().toUpperCase();
    if (rawPostType == 'GENERAL') rawPostType = 'POST';
    if (rawPostType == 'ONLINE_MEETING') rawPostType = 'WEBINAR';
    if (rawPostType == 'OFFLINE_SEMINAR') rawPostType = 'SEMINAR';
    if (rawPostType == 'COURSE_LAUNCH') rawPostType = 'ANNOUNCEMENT';

    DateTime? parsedEventDate;
    if (json['event_date'] != null) {
      parsedEventDate = DateTime.tryParse(json['event_date'].toString())?.toLocal();
    }

    CommunityCourseEmbed? parsedCourse;
    if (json['course'] is Map<String, dynamic>) {
      parsedCourse = CommunityCourseEmbed.fromJson(json['course'] as Map<String, dynamic>);
    }

    String? resolvedCourseId;
    if (parsedCourse != null && parsedCourse.id.isNotEmpty) {
      resolvedCourseId = parsedCourse.id;
    } else if (json['course'] != null && json['course'] is! Map) {
      resolvedCourseId = json['course'].toString();
    } else if (json['course_id'] != null) {
      resolvedCourseId = json['course_id'].toString();
    }

    String? resolvedCourseName;
    if (parsedCourse != null && parsedCourse.title.isNotEmpty) {
      resolvedCourseName = parsedCourse.title;
    } else if (json['course_name'] != null) {
      resolvedCourseName = json['course_name'].toString();
    }

    final parsedReactionsCount = json['reactions_count'] as int? ??
        json['upvotes_count'] as int? ??
        json['likes_count'] as int? ??
        0;

    final breakdownRaw = json['reactions_breakdown'];
    final Map<String, int> parsedBreakdown = {};
    if (breakdownRaw is Map) {
      breakdownRaw.forEach((k, v) {
        if (v is num) {
          parsedBreakdown[k.toString().toUpperCase()] = v.toInt();
        }
      });
    }

    String? parsedUserReaction = json['user_reaction']?.toString();
    if (parsedUserReaction == null || parsedUserReaction.isEmpty || parsedUserReaction == 'null') {
      parsedUserReaction = null;
      final isLiked = json['is_liked'] as bool? ?? json['is_liked_by_me'] as bool? ?? false;
      if (isLiked) {
        parsedUserReaction = 'LIKE';
      }
    }

    return CommunityPost(
      id: json['id'] as String? ?? '',
      author: CommunityAuthor.fromJson(authorMap),
      topic: parsedTopic,
      hubId: json['hub']?.toString() ?? json['hub_id']?.toString(),
      hubName: json['hub_name']?.toString(),
      postType: rawPostType.isNotEmpty ? rawPostType : 'POST',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      image: json['image'] as String?,
      courseId: resolvedCourseId,
      courseName: resolvedCourseName,
      courseEmbed: parsedCourse,
      eventDate: parsedEventDate,
      venueAddress: json['venue_address']?.toString(),
      link: json['link']?.toString(),
      isPinned: json['is_pinned'] as bool? ?? false,
      tag: rawTag,
      viewsCount: json['views_count'] as int? ?? 0,
      reactionsCount: parsedReactionsCount,
      userReaction: parsedUserReaction,
      reactionsBreakdown: parsedBreakdown,
      commentsCount: json['comments_count'] as int? ?? 0,
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

  /// Whether a scheduled webinar is currently open for joining (starts 15 minutes before event date up to 4 hours after).
  bool get isWebinarJoinable {
    if (eventDate == null) return true;
    final now = DateTime.now();
    final joinWindowStart = eventDate!.toLocal().subtract(const Duration(minutes: 15));
    final sessionEnd = eventDate!.toLocal().add(const Duration(hours: 4));
    return now.isAfter(joinWindowStart) && now.isBefore(sessionEnd);
  }

  /// Whether the webinar is scheduled in the future (starts more than 15 minutes ahead).
  bool get isWebinarUpcoming {
    if (eventDate == null) return false;
    final now = DateTime.now();
    final joinWindowStart = eventDate!.toLocal().subtract(const Duration(minutes: 15));
    return now.isBefore(joinWindowStart);
  }

  /// Whether the webinar has already concluded (more than 4 hours past start).
  bool get isWebinarEnded {
    if (eventDate == null) return false;
    final now = DateTime.now();
    final sessionEnd = eventDate!.toLocal().add(const Duration(hours: 4));
    return now.isAfter(sessionEnd);
  }

  /// Human-readable time remaining until the webinar starts (or null if already started or joinable).
  String? get webinarCountdownMessage {
    if (eventDate == null) return null;
    final now = DateTime.now();
    final localStart = eventDate!.toLocal();
    if (now.isAfter(localStart)) return null;
    final diff = localStart.difference(now);
    if (diff.inDays > 1) {
      return 'Starts in ${diff.inDays} days';
    } else if (diff.inDays == 1) {
      return 'Starts tomorrow';
    } else if (diff.inHours > 0) {
      return 'Starts in ${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      return 'Starts in ${diff.inMinutes}m';
    }
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
    CommunityCourseEmbed? courseEmbed,
    DateTime? eventDate,
    String? venueAddress,
    String? link,
    bool? isPinned,
    String? tag,
    int? viewsCount,
    int? reactionsCount,
    String? userReaction,
    Map<String, int>? reactionsBreakdown,
    int? likesCount,
    bool? isLikedByMe,
    int? commentsCount,
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
      courseEmbed: courseEmbed ?? this.courseEmbed,
      eventDate: eventDate ?? this.eventDate,
      venueAddress: venueAddress ?? this.venueAddress,
      link: link ?? this.link,
      isPinned: isPinned ?? this.isPinned,
      tag: tag ?? this.tag,
      viewsCount: viewsCount ?? this.viewsCount,
      reactionsCount: reactionsCount ?? likesCount ?? this.reactionsCount,
      userReaction: userReaction ?? (isLikedByMe != null ? (isLikedByMe ? 'LIKE' : null) : this.userReaction),
      reactionsBreakdown: reactionsBreakdown ?? this.reactionsBreakdown,
      commentsCount: commentsCount ?? this.commentsCount,
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

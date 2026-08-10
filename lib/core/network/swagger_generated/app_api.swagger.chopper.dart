// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'app_api.swagger.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AppApi extends AppApi {
  _$AppApi([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AppApi;

  @override
  Future<Response<PaginatedCategoryAdminList>> _apiV1AdminCategoriesGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'List all categories (admin)',
      operationId: 'api_v1_admin_categories_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCategoryAdminList, PaginatedCategoryAdminList>(
      $request,
    );
  }

  @override
  Future<Response<CategoryAdmin>> _apiV1AdminCategoriesPost({
    required CategoryAdminRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'Create a new category',
      operationId: 'api_v1_admin_categories_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CategoryAdmin, CategoryAdmin>($request);
  }

  @override
  Future<Response<CategoryAdmin>> _apiV1AdminCategoriesIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'Get category detail (admin)',
      operationId: 'api_v1_admin_categories_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CategoryAdmin, CategoryAdmin>($request);
  }

  @override
  Future<Response<CategoryAdmin>> _apiV1AdminCategoriesIdPut({
    required String? id,
    required CategoryAdminRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'Full update a category',
      operationId: 'api_v1_admin_categories_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/${id}/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CategoryAdmin, CategoryAdmin>($request);
  }

  @override
  Future<Response<CategoryAdmin>> _apiV1AdminCategoriesIdPatch({
    required String? id,
    required PatchedCategoryAdminRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'Partial update a category',
      operationId: 'api_v1_admin_categories_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/${id}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CategoryAdmin, CategoryAdmin>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AdminCategoriesIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin-only CRUD for categories.
Shows all language fields (name_en, name_hi, name_mr, etc.) simultaneously.
Restricted to users with role=ADMIN.''',
      summary: 'Delete a category',
      operationId: 'api_v1_admin_categories_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/categories/${id}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedCourseDetailList>> _apiV1AdminCoursesReviewsGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Admin-only management for reviewing and approving/rejecting submitted courses.',
      summary: 'List all courses pending review',
      operationId: 'api_v1_admin_courses_reviews_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/courses/reviews/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCourseDetailList, PaginatedCourseDetailList>(
      $request,
    );
  }

  @override
  Future<Response<CourseDetail>> _apiV1AdminCoursesReviewsIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Admin-only management for reviewing and approving/rejecting submitted courses.',
      summary: 'Get details of a course pending review',
      operationId: 'api_v1_admin_courses_reviews_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/courses/reviews/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CourseDetail, CourseDetail>($request);
  }

  @override
  Future<Response<CourseDetail>> _apiV1AdminCoursesReviewsIdApprovePost({
    required String? id,
    required CourseDetailRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Admin-only management for reviewing and approving/rejecting submitted courses.',
      summary: 'Approve a course and publish it live',
      operationId: 'api_v1_admin_courses_reviews_approve_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/courses/reviews/${id}/approve/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseDetail, CourseDetail>($request);
  }

  @override
  Future<Response<CourseDetail>> _apiV1AdminCoursesReviewsIdRejectPost({
    required String? id,
    required CourseDetailRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Admin-only management for reviewing and approving/rejecting submitted courses.',
      summary: 'Reject a course with admin feedback',
      operationId: 'api_v1_admin_courses_reviews_reject_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/courses/reviews/${id}/reject/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseDetail, CourseDetail>($request);
  }

  @override
  Future<Response<PaginatedEBookList>> _apiV1AdminEbooksGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: 'List all E-Books pending review',
      operationId: 'api_v1_admin_ebooks_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedEBookList, PaginatedEBookList>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksPost({
    required EBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: '',
      operationId: 'api_v1_admin_ebooks_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["api"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: 'Get details of a pending E-Book',
      operationId: 'api_v1_admin_ebooks_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksIdPut({
    required String? id,
    required EBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: '',
      operationId: 'api_v1_admin_ebooks_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["api"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksIdPatch({
    required String? id,
    required PatchedEBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: '',
      operationId: 'api_v1_admin_ebooks_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["api"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AdminEbooksIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: '',
      operationId: 'api_v1_admin_ebooks_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["api"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksIdApprovePost({
    required String? id,
    required EBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: 'Approve an E-Book and notify instructor',
      operationId: 'api_v1_admin_ebooks_approve_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/approve/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBook>> _apiV1AdminEbooksIdRejectPost({
    required String? id,
    required EBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Admin APIs to review, approve, or reject E-Books.
Only lists EBooks that are in REVIEW state.''',
      summary: 'Reject an E-Book and notify instructor',
      operationId: 'api_v1_admin_ebooks_reject_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/admin/ebooks/${id}/reject/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<AdminInstructorReview>>
  _apiV1AuthAdminInstructorsIdReviewPost({
    required String? id,
    required AdminInstructorReviewRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/admin/instructors/<uuid:pk>/review/
Allows an Admin to approve, reject or suspend an instructor account and update KYC status.''',
      summary: '',
      operationId: 'api_v1_auth_admin_instructors_review_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/instructors/${id}/review/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<AdminInstructorReview, AdminInstructorReview>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminLogsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'List available system log files for Admin download/preview.',
      summary: '',
      operationId: 'api_v1_auth_admin_logs_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/logs/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminLogsDownloadGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Download a specific system log file.',
      summary: '',
      operationId: 'api_v1_auth_admin_logs_download_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/logs/download/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminLogsPreviewGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Preview recent lines of a specific system log file.',
      summary: '',
      operationId: 'api_v1_auth_admin_logs_preview_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/logs/preview/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminSettingsPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/admin/settings/
Update system configuration.''',
      summary: '',
      operationId: 'api_v1_auth_admin_settings_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/settings/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminStatsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Admin API for fetching dashboard stats and recent joinings.',
      summary: '',
      operationId: 'api_v1_auth_admin_stats_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/stats/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedAdminUserList>> _apiV1AuthAdminUsersGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for listing and creating users.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedAdminUserList, PaginatedAdminUserList>(
      $request,
    );
  }

  @override
  Future<Response<AdminUser>> _apiV1AuthAdminUsersPost({
    required AdminUserRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for listing and creating users.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<AdminUser, AdminUser>($request);
  }

  @override
  Future<Response<AdminUser>> _apiV1AuthAdminUsersIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for retrieving, updating, and deleting a user.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<AdminUser, AdminUser>($request);
  }

  @override
  Future<Response<AdminUser>> _apiV1AuthAdminUsersIdPut({
    required String? id,
    required AdminUserRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for retrieving, updating, and deleting a user.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/${id}/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<AdminUser, AdminUser>($request);
  }

  @override
  Future<Response<AdminUser>> _apiV1AuthAdminUsersIdPatch({
    required String? id,
    required PatchedAdminUserRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for retrieving, updating, and deleting a user.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/${id}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<AdminUser, AdminUser>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminUsersIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for retrieving, updating, and deleting a user.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/${id}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthAdminUsersExportGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Admin API for exporting filtered users to Excel or PDF.',
      summary: '',
      operationId: 'api_v1_auth_admin_users_export_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/admin/users/export/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<ChangePassword>> _apiV1AuthChangePasswordPost({
    required ChangePasswordRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/change-password/
Authenticated user changes their own password.''',
      summary: '',
      operationId: 'api_v1_auth_change_password_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/change-password/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ChangePassword, ChangePassword>($request);
  }

  @override
  Future<Response<ApiV1AuthFcmTokenPost$Response>> _apiV1AuthFcmTokenPost({
    required FCMTokenRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/fcm-token/
Register or update user\'s FCM device token for push notifications.''',
      summary: '',
      operationId: 'api_v1_auth_fcm_token_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/fcm-token/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client
        .send<ApiV1AuthFcmTokenPost$Response, ApiV1AuthFcmTokenPost$Response>(
          $request,
        );
  }

  @override
  Future<Response<ForgotPassword>> _apiV1AuthForgotPasswordPost({
    required ForgotPasswordRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/forgot-password/
Step 1: Request a password reset OTP. Sends 6-digit code to user\'s email.''',
      summary: '',
      operationId: 'api_v1_auth_forgot_password_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/forgot-password/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ForgotPassword, ForgotPassword>($request);
  }

  @override
  Future<Response<InstructorProfile>> _apiV1AuthInstructorProfileGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/instructor-profile/
Manage instructor-specific profile data.''',
      summary: '',
      operationId: 'api_v1_auth_instructor_profile_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/instructor-profile/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<InstructorProfile, InstructorProfile>($request);
  }

  @override
  Future<Response<InstructorProfile>> _apiV1AuthInstructorProfilePut({
    required InstructorProfileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/instructor-profile/
Manage instructor-specific profile data.''',
      summary: '',
      operationId: 'api_v1_auth_instructor_profile_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/instructor-profile/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<InstructorProfile, InstructorProfile>($request);
  }

  @override
  Future<Response<InstructorProfile>> _apiV1AuthInstructorProfilePatch({
    required PatchedInstructorProfileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/instructor-profile/
Manage instructor-specific profile data.''',
      summary: '',
      operationId: 'api_v1_auth_instructor_profile_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/instructor-profile/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<InstructorProfile, InstructorProfile>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthInstructorStatsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/auth/instructor-stats/
Analytics data for instructor dashboard widgets.''',
      summary: '',
      operationId: 'api_v1_auth_instructor_stats_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/instructor-stats/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Object>> _apiV1AuthLocationsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Returns a dictionary of Indian States and their Districts.
No authentication required.''',
      summary: '',
      operationId: 'api_v1_auth_locations_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/locations/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Object, Object>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthLoginPost({
    required CustomTokenObtainPairRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/login/
Returns JWT access + refresh tokens with role payload.''',
      summary: '',
      operationId: 'api_v1_auth_login_create',
      consumes: [],
      produces: [],
      security: [],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/login/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthLogoutPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/logout/
Blacklist refresh token on logout.''',
      summary: '',
      operationId: 'api_v1_auth_logout_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/logout/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<UserProfile>> _apiV1AuthMeGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/me/
Retrieve and update authenticated user profile.''',
      summary: '',
      operationId: 'api_v1_auth_me_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/me/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<UserProfile, UserProfile>($request);
  }

  @override
  Future<Response<UserProfile>> _apiV1AuthMePut({
    required UserProfileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/me/
Retrieve and update authenticated user profile.''',
      summary: '',
      operationId: 'api_v1_auth_me_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/me/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UserProfile, UserProfile>($request);
  }

  @override
  Future<Response<UserProfile>> _apiV1AuthMePatch({
    required PatchedUserProfileRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/PATCH /api/v1/auth/me/
Retrieve and update authenticated user profile.''',
      summary: '',
      operationId: 'api_v1_auth_me_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/me/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<UserProfile, UserProfile>($request);
  }

  @override
  Future<Response<TokenRefresh>> _apiV1AuthRefreshPost({
    required TokenRefreshRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          '''Takes a refresh type JSON web token and returns an access type JSON web
token if the refresh token is valid.''',
      summary: '',
      operationId: 'api_v1_auth_refresh_create',
      consumes: [],
      produces: [],
      security: [],
      tags: ["api"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/refresh/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<TokenRefresh, TokenRefresh>($request);
  }

  @override
  Future<Response<Register>> _apiV1AuthRegisterPost({
    required RegisterRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/register/
Register new student or instructor account.''',
      summary: '',
      operationId: 'api_v1_auth_register_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/register/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<Register, Register>($request);
  }

  @override
  Future<Response<ResendOTP>> _apiV1AuthResendOtpPost({
    required ResendOTPRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/resend-otp/
Resend OTP to user\'s email. Rate limited to 3 requests per 10 minutes.''',
      summary: '',
      operationId: 'api_v1_auth_resend_otp_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/resend-otp/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ResendOTP, ResendOTP>($request);
  }

  @override
  Future<Response<ResetPassword>> _apiV1AuthResetPasswordPost({
    required ResetPasswordRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/reset-password/
Step 3: Set a new password using the reset token from Step 2.''',
      summary: '',
      operationId: 'api_v1_auth_reset_password_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/reset-password/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<ResetPassword, ResetPassword>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1AuthSystemSettingsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/system-settings/
Public system configuration.''',
      summary: '',
      operationId: 'api_v1_auth_system_settings_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Internal"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/system-settings/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<VerifyResetOTP>> _apiV1AuthVerifyResetOtpPost({
    required VerifyResetOTPRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/auth/verify-reset-otp/
Step 2: Verify the OTP code. Returns a temporary reset token on success.''',
      summary: '',
      operationId: 'api_v1_auth_verify_reset_otp_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Authentication"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/auth/verify-reset-otp/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<VerifyResetOTP, VerifyResetOTP>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1BunnyWebhookPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/courses/bunny-webhook/
Receives automated transcode completion notifications from Bunny Stream.''',
      summary: '',
      operationId: 'api_v1_bunny_webhook_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Internal"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/bunny-webhook/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Cart>> _apiV1CartGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/cart/
Returns the student\'s current cart with all items.''',
      summary: '',
      operationId: 'api_v1_cart_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/cart/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Cart, Cart>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1CartAddPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/cart/add/
Add a course to the student\'s cart.''',
      summary: '',
      operationId: 'api_v1_cart_add_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/cart/add/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1CartClearDelete({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'DELETE /api/v1/cart/clear/',
      summary: '',
      operationId: 'api_v1_cart_clear_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/cart/clear/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1CartRemoveCourseIdDelete({
    required String? courseId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''DELETE /api/v1/cart/remove/<course_id>/
Remove a course from the cart.''',
      summary: '',
      operationId: 'api_v1_cart_remove_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/cart/remove/${courseId}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedCategoryList>> _apiV1CategoriesGet({
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'Returns all active categories. The `name` and `description` fields are returned in the language specified by the `Accept-Language` header (en / hi / mr). Filter by `?content_type=COURSE` or `?content_type=EBOOK`.',
      summary: 'List categories (language-aware)',
      operationId: 'api_v1_categories_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/categories/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCategoryList, PaginatedCategoryList>($request);
  }

  @override
  Future<Response<Category>> _apiV1CategoriesSlugGet({
    required String? slug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Public read-only endpoint for the Flutter app.
Language is resolved automatically by Django\'s LocaleMiddleware
from the Accept-Language request header.''',
      summary: 'Get a single category by slug',
      operationId: 'api_v1_categories_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/categories/${slug}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Category, Category>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1CheckoutPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/checkout/
Simulate sandbox payment checkout.

Flow:
1. Validate cart is not empty
2. Validate payment credentials (dummy validation)
3. Simulate payment gateway call (always succeeds in sandbox)
4. Generate mock gateway_reference ID
5. Create Order + OrderItems
6. Create Enrollments for all purchased courses
7. Clear cart
8. Return order confirmation''',
      summary: '',
      operationId: 'api_v1_checkout_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/checkout/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ClientEventsPost({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '',
      summary: '',
      operationId: 'api_v1_client_events_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Internal"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/client-events/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<CourseDetail>> _apiV1CoursesSlugGet({
    required String? slug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/courses/<slug>/
Public course detail — shows full section/lecture tree.''',
      summary: '',
      operationId: 'api_v1_courses_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/courses/${slug}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CourseDetail, CourseDetail>($request);
  }

  @override
  Future<Response<PaginatedCourseListList>> _apiV1CoursesCatalogGet({
    String? category,
    String? categorySlug,
    String? level,
    num? maxPrice,
    num? minPrice,
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/courses/catalog/
Public endpoint — lists all APPROVED courses with filtering.''',
      summary: '',
      operationId: 'api_v1_courses_catalog_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/courses/catalog/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'category': category,
      'category_slug': categorySlug,
      'level': level,
      'max_price': maxPrice,
      'min_price': minPrice,
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCourseListList, PaginatedCourseListList>(
      $request,
    );
  }

  @override
  Future<Response<PaginatedEBookList>> _apiV1EbooksGet({
    String? category,
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Public and student APIs to browse live E-Books.
Only returns EBooks with APPROVED status.
Supports: ?search=, ?category=<uuid>, ?ordering=title/-title/created_at/-created_at''',
      summary: 'List approved E-Books',
      operationId: 'api_v1_ebooks_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - EBooks"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/ebooks/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'category': category,
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedEBookList, PaginatedEBookList>($request);
  }

  @override
  Future<Response<EBook>> _apiV1EbooksSlugGet({
    required String? slug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Public and student APIs to browse live E-Books.
Only returns EBooks with APPROVED status.
Supports: ?search=, ?category=<uuid>, ?ordering=title/-title/created_at/-created_at''',
      summary: 'Get details of an approved E-Book',
      operationId: 'api_v1_ebooks_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - EBooks"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/ebooks/${slug}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBook>> _apiV1EbooksSlugReadGet({
    required String? slug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Public and student APIs to browse live E-Books.
Only returns EBooks with APPROVED status.
Supports: ?search=, ?category=<uuid>, ?ordering=title/-title/created_at/-created_at''',
      summary: 'Retrieve read file url for E-Book',
      operationId: 'api_v1_ebooks_read_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - EBooks"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/ebooks/${slug}/read/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<PaginatedEnrollmentList>> _apiV1EnrollmentsGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/enrollments/
Student\'s enrolled courses list.''',
      summary: '',
      operationId: 'api_v1_enrollments_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/enrollments/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedEnrollmentList, PaginatedEnrollmentList>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _apiV1EnrollmentsCheckCourseIdGet({
    required String? courseId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'Check if current user is enrolled in a course.',
      summary: '',
      operationId: 'api_v1_enrollments_check_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/enrollments/check/${courseId}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedCourseListList>> _apiV1InstructorCoursesGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCourseListList, PaginatedCourseListList>(
      $request,
    );
  }

  @override
  Future<Response<CourseCreate>> _apiV1InstructorCoursesPost({
    required CourseCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseCreate, CourseCreate>($request);
  }

  @override
  Future<Response<PaginatedCertificateTemplateList>>
  _apiV1InstructorCoursesCoursePkCertificateGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<
      PaginatedCertificateTemplateList,
      PaginatedCertificateTemplateList
    >($request);
  }

  @override
  Future<Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificatePost({
    required String? coursePk,
    required CertificateTemplateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CertificateTemplate, CertificateTemplate>($request);
  }

  @override
  Future<Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdGet({
    required String? coursePk,
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/${id}/',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CertificateTemplate, CertificateTemplate>($request);
  }

  @override
  Future<Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdPut({
    required String? coursePk,
    required String? id,
    required CertificateTemplateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CertificateTemplate, CertificateTemplate>($request);
  }

  @override
  Future<Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdPatch({
    required String? coursePk,
    required String? id,
    required PatchedCertificateTemplateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CertificateTemplate, CertificateTemplate>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorCoursesCoursePkCertificateIdDelete({
    required String? coursePk,
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for certificate templates for a specific course.',
      summary: '',
      operationId: 'api_v1_instructor_courses_certificate_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/certificate/${id}/',
    );
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedCourseSectionList>>
  _apiV1InstructorCoursesCoursePkSectionsGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedCourseSectionList, PaginatedCourseSectionList>(
      $request,
    );
  }

  @override
  Future<Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsPost({
    required String? coursePk,
    required CourseSectionCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseSectionCreate, CourseSectionCreate>($request);
  }

  @override
  Future<Response<CourseSection>> _apiV1InstructorCoursesCoursePkSectionsIdGet({
    required String? coursePk,
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${id}/',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CourseSection, CourseSection>($request);
  }

  @override
  Future<Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsIdPut({
    required String? coursePk,
    required String? id,
    required CourseSectionCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseSectionCreate, CourseSectionCreate>($request);
  }

  @override
  Future<Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsIdPatch({
    required String? coursePk,
    required String? id,
    required PatchedCourseSectionCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseSectionCreate, CourseSectionCreate>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorCoursesCoursePkSectionsIdDelete({
    required String? coursePk,
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for course sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${id}/',
    );
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedLectureList>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
    required String? sectionPk,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/',
    );
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedLectureList, PaginatedLectureList>($request);
  }

  @override
  Future<Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesPost({
    required String? coursePk,
    required String? sectionPk,
    required LectureCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/',
    );
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LectureCreate, LectureCreate>($request);
  }

  @override
  Future<Response<Lecture>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdGet({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/${id}/',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<Lecture, Lecture>($request);
  }

  @override
  Future<Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPut({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    required LectureCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LectureCreate, LectureCreate>($request);
  }

  @override
  Future<Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPatch({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    required PatchedLectureCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/${id}/',
    );
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<LectureCreate, LectureCreate>($request);
  }

  @override
  Future<Response<dynamic>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdDelete({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'CRUD for lectures within sections.',
      summary: '',
      operationId: 'api_v1_instructor_courses_sections_lectures_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${coursePk}/sections/${sectionPk}/lectures/${id}/',
    );
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<CourseDetail>> _apiV1InstructorCoursesIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CourseDetail, CourseDetail>($request);
  }

  @override
  Future<Response<CourseCreate>> _apiV1InstructorCoursesIdPut({
    required String? id,
    required CourseCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/${id}/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseCreate, CourseCreate>($request);
  }

  @override
  Future<Response<CourseCreate>> _apiV1InstructorCoursesIdPatch({
    required String? id,
    required PatchedCourseCreateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/${id}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseCreate, CourseCreate>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorCoursesIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor CRUD for their own courses.
POST triggers Layer 1 NLP validation, then sets to PROCESSING.''',
      summary: '',
      operationId: 'api_v1_instructor_courses_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/${id}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<CourseList>> _apiV1InstructorCoursesIdModerationStatusGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'GET /api/v1/instructor/courses/<id>/moderation-status/',
      summary: '',
      operationId: 'api_v1_instructor_courses_moderation_status_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/instructor/courses/${id}/moderation-status/',
    );
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<CourseList, CourseList>($request);
  }

  @override
  Future<Response<CourseList>> _apiV1InstructorCoursesIdPublishPost({
    required String? id,
    required CourseListRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'POST /api/v1/instructor/courses/<id>/publish/',
      summary: '',
      operationId: 'api_v1_instructor_courses_publish_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/courses/${id}/publish/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<CourseList, CourseList>($request);
  }

  @override
  Future<Response<PaginatedEBookList>> _apiV1InstructorEbooksGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'List instructor\'s own E-Books',
      operationId: 'api_v1_instructor_ebooks_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedEBookList, PaginatedEBookList>($request);
  }

  @override
  Future<Response<EBookCreateUpdate>> _apiV1InstructorEbooksPost({
    required EBookCreateUpdateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Create a new E-Book draft',
      operationId: 'api_v1_instructor_ebooks_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBookCreateUpdate, EBookCreateUpdate>($request);
  }

  @override
  Future<Response<EBook>> _apiV1InstructorEbooksIdGet({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Get detail of instructor\'s E-Book',
      operationId: 'api_v1_instructor_ebooks_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/${id}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<EBookCreateUpdate>> _apiV1InstructorEbooksIdPut({
    required String? id,
    required EBookCreateUpdateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Update an E-Book',
      operationId: 'api_v1_instructor_ebooks_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/${id}/');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBookCreateUpdate, EBookCreateUpdate>($request);
  }

  @override
  Future<Response<EBookCreateUpdate>> _apiV1InstructorEbooksIdPatch({
    required String? id,
    required PatchedEBookCreateUpdateRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Partially update an E-Book',
      operationId: 'api_v1_instructor_ebooks_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/${id}/');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBookCreateUpdate, EBookCreateUpdate>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorEbooksIdDelete({
    required String? id,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Delete an E-Book draft',
      operationId: 'api_v1_instructor_ebooks_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/${id}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<EBook>> _apiV1InstructorEbooksIdSubmitPost({
    required String? id,
    required EBookRequest? body,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''Instructor APIs to manage their own E-Books.
Can create drafts, update, delete drafts, and submit for admin review.''',
      summary: 'Submit E-Book for review',
      operationId: 'api_v1_instructor_ebooks_submit_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/ebooks/${id}/submit/');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      tag: swaggerMetaData,
    );
    return client.send<EBook, EBook>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorQaGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/instructor/qa/
Returns all CourseQuestions from courses where the authenticated user is the instructor.
Optional query param: ?status=UNRESOLVED|RESOLVED|ALL (default: ALL)''',
      summary: '',
      operationId: 'api_v1_instructor_qa_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/qa/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorQaQuestionIdAnswerPost({
    required String? questionId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/instructor/qa/<uuid:question_id>/answer/
Instructor posts an answer to a student question on one of their courses.
Body: { "answer_text": "..." }''',
      summary: '',
      operationId: 'api_v1_instructor_qa_answer_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/qa/${questionId}/answer/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1InstructorTransactionsGet({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description:
          'GET /api/v1/instructor/transactions/ — Instructor sales transactions ledger',
      summary: 'Get instructor\'s sales transactions ledger',
      operationId: 'api_v1_instructor_transactions_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/instructor/transactions/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1LecturesLectureIdStreamGet({
    required String? lectureId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/courses/lectures/<uuid>/stream/
Generates a secure, time-limited SHA-256 signed HLS URL for lecture streaming.''',
      summary: '',
      operationId: 'api_v1_lectures_stream_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Courses"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/lectures/${lectureId}/stream/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1LecturesLectureIdUploadResourcePost({
    required String? lectureId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/courses/lectures/<uuid>/upload-resource/
Uploads a study material PDF or document for a lecture.''',
      summary: '',
      operationId: 'api_v1_lectures_upload_resource_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/lectures/${lectureId}/upload-resource/',
    );
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1LecturesLectureIdUploadVideoPost({
    required String? lectureId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/courses/lectures/<uuid>/upload-video/
Uploads a video file for a lecture to Bunny Stream.''',
      summary: '',
      operationId: 'api_v1_lectures_upload_video_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Instructor"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/lectures/${lectureId}/upload-video/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedModerationLogList>> _apiV1ModerationLogsGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/moderation/logs/
History of moderation decisions for an instructor\'s courses.''',
      summary: '',
      operationId: 'api_v1_moderation_logs_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/moderation/logs/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedModerationLogList, PaginatedModerationLogList>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _apiV1ModerationStatusCourseIdGet({
    required String? courseId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/moderation/status/<course_id>/
Polling endpoint for real-time moderation status updates.''',
      summary: '',
      operationId: 'api_v1_moderation_status_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/moderation/status/${courseId}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<Notification>>> _apiV1NotificationsGet({
    String? ordering,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/notifications/
Returns latest 20 notifications for the authenticated instructor.
Polled every 10 seconds by the React frontend for real-time alerts.''',
      summary: '',
      operationId: 'api_v1_notifications_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<Notification>, Notification>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsNotificationIdReadPatch({
    required String? notificationId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/<id>/read/',
      summary: '',
      operationId: 'api_v1_notifications_read_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/${notificationId}/read/');
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<AdminNotification>>> _apiV1NotificationsAdminGet({
    String? ordering,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/notifications/admin/
Returns latest 20 admin system notifications.''',
      summary: '',
      operationId: 'api_v1_notifications_admin_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/admin/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<AdminNotification>, AdminNotification>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsAdminNotificationIdReadPatch({
    required String? notificationId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/admin/<id>/read/',
      summary: '',
      operationId: 'api_v1_notifications_admin_read_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/notifications/admin/${notificationId}/read/',
    );
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsAdminReadAllPatch({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/admin/read-all/',
      summary: '',
      operationId: 'api_v1_notifications_admin_read_all_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["Admin Panel"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/admin/read-all/');
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsReadAllPatch({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/read-all/',
      summary: '',
      operationId: 'api_v1_notifications_read_all_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/read-all/');
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<List<StudentNotification>>> _apiV1NotificationsStudentGet({
    String? ordering,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/notifications/student/
Returns latest 20 notifications for the authenticated student.''',
      summary: '',
      operationId: 'api_v1_notifications_student_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/student/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<List<StudentNotification>, StudentNotification>(
      $request,
    );
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsStudentNotificationIdReadPatch({
    required String? notificationId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/student/<id>/read/',
      summary: '',
      operationId: 'api_v1_notifications_student_read_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse(
      '/api/v1/notifications/student/${notificationId}/read/',
    );
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1NotificationsStudentReadAllPatch({
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'PATCH /api/v1/notifications/student/read-all/',
      summary: '',
      operationId: 'api_v1_notifications_student_read_all_partial_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Notifications"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/notifications/student/read-all/');
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<PaginatedOrderList>> _apiV1OrdersGet({
    String? ordering,
    int? page,
    String? search,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'GET /api/v1/orders/ — student\'s order history',
      summary: '',
      operationId: 'api_v1_orders_list',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Orders"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/orders/');
    final Map<String, dynamic> $params = <String, dynamic>{
      'ordering': ordering,
      'page': page,
      'search': search,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
      tag: swaggerMetaData,
    );
    return client.send<PaginatedOrderList, PaginatedOrderList>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressLectureIdPost({
    required String? lectureId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/progress/<lecture_id>/
Update student\'s watched time and completion status for a lecture.''',
      summary: '',
      operationId: 'api_v1_progress_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/${lectureId}/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressCourseCourseSlugGet({
    required String? courseSlug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET /api/v1/progress/course/<slug>/
Returns progress for all lectures in a course.''',
      summary: '',
      operationId: 'api_v1_progress_course_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/course/${courseSlug}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressCourseCourseSlugNotesGet({
    required String? courseSlug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/POST /api/v1/progress/course/<slug>/notes/
List or create notes for a student in a course.''',
      summary: '',
      operationId: 'api_v1_progress_course_notes_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/course/${courseSlug}/notes/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressCourseCourseSlugNotesPost({
    required String? courseSlug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/POST /api/v1/progress/course/<slug>/notes/
List or create notes for a student in a course.''',
      summary: '',
      operationId: 'api_v1_progress_course_notes_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/course/${courseSlug}/notes/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressCourseCourseSlugQaGet({
    required String? courseSlug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/POST /api/v1/progress/course/<slug>/qa/
List or create Q&A questions for a course.''',
      summary: '',
      operationId: 'api_v1_progress_course_qa_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/course/${courseSlug}/qa/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressCourseCourseSlugQaPost({
    required String? courseSlug,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''GET/POST /api/v1/progress/course/<slug>/qa/
List or create Q&A questions for a course.''',
      summary: '',
      operationId: 'api_v1_progress_course_qa_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/course/${courseSlug}/qa/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressNotesNoteIdDelete({
    required String? noteId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''DELETE /api/v1/progress/notes/<uuid:note_id>/
Delete a specific student note.''',
      summary: '',
      operationId: 'api_v1_progress_notes_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/notes/${noteId}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressQaQuestionIdPut({
    required String? questionId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''PUT/DELETE /api/v1/progress/qa/<uuid:question_id>/
Edit or delete a student question.''',
      summary: '',
      operationId: 'api_v1_progress_qa_update',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/qa/${questionId}/');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1ProgressQaQuestionIdDelete({
    required String? questionId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''PUT/DELETE /api/v1/progress/qa/<uuid:question_id>/
Edit or delete a student question.''',
      summary: '',
      operationId: 'api_v1_progress_qa_destroy',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/progress/qa/${questionId}/');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1QuizQuizIdSubmitPost({
    required String? quizId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: '''POST /api/v1/quiz/<quiz_id>/submit/
Submit quiz answers and receive score.
answers: { "question_id": selected_option_index, ... }''',
      summary: '',
      operationId: 'api_v1_quiz_submit_create',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/quiz/${quizId}/submit/');
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _apiV1QuizSectionSectionIdGet({
    required String? sectionId,
    SwaggerMetaData swaggerMetaData = const SwaggerMetaData(
      description: 'GET /api/v1/quiz/<section_id>/',
      summary: '',
      operationId: 'api_v1_quiz_section_retrieve',
      consumes: [],
      produces: [],
      security: ["jwtAuth"],
      tags: ["App - Progress"],
      deprecated: false,
    ),
  }) {
    final Uri $url = Uri.parse('/api/v1/quiz/section/${sectionId}/');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      tag: swaggerMetaData,
    );
    return client.send<dynamic, dynamic>($request);
  }
}

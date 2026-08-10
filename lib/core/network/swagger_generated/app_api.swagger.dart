// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element_parameter

import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as json;
import 'package:collection/collection.dart';
import 'dart:convert';

import 'package:chopper/chopper.dart';

import 'client_mapping.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show MultipartFile;
import 'package:chopper/chopper.dart' as chopper;
import 'app_api.enums.swagger.dart' as enums;
import 'app_api.metadata.swagger.dart';
export 'app_api.enums.swagger.dart';

part 'app_api.swagger.chopper.dart';
part 'app_api.swagger.g.dart';

// **************************************************************************
// SwaggerChopperGenerator
// **************************************************************************

@ChopperApi()
abstract class AppApi extends ChopperService {
  static AppApi create({
    ChopperClient? client,
    http.Client? httpClient,
    Authenticator? authenticator,
    ErrorConverter? errorConverter,
    Converter? converter,
    Uri? baseUrl,
    List<Interceptor>? interceptors,
  }) {
    if (client != null) {
      return _$AppApi(client);
    }

    final newClient = ChopperClient(
      services: [_$AppApi()],
      converter: converter ?? $JsonSerializableConverter(),
      interceptors: interceptors ?? [],
      client: httpClient,
      authenticator: authenticator,
      errorConverter: errorConverter,
      baseUrl: baseUrl ?? Uri.parse('http://'),
    );
    return _$AppApi(newClient);
  }

  ///List all categories (admin)
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCategoryAdminList>> apiV1AdminCategoriesGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCategoryAdminList,
      () => PaginatedCategoryAdminList.fromJsonFactory,
    );

    return _apiV1AdminCategoriesGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///List all categories (admin)
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/admin/categories/')
  Future<chopper.Response<PaginatedCategoryAdminList>>
  _apiV1AdminCategoriesGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///Create a new category
  Future<chopper.Response<CategoryAdmin>> apiV1AdminCategoriesPost({
    required CategoryAdminRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CategoryAdmin,
      () => CategoryAdmin.fromJsonFactory,
    );

    return _apiV1AdminCategoriesPost(body: body);
  }

  ///Create a new category
  @POST(path: '/api/v1/admin/categories/', optionalBody: true)
  Future<chopper.Response<CategoryAdmin>> _apiV1AdminCategoriesPost({
    @Body() required CategoryAdminRequest? body,
    @chopper.Tag()
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
  });

  ///Get category detail (admin)
  ///@param id A UUID string identifying this Category.
  Future<chopper.Response<CategoryAdmin>> apiV1AdminCategoriesIdGet({
    required String? id,
  }) {
    generatedMapping.putIfAbsent(
      CategoryAdmin,
      () => CategoryAdmin.fromJsonFactory,
    );

    return _apiV1AdminCategoriesIdGet(id: id);
  }

  ///Get category detail (admin)
  ///@param id A UUID string identifying this Category.
  @GET(path: '/api/v1/admin/categories/{id}/')
  Future<chopper.Response<CategoryAdmin>> _apiV1AdminCategoriesIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///Full update a category
  ///@param id A UUID string identifying this Category.
  Future<chopper.Response<CategoryAdmin>> apiV1AdminCategoriesIdPut({
    required String? id,
    required CategoryAdminRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CategoryAdmin,
      () => CategoryAdmin.fromJsonFactory,
    );

    return _apiV1AdminCategoriesIdPut(id: id, body: body);
  }

  ///Full update a category
  ///@param id A UUID string identifying this Category.
  @PUT(path: '/api/v1/admin/categories/{id}/', optionalBody: true)
  Future<chopper.Response<CategoryAdmin>> _apiV1AdminCategoriesIdPut({
    @Path('id') required String? id,
    @Body() required CategoryAdminRequest? body,
    @chopper.Tag()
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
  });

  ///Partial update a category
  ///@param id A UUID string identifying this Category.
  Future<chopper.Response<CategoryAdmin>> apiV1AdminCategoriesIdPatch({
    required String? id,
    required PatchedCategoryAdminRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CategoryAdmin,
      () => CategoryAdmin.fromJsonFactory,
    );

    return _apiV1AdminCategoriesIdPatch(id: id, body: body);
  }

  ///Partial update a category
  ///@param id A UUID string identifying this Category.
  @PATCH(path: '/api/v1/admin/categories/{id}/', optionalBody: true)
  Future<chopper.Response<CategoryAdmin>> _apiV1AdminCategoriesIdPatch({
    @Path('id') required String? id,
    @Body() required PatchedCategoryAdminRequest? body,
    @chopper.Tag()
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
  });

  ///Delete a category
  ///@param id A UUID string identifying this Category.
  Future<chopper.Response> apiV1AdminCategoriesIdDelete({required String? id}) {
    return _apiV1AdminCategoriesIdDelete(id: id);
  }

  ///Delete a category
  ///@param id A UUID string identifying this Category.
  @DELETE(path: '/api/v1/admin/categories/{id}/')
  Future<chopper.Response> _apiV1AdminCategoriesIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///List all courses pending review
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCourseDetailList>>
  apiV1AdminCoursesReviewsGet({String? ordering, int? page, String? search}) {
    generatedMapping.putIfAbsent(
      PaginatedCourseDetailList,
      () => PaginatedCourseDetailList.fromJsonFactory,
    );

    return _apiV1AdminCoursesReviewsGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///List all courses pending review
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/admin/courses/reviews/')
  Future<chopper.Response<PaginatedCourseDetailList>>
  _apiV1AdminCoursesReviewsGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///Get details of a course pending review
  ///@param id A UUID string identifying this Course.
  Future<chopper.Response<CourseDetail>> apiV1AdminCoursesReviewsIdGet({
    required String? id,
  }) {
    generatedMapping.putIfAbsent(
      CourseDetail,
      () => CourseDetail.fromJsonFactory,
    );

    return _apiV1AdminCoursesReviewsIdGet(id: id);
  }

  ///Get details of a course pending review
  ///@param id A UUID string identifying this Course.
  @GET(path: '/api/v1/admin/courses/reviews/{id}/')
  Future<chopper.Response<CourseDetail>> _apiV1AdminCoursesReviewsIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///Approve a course and publish it live
  ///@param id A UUID string identifying this Course.
  Future<chopper.Response<CourseDetail>> apiV1AdminCoursesReviewsIdApprovePost({
    required String? id,
    required CourseDetailRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseDetail,
      () => CourseDetail.fromJsonFactory,
    );

    return _apiV1AdminCoursesReviewsIdApprovePost(id: id, body: body);
  }

  ///Approve a course and publish it live
  ///@param id A UUID string identifying this Course.
  @POST(path: '/api/v1/admin/courses/reviews/{id}/approve/', optionalBody: true)
  Future<chopper.Response<CourseDetail>>
  _apiV1AdminCoursesReviewsIdApprovePost({
    @Path('id') required String? id,
    @Body() required CourseDetailRequest? body,
    @chopper.Tag()
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
  });

  ///Reject a course with admin feedback
  ///@param id A UUID string identifying this Course.
  Future<chopper.Response<CourseDetail>> apiV1AdminCoursesReviewsIdRejectPost({
    required String? id,
    required CourseDetailRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseDetail,
      () => CourseDetail.fromJsonFactory,
    );

    return _apiV1AdminCoursesReviewsIdRejectPost(id: id, body: body);
  }

  ///Reject a course with admin feedback
  ///@param id A UUID string identifying this Course.
  @POST(path: '/api/v1/admin/courses/reviews/{id}/reject/', optionalBody: true)
  Future<chopper.Response<CourseDetail>> _apiV1AdminCoursesReviewsIdRejectPost({
    @Path('id') required String? id,
    @Body() required CourseDetailRequest? body,
    @chopper.Tag()
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
  });

  ///List all E-Books pending review
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedEBookList>> apiV1AdminEbooksGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedEBookList,
      () => PaginatedEBookList.fromJsonFactory,
    );

    return _apiV1AdminEbooksGet(ordering: ordering, page: page, search: search);
  }

  ///List all E-Books pending review
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/admin/ebooks/')
  Future<chopper.Response<PaginatedEBookList>> _apiV1AdminEbooksGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<EBook>> apiV1AdminEbooksPost({
    required EBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksPost(body: body);
  }

  ///
  @POST(path: '/api/v1/admin/ebooks/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1AdminEbooksPost({
    @Body() required EBookRequest? body,
    @chopper.Tag()
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
  });

  ///Get details of a pending E-Book
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response<EBook>> apiV1AdminEbooksIdGet({required String? id}) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksIdGet(id: id);
  }

  ///Get details of a pending E-Book
  ///@param id A UUID string identifying this EBook.
  @GET(path: '/api/v1/admin/ebooks/{id}/')
  Future<chopper.Response<EBook>> _apiV1AdminEbooksIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response<EBook>> apiV1AdminEbooksIdPut({
    required String? id,
    required EBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksIdPut(id: id, body: body);
  }

  ///
  ///@param id A UUID string identifying this EBook.
  @PUT(path: '/api/v1/admin/ebooks/{id}/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1AdminEbooksIdPut({
    @Path('id') required String? id,
    @Body() required EBookRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response<EBook>> apiV1AdminEbooksIdPatch({
    required String? id,
    required PatchedEBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksIdPatch(id: id, body: body);
  }

  ///
  ///@param id A UUID string identifying this EBook.
  @PATCH(path: '/api/v1/admin/ebooks/{id}/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1AdminEbooksIdPatch({
    @Path('id') required String? id,
    @Body() required PatchedEBookRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response> apiV1AdminEbooksIdDelete({required String? id}) {
    return _apiV1AdminEbooksIdDelete(id: id);
  }

  ///
  ///@param id A UUID string identifying this EBook.
  @DELETE(path: '/api/v1/admin/ebooks/{id}/')
  Future<chopper.Response> _apiV1AdminEbooksIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///Approve an E-Book and notify instructor
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response<EBook>> apiV1AdminEbooksIdApprovePost({
    required String? id,
    required EBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksIdApprovePost(id: id, body: body);
  }

  ///Approve an E-Book and notify instructor
  ///@param id A UUID string identifying this EBook.
  @POST(path: '/api/v1/admin/ebooks/{id}/approve/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1AdminEbooksIdApprovePost({
    @Path('id') required String? id,
    @Body() required EBookRequest? body,
    @chopper.Tag()
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
  });

  ///Reject an E-Book and notify instructor
  ///@param id A UUID string identifying this EBook.
  Future<chopper.Response<EBook>> apiV1AdminEbooksIdRejectPost({
    required String? id,
    required EBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1AdminEbooksIdRejectPost(id: id, body: body);
  }

  ///Reject an E-Book and notify instructor
  ///@param id A UUID string identifying this EBook.
  @POST(path: '/api/v1/admin/ebooks/{id}/reject/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1AdminEbooksIdRejectPost({
    @Path('id') required String? id,
    @Body() required EBookRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<AdminInstructorReview>>
  apiV1AuthAdminInstructorsIdReviewPost({
    required String? id,
    required AdminInstructorReviewRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      AdminInstructorReview,
      () => AdminInstructorReview.fromJsonFactory,
    );

    return _apiV1AuthAdminInstructorsIdReviewPost(id: id, body: body);
  }

  ///
  ///@param id
  @POST(path: '/api/v1/auth/admin/instructors/{id}/review/', optionalBody: true)
  Future<chopper.Response<AdminInstructorReview>>
  _apiV1AuthAdminInstructorsIdReviewPost({
    @Path('id') required String? id,
    @Body() required AdminInstructorReviewRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminLogsGet() {
    return _apiV1AuthAdminLogsGet();
  }

  ///
  @GET(path: '/api/v1/auth/admin/logs/')
  Future<chopper.Response> _apiV1AuthAdminLogsGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminLogsDownloadGet() {
    return _apiV1AuthAdminLogsDownloadGet();
  }

  ///
  @GET(path: '/api/v1/auth/admin/logs/download/')
  Future<chopper.Response> _apiV1AuthAdminLogsDownloadGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminLogsPreviewGet() {
    return _apiV1AuthAdminLogsPreviewGet();
  }

  ///
  @GET(path: '/api/v1/auth/admin/logs/preview/')
  Future<chopper.Response> _apiV1AuthAdminLogsPreviewGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminSettingsPost() {
    return _apiV1AuthAdminSettingsPost();
  }

  ///
  @POST(path: '/api/v1/auth/admin/settings/', optionalBody: true)
  Future<chopper.Response> _apiV1AuthAdminSettingsPost({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminStatsGet() {
    return _apiV1AuthAdminStatsGet();
  }

  ///
  @GET(path: '/api/v1/auth/admin/stats/')
  Future<chopper.Response> _apiV1AuthAdminStatsGet({
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedAdminUserList>> apiV1AuthAdminUsersGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedAdminUserList,
      () => PaginatedAdminUserList.fromJsonFactory,
    );

    return _apiV1AuthAdminUsersGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/auth/admin/users/')
  Future<chopper.Response<PaginatedAdminUserList>> _apiV1AuthAdminUsersGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<AdminUser>> apiV1AuthAdminUsersPost({
    required AdminUserRequest? body,
  }) {
    generatedMapping.putIfAbsent(AdminUser, () => AdminUser.fromJsonFactory);

    return _apiV1AuthAdminUsersPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/admin/users/', optionalBody: true)
  Future<chopper.Response<AdminUser>> _apiV1AuthAdminUsersPost({
    @Body() required AdminUserRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<AdminUser>> apiV1AuthAdminUsersIdGet({
    required String? id,
  }) {
    generatedMapping.putIfAbsent(AdminUser, () => AdminUser.fromJsonFactory);

    return _apiV1AuthAdminUsersIdGet(id: id);
  }

  ///
  ///@param id
  @GET(path: '/api/v1/auth/admin/users/{id}/')
  Future<chopper.Response<AdminUser>> _apiV1AuthAdminUsersIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<AdminUser>> apiV1AuthAdminUsersIdPut({
    required String? id,
    required AdminUserRequest? body,
  }) {
    generatedMapping.putIfAbsent(AdminUser, () => AdminUser.fromJsonFactory);

    return _apiV1AuthAdminUsersIdPut(id: id, body: body);
  }

  ///
  ///@param id
  @PUT(path: '/api/v1/auth/admin/users/{id}/', optionalBody: true)
  Future<chopper.Response<AdminUser>> _apiV1AuthAdminUsersIdPut({
    @Path('id') required String? id,
    @Body() required AdminUserRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<AdminUser>> apiV1AuthAdminUsersIdPatch({
    required String? id,
    required PatchedAdminUserRequest? body,
  }) {
    generatedMapping.putIfAbsent(AdminUser, () => AdminUser.fromJsonFactory);

    return _apiV1AuthAdminUsersIdPatch(id: id, body: body);
  }

  ///
  ///@param id
  @PATCH(path: '/api/v1/auth/admin/users/{id}/', optionalBody: true)
  Future<chopper.Response<AdminUser>> _apiV1AuthAdminUsersIdPatch({
    @Path('id') required String? id,
    @Body() required PatchedAdminUserRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response> apiV1AuthAdminUsersIdDelete({required String? id}) {
    return _apiV1AuthAdminUsersIdDelete(id: id);
  }

  ///
  ///@param id
  @DELETE(path: '/api/v1/auth/admin/users/{id}/')
  Future<chopper.Response> _apiV1AuthAdminUsersIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthAdminUsersExportGet() {
    return _apiV1AuthAdminUsersExportGet();
  }

  ///
  @GET(path: '/api/v1/auth/admin/users/export/')
  Future<chopper.Response> _apiV1AuthAdminUsersExportGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ChangePassword>> apiV1AuthChangePasswordPost({
    required ChangePasswordRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      ChangePassword,
      () => ChangePassword.fromJsonFactory,
    );

    return _apiV1AuthChangePasswordPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/change-password/', optionalBody: true)
  Future<chopper.Response<ChangePassword>> _apiV1AuthChangePasswordPost({
    @Body() required ChangePasswordRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ApiV1AuthFcmTokenPost$Response>>
  apiV1AuthFcmTokenPost({required FCMTokenRequest? body}) {
    generatedMapping.putIfAbsent(
      ApiV1AuthFcmTokenPost$Response,
      () => ApiV1AuthFcmTokenPost$Response.fromJsonFactory,
    );

    return _apiV1AuthFcmTokenPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/fcm-token/', optionalBody: true)
  Future<chopper.Response<ApiV1AuthFcmTokenPost$Response>>
  _apiV1AuthFcmTokenPost({
    @Body() required FCMTokenRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ForgotPassword>> apiV1AuthForgotPasswordPost({
    required ForgotPasswordRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      ForgotPassword,
      () => ForgotPassword.fromJsonFactory,
    );

    return _apiV1AuthForgotPasswordPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/forgot-password/', optionalBody: true)
  Future<chopper.Response<ForgotPassword>> _apiV1AuthForgotPasswordPost({
    @Body() required ForgotPasswordRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<InstructorProfile>> apiV1AuthInstructorProfileGet() {
    generatedMapping.putIfAbsent(
      InstructorProfile,
      () => InstructorProfile.fromJsonFactory,
    );

    return _apiV1AuthInstructorProfileGet();
  }

  ///
  @GET(path: '/api/v1/auth/instructor-profile/')
  Future<chopper.Response<InstructorProfile>> _apiV1AuthInstructorProfileGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<InstructorProfile>> apiV1AuthInstructorProfilePut({
    required InstructorProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      InstructorProfile,
      () => InstructorProfile.fromJsonFactory,
    );

    return _apiV1AuthInstructorProfilePut(body: body);
  }

  ///
  @PUT(path: '/api/v1/auth/instructor-profile/', optionalBody: true)
  Future<chopper.Response<InstructorProfile>> _apiV1AuthInstructorProfilePut({
    @Body() required InstructorProfileRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<InstructorProfile>> apiV1AuthInstructorProfilePatch({
    required PatchedInstructorProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      InstructorProfile,
      () => InstructorProfile.fromJsonFactory,
    );

    return _apiV1AuthInstructorProfilePatch(body: body);
  }

  ///
  @PATCH(path: '/api/v1/auth/instructor-profile/', optionalBody: true)
  Future<chopper.Response<InstructorProfile>> _apiV1AuthInstructorProfilePatch({
    @Body() required PatchedInstructorProfileRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthInstructorStatsGet() {
    return _apiV1AuthInstructorStatsGet();
  }

  ///
  @GET(path: '/api/v1/auth/instructor-stats/')
  Future<chopper.Response> _apiV1AuthInstructorStatsGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<Object>> apiV1AuthLocationsGet() {
    return _apiV1AuthLocationsGet();
  }

  ///
  @GET(path: '/api/v1/auth/locations/')
  Future<chopper.Response<Object>> _apiV1AuthLocationsGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthLoginPost({
    required CustomTokenObtainPairRequest? body,
  }) {
    return _apiV1AuthLoginPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/login/', optionalBody: true)
  Future<chopper.Response> _apiV1AuthLoginPost({
    @Body() required CustomTokenObtainPairRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthLogoutPost() {
    return _apiV1AuthLogoutPost();
  }

  ///
  @POST(path: '/api/v1/auth/logout/', optionalBody: true)
  Future<chopper.Response> _apiV1AuthLogoutPost({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<UserProfile>> apiV1AuthMeGet() {
    generatedMapping.putIfAbsent(
      UserProfile,
      () => UserProfile.fromJsonFactory,
    );

    return _apiV1AuthMeGet();
  }

  ///
  @GET(path: '/api/v1/auth/me/')
  Future<chopper.Response<UserProfile>> _apiV1AuthMeGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<UserProfile>> apiV1AuthMePut({
    required UserProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      UserProfile,
      () => UserProfile.fromJsonFactory,
    );

    return _apiV1AuthMePut(body: body);
  }

  ///
  @PUT(path: '/api/v1/auth/me/', optionalBody: true)
  Future<chopper.Response<UserProfile>> _apiV1AuthMePut({
    @Body() required UserProfileRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<UserProfile>> apiV1AuthMePatch({
    required PatchedUserProfileRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      UserProfile,
      () => UserProfile.fromJsonFactory,
    );

    return _apiV1AuthMePatch(body: body);
  }

  ///
  @PATCH(path: '/api/v1/auth/me/', optionalBody: true)
  Future<chopper.Response<UserProfile>> _apiV1AuthMePatch({
    @Body() required PatchedUserProfileRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<TokenRefresh>> apiV1AuthRefreshPost({
    required TokenRefreshRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      TokenRefresh,
      () => TokenRefresh.fromJsonFactory,
    );

    return _apiV1AuthRefreshPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/refresh/', optionalBody: true)
  Future<chopper.Response<TokenRefresh>> _apiV1AuthRefreshPost({
    @Body() required TokenRefreshRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<Register>> apiV1AuthRegisterPost({
    required RegisterRequest? body,
  }) {
    generatedMapping.putIfAbsent(Register, () => Register.fromJsonFactory);

    return _apiV1AuthRegisterPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/register/', optionalBody: true)
  Future<chopper.Response<Register>> _apiV1AuthRegisterPost({
    @Body() required RegisterRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ResendOTP>> apiV1AuthResendOtpPost({
    required ResendOTPRequest? body,
  }) {
    generatedMapping.putIfAbsent(ResendOTP, () => ResendOTP.fromJsonFactory);

    return _apiV1AuthResendOtpPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/resend-otp/', optionalBody: true)
  Future<chopper.Response<ResendOTP>> _apiV1AuthResendOtpPost({
    @Body() required ResendOTPRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<ResetPassword>> apiV1AuthResetPasswordPost({
    required ResetPasswordRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      ResetPassword,
      () => ResetPassword.fromJsonFactory,
    );

    return _apiV1AuthResetPasswordPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/reset-password/', optionalBody: true)
  Future<chopper.Response<ResetPassword>> _apiV1AuthResetPasswordPost({
    @Body() required ResetPasswordRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1AuthSystemSettingsGet() {
    return _apiV1AuthSystemSettingsGet();
  }

  ///
  @GET(path: '/api/v1/auth/system-settings/')
  Future<chopper.Response> _apiV1AuthSystemSettingsGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<VerifyResetOTP>> apiV1AuthVerifyResetOtpPost({
    required VerifyResetOTPRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      VerifyResetOTP,
      () => VerifyResetOTP.fromJsonFactory,
    );

    return _apiV1AuthVerifyResetOtpPost(body: body);
  }

  ///
  @POST(path: '/api/v1/auth/verify-reset-otp/', optionalBody: true)
  Future<chopper.Response<VerifyResetOTP>> _apiV1AuthVerifyResetOtpPost({
    @Body() required VerifyResetOTPRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1BunnyWebhookPost() {
    return _apiV1BunnyWebhookPost();
  }

  ///
  @POST(path: '/api/v1/bunny-webhook/', optionalBody: true)
  Future<chopper.Response> _apiV1BunnyWebhookPost({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<Cart>> apiV1CartGet() {
    generatedMapping.putIfAbsent(Cart, () => Cart.fromJsonFactory);

    return _apiV1CartGet();
  }

  ///
  @GET(path: '/api/v1/cart/')
  Future<chopper.Response<Cart>> _apiV1CartGet({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1CartAddPost() {
    return _apiV1CartAddPost();
  }

  ///
  @POST(path: '/api/v1/cart/add/', optionalBody: true)
  Future<chopper.Response> _apiV1CartAddPost({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1CartClearDelete() {
    return _apiV1CartClearDelete();
  }

  ///
  @DELETE(path: '/api/v1/cart/clear/')
  Future<chopper.Response> _apiV1CartClearDelete({
    @chopper.Tag()
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
  });

  ///
  ///@param course_id
  Future<chopper.Response> apiV1CartRemoveCourseIdDelete({
    required String? courseId,
  }) {
    return _apiV1CartRemoveCourseIdDelete(courseId: courseId);
  }

  ///
  ///@param course_id
  @DELETE(path: '/api/v1/cart/remove/{course_id}/')
  Future<chopper.Response> _apiV1CartRemoveCourseIdDelete({
    @Path('course_id') required String? courseId,
    @chopper.Tag()
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
  });

  ///List categories (language-aware)
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCategoryList>> apiV1CategoriesGet({
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCategoryList,
      () => PaginatedCategoryList.fromJsonFactory,
    );

    return _apiV1CategoriesGet(page: page, search: search);
  }

  ///List categories (language-aware)
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/categories/')
  Future<chopper.Response<PaginatedCategoryList>> _apiV1CategoriesGet({
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///Get a single category by slug
  ///@param slug
  Future<chopper.Response<Category>> apiV1CategoriesSlugGet({
    required String? slug,
  }) {
    generatedMapping.putIfAbsent(Category, () => Category.fromJsonFactory);

    return _apiV1CategoriesSlugGet(slug: slug);
  }

  ///Get a single category by slug
  ///@param slug
  @GET(path: '/api/v1/categories/{slug}/')
  Future<chopper.Response<Category>> _apiV1CategoriesSlugGet({
    @Path('slug') required String? slug,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1CheckoutPost() {
    return _apiV1CheckoutPost();
  }

  ///
  @POST(path: '/api/v1/checkout/', optionalBody: true)
  Future<chopper.Response> _apiV1CheckoutPost({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1ClientEventsPost() {
    return _apiV1ClientEventsPost();
  }

  ///
  @POST(path: '/api/v1/client-events/', optionalBody: true)
  Future<chopper.Response> _apiV1ClientEventsPost({
    @chopper.Tag()
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
  });

  ///
  ///@param slug
  Future<chopper.Response<CourseDetail>> apiV1CoursesSlugGet({
    required String? slug,
  }) {
    generatedMapping.putIfAbsent(
      CourseDetail,
      () => CourseDetail.fromJsonFactory,
    );

    return _apiV1CoursesSlugGet(slug: slug);
  }

  ///
  ///@param slug
  @GET(path: '/api/v1/courses/{slug}/')
  Future<chopper.Response<CourseDetail>> _apiV1CoursesSlugGet({
    @Path('slug') required String? slug,
    @chopper.Tag()
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
  });

  ///
  ///@param category
  ///@param category_slug
  ///@param level
  ///@param max_price
  ///@param min_price
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCourseListList>> apiV1CoursesCatalogGet({
    String? category,
    String? categorySlug,
    String? level,
    num? maxPrice,
    num? minPrice,
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCourseListList,
      () => PaginatedCourseListList.fromJsonFactory,
    );

    return _apiV1CoursesCatalogGet(
      category: category,
      categorySlug: categorySlug,
      level: level,
      maxPrice: maxPrice,
      minPrice: minPrice,
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param category
  ///@param category_slug
  ///@param level
  ///@param max_price
  ///@param min_price
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/courses/catalog/')
  Future<chopper.Response<PaginatedCourseListList>> _apiV1CoursesCatalogGet({
    @Query('category') String? category,
    @Query('category_slug') String? categorySlug,
    @Query('level') String? level,
    @Query('max_price') num? maxPrice,
    @Query('min_price') num? minPrice,
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///List approved E-Books
  ///@param category
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedEBookList>> apiV1EbooksGet({
    String? category,
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedEBookList,
      () => PaginatedEBookList.fromJsonFactory,
    );

    return _apiV1EbooksGet(
      category: category,
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///List approved E-Books
  ///@param category
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/ebooks/')
  Future<chopper.Response<PaginatedEBookList>> _apiV1EbooksGet({
    @Query('category') String? category,
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///Get details of an approved E-Book
  ///@param slug
  Future<chopper.Response<EBook>> apiV1EbooksSlugGet({required String? slug}) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1EbooksSlugGet(slug: slug);
  }

  ///Get details of an approved E-Book
  ///@param slug
  @GET(path: '/api/v1/ebooks/{slug}/')
  Future<chopper.Response<EBook>> _apiV1EbooksSlugGet({
    @Path('slug') required String? slug,
    @chopper.Tag()
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
  });

  ///Retrieve read file url for E-Book
  ///@param slug
  Future<chopper.Response<EBook>> apiV1EbooksSlugReadGet({
    required String? slug,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1EbooksSlugReadGet(slug: slug);
  }

  ///Retrieve read file url for E-Book
  ///@param slug
  @GET(path: '/api/v1/ebooks/{slug}/read/')
  Future<chopper.Response<EBook>> _apiV1EbooksSlugReadGet({
    @Path('slug') required String? slug,
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedEnrollmentList>> apiV1EnrollmentsGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedEnrollmentList,
      () => PaginatedEnrollmentList.fromJsonFactory,
    );

    return _apiV1EnrollmentsGet(ordering: ordering, page: page, search: search);
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/enrollments/')
  Future<chopper.Response<PaginatedEnrollmentList>> _apiV1EnrollmentsGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param course_id
  Future<chopper.Response> apiV1EnrollmentsCheckCourseIdGet({
    required String? courseId,
  }) {
    return _apiV1EnrollmentsCheckCourseIdGet(courseId: courseId);
  }

  ///
  ///@param course_id
  @GET(path: '/api/v1/enrollments/check/{course_id}/')
  Future<chopper.Response> _apiV1EnrollmentsCheckCourseIdGet({
    @Path('course_id') required String? courseId,
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCourseListList>> apiV1InstructorCoursesGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCourseListList,
      () => PaginatedCourseListList.fromJsonFactory,
    );

    return _apiV1InstructorCoursesGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/instructor/courses/')
  Future<chopper.Response<PaginatedCourseListList>> _apiV1InstructorCoursesGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response<CourseCreate>> apiV1InstructorCoursesPost({
    required CourseCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseCreate,
      () => CourseCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesPost(body: body);
  }

  ///
  @POST(path: '/api/v1/instructor/courses/', optionalBody: true)
  Future<chopper.Response<CourseCreate>> _apiV1InstructorCoursesPost({
    @Body() required CourseCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCertificateTemplateList>>
  apiV1InstructorCoursesCoursePkCertificateGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCertificateTemplateList,
      () => PaginatedCertificateTemplateList.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkCertificateGet(
      coursePk: coursePk,
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/instructor/courses/{course_pk}/certificate/')
  Future<chopper.Response<PaginatedCertificateTemplateList>>
  _apiV1InstructorCoursesCoursePkCertificateGet({
    @Path('course_pk') required String? coursePk,
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  Future<chopper.Response<CertificateTemplate>>
  apiV1InstructorCoursesCoursePkCertificatePost({
    required String? coursePk,
    required CertificateTemplateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CertificateTemplate,
      () => CertificateTemplate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkCertificatePost(
      coursePk: coursePk,
      body: body,
    );
  }

  ///
  ///@param course_pk
  @POST(
    path: '/api/v1/instructor/courses/{course_pk}/certificate/',
    optionalBody: true,
  )
  Future<chopper.Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificatePost({
    @Path('course_pk') required String? coursePk,
    @Body() required CertificateTemplateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CertificateTemplate>>
  apiV1InstructorCoursesCoursePkCertificateIdGet({
    required String? coursePk,
    required String? id,
  }) {
    generatedMapping.putIfAbsent(
      CertificateTemplate,
      () => CertificateTemplate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkCertificateIdGet(
      coursePk: coursePk,
      id: id,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @GET(path: '/api/v1/instructor/courses/{course_pk}/certificate/{id}/')
  Future<chopper.Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdGet({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CertificateTemplate>>
  apiV1InstructorCoursesCoursePkCertificateIdPut({
    required String? coursePk,
    required String? id,
    required CertificateTemplateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CertificateTemplate,
      () => CertificateTemplate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkCertificateIdPut(
      coursePk: coursePk,
      id: id,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @PUT(
    path: '/api/v1/instructor/courses/{course_pk}/certificate/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdPut({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Body() required CertificateTemplateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CertificateTemplate>>
  apiV1InstructorCoursesCoursePkCertificateIdPatch({
    required String? coursePk,
    required String? id,
    required PatchedCertificateTemplateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CertificateTemplate,
      () => CertificateTemplate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkCertificateIdPatch(
      coursePk: coursePk,
      id: id,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @PATCH(
    path: '/api/v1/instructor/courses/{course_pk}/certificate/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<CertificateTemplate>>
  _apiV1InstructorCoursesCoursePkCertificateIdPatch({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Body() required PatchedCertificateTemplateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response> apiV1InstructorCoursesCoursePkCertificateIdDelete({
    required String? coursePk,
    required String? id,
  }) {
    return _apiV1InstructorCoursesCoursePkCertificateIdDelete(
      coursePk: coursePk,
      id: id,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @DELETE(path: '/api/v1/instructor/courses/{course_pk}/certificate/{id}/')
  Future<chopper.Response> _apiV1InstructorCoursesCoursePkCertificateIdDelete({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedCourseSectionList>>
  apiV1InstructorCoursesCoursePkSectionsGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedCourseSectionList,
      () => PaginatedCourseSectionList.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsGet(
      coursePk: coursePk,
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/instructor/courses/{course_pk}/sections/')
  Future<chopper.Response<PaginatedCourseSectionList>>
  _apiV1InstructorCoursesCoursePkSectionsGet({
    @Path('course_pk') required String? coursePk,
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  Future<chopper.Response<CourseSectionCreate>>
  apiV1InstructorCoursesCoursePkSectionsPost({
    required String? coursePk,
    required CourseSectionCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseSectionCreate,
      () => CourseSectionCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsPost(
      coursePk: coursePk,
      body: body,
    );
  }

  ///
  ///@param course_pk
  @POST(
    path: '/api/v1/instructor/courses/{course_pk}/sections/',
    optionalBody: true,
  )
  Future<chopper.Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsPost({
    @Path('course_pk') required String? coursePk,
    @Body() required CourseSectionCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CourseSection>>
  apiV1InstructorCoursesCoursePkSectionsIdGet({
    required String? coursePk,
    required String? id,
  }) {
    generatedMapping.putIfAbsent(
      CourseSection,
      () => CourseSection.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsIdGet(
      coursePk: coursePk,
      id: id,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @GET(path: '/api/v1/instructor/courses/{course_pk}/sections/{id}/')
  Future<chopper.Response<CourseSection>>
  _apiV1InstructorCoursesCoursePkSectionsIdGet({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CourseSectionCreate>>
  apiV1InstructorCoursesCoursePkSectionsIdPut({
    required String? coursePk,
    required String? id,
    required CourseSectionCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseSectionCreate,
      () => CourseSectionCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsIdPut(
      coursePk: coursePk,
      id: id,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @PUT(
    path: '/api/v1/instructor/courses/{course_pk}/sections/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsIdPut({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Body() required CourseSectionCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response<CourseSectionCreate>>
  apiV1InstructorCoursesCoursePkSectionsIdPatch({
    required String? coursePk,
    required String? id,
    required PatchedCourseSectionCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseSectionCreate,
      () => CourseSectionCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsIdPatch(
      coursePk: coursePk,
      id: id,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @PATCH(
    path: '/api/v1/instructor/courses/{course_pk}/sections/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<CourseSectionCreate>>
  _apiV1InstructorCoursesCoursePkSectionsIdPatch({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Body() required PatchedCourseSectionCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  Future<chopper.Response> apiV1InstructorCoursesCoursePkSectionsIdDelete({
    required String? coursePk,
    required String? id,
  }) {
    return _apiV1InstructorCoursesCoursePkSectionsIdDelete(
      coursePk: coursePk,
      id: id,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  @DELETE(path: '/api/v1/instructor/courses/{course_pk}/sections/{id}/')
  Future<chopper.Response> _apiV1InstructorCoursesCoursePkSectionsIdDelete({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  ///@param section_pk
  Future<chopper.Response<PaginatedLectureList>>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesGet({
    required String? coursePk,
    String? ordering,
    int? page,
    String? search,
    required String? sectionPk,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedLectureList,
      () => PaginatedLectureList.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesGet(
      coursePk: coursePk,
      ordering: ordering,
      page: page,
      search: search,
      sectionPk: sectionPk,
    );
  }

  ///
  ///@param course_pk
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  ///@param section_pk
  @GET(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/',
  )
  Future<chopper.Response<PaginatedLectureList>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesGet({
    @Path('course_pk') required String? coursePk,
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @Path('section_pk') required String? sectionPk,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param section_pk
  Future<chopper.Response<LectureCreate>>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesPost({
    required String? coursePk,
    required String? sectionPk,
    required LectureCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      LectureCreate,
      () => LectureCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesPost(
      coursePk: coursePk,
      sectionPk: sectionPk,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param section_pk
  @POST(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/',
    optionalBody: true,
  )
  Future<chopper.Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesPost({
    @Path('course_pk') required String? coursePk,
    @Path('section_pk') required String? sectionPk,
    @Body() required LectureCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  Future<chopper.Response<Lecture>>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdGet({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
  }) {
    generatedMapping.putIfAbsent(Lecture, () => Lecture.fromJsonFactory);

    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdGet(
      coursePk: coursePk,
      id: id,
      sectionPk: sectionPk,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  @GET(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/{id}/',
  )
  Future<chopper.Response<Lecture>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdGet({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Path('section_pk') required String? sectionPk,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  Future<chopper.Response<LectureCreate>>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPut({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    required LectureCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      LectureCreate,
      () => LectureCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPut(
      coursePk: coursePk,
      id: id,
      sectionPk: sectionPk,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  @PUT(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPut({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Path('section_pk') required String? sectionPk,
    @Body() required LectureCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  Future<chopper.Response<LectureCreate>>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPatch({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
    required PatchedLectureCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      LectureCreate,
      () => LectureCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPatch(
      coursePk: coursePk,
      id: id,
      sectionPk: sectionPk,
      body: body,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  @PATCH(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/{id}/',
    optionalBody: true,
  )
  Future<chopper.Response<LectureCreate>>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdPatch({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Path('section_pk') required String? sectionPk,
    @Body() required PatchedLectureCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  Future<chopper.Response>
  apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdDelete({
    required String? coursePk,
    required String? id,
    required String? sectionPk,
  }) {
    return _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdDelete(
      coursePk: coursePk,
      id: id,
      sectionPk: sectionPk,
    );
  }

  ///
  ///@param course_pk
  ///@param id
  ///@param section_pk
  @DELETE(
    path:
        '/api/v1/instructor/courses/{course_pk}/sections/{section_pk}/lectures/{id}/',
  )
  Future<chopper.Response>
  _apiV1InstructorCoursesCoursePkSectionsSectionPkLecturesIdDelete({
    @Path('course_pk') required String? coursePk,
    @Path('id') required String? id,
    @Path('section_pk') required String? sectionPk,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<CourseDetail>> apiV1InstructorCoursesIdGet({
    required String? id,
  }) {
    generatedMapping.putIfAbsent(
      CourseDetail,
      () => CourseDetail.fromJsonFactory,
    );

    return _apiV1InstructorCoursesIdGet(id: id);
  }

  ///
  ///@param id
  @GET(path: '/api/v1/instructor/courses/{id}/')
  Future<chopper.Response<CourseDetail>> _apiV1InstructorCoursesIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<CourseCreate>> apiV1InstructorCoursesIdPut({
    required String? id,
    required CourseCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseCreate,
      () => CourseCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesIdPut(id: id, body: body);
  }

  ///
  ///@param id
  @PUT(path: '/api/v1/instructor/courses/{id}/', optionalBody: true)
  Future<chopper.Response<CourseCreate>> _apiV1InstructorCoursesIdPut({
    @Path('id') required String? id,
    @Body() required CourseCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<CourseCreate>> apiV1InstructorCoursesIdPatch({
    required String? id,
    required PatchedCourseCreateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      CourseCreate,
      () => CourseCreate.fromJsonFactory,
    );

    return _apiV1InstructorCoursesIdPatch(id: id, body: body);
  }

  ///
  ///@param id
  @PATCH(path: '/api/v1/instructor/courses/{id}/', optionalBody: true)
  Future<chopper.Response<CourseCreate>> _apiV1InstructorCoursesIdPatch({
    @Path('id') required String? id,
    @Body() required PatchedCourseCreateRequest? body,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response> apiV1InstructorCoursesIdDelete({
    required String? id,
  }) {
    return _apiV1InstructorCoursesIdDelete(id: id);
  }

  ///
  ///@param id
  @DELETE(path: '/api/v1/instructor/courses/{id}/')
  Future<chopper.Response> _apiV1InstructorCoursesIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<CourseList>>
  apiV1InstructorCoursesIdModerationStatusGet({required String? id}) {
    generatedMapping.putIfAbsent(CourseList, () => CourseList.fromJsonFactory);

    return _apiV1InstructorCoursesIdModerationStatusGet(id: id);
  }

  ///
  ///@param id
  @GET(path: '/api/v1/instructor/courses/{id}/moderation-status/')
  Future<chopper.Response<CourseList>>
  _apiV1InstructorCoursesIdModerationStatusGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///
  ///@param id
  Future<chopper.Response<CourseList>> apiV1InstructorCoursesIdPublishPost({
    required String? id,
    required CourseListRequest? body,
  }) {
    generatedMapping.putIfAbsent(CourseList, () => CourseList.fromJsonFactory);

    return _apiV1InstructorCoursesIdPublishPost(id: id, body: body);
  }

  ///
  ///@param id
  @POST(path: '/api/v1/instructor/courses/{id}/publish/', optionalBody: true)
  Future<chopper.Response<CourseList>> _apiV1InstructorCoursesIdPublishPost({
    @Path('id') required String? id,
    @Body() required CourseListRequest? body,
    @chopper.Tag()
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
  });

  ///List instructor's own E-Books
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedEBookList>> apiV1InstructorEbooksGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedEBookList,
      () => PaginatedEBookList.fromJsonFactory,
    );

    return _apiV1InstructorEbooksGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///List instructor's own E-Books
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/instructor/ebooks/')
  Future<chopper.Response<PaginatedEBookList>> _apiV1InstructorEbooksGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///Create a new E-Book draft
  Future<chopper.Response<EBookCreateUpdate>> apiV1InstructorEbooksPost({
    required EBookCreateUpdateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      EBookCreateUpdate,
      () => EBookCreateUpdate.fromJsonFactory,
    );

    return _apiV1InstructorEbooksPost(body: body);
  }

  ///Create a new E-Book draft
  @POST(path: '/api/v1/instructor/ebooks/', optionalBody: true)
  Future<chopper.Response<EBookCreateUpdate>> _apiV1InstructorEbooksPost({
    @Body() required EBookCreateUpdateRequest? body,
    @chopper.Tag()
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
  });

  ///Get detail of instructor's E-Book
  ///@param id
  Future<chopper.Response<EBook>> apiV1InstructorEbooksIdGet({
    required String? id,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1InstructorEbooksIdGet(id: id);
  }

  ///Get detail of instructor's E-Book
  ///@param id
  @GET(path: '/api/v1/instructor/ebooks/{id}/')
  Future<chopper.Response<EBook>> _apiV1InstructorEbooksIdGet({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///Update an E-Book
  ///@param id
  Future<chopper.Response<EBookCreateUpdate>> apiV1InstructorEbooksIdPut({
    required String? id,
    required EBookCreateUpdateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      EBookCreateUpdate,
      () => EBookCreateUpdate.fromJsonFactory,
    );

    return _apiV1InstructorEbooksIdPut(id: id, body: body);
  }

  ///Update an E-Book
  ///@param id
  @PUT(path: '/api/v1/instructor/ebooks/{id}/', optionalBody: true)
  Future<chopper.Response<EBookCreateUpdate>> _apiV1InstructorEbooksIdPut({
    @Path('id') required String? id,
    @Body() required EBookCreateUpdateRequest? body,
    @chopper.Tag()
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
  });

  ///Partially update an E-Book
  ///@param id
  Future<chopper.Response<EBookCreateUpdate>> apiV1InstructorEbooksIdPatch({
    required String? id,
    required PatchedEBookCreateUpdateRequest? body,
  }) {
    generatedMapping.putIfAbsent(
      EBookCreateUpdate,
      () => EBookCreateUpdate.fromJsonFactory,
    );

    return _apiV1InstructorEbooksIdPatch(id: id, body: body);
  }

  ///Partially update an E-Book
  ///@param id
  @PATCH(path: '/api/v1/instructor/ebooks/{id}/', optionalBody: true)
  Future<chopper.Response<EBookCreateUpdate>> _apiV1InstructorEbooksIdPatch({
    @Path('id') required String? id,
    @Body() required PatchedEBookCreateUpdateRequest? body,
    @chopper.Tag()
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
  });

  ///Delete an E-Book draft
  ///@param id
  Future<chopper.Response> apiV1InstructorEbooksIdDelete({
    required String? id,
  }) {
    return _apiV1InstructorEbooksIdDelete(id: id);
  }

  ///Delete an E-Book draft
  ///@param id
  @DELETE(path: '/api/v1/instructor/ebooks/{id}/')
  Future<chopper.Response> _apiV1InstructorEbooksIdDelete({
    @Path('id') required String? id,
    @chopper.Tag()
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
  });

  ///Submit E-Book for review
  ///@param id
  Future<chopper.Response<EBook>> apiV1InstructorEbooksIdSubmitPost({
    required String? id,
    required EBookRequest? body,
  }) {
    generatedMapping.putIfAbsent(EBook, () => EBook.fromJsonFactory);

    return _apiV1InstructorEbooksIdSubmitPost(id: id, body: body);
  }

  ///Submit E-Book for review
  ///@param id
  @POST(path: '/api/v1/instructor/ebooks/{id}/submit/', optionalBody: true)
  Future<chopper.Response<EBook>> _apiV1InstructorEbooksIdSubmitPost({
    @Path('id') required String? id,
    @Body() required EBookRequest? body,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1InstructorQaGet() {
    return _apiV1InstructorQaGet();
  }

  ///
  @GET(path: '/api/v1/instructor/qa/')
  Future<chopper.Response> _apiV1InstructorQaGet({
    @chopper.Tag()
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
  });

  ///
  ///@param question_id
  Future<chopper.Response> apiV1InstructorQaQuestionIdAnswerPost({
    required String? questionId,
  }) {
    return _apiV1InstructorQaQuestionIdAnswerPost(questionId: questionId);
  }

  ///
  ///@param question_id
  @POST(path: '/api/v1/instructor/qa/{question_id}/answer/', optionalBody: true)
  Future<chopper.Response> _apiV1InstructorQaQuestionIdAnswerPost({
    @Path('question_id') required String? questionId,
    @chopper.Tag()
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
  });

  ///Get instructor's sales transactions ledger
  Future<chopper.Response> apiV1InstructorTransactionsGet() {
    return _apiV1InstructorTransactionsGet();
  }

  ///Get instructor's sales transactions ledger
  @GET(path: '/api/v1/instructor/transactions/')
  Future<chopper.Response> _apiV1InstructorTransactionsGet({
    @chopper.Tag()
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
  });

  ///
  ///@param lecture_id
  Future<chopper.Response> apiV1LecturesLectureIdStreamGet({
    required String? lectureId,
  }) {
    return _apiV1LecturesLectureIdStreamGet(lectureId: lectureId);
  }

  ///
  ///@param lecture_id
  @GET(path: '/api/v1/lectures/{lecture_id}/stream/')
  Future<chopper.Response> _apiV1LecturesLectureIdStreamGet({
    @Path('lecture_id') required String? lectureId,
    @chopper.Tag()
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
  });

  ///
  ///@param lecture_id
  Future<chopper.Response> apiV1LecturesLectureIdUploadResourcePost({
    required String? lectureId,
  }) {
    return _apiV1LecturesLectureIdUploadResourcePost(lectureId: lectureId);
  }

  ///
  ///@param lecture_id
  @POST(
    path: '/api/v1/lectures/{lecture_id}/upload-resource/',
    optionalBody: true,
  )
  Future<chopper.Response> _apiV1LecturesLectureIdUploadResourcePost({
    @Path('lecture_id') required String? lectureId,
    @chopper.Tag()
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
  });

  ///
  ///@param lecture_id
  Future<chopper.Response> apiV1LecturesLectureIdUploadVideoPost({
    required String? lectureId,
  }) {
    return _apiV1LecturesLectureIdUploadVideoPost(lectureId: lectureId);
  }

  ///
  ///@param lecture_id
  @POST(path: '/api/v1/lectures/{lecture_id}/upload-video/', optionalBody: true)
  Future<chopper.Response> _apiV1LecturesLectureIdUploadVideoPost({
    @Path('lecture_id') required String? lectureId,
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedModerationLogList>> apiV1ModerationLogsGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedModerationLogList,
      () => PaginatedModerationLogList.fromJsonFactory,
    );

    return _apiV1ModerationLogsGet(
      ordering: ordering,
      page: page,
      search: search,
    );
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/moderation/logs/')
  Future<chopper.Response<PaginatedModerationLogList>> _apiV1ModerationLogsGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param course_id
  Future<chopper.Response> apiV1ModerationStatusCourseIdGet({
    required String? courseId,
  }) {
    return _apiV1ModerationStatusCourseIdGet(courseId: courseId);
  }

  ///
  ///@param course_id
  @GET(path: '/api/v1/moderation/status/{course_id}/')
  Future<chopper.Response> _apiV1ModerationStatusCourseIdGet({
    @Path('course_id') required String? courseId,
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  Future<chopper.Response<List<Notification>>> apiV1NotificationsGet({
    String? ordering,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      Notification,
      () => Notification.fromJsonFactory,
    );

    return _apiV1NotificationsGet(ordering: ordering, search: search);
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  @GET(path: '/api/v1/notifications/')
  Future<chopper.Response<List<Notification>>> _apiV1NotificationsGet({
    @Query('ordering') String? ordering,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param notification_id
  Future<chopper.Response> apiV1NotificationsNotificationIdReadPatch({
    required String? notificationId,
  }) {
    return _apiV1NotificationsNotificationIdReadPatch(
      notificationId: notificationId,
    );
  }

  ///
  ///@param notification_id
  @PATCH(
    path: '/api/v1/notifications/{notification_id}/read/',
    optionalBody: true,
  )
  Future<chopper.Response> _apiV1NotificationsNotificationIdReadPatch({
    @Path('notification_id') required String? notificationId,
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  Future<chopper.Response<List<AdminNotification>>> apiV1NotificationsAdminGet({
    String? ordering,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      AdminNotification,
      () => AdminNotification.fromJsonFactory,
    );

    return _apiV1NotificationsAdminGet(ordering: ordering, search: search);
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  @GET(path: '/api/v1/notifications/admin/')
  Future<chopper.Response<List<AdminNotification>>>
  _apiV1NotificationsAdminGet({
    @Query('ordering') String? ordering,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param notification_id
  Future<chopper.Response> apiV1NotificationsAdminNotificationIdReadPatch({
    required String? notificationId,
  }) {
    return _apiV1NotificationsAdminNotificationIdReadPatch(
      notificationId: notificationId,
    );
  }

  ///
  ///@param notification_id
  @PATCH(
    path: '/api/v1/notifications/admin/{notification_id}/read/',
    optionalBody: true,
  )
  Future<chopper.Response> _apiV1NotificationsAdminNotificationIdReadPatch({
    @Path('notification_id') required String? notificationId,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1NotificationsAdminReadAllPatch() {
    return _apiV1NotificationsAdminReadAllPatch();
  }

  ///
  @PATCH(path: '/api/v1/notifications/admin/read-all/', optionalBody: true)
  Future<chopper.Response> _apiV1NotificationsAdminReadAllPatch({
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1NotificationsReadAllPatch() {
    return _apiV1NotificationsReadAllPatch();
  }

  ///
  @PATCH(path: '/api/v1/notifications/read-all/', optionalBody: true)
  Future<chopper.Response> _apiV1NotificationsReadAllPatch({
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  Future<chopper.Response<List<StudentNotification>>>
  apiV1NotificationsStudentGet({String? ordering, String? search}) {
    generatedMapping.putIfAbsent(
      StudentNotification,
      () => StudentNotification.fromJsonFactory,
    );

    return _apiV1NotificationsStudentGet(ordering: ordering, search: search);
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param search A search term.
  @GET(path: '/api/v1/notifications/student/')
  Future<chopper.Response<List<StudentNotification>>>
  _apiV1NotificationsStudentGet({
    @Query('ordering') String? ordering,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param notification_id
  Future<chopper.Response> apiV1NotificationsStudentNotificationIdReadPatch({
    required String? notificationId,
  }) {
    return _apiV1NotificationsStudentNotificationIdReadPatch(
      notificationId: notificationId,
    );
  }

  ///
  ///@param notification_id
  @PATCH(
    path: '/api/v1/notifications/student/{notification_id}/read/',
    optionalBody: true,
  )
  Future<chopper.Response> _apiV1NotificationsStudentNotificationIdReadPatch({
    @Path('notification_id') required String? notificationId,
    @chopper.Tag()
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
  });

  ///
  Future<chopper.Response> apiV1NotificationsStudentReadAllPatch() {
    return _apiV1NotificationsStudentReadAllPatch();
  }

  ///
  @PATCH(path: '/api/v1/notifications/student/read-all/', optionalBody: true)
  Future<chopper.Response> _apiV1NotificationsStudentReadAllPatch({
    @chopper.Tag()
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
  });

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  Future<chopper.Response<PaginatedOrderList>> apiV1OrdersGet({
    String? ordering,
    int? page,
    String? search,
  }) {
    generatedMapping.putIfAbsent(
      PaginatedOrderList,
      () => PaginatedOrderList.fromJsonFactory,
    );

    return _apiV1OrdersGet(ordering: ordering, page: page, search: search);
  }

  ///
  ///@param ordering Which field to use when ordering the results.
  ///@param page A page number within the paginated result set.
  ///@param search A search term.
  @GET(path: '/api/v1/orders/')
  Future<chopper.Response<PaginatedOrderList>> _apiV1OrdersGet({
    @Query('ordering') String? ordering,
    @Query('page') int? page,
    @Query('search') String? search,
    @chopper.Tag()
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
  });

  ///
  ///@param lecture_id
  Future<chopper.Response> apiV1ProgressLectureIdPost({
    required String? lectureId,
  }) {
    return _apiV1ProgressLectureIdPost(lectureId: lectureId);
  }

  ///
  ///@param lecture_id
  @POST(path: '/api/v1/progress/{lecture_id}/', optionalBody: true)
  Future<chopper.Response> _apiV1ProgressLectureIdPost({
    @Path('lecture_id') required String? lectureId,
    @chopper.Tag()
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
  });

  ///
  ///@param course_slug
  Future<chopper.Response> apiV1ProgressCourseCourseSlugGet({
    required String? courseSlug,
  }) {
    return _apiV1ProgressCourseCourseSlugGet(courseSlug: courseSlug);
  }

  ///
  ///@param course_slug
  @GET(path: '/api/v1/progress/course/{course_slug}/')
  Future<chopper.Response> _apiV1ProgressCourseCourseSlugGet({
    @Path('course_slug') required String? courseSlug,
    @chopper.Tag()
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
  });

  ///
  ///@param course_slug
  Future<chopper.Response> apiV1ProgressCourseCourseSlugNotesGet({
    required String? courseSlug,
  }) {
    return _apiV1ProgressCourseCourseSlugNotesGet(courseSlug: courseSlug);
  }

  ///
  ///@param course_slug
  @GET(path: '/api/v1/progress/course/{course_slug}/notes/')
  Future<chopper.Response> _apiV1ProgressCourseCourseSlugNotesGet({
    @Path('course_slug') required String? courseSlug,
    @chopper.Tag()
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
  });

  ///
  ///@param course_slug
  Future<chopper.Response> apiV1ProgressCourseCourseSlugNotesPost({
    required String? courseSlug,
  }) {
    return _apiV1ProgressCourseCourseSlugNotesPost(courseSlug: courseSlug);
  }

  ///
  ///@param course_slug
  @POST(
    path: '/api/v1/progress/course/{course_slug}/notes/',
    optionalBody: true,
  )
  Future<chopper.Response> _apiV1ProgressCourseCourseSlugNotesPost({
    @Path('course_slug') required String? courseSlug,
    @chopper.Tag()
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
  });

  ///
  ///@param course_slug
  Future<chopper.Response> apiV1ProgressCourseCourseSlugQaGet({
    required String? courseSlug,
  }) {
    return _apiV1ProgressCourseCourseSlugQaGet(courseSlug: courseSlug);
  }

  ///
  ///@param course_slug
  @GET(path: '/api/v1/progress/course/{course_slug}/qa/')
  Future<chopper.Response> _apiV1ProgressCourseCourseSlugQaGet({
    @Path('course_slug') required String? courseSlug,
    @chopper.Tag()
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
  });

  ///
  ///@param course_slug
  Future<chopper.Response> apiV1ProgressCourseCourseSlugQaPost({
    required String? courseSlug,
  }) {
    return _apiV1ProgressCourseCourseSlugQaPost(courseSlug: courseSlug);
  }

  ///
  ///@param course_slug
  @POST(path: '/api/v1/progress/course/{course_slug}/qa/', optionalBody: true)
  Future<chopper.Response> _apiV1ProgressCourseCourseSlugQaPost({
    @Path('course_slug') required String? courseSlug,
    @chopper.Tag()
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
  });

  ///
  ///@param note_id
  Future<chopper.Response> apiV1ProgressNotesNoteIdDelete({
    required String? noteId,
  }) {
    return _apiV1ProgressNotesNoteIdDelete(noteId: noteId);
  }

  ///
  ///@param note_id
  @DELETE(path: '/api/v1/progress/notes/{note_id}/')
  Future<chopper.Response> _apiV1ProgressNotesNoteIdDelete({
    @Path('note_id') required String? noteId,
    @chopper.Tag()
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
  });

  ///
  ///@param question_id
  Future<chopper.Response> apiV1ProgressQaQuestionIdPut({
    required String? questionId,
  }) {
    return _apiV1ProgressQaQuestionIdPut(questionId: questionId);
  }

  ///
  ///@param question_id
  @PUT(path: '/api/v1/progress/qa/{question_id}/', optionalBody: true)
  Future<chopper.Response> _apiV1ProgressQaQuestionIdPut({
    @Path('question_id') required String? questionId,
    @chopper.Tag()
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
  });

  ///
  ///@param question_id
  Future<chopper.Response> apiV1ProgressQaQuestionIdDelete({
    required String? questionId,
  }) {
    return _apiV1ProgressQaQuestionIdDelete(questionId: questionId);
  }

  ///
  ///@param question_id
  @DELETE(path: '/api/v1/progress/qa/{question_id}/')
  Future<chopper.Response> _apiV1ProgressQaQuestionIdDelete({
    @Path('question_id') required String? questionId,
    @chopper.Tag()
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
  });

  ///
  ///@param quiz_id
  Future<chopper.Response> apiV1QuizQuizIdSubmitPost({
    required String? quizId,
  }) {
    return _apiV1QuizQuizIdSubmitPost(quizId: quizId);
  }

  ///
  ///@param quiz_id
  @POST(path: '/api/v1/quiz/{quiz_id}/submit/', optionalBody: true)
  Future<chopper.Response> _apiV1QuizQuizIdSubmitPost({
    @Path('quiz_id') required String? quizId,
    @chopper.Tag()
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
  });

  ///
  ///@param section_id
  Future<chopper.Response> apiV1QuizSectionSectionIdGet({
    required String? sectionId,
  }) {
    return _apiV1QuizSectionSectionIdGet(sectionId: sectionId);
  }

  ///
  ///@param section_id
  @GET(path: '/api/v1/quiz/section/{section_id}/')
  Future<chopper.Response> _apiV1QuizSectionSectionIdGet({
    @Path('section_id') required String? sectionId,
    @chopper.Tag()
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
  });
}

@JsonSerializable(explicitToJson: true)
class AdminInstructorReview {
  const AdminInstructorReview({
    required this.status,
    this.kycVerified,
    this.reviewComments,
  });

  factory AdminInstructorReview.fromJson(Map<String, dynamic> json) =>
      _$AdminInstructorReviewFromJson(json);

  static const toJsonFactory = _$AdminInstructorReviewToJson;
  Map<String, dynamic> toJson() => _$AdminInstructorReviewToJson(this);

  @JsonKey(
    name: 'status',
    toJson: statusC09EnumToJson,
    fromJson: statusC09EnumFromJson,
  )
  final enums.StatusC09Enum status;
  @JsonKey(name: 'kyc_verified')
  final bool? kycVerified;
  @JsonKey(name: 'review_comments')
  final String? reviewComments;
  static const fromJsonFactory = _$AdminInstructorReviewFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminInstructorReview &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.kycVerified, kycVerified) ||
                const DeepCollectionEquality().equals(
                  other.kycVerified,
                  kycVerified,
                )) &&
            (identical(other.reviewComments, reviewComments) ||
                const DeepCollectionEquality().equals(
                  other.reviewComments,
                  reviewComments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(kycVerified) ^
      const DeepCollectionEquality().hash(reviewComments) ^
      runtimeType.hashCode;
}

extension $AdminInstructorReviewExtension on AdminInstructorReview {
  AdminInstructorReview copyWith({
    enums.StatusC09Enum? status,
    bool? kycVerified,
    String? reviewComments,
  }) {
    return AdminInstructorReview(
      status: status ?? this.status,
      kycVerified: kycVerified ?? this.kycVerified,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }

  AdminInstructorReview copyWithWrapped({
    Wrapped<enums.StatusC09Enum>? status,
    Wrapped<bool?>? kycVerified,
    Wrapped<String?>? reviewComments,
  }) {
    return AdminInstructorReview(
      status: (status != null ? status.value : this.status),
      kycVerified: (kycVerified != null ? kycVerified.value : this.kycVerified),
      reviewComments: (reviewComments != null
          ? reviewComments.value
          : this.reviewComments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminInstructorReviewRequest {
  const AdminInstructorReviewRequest({
    required this.status,
    this.kycVerified,
    this.reviewComments,
  });

  factory AdminInstructorReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminInstructorReviewRequestFromJson(json);

  static const toJsonFactory = _$AdminInstructorReviewRequestToJson;
  Map<String, dynamic> toJson() => _$AdminInstructorReviewRequestToJson(this);

  @JsonKey(
    name: 'status',
    toJson: statusC09EnumToJson,
    fromJson: statusC09EnumFromJson,
  )
  final enums.StatusC09Enum status;
  @JsonKey(name: 'kyc_verified')
  final bool? kycVerified;
  @JsonKey(name: 'review_comments')
  final String? reviewComments;
  static const fromJsonFactory = _$AdminInstructorReviewRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminInstructorReviewRequest &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.kycVerified, kycVerified) ||
                const DeepCollectionEquality().equals(
                  other.kycVerified,
                  kycVerified,
                )) &&
            (identical(other.reviewComments, reviewComments) ||
                const DeepCollectionEquality().equals(
                  other.reviewComments,
                  reviewComments,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(kycVerified) ^
      const DeepCollectionEquality().hash(reviewComments) ^
      runtimeType.hashCode;
}

extension $AdminInstructorReviewRequestExtension
    on AdminInstructorReviewRequest {
  AdminInstructorReviewRequest copyWith({
    enums.StatusC09Enum? status,
    bool? kycVerified,
    String? reviewComments,
  }) {
    return AdminInstructorReviewRequest(
      status: status ?? this.status,
      kycVerified: kycVerified ?? this.kycVerified,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }

  AdminInstructorReviewRequest copyWithWrapped({
    Wrapped<enums.StatusC09Enum>? status,
    Wrapped<bool?>? kycVerified,
    Wrapped<String?>? reviewComments,
  }) {
    return AdminInstructorReviewRequest(
      status: (status != null ? status.value : this.status),
      kycVerified: (kycVerified != null ? kycVerified.value : this.kycVerified),
      reviewComments: (reviewComments != null
          ? reviewComments.value
          : this.reviewComments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminNotification {
  const AdminNotification({
    this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.instructorId,
    this.instructorName,
    this.instructorEmail,
    this.isRead,
    this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) =>
      _$AdminNotificationFromJson(json);

  static const toJsonFactory = _$AdminNotificationToJson;
  Map<String, dynamic> toJson() => _$AdminNotificationToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'notification_type',
    toJson: adminNotificationNotificationTypeEnumToJson,
    fromJson: adminNotificationNotificationTypeEnumFromJson,
  )
  final enums.AdminNotificationNotificationTypeEnum notificationType;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'instructor_id')
  final String? instructorId;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'instructor_email')
  final String? instructorEmail;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$AdminNotificationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminNotification &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.instructorId, instructorId) ||
                const DeepCollectionEquality().equals(
                  other.instructorId,
                  instructorId,
                )) &&
            (identical(other.instructorName, instructorName) ||
                const DeepCollectionEquality().equals(
                  other.instructorName,
                  instructorName,
                )) &&
            (identical(other.instructorEmail, instructorEmail) ||
                const DeepCollectionEquality().equals(
                  other.instructorEmail,
                  instructorEmail,
                )) &&
            (identical(other.isRead, isRead) ||
                const DeepCollectionEquality().equals(other.isRead, isRead)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(instructorId) ^
      const DeepCollectionEquality().hash(instructorName) ^
      const DeepCollectionEquality().hash(instructorEmail) ^
      const DeepCollectionEquality().hash(isRead) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AdminNotificationExtension on AdminNotification {
  AdminNotification copyWith({
    String? id,
    enums.AdminNotificationNotificationTypeEnum? notificationType,
    String? title,
    String? message,
    String? instructorId,
    String? instructorName,
    String? instructorEmail,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorEmail: instructorEmail ?? this.instructorEmail,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AdminNotification copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<enums.AdminNotificationNotificationTypeEnum>? notificationType,
    Wrapped<String>? title,
    Wrapped<String>? message,
    Wrapped<String?>? instructorId,
    Wrapped<String?>? instructorName,
    Wrapped<String?>? instructorEmail,
    Wrapped<bool?>? isRead,
    Wrapped<DateTime?>? createdAt,
  }) {
    return AdminNotification(
      id: (id != null ? id.value : this.id),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      title: (title != null ? title.value : this.title),
      message: (message != null ? message.value : this.message),
      instructorId: (instructorId != null
          ? instructorId.value
          : this.instructorId),
      instructorName: (instructorName != null
          ? instructorName.value
          : this.instructorName),
      instructorEmail: (instructorEmail != null
          ? instructorEmail.value
          : this.instructorEmail),
      isRead: (isRead != null ? isRead.value : this.isRead),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminUser {
  const AdminUser({
    this.id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.dateJoined,
    this.lastLogin,
    this.instructorProfile,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);

  static const toJsonFactory = _$AdminUserToJson;
  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'is_staff')
  final bool? isStaff;
  @JsonKey(name: 'is_superuser')
  final bool? isSuperuser;
  @JsonKey(name: 'date_joined')
  final DateTime? dateJoined;
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  @JsonKey(name: 'instructor_profile')
  final String? instructorProfile;
  static const fromJsonFactory = _$AdminUserFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminUser &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.isStaff, isStaff) ||
                const DeepCollectionEquality().equals(
                  other.isStaff,
                  isStaff,
                )) &&
            (identical(other.isSuperuser, isSuperuser) ||
                const DeepCollectionEquality().equals(
                  other.isSuperuser,
                  isSuperuser,
                )) &&
            (identical(other.dateJoined, dateJoined) ||
                const DeepCollectionEquality().equals(
                  other.dateJoined,
                  dateJoined,
                )) &&
            (identical(other.lastLogin, lastLogin) ||
                const DeepCollectionEquality().equals(
                  other.lastLogin,
                  lastLogin,
                )) &&
            (identical(other.instructorProfile, instructorProfile) ||
                const DeepCollectionEquality().equals(
                  other.instructorProfile,
                  instructorProfile,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(isStaff) ^
      const DeepCollectionEquality().hash(isSuperuser) ^
      const DeepCollectionEquality().hash(dateJoined) ^
      const DeepCollectionEquality().hash(lastLogin) ^
      const DeepCollectionEquality().hash(instructorProfile) ^
      runtimeType.hashCode;
}

extension $AdminUserExtension on AdminUser {
  AdminUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
    String? instructorProfile,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      instructorProfile: instructorProfile ?? this.instructorProfile,
    );
  }

  AdminUser copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
    Wrapped<bool?>? isActive,
    Wrapped<bool?>? isStaff,
    Wrapped<bool?>? isSuperuser,
    Wrapped<DateTime?>? dateJoined,
    Wrapped<DateTime?>? lastLogin,
    Wrapped<String?>? instructorProfile,
  }) {
    return AdminUser(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
      isActive: (isActive != null ? isActive.value : this.isActive),
      isStaff: (isStaff != null ? isStaff.value : this.isStaff),
      isSuperuser: (isSuperuser != null ? isSuperuser.value : this.isSuperuser),
      dateJoined: (dateJoined != null ? dateJoined.value : this.dateJoined),
      lastLogin: (lastLogin != null ? lastLogin.value : this.lastLogin),
      instructorProfile: (instructorProfile != null
          ? instructorProfile.value
          : this.instructorProfile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminUserRequest {
  const AdminUserRequest({
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.password,
  });

  factory AdminUserRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminUserRequestFromJson(json);

  static const toJsonFactory = _$AdminUserRequestToJson;
  Map<String, dynamic> toJson() => _$AdminUserRequestToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'is_staff')
  final bool? isStaff;
  @JsonKey(name: 'is_superuser')
  final bool? isSuperuser;
  @JsonKey(name: 'password')
  final String? password;
  static const fromJsonFactory = _$AdminUserRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminUserRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.isStaff, isStaff) ||
                const DeepCollectionEquality().equals(
                  other.isStaff,
                  isStaff,
                )) &&
            (identical(other.isSuperuser, isSuperuser) ||
                const DeepCollectionEquality().equals(
                  other.isSuperuser,
                  isSuperuser,
                )) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(isStaff) ^
      const DeepCollectionEquality().hash(isSuperuser) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $AdminUserRequestExtension on AdminUserRequest {
  AdminUserRequest copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? password,
  }) {
    return AdminUserRequest(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      password: password ?? this.password,
    );
  }

  AdminUserRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
    Wrapped<bool?>? isActive,
    Wrapped<bool?>? isStaff,
    Wrapped<bool?>? isSuperuser,
    Wrapped<String?>? password,
  }) {
    return AdminUserRequest(
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
      isActive: (isActive != null ? isActive.value : this.isActive),
      isStaff: (isStaff != null ? isStaff.value : this.isStaff),
      isSuperuser: (isSuperuser != null ? isSuperuser.value : this.isSuperuser),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Cart {
  const Cart({this.id, this.items, this.total, this.itemCount, this.updatedAt});

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  static const toJsonFactory = _$CartToJson;
  Map<String, dynamic> toJson() => _$CartToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'items', defaultValue: <CartItem>[])
  final List<CartItem>? items;
  @JsonKey(name: 'total')
  final String? total;
  @JsonKey(name: 'item_count')
  final String? itemCount;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$CartFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Cart &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.items, items) ||
                const DeepCollectionEquality().equals(other.items, items)) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)) &&
            (identical(other.itemCount, itemCount) ||
                const DeepCollectionEquality().equals(
                  other.itemCount,
                  itemCount,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(items) ^
      const DeepCollectionEquality().hash(total) ^
      const DeepCollectionEquality().hash(itemCount) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $CartExtension on Cart {
  Cart copyWith({
    String? id,
    List<CartItem>? items,
    String? total,
    String? itemCount,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      items: items ?? this.items,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Cart copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<List<CartItem>?>? items,
    Wrapped<String?>? total,
    Wrapped<String?>? itemCount,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return Cart(
      id: (id != null ? id.value : this.id),
      items: (items != null ? items.value : this.items),
      total: (total != null ? total.value : this.total),
      itemCount: (itemCount != null ? itemCount.value : this.itemCount),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CartItem {
  const CartItem({
    this.id,
    required this.course,
    this.courseDetail,
    this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  static const toJsonFactory = _$CartItemToJson;
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'course')
  final String course;
  @JsonKey(name: 'course_detail')
  final CourseList? courseDetail;
  @JsonKey(name: 'added_at')
  final DateTime? addedAt;
  static const fromJsonFactory = _$CartItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CartItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.course, course) ||
                const DeepCollectionEquality().equals(other.course, course)) &&
            (identical(other.courseDetail, courseDetail) ||
                const DeepCollectionEquality().equals(
                  other.courseDetail,
                  courseDetail,
                )) &&
            (identical(other.addedAt, addedAt) ||
                const DeepCollectionEquality().equals(other.addedAt, addedAt)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(course) ^
      const DeepCollectionEquality().hash(courseDetail) ^
      const DeepCollectionEquality().hash(addedAt) ^
      runtimeType.hashCode;
}

extension $CartItemExtension on CartItem {
  CartItem copyWith({
    String? id,
    String? course,
    CourseList? courseDetail,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      course: course ?? this.course,
      courseDetail: courseDetail ?? this.courseDetail,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  CartItem copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? course,
    Wrapped<CourseList?>? courseDetail,
    Wrapped<DateTime?>? addedAt,
  }) {
    return CartItem(
      id: (id != null ? id.value : this.id),
      course: (course != null ? course.value : this.course),
      courseDetail: (courseDetail != null
          ? courseDetail.value
          : this.courseDetail),
      addedAt: (addedAt != null ? addedAt.value : this.addedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Category {
  const Category({
    this.id,
    required this.slug,
    required this.name,
    this.description,
    this.contentType,
    this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  static const toJsonFactory = _$CategoryToJson;
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(
    name: 'content_type',
    toJson: contentTypeEnumNullableToJson,
    fromJson: contentTypeEnumNullableFromJson,
  )
  final enums.ContentTypeEnum? contentType;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$CategoryFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Category &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(
                  other.contentType,
                  contentType,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(contentType) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $CategoryExtension on Category {
  Category copyWith({
    String? id,
    String? slug,
    String? name,
    String? description,
    enums.ContentTypeEnum? contentType,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Category copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? slug,
    Wrapped<String>? name,
    Wrapped<String?>? description,
    Wrapped<enums.ContentTypeEnum?>? contentType,
    Wrapped<int?>? sortOrder,
  }) {
    return Category(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      name: (name != null ? name.value : this.name),
      description: (description != null ? description.value : this.description),
      contentType: (contentType != null ? contentType.value : this.contentType),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CategoryAdmin {
  const CategoryAdmin({
    this.id,
    required this.slug,
    this.contentType,
    this.isActive,
    this.sortOrder,
    this.nameEn,
    this.descriptionEn,
    this.nameHi,
    this.descriptionHi,
    this.nameMr,
    this.descriptionMr,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryAdmin.fromJson(Map<String, dynamic> json) =>
      _$CategoryAdminFromJson(json);

  static const toJsonFactory = _$CategoryAdminToJson;
  Map<String, dynamic> toJson() => _$CategoryAdminToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(
    name: 'content_type',
    toJson: contentTypeEnumNullableToJson,
    fromJson: contentTypeEnumNullableFromJson,
  )
  final enums.ContentTypeEnum? contentType;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'name_hi')
  final String? nameHi;
  @JsonKey(name: 'description_hi')
  final String? descriptionHi;
  @JsonKey(name: 'name_mr')
  final String? nameMr;
  @JsonKey(name: 'description_mr')
  final String? descriptionMr;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$CategoryAdminFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CategoryAdmin &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(
                  other.contentType,
                  contentType,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.nameEn, nameEn) ||
                const DeepCollectionEquality().equals(other.nameEn, nameEn)) &&
            (identical(other.descriptionEn, descriptionEn) ||
                const DeepCollectionEquality().equals(
                  other.descriptionEn,
                  descriptionEn,
                )) &&
            (identical(other.nameHi, nameHi) ||
                const DeepCollectionEquality().equals(other.nameHi, nameHi)) &&
            (identical(other.descriptionHi, descriptionHi) ||
                const DeepCollectionEquality().equals(
                  other.descriptionHi,
                  descriptionHi,
                )) &&
            (identical(other.nameMr, nameMr) ||
                const DeepCollectionEquality().equals(other.nameMr, nameMr)) &&
            (identical(other.descriptionMr, descriptionMr) ||
                const DeepCollectionEquality().equals(
                  other.descriptionMr,
                  descriptionMr,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(contentType) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(nameEn) ^
      const DeepCollectionEquality().hash(descriptionEn) ^
      const DeepCollectionEquality().hash(nameHi) ^
      const DeepCollectionEquality().hash(descriptionHi) ^
      const DeepCollectionEquality().hash(nameMr) ^
      const DeepCollectionEquality().hash(descriptionMr) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $CategoryAdminExtension on CategoryAdmin {
  CategoryAdmin copyWith({
    String? id,
    String? slug,
    enums.ContentTypeEnum? contentType,
    bool? isActive,
    int? sortOrder,
    String? nameEn,
    String? descriptionEn,
    String? nameHi,
    String? descriptionHi,
    String? nameMr,
    String? descriptionMr,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryAdmin(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      contentType: contentType ?? this.contentType,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      nameEn: nameEn ?? this.nameEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      nameHi: nameHi ?? this.nameHi,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      nameMr: nameMr ?? this.nameMr,
      descriptionMr: descriptionMr ?? this.descriptionMr,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  CategoryAdmin copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? slug,
    Wrapped<enums.ContentTypeEnum?>? contentType,
    Wrapped<bool?>? isActive,
    Wrapped<int?>? sortOrder,
    Wrapped<String?>? nameEn,
    Wrapped<String?>? descriptionEn,
    Wrapped<String?>? nameHi,
    Wrapped<String?>? descriptionHi,
    Wrapped<String?>? nameMr,
    Wrapped<String?>? descriptionMr,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return CategoryAdmin(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      contentType: (contentType != null ? contentType.value : this.contentType),
      isActive: (isActive != null ? isActive.value : this.isActive),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      nameEn: (nameEn != null ? nameEn.value : this.nameEn),
      descriptionEn: (descriptionEn != null
          ? descriptionEn.value
          : this.descriptionEn),
      nameHi: (nameHi != null ? nameHi.value : this.nameHi),
      descriptionHi: (descriptionHi != null
          ? descriptionHi.value
          : this.descriptionHi),
      nameMr: (nameMr != null ? nameMr.value : this.nameMr),
      descriptionMr: (descriptionMr != null
          ? descriptionMr.value
          : this.descriptionMr),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CategoryAdminRequest {
  const CategoryAdminRequest({
    required this.slug,
    this.contentType,
    this.isActive,
    this.sortOrder,
    this.nameEn,
    this.descriptionEn,
    this.nameHi,
    this.descriptionHi,
    this.nameMr,
    this.descriptionMr,
  });

  factory CategoryAdminRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryAdminRequestFromJson(json);

  static const toJsonFactory = _$CategoryAdminRequestToJson;
  Map<String, dynamic> toJson() => _$CategoryAdminRequestToJson(this);

  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(
    name: 'content_type',
    toJson: contentTypeEnumNullableToJson,
    fromJson: contentTypeEnumNullableFromJson,
  )
  final enums.ContentTypeEnum? contentType;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'name_hi')
  final String? nameHi;
  @JsonKey(name: 'description_hi')
  final String? descriptionHi;
  @JsonKey(name: 'name_mr')
  final String? nameMr;
  @JsonKey(name: 'description_mr')
  final String? descriptionMr;
  static const fromJsonFactory = _$CategoryAdminRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CategoryAdminRequest &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(
                  other.contentType,
                  contentType,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.nameEn, nameEn) ||
                const DeepCollectionEquality().equals(other.nameEn, nameEn)) &&
            (identical(other.descriptionEn, descriptionEn) ||
                const DeepCollectionEquality().equals(
                  other.descriptionEn,
                  descriptionEn,
                )) &&
            (identical(other.nameHi, nameHi) ||
                const DeepCollectionEquality().equals(other.nameHi, nameHi)) &&
            (identical(other.descriptionHi, descriptionHi) ||
                const DeepCollectionEquality().equals(
                  other.descriptionHi,
                  descriptionHi,
                )) &&
            (identical(other.nameMr, nameMr) ||
                const DeepCollectionEquality().equals(other.nameMr, nameMr)) &&
            (identical(other.descriptionMr, descriptionMr) ||
                const DeepCollectionEquality().equals(
                  other.descriptionMr,
                  descriptionMr,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(contentType) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(nameEn) ^
      const DeepCollectionEquality().hash(descriptionEn) ^
      const DeepCollectionEquality().hash(nameHi) ^
      const DeepCollectionEquality().hash(descriptionHi) ^
      const DeepCollectionEquality().hash(nameMr) ^
      const DeepCollectionEquality().hash(descriptionMr) ^
      runtimeType.hashCode;
}

extension $CategoryAdminRequestExtension on CategoryAdminRequest {
  CategoryAdminRequest copyWith({
    String? slug,
    enums.ContentTypeEnum? contentType,
    bool? isActive,
    int? sortOrder,
    String? nameEn,
    String? descriptionEn,
    String? nameHi,
    String? descriptionHi,
    String? nameMr,
    String? descriptionMr,
  }) {
    return CategoryAdminRequest(
      slug: slug ?? this.slug,
      contentType: contentType ?? this.contentType,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      nameEn: nameEn ?? this.nameEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      nameHi: nameHi ?? this.nameHi,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      nameMr: nameMr ?? this.nameMr,
      descriptionMr: descriptionMr ?? this.descriptionMr,
    );
  }

  CategoryAdminRequest copyWithWrapped({
    Wrapped<String>? slug,
    Wrapped<enums.ContentTypeEnum?>? contentType,
    Wrapped<bool?>? isActive,
    Wrapped<int?>? sortOrder,
    Wrapped<String?>? nameEn,
    Wrapped<String?>? descriptionEn,
    Wrapped<String?>? nameHi,
    Wrapped<String?>? descriptionHi,
    Wrapped<String?>? nameMr,
    Wrapped<String?>? descriptionMr,
  }) {
    return CategoryAdminRequest(
      slug: (slug != null ? slug.value : this.slug),
      contentType: (contentType != null ? contentType.value : this.contentType),
      isActive: (isActive != null ? isActive.value : this.isActive),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      nameEn: (nameEn != null ? nameEn.value : this.nameEn),
      descriptionEn: (descriptionEn != null
          ? descriptionEn.value
          : this.descriptionEn),
      nameHi: (nameHi != null ? nameHi.value : this.nameHi),
      descriptionHi: (descriptionHi != null
          ? descriptionHi.value
          : this.descriptionHi),
      nameMr: (nameMr != null ? nameMr.value : this.nameMr),
      descriptionMr: (descriptionMr != null
          ? descriptionMr.value
          : this.descriptionMr),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CategoryRequest {
  const CategoryRequest({
    required this.slug,
    required this.name,
    this.description,
    this.contentType,
    this.sortOrder,
  });

  factory CategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryRequestFromJson(json);

  static const toJsonFactory = _$CategoryRequestToJson;
  Map<String, dynamic> toJson() => _$CategoryRequestToJson(this);

  @JsonKey(name: 'slug')
  final String slug;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(
    name: 'content_type',
    toJson: contentTypeEnumNullableToJson,
    fromJson: contentTypeEnumNullableFromJson,
  )
  final enums.ContentTypeEnum? contentType;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$CategoryRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CategoryRequest &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(
                  other.contentType,
                  contentType,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(contentType) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $CategoryRequestExtension on CategoryRequest {
  CategoryRequest copyWith({
    String? slug,
    String? name,
    String? description,
    enums.ContentTypeEnum? contentType,
    int? sortOrder,
  }) {
    return CategoryRequest(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      contentType: contentType ?? this.contentType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  CategoryRequest copyWithWrapped({
    Wrapped<String>? slug,
    Wrapped<String>? name,
    Wrapped<String?>? description,
    Wrapped<enums.ContentTypeEnum?>? contentType,
    Wrapped<int?>? sortOrder,
  }) {
    return CategoryRequest(
      slug: (slug != null ? slug.value : this.slug),
      name: (name != null ? name.value : this.name),
      description: (description != null ? description.value : this.description),
      contentType: (contentType != null ? contentType.value : this.contentType),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CertificateTemplate {
  const CertificateTemplate({
    this.id,
    this.title,
    required this.templateImage,
    this.isActive,
    this.createdAt,
  });

  factory CertificateTemplate.fromJson(Map<String, dynamic> json) =>
      _$CertificateTemplateFromJson(json);

  static const toJsonFactory = _$CertificateTemplateToJson;
  Map<String, dynamic> toJson() => _$CertificateTemplateToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'template_image')
  final String templateImage;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$CertificateTemplateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CertificateTemplate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.templateImage, templateImage) ||
                const DeepCollectionEquality().equals(
                  other.templateImage,
                  templateImage,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(templateImage) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $CertificateTemplateExtension on CertificateTemplate {
  CertificateTemplate copyWith({
    String? id,
    String? title,
    String? templateImage,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CertificateTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      templateImage: templateImage ?? this.templateImage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  CertificateTemplate copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? title,
    Wrapped<String>? templateImage,
    Wrapped<bool?>? isActive,
    Wrapped<DateTime?>? createdAt,
  }) {
    return CertificateTemplate(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      templateImage: (templateImage != null
          ? templateImage.value
          : this.templateImage),
      isActive: (isActive != null ? isActive.value : this.isActive),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CertificateTemplateRequest {
  const CertificateTemplateRequest({
    this.title,
    required this.templateImage,
    this.isActive,
  });

  factory CertificateTemplateRequest.fromJson(Map<String, dynamic> json) =>
      _$CertificateTemplateRequestFromJson(json);

  static const toJsonFactory = _$CertificateTemplateRequestToJson;
  Map<String, dynamic> toJson() => _$CertificateTemplateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'template_image')
  final String templateImage;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  static const fromJsonFactory = _$CertificateTemplateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CertificateTemplateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.templateImage, templateImage) ||
                const DeepCollectionEquality().equals(
                  other.templateImage,
                  templateImage,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(templateImage) ^
      const DeepCollectionEquality().hash(isActive) ^
      runtimeType.hashCode;
}

extension $CertificateTemplateRequestExtension on CertificateTemplateRequest {
  CertificateTemplateRequest copyWith({
    String? title,
    String? templateImage,
    bool? isActive,
  }) {
    return CertificateTemplateRequest(
      title: title ?? this.title,
      templateImage: templateImage ?? this.templateImage,
      isActive: isActive ?? this.isActive,
    );
  }

  CertificateTemplateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String>? templateImage,
    Wrapped<bool?>? isActive,
  }) {
    return CertificateTemplateRequest(
      title: (title != null ? title.value : this.title),
      templateImage: (templateImage != null
          ? templateImage.value
          : this.templateImage),
      isActive: (isActive != null ? isActive.value : this.isActive),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChangePassword {
  const ChangePassword({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePassword.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordFromJson(json);

  static const toJsonFactory = _$ChangePasswordToJson;
  Map<String, dynamic> toJson() => _$ChangePasswordToJson(this);

  @JsonKey(name: 'old_password')
  final String oldPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  static const fromJsonFactory = _$ChangePasswordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChangePassword &&
            (identical(other.oldPassword, oldPassword) ||
                const DeepCollectionEquality().equals(
                  other.oldPassword,
                  oldPassword,
                )) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )) &&
            (identical(other.confirmPassword, confirmPassword) ||
                const DeepCollectionEquality().equals(
                  other.confirmPassword,
                  confirmPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(oldPassword) ^
      const DeepCollectionEquality().hash(newPassword) ^
      const DeepCollectionEquality().hash(confirmPassword) ^
      runtimeType.hashCode;
}

extension $ChangePasswordExtension on ChangePassword {
  ChangePassword copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ChangePassword(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  ChangePassword copyWithWrapped({
    Wrapped<String>? oldPassword,
    Wrapped<String>? newPassword,
    Wrapped<String>? confirmPassword,
  }) {
    return ChangePassword(
      oldPassword: (oldPassword != null ? oldPassword.value : this.oldPassword),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
      confirmPassword: (confirmPassword != null
          ? confirmPassword.value
          : this.confirmPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChangePasswordRequest {
  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);

  static const toJsonFactory = _$ChangePasswordRequestToJson;
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);

  @JsonKey(name: 'old_password')
  final String oldPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  static const fromJsonFactory = _$ChangePasswordRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChangePasswordRequest &&
            (identical(other.oldPassword, oldPassword) ||
                const DeepCollectionEquality().equals(
                  other.oldPassword,
                  oldPassword,
                )) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )) &&
            (identical(other.confirmPassword, confirmPassword) ||
                const DeepCollectionEquality().equals(
                  other.confirmPassword,
                  confirmPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(oldPassword) ^
      const DeepCollectionEquality().hash(newPassword) ^
      const DeepCollectionEquality().hash(confirmPassword) ^
      runtimeType.hashCode;
}

extension $ChangePasswordRequestExtension on ChangePasswordRequest {
  ChangePasswordRequest copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ChangePasswordRequest(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  ChangePasswordRequest copyWithWrapped({
    Wrapped<String>? oldPassword,
    Wrapped<String>? newPassword,
    Wrapped<String>? confirmPassword,
  }) {
    return ChangePasswordRequest(
      oldPassword: (oldPassword != null ? oldPassword.value : this.oldPassword),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
      confirmPassword: (confirmPassword != null
          ? confirmPassword.value
          : this.confirmPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseCreate {
  const CourseCreate({
    this.id,
    required this.title,
    required this.description,
    this.shortDescription,
    this.category,
    this.level,
    this.price,
    this.thumbnail,
    this.previewVideoUrl,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
  });

  factory CourseCreate.fromJson(Map<String, dynamic> json) =>
      _$CourseCreateFromJson(json);

  static const toJsonFactory = _$CourseCreateToJson;
  Map<String, dynamic> toJson() => _$CourseCreateToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'category')
  final Category? category;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'preview_video_url')
  final String? previewVideoUrl;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'what_you_learn')
  final String? whatYouLearn;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'tags')
  final String? tags;
  static const fromJsonFactory = _$CourseCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseCreate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.previewVideoUrl, previewVideoUrl) ||
                const DeepCollectionEquality().equals(
                  other.previewVideoUrl,
                  previewVideoUrl,
                )) &&
            (identical(other.language, language) ||
                const DeepCollectionEquality().equals(
                  other.language,
                  language,
                )) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                const DeepCollectionEquality().equals(
                  other.whatYouLearn,
                  whatYouLearn,
                )) &&
            (identical(other.requirements, requirements) ||
                const DeepCollectionEquality().equals(
                  other.requirements,
                  requirements,
                )) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(previewVideoUrl) ^
      const DeepCollectionEquality().hash(language) ^
      const DeepCollectionEquality().hash(whatYouLearn) ^
      const DeepCollectionEquality().hash(requirements) ^
      const DeepCollectionEquality().hash(tags) ^
      runtimeType.hashCode;
}

extension $CourseCreateExtension on CourseCreate {
  CourseCreate copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    Category? category,
    enums.LevelEnum? level,
    String? price,
    String? thumbnail,
    String? previewVideoUrl,
    String? language,
    String? whatYouLearn,
    String? requirements,
    String? tags,
  }) {
    return CourseCreate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      category: category ?? this.category,
      level: level ?? this.level,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      language: language ?? this.language,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
    );
  }

  CourseCreate copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String?>? shortDescription,
    Wrapped<Category?>? category,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? price,
    Wrapped<String?>? thumbnail,
    Wrapped<String?>? previewVideoUrl,
    Wrapped<String?>? language,
    Wrapped<String?>? whatYouLearn,
    Wrapped<String?>? requirements,
    Wrapped<String?>? tags,
  }) {
    return CourseCreate(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      category: (category != null ? category.value : this.category),
      level: (level != null ? level.value : this.level),
      price: (price != null ? price.value : this.price),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      previewVideoUrl: (previewVideoUrl != null
          ? previewVideoUrl.value
          : this.previewVideoUrl),
      language: (language != null ? language.value : this.language),
      whatYouLearn: (whatYouLearn != null
          ? whatYouLearn.value
          : this.whatYouLearn),
      requirements: (requirements != null
          ? requirements.value
          : this.requirements),
      tags: (tags != null ? tags.value : this.tags),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseCreateRequest {
  const CourseCreateRequest({
    required this.title,
    required this.description,
    this.shortDescription,
    this.categoryId,
    this.level,
    this.price,
    this.thumbnail,
    this.previewVideoUrl,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
  });

  factory CourseCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CourseCreateRequestFromJson(json);

  static const toJsonFactory = _$CourseCreateRequestToJson;
  Map<String, dynamic> toJson() => _$CourseCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'preview_video_url')
  final String? previewVideoUrl;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'what_you_learn')
  final String? whatYouLearn;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'tags')
  final String? tags;
  static const fromJsonFactory = _$CourseCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.categoryId, categoryId) ||
                const DeepCollectionEquality().equals(
                  other.categoryId,
                  categoryId,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.previewVideoUrl, previewVideoUrl) ||
                const DeepCollectionEquality().equals(
                  other.previewVideoUrl,
                  previewVideoUrl,
                )) &&
            (identical(other.language, language) ||
                const DeepCollectionEquality().equals(
                  other.language,
                  language,
                )) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                const DeepCollectionEquality().equals(
                  other.whatYouLearn,
                  whatYouLearn,
                )) &&
            (identical(other.requirements, requirements) ||
                const DeepCollectionEquality().equals(
                  other.requirements,
                  requirements,
                )) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(categoryId) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(previewVideoUrl) ^
      const DeepCollectionEquality().hash(language) ^
      const DeepCollectionEquality().hash(whatYouLearn) ^
      const DeepCollectionEquality().hash(requirements) ^
      const DeepCollectionEquality().hash(tags) ^
      runtimeType.hashCode;
}

extension $CourseCreateRequestExtension on CourseCreateRequest {
  CourseCreateRequest copyWith({
    String? title,
    String? description,
    String? shortDescription,
    String? categoryId,
    enums.LevelEnum? level,
    String? price,
    String? thumbnail,
    String? previewVideoUrl,
    String? language,
    String? whatYouLearn,
    String? requirements,
    String? tags,
  }) {
    return CourseCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      language: language ?? this.language,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
    );
  }

  CourseCreateRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? categoryId,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? price,
    Wrapped<String?>? thumbnail,
    Wrapped<String?>? previewVideoUrl,
    Wrapped<String?>? language,
    Wrapped<String?>? whatYouLearn,
    Wrapped<String?>? requirements,
    Wrapped<String?>? tags,
  }) {
    return CourseCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      categoryId: (categoryId != null ? categoryId.value : this.categoryId),
      level: (level != null ? level.value : this.level),
      price: (price != null ? price.value : this.price),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      previewVideoUrl: (previewVideoUrl != null
          ? previewVideoUrl.value
          : this.previewVideoUrl),
      language: (language != null ? language.value : this.language),
      whatYouLearn: (whatYouLearn != null
          ? whatYouLearn.value
          : this.whatYouLearn),
      requirements: (requirements != null
          ? requirements.value
          : this.requirements),
      tags: (tags != null ? tags.value : this.tags),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseDetail {
  const CourseDetail({
    this.id,
    this.slug,
    required this.title,
    required this.description,
    this.shortDescription,
    this.thumbnail,
    this.previewVideoUrl,
    this.category,
    this.level,
    this.levelDisplay,
    this.price,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
    this.instructorName,
    this.instructorAvatar,
    this.enrollmentCount,
    this.totalLectures,
    this.totalDuration,
    this.status,
    this.sections,
    this.createdAt,
    this.publishedAt,
    this.isEnrolled,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) =>
      _$CourseDetailFromJson(json);

  static const toJsonFactory = _$CourseDetailToJson;
  Map<String, dynamic> toJson() => _$CourseDetailToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'preview_video_url')
  final String? previewVideoUrl;
  @JsonKey(name: 'category')
  final Category? category;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'level_display')
  final String? levelDisplay;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'what_you_learn')
  final String? whatYouLearn;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'tags')
  final String? tags;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'instructor_avatar')
  final String? instructorAvatar;
  @JsonKey(name: 'enrollment_count')
  final String? enrollmentCount;
  @JsonKey(name: 'total_lectures')
  final String? totalLectures;
  @JsonKey(name: 'total_duration')
  final String? totalDuration;
  @JsonKey(
    name: 'status',
    toJson: status76eEnumNullableToJson,
    fromJson: status76eEnumNullableFromJson,
  )
  final enums.Status76eEnum? status;
  @JsonKey(name: 'sections', defaultValue: <CourseSection>[])
  final List<CourseSection>? sections;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'is_enrolled')
  final String? isEnrolled;
  static const fromJsonFactory = _$CourseDetailFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseDetail &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.previewVideoUrl, previewVideoUrl) ||
                const DeepCollectionEquality().equals(
                  other.previewVideoUrl,
                  previewVideoUrl,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.levelDisplay, levelDisplay) ||
                const DeepCollectionEquality().equals(
                  other.levelDisplay,
                  levelDisplay,
                )) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.language, language) ||
                const DeepCollectionEquality().equals(
                  other.language,
                  language,
                )) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                const DeepCollectionEquality().equals(
                  other.whatYouLearn,
                  whatYouLearn,
                )) &&
            (identical(other.requirements, requirements) ||
                const DeepCollectionEquality().equals(
                  other.requirements,
                  requirements,
                )) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)) &&
            (identical(other.instructorName, instructorName) ||
                const DeepCollectionEquality().equals(
                  other.instructorName,
                  instructorName,
                )) &&
            (identical(other.instructorAvatar, instructorAvatar) ||
                const DeepCollectionEquality().equals(
                  other.instructorAvatar,
                  instructorAvatar,
                )) &&
            (identical(other.enrollmentCount, enrollmentCount) ||
                const DeepCollectionEquality().equals(
                  other.enrollmentCount,
                  enrollmentCount,
                )) &&
            (identical(other.totalLectures, totalLectures) ||
                const DeepCollectionEquality().equals(
                  other.totalLectures,
                  totalLectures,
                )) &&
            (identical(other.totalDuration, totalDuration) ||
                const DeepCollectionEquality().equals(
                  other.totalDuration,
                  totalDuration,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.sections, sections) ||
                const DeepCollectionEquality().equals(
                  other.sections,
                  sections,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )) &&
            (identical(other.isEnrolled, isEnrolled) ||
                const DeepCollectionEquality().equals(
                  other.isEnrolled,
                  isEnrolled,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(previewVideoUrl) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(levelDisplay) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(language) ^
      const DeepCollectionEquality().hash(whatYouLearn) ^
      const DeepCollectionEquality().hash(requirements) ^
      const DeepCollectionEquality().hash(tags) ^
      const DeepCollectionEquality().hash(instructorName) ^
      const DeepCollectionEquality().hash(instructorAvatar) ^
      const DeepCollectionEquality().hash(enrollmentCount) ^
      const DeepCollectionEquality().hash(totalLectures) ^
      const DeepCollectionEquality().hash(totalDuration) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(sections) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      const DeepCollectionEquality().hash(isEnrolled) ^
      runtimeType.hashCode;
}

extension $CourseDetailExtension on CourseDetail {
  CourseDetail copyWith({
    String? id,
    String? slug,
    String? title,
    String? description,
    String? shortDescription,
    String? thumbnail,
    String? previewVideoUrl,
    Category? category,
    enums.LevelEnum? level,
    String? levelDisplay,
    String? price,
    String? language,
    String? whatYouLearn,
    String? requirements,
    String? tags,
    String? instructorName,
    String? instructorAvatar,
    String? enrollmentCount,
    String? totalLectures,
    String? totalDuration,
    enums.Status76eEnum? status,
    List<CourseSection>? sections,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? isEnrolled,
  }) {
    return CourseDetail(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      category: category ?? this.category,
      level: level ?? this.level,
      levelDisplay: levelDisplay ?? this.levelDisplay,
      price: price ?? this.price,
      language: language ?? this.language,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      totalLectures: totalLectures ?? this.totalLectures,
      totalDuration: totalDuration ?? this.totalDuration,
      status: status ?? this.status,
      sections: sections ?? this.sections,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      isEnrolled: isEnrolled ?? this.isEnrolled,
    );
  }

  CourseDetail copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? slug,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? thumbnail,
    Wrapped<String?>? previewVideoUrl,
    Wrapped<Category?>? category,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? levelDisplay,
    Wrapped<String?>? price,
    Wrapped<String?>? language,
    Wrapped<String?>? whatYouLearn,
    Wrapped<String?>? requirements,
    Wrapped<String?>? tags,
    Wrapped<String?>? instructorName,
    Wrapped<String?>? instructorAvatar,
    Wrapped<String?>? enrollmentCount,
    Wrapped<String?>? totalLectures,
    Wrapped<String?>? totalDuration,
    Wrapped<enums.Status76eEnum?>? status,
    Wrapped<List<CourseSection>?>? sections,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? publishedAt,
    Wrapped<String?>? isEnrolled,
  }) {
    return CourseDetail(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      previewVideoUrl: (previewVideoUrl != null
          ? previewVideoUrl.value
          : this.previewVideoUrl),
      category: (category != null ? category.value : this.category),
      level: (level != null ? level.value : this.level),
      levelDisplay: (levelDisplay != null
          ? levelDisplay.value
          : this.levelDisplay),
      price: (price != null ? price.value : this.price),
      language: (language != null ? language.value : this.language),
      whatYouLearn: (whatYouLearn != null
          ? whatYouLearn.value
          : this.whatYouLearn),
      requirements: (requirements != null
          ? requirements.value
          : this.requirements),
      tags: (tags != null ? tags.value : this.tags),
      instructorName: (instructorName != null
          ? instructorName.value
          : this.instructorName),
      instructorAvatar: (instructorAvatar != null
          ? instructorAvatar.value
          : this.instructorAvatar),
      enrollmentCount: (enrollmentCount != null
          ? enrollmentCount.value
          : this.enrollmentCount),
      totalLectures: (totalLectures != null
          ? totalLectures.value
          : this.totalLectures),
      totalDuration: (totalDuration != null
          ? totalDuration.value
          : this.totalDuration),
      status: (status != null ? status.value : this.status),
      sections: (sections != null ? sections.value : this.sections),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
      isEnrolled: (isEnrolled != null ? isEnrolled.value : this.isEnrolled),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseDetailRequest {
  const CourseDetailRequest({
    this.slug,
    required this.title,
    required this.description,
    this.shortDescription,
    this.thumbnail,
    this.previewVideoUrl,
    this.level,
    this.price,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
    this.status,
    this.publishedAt,
  });

  factory CourseDetailRequest.fromJson(Map<String, dynamic> json) =>
      _$CourseDetailRequestFromJson(json);

  static const toJsonFactory = _$CourseDetailRequestToJson;
  Map<String, dynamic> toJson() => _$CourseDetailRequestToJson(this);

  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'preview_video_url')
  final String? previewVideoUrl;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'what_you_learn')
  final String? whatYouLearn;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'tags')
  final String? tags;
  @JsonKey(
    name: 'status',
    toJson: status76eEnumNullableToJson,
    fromJson: status76eEnumNullableFromJson,
  )
  final enums.Status76eEnum? status;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  static const fromJsonFactory = _$CourseDetailRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseDetailRequest &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.previewVideoUrl, previewVideoUrl) ||
                const DeepCollectionEquality().equals(
                  other.previewVideoUrl,
                  previewVideoUrl,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.language, language) ||
                const DeepCollectionEquality().equals(
                  other.language,
                  language,
                )) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                const DeepCollectionEquality().equals(
                  other.whatYouLearn,
                  whatYouLearn,
                )) &&
            (identical(other.requirements, requirements) ||
                const DeepCollectionEquality().equals(
                  other.requirements,
                  requirements,
                )) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.publishedAt, publishedAt) ||
                const DeepCollectionEquality().equals(
                  other.publishedAt,
                  publishedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(previewVideoUrl) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(language) ^
      const DeepCollectionEquality().hash(whatYouLearn) ^
      const DeepCollectionEquality().hash(requirements) ^
      const DeepCollectionEquality().hash(tags) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(publishedAt) ^
      runtimeType.hashCode;
}

extension $CourseDetailRequestExtension on CourseDetailRequest {
  CourseDetailRequest copyWith({
    String? slug,
    String? title,
    String? description,
    String? shortDescription,
    String? thumbnail,
    String? previewVideoUrl,
    enums.LevelEnum? level,
    String? price,
    String? language,
    String? whatYouLearn,
    String? requirements,
    String? tags,
    enums.Status76eEnum? status,
    DateTime? publishedAt,
  }) {
    return CourseDetailRequest(
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      level: level ?? this.level,
      price: price ?? this.price,
      language: language ?? this.language,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  CourseDetailRequest copyWithWrapped({
    Wrapped<String?>? slug,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? thumbnail,
    Wrapped<String?>? previewVideoUrl,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? price,
    Wrapped<String?>? language,
    Wrapped<String?>? whatYouLearn,
    Wrapped<String?>? requirements,
    Wrapped<String?>? tags,
    Wrapped<enums.Status76eEnum?>? status,
    Wrapped<DateTime?>? publishedAt,
  }) {
    return CourseDetailRequest(
      slug: (slug != null ? slug.value : this.slug),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      previewVideoUrl: (previewVideoUrl != null
          ? previewVideoUrl.value
          : this.previewVideoUrl),
      level: (level != null ? level.value : this.level),
      price: (price != null ? price.value : this.price),
      language: (language != null ? language.value : this.language),
      whatYouLearn: (whatYouLearn != null
          ? whatYouLearn.value
          : this.whatYouLearn),
      requirements: (requirements != null
          ? requirements.value
          : this.requirements),
      tags: (tags != null ? tags.value : this.tags),
      status: (status != null ? status.value : this.status),
      publishedAt: (publishedAt != null ? publishedAt.value : this.publishedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseList {
  const CourseList({
    this.id,
    this.slug,
    required this.title,
    this.shortDescription,
    this.thumbnail,
    this.category,
    this.level,
    this.levelDisplay,
    this.price,
    this.instructorName,
    this.instructorAvatar,
    this.enrollmentCount,
    this.totalLectures,
    this.totalDuration,
    this.status,
    this.createdAt,
  });

  factory CourseList.fromJson(Map<String, dynamic> json) =>
      _$CourseListFromJson(json);

  static const toJsonFactory = _$CourseListToJson;
  Map<String, dynamic> toJson() => _$CourseListToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'category')
  final Category? category;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'level_display')
  final String? levelDisplay;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'instructor_avatar')
  final String? instructorAvatar;
  @JsonKey(name: 'enrollment_count')
  final String? enrollmentCount;
  @JsonKey(name: 'total_lectures')
  final String? totalLectures;
  @JsonKey(name: 'total_duration')
  final String? totalDuration;
  @JsonKey(
    name: 'status',
    toJson: status76eEnumNullableToJson,
    fromJson: status76eEnumNullableFromJson,
  )
  final enums.Status76eEnum? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$CourseListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseList &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.levelDisplay, levelDisplay) ||
                const DeepCollectionEquality().equals(
                  other.levelDisplay,
                  levelDisplay,
                )) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.instructorName, instructorName) ||
                const DeepCollectionEquality().equals(
                  other.instructorName,
                  instructorName,
                )) &&
            (identical(other.instructorAvatar, instructorAvatar) ||
                const DeepCollectionEquality().equals(
                  other.instructorAvatar,
                  instructorAvatar,
                )) &&
            (identical(other.enrollmentCount, enrollmentCount) ||
                const DeepCollectionEquality().equals(
                  other.enrollmentCount,
                  enrollmentCount,
                )) &&
            (identical(other.totalLectures, totalLectures) ||
                const DeepCollectionEquality().equals(
                  other.totalLectures,
                  totalLectures,
                )) &&
            (identical(other.totalDuration, totalDuration) ||
                const DeepCollectionEquality().equals(
                  other.totalDuration,
                  totalDuration,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(levelDisplay) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(instructorName) ^
      const DeepCollectionEquality().hash(instructorAvatar) ^
      const DeepCollectionEquality().hash(enrollmentCount) ^
      const DeepCollectionEquality().hash(totalLectures) ^
      const DeepCollectionEquality().hash(totalDuration) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $CourseListExtension on CourseList {
  CourseList copyWith({
    String? id,
    String? slug,
    String? title,
    String? shortDescription,
    String? thumbnail,
    Category? category,
    enums.LevelEnum? level,
    String? levelDisplay,
    String? price,
    String? instructorName,
    String? instructorAvatar,
    String? enrollmentCount,
    String? totalLectures,
    String? totalDuration,
    enums.Status76eEnum? status,
    DateTime? createdAt,
  }) {
    return CourseList(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      level: level ?? this.level,
      levelDisplay: levelDisplay ?? this.levelDisplay,
      price: price ?? this.price,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      enrollmentCount: enrollmentCount ?? this.enrollmentCount,
      totalLectures: totalLectures ?? this.totalLectures,
      totalDuration: totalDuration ?? this.totalDuration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  CourseList copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? slug,
    Wrapped<String>? title,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? thumbnail,
    Wrapped<Category?>? category,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? levelDisplay,
    Wrapped<String?>? price,
    Wrapped<String?>? instructorName,
    Wrapped<String?>? instructorAvatar,
    Wrapped<String?>? enrollmentCount,
    Wrapped<String?>? totalLectures,
    Wrapped<String?>? totalDuration,
    Wrapped<enums.Status76eEnum?>? status,
    Wrapped<DateTime?>? createdAt,
  }) {
    return CourseList(
      id: (id != null ? id.value : this.id),
      slug: (slug != null ? slug.value : this.slug),
      title: (title != null ? title.value : this.title),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      category: (category != null ? category.value : this.category),
      level: (level != null ? level.value : this.level),
      levelDisplay: (levelDisplay != null
          ? levelDisplay.value
          : this.levelDisplay),
      price: (price != null ? price.value : this.price),
      instructorName: (instructorName != null
          ? instructorName.value
          : this.instructorName),
      instructorAvatar: (instructorAvatar != null
          ? instructorAvatar.value
          : this.instructorAvatar),
      enrollmentCount: (enrollmentCount != null
          ? enrollmentCount.value
          : this.enrollmentCount),
      totalLectures: (totalLectures != null
          ? totalLectures.value
          : this.totalLectures),
      totalDuration: (totalDuration != null
          ? totalDuration.value
          : this.totalDuration),
      status: (status != null ? status.value : this.status),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseListRequest {
  const CourseListRequest({
    this.slug,
    required this.title,
    this.shortDescription,
    this.thumbnail,
    this.level,
    this.price,
    this.status,
  });

  factory CourseListRequest.fromJson(Map<String, dynamic> json) =>
      _$CourseListRequestFromJson(json);

  static const toJsonFactory = _$CourseListRequestToJson;
  Map<String, dynamic> toJson() => _$CourseListRequestToJson(this);

  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(
    name: 'status',
    toJson: status76eEnumNullableToJson,
    fromJson: status76eEnumNullableFromJson,
  )
  final enums.Status76eEnum? status;
  static const fromJsonFactory = _$CourseListRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseListRequest &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(status) ^
      runtimeType.hashCode;
}

extension $CourseListRequestExtension on CourseListRequest {
  CourseListRequest copyWith({
    String? slug,
    String? title,
    String? shortDescription,
    String? thumbnail,
    enums.LevelEnum? level,
    String? price,
    enums.Status76eEnum? status,
  }) {
    return CourseListRequest(
      slug: slug ?? this.slug,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      thumbnail: thumbnail ?? this.thumbnail,
      level: level ?? this.level,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }

  CourseListRequest copyWithWrapped({
    Wrapped<String?>? slug,
    Wrapped<String>? title,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? thumbnail,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? price,
    Wrapped<enums.Status76eEnum?>? status,
  }) {
    return CourseListRequest(
      slug: (slug != null ? slug.value : this.slug),
      title: (title != null ? title.value : this.title),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      level: (level != null ? level.value : this.level),
      price: (price != null ? price.value : this.price),
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseSection {
  const CourseSection({
    this.id,
    required this.title,
    this.description,
    this.sortOrder,
    this.lectures,
    this.lectureCount,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) =>
      _$CourseSectionFromJson(json);

  static const toJsonFactory = _$CourseSectionToJson;
  Map<String, dynamic> toJson() => _$CourseSectionToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'lectures', defaultValue: <Lecture>[])
  final List<Lecture>? lectures;
  @JsonKey(name: 'lecture_count')
  final String? lectureCount;
  static const fromJsonFactory = _$CourseSectionFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseSection &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.lectures, lectures) ||
                const DeepCollectionEquality().equals(
                  other.lectures,
                  lectures,
                )) &&
            (identical(other.lectureCount, lectureCount) ||
                const DeepCollectionEquality().equals(
                  other.lectureCount,
                  lectureCount,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(lectures) ^
      const DeepCollectionEquality().hash(lectureCount) ^
      runtimeType.hashCode;
}

extension $CourseSectionExtension on CourseSection {
  CourseSection copyWith({
    String? id,
    String? title,
    String? description,
    int? sortOrder,
    List<Lecture>? lectures,
    String? lectureCount,
  }) {
    return CourseSection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      lectures: lectures ?? this.lectures,
      lectureCount: lectureCount ?? this.lectureCount,
    );
  }

  CourseSection copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<int?>? sortOrder,
    Wrapped<List<Lecture>?>? lectures,
    Wrapped<String?>? lectureCount,
  }) {
    return CourseSection(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      lectures: (lectures != null ? lectures.value : this.lectures),
      lectureCount: (lectureCount != null
          ? lectureCount.value
          : this.lectureCount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseSectionCreate {
  const CourseSectionCreate({
    this.id,
    required this.title,
    this.description,
    this.sortOrder,
  });

  factory CourseSectionCreate.fromJson(Map<String, dynamic> json) =>
      _$CourseSectionCreateFromJson(json);

  static const toJsonFactory = _$CourseSectionCreateToJson;
  Map<String, dynamic> toJson() => _$CourseSectionCreateToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$CourseSectionCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseSectionCreate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $CourseSectionCreateExtension on CourseSectionCreate {
  CourseSectionCreate copyWith({
    String? id,
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return CourseSectionCreate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  CourseSectionCreate copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<int?>? sortOrder,
  }) {
    return CourseSectionCreate(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseSectionCreateRequest {
  const CourseSectionCreateRequest({
    required this.title,
    this.description,
    this.sortOrder,
  });

  factory CourseSectionCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$CourseSectionCreateRequestFromJson(json);

  static const toJsonFactory = _$CourseSectionCreateRequestToJson;
  Map<String, dynamic> toJson() => _$CourseSectionCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$CourseSectionCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseSectionCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $CourseSectionCreateRequestExtension on CourseSectionCreateRequest {
  CourseSectionCreateRequest copyWith({
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return CourseSectionCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  CourseSectionCreateRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<int?>? sortOrder,
  }) {
    return CourseSectionCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CourseSectionRequest {
  const CourseSectionRequest({
    required this.title,
    this.description,
    this.sortOrder,
  });

  factory CourseSectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CourseSectionRequestFromJson(json);

  static const toJsonFactory = _$CourseSectionRequestToJson;
  Map<String, dynamic> toJson() => _$CourseSectionRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$CourseSectionRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CourseSectionRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $CourseSectionRequestExtension on CourseSectionRequest {
  CourseSectionRequest copyWith({
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return CourseSectionRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  CourseSectionRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<int?>? sortOrder,
  }) {
    return CourseSectionRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CustomTokenObtainPairRequest {
  const CustomTokenObtainPairRequest({this.email, this.password});

  factory CustomTokenObtainPairRequest.fromJson(Map<String, dynamic> json) =>
      _$CustomTokenObtainPairRequestFromJson(json);

  static const toJsonFactory = _$CustomTokenObtainPairRequestToJson;
  Map<String, dynamic> toJson() => _$CustomTokenObtainPairRequestToJson(this);

  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'password')
  final String? password;
  static const fromJsonFactory = _$CustomTokenObtainPairRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CustomTokenObtainPairRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $CustomTokenObtainPairRequestExtension
    on CustomTokenObtainPairRequest {
  CustomTokenObtainPairRequest copyWith({String? email, String? password}) {
    return CustomTokenObtainPairRequest(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  CustomTokenObtainPairRequest copyWithWrapped({
    Wrapped<String?>? email,
    Wrapped<String?>? password,
  }) {
    return CustomTokenObtainPairRequest(
      email: (email != null ? email.value : this.email),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EBook {
  const EBook({
    this.id,
    required this.instructor,
    this.instructorName,
    required this.title,
    this.slug,
    required this.description,
    required this.authorName,
    this.coverImage,
    required this.pdfFile,
    this.category,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory EBook.fromJson(Map<String, dynamic> json) => _$EBookFromJson(json);

  static const toJsonFactory = _$EBookToJson;
  Map<String, dynamic> toJson() => _$EBookToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'instructor')
  final String instructor;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String pdfFile;
  @JsonKey(name: 'category')
  final Category? category;
  @JsonKey(
    name: 'status',
    toJson: status1bcEnumNullableToJson,
    fromJson: status1bcEnumNullableFromJson,
  )
  final enums.Status1bcEnum? status;
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  static const fromJsonFactory = _$EBookFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EBook &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.instructor, instructor) ||
                const DeepCollectionEquality().equals(
                  other.instructor,
                  instructor,
                )) &&
            (identical(other.instructorName, instructorName) ||
                const DeepCollectionEquality().equals(
                  other.instructorName,
                  instructorName,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(
                  other.pdfFile,
                  pdfFile,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.rejectionReason, rejectionReason) ||
                const DeepCollectionEquality().equals(
                  other.rejectionReason,
                  rejectionReason,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.updatedAt, updatedAt) ||
                const DeepCollectionEquality().equals(
                  other.updatedAt,
                  updatedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(instructor) ^
      const DeepCollectionEquality().hash(instructorName) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(rejectionReason) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(updatedAt) ^
      runtimeType.hashCode;
}

extension $EBookExtension on EBook {
  EBook copyWith({
    String? id,
    String? instructor,
    String? instructorName,
    String? title,
    String? slug,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
    Category? category,
    enums.Status1bcEnum? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EBook(
      id: id ?? this.id,
      instructor: instructor ?? this.instructor,
      instructorName: instructorName ?? this.instructorName,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
      category: category ?? this.category,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  EBook copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? instructor,
    Wrapped<String?>? instructorName,
    Wrapped<String>? title,
    Wrapped<String?>? slug,
    Wrapped<String>? description,
    Wrapped<String>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String>? pdfFile,
    Wrapped<Category?>? category,
    Wrapped<enums.Status1bcEnum?>? status,
    Wrapped<String?>? rejectionReason,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? updatedAt,
  }) {
    return EBook(
      id: (id != null ? id.value : this.id),
      instructor: (instructor != null ? instructor.value : this.instructor),
      instructorName: (instructorName != null
          ? instructorName.value
          : this.instructorName),
      title: (title != null ? title.value : this.title),
      slug: (slug != null ? slug.value : this.slug),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
      category: (category != null ? category.value : this.category),
      status: (status != null ? status.value : this.status),
      rejectionReason: (rejectionReason != null
          ? rejectionReason.value
          : this.rejectionReason),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      updatedAt: (updatedAt != null ? updatedAt.value : this.updatedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EBookCreateUpdate {
  const EBookCreateUpdate({
    this.id,
    required this.title,
    this.slug,
    this.status,
    required this.description,
    required this.authorName,
    this.coverImage,
    required this.pdfFile,
    this.category,
  });

  factory EBookCreateUpdate.fromJson(Map<String, dynamic> json) =>
      _$EBookCreateUpdateFromJson(json);

  static const toJsonFactory = _$EBookCreateUpdateToJson;
  Map<String, dynamic> toJson() => _$EBookCreateUpdateToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(
    name: 'status',
    toJson: status1bcEnumNullableToJson,
    fromJson: status1bcEnumNullableFromJson,
  )
  final enums.Status1bcEnum? status;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String pdfFile;
  @JsonKey(name: 'category')
  final Category? category;
  static const fromJsonFactory = _$EBookCreateUpdateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EBookCreateUpdate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(
                  other.pdfFile,
                  pdfFile,
                )) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      const DeepCollectionEquality().hash(category) ^
      runtimeType.hashCode;
}

extension $EBookCreateUpdateExtension on EBookCreateUpdate {
  EBookCreateUpdate copyWith({
    String? id,
    String? title,
    String? slug,
    enums.Status1bcEnum? status,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
    Category? category,
  }) {
    return EBookCreateUpdate(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
      category: category ?? this.category,
    );
  }

  EBookCreateUpdate copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String?>? slug,
    Wrapped<enums.Status1bcEnum?>? status,
    Wrapped<String>? description,
    Wrapped<String>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String>? pdfFile,
    Wrapped<Category?>? category,
  }) {
    return EBookCreateUpdate(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      slug: (slug != null ? slug.value : this.slug),
      status: (status != null ? status.value : this.status),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
      category: (category != null ? category.value : this.category),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EBookCreateUpdateRequest {
  const EBookCreateUpdateRequest({
    required this.title,
    required this.description,
    required this.authorName,
    this.coverImage,
    required this.pdfFile,
    this.categoryId,
  });

  factory EBookCreateUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EBookCreateUpdateRequestFromJson(json);

  static const toJsonFactory = _$EBookCreateUpdateRequestToJson;
  Map<String, dynamic> toJson() => _$EBookCreateUpdateRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String pdfFile;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  static const fromJsonFactory = _$EBookCreateUpdateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EBookCreateUpdateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(
                  other.pdfFile,
                  pdfFile,
                )) &&
            (identical(other.categoryId, categoryId) ||
                const DeepCollectionEquality().equals(
                  other.categoryId,
                  categoryId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      const DeepCollectionEquality().hash(categoryId) ^
      runtimeType.hashCode;
}

extension $EBookCreateUpdateRequestExtension on EBookCreateUpdateRequest {
  EBookCreateUpdateRequest copyWith({
    String? title,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
    String? categoryId,
  }) {
    return EBookCreateUpdateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  EBookCreateUpdateRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String>? pdfFile,
    Wrapped<String?>? categoryId,
  }) {
    return EBookCreateUpdateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
      categoryId: (categoryId != null ? categoryId.value : this.categoryId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class EBookRequest {
  const EBookRequest({
    required this.instructor,
    required this.title,
    required this.description,
    required this.authorName,
    this.coverImage,
    required this.pdfFile,
  });

  factory EBookRequest.fromJson(Map<String, dynamic> json) =>
      _$EBookRequestFromJson(json);

  static const toJsonFactory = _$EBookRequestToJson;
  Map<String, dynamic> toJson() => _$EBookRequestToJson(this);

  @JsonKey(name: 'instructor')
  final String instructor;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String pdfFile;
  static const fromJsonFactory = _$EBookRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is EBookRequest &&
            (identical(other.instructor, instructor) ||
                const DeepCollectionEquality().equals(
                  other.instructor,
                  instructor,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(other.pdfFile, pdfFile)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(instructor) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      runtimeType.hashCode;
}

extension $EBookRequestExtension on EBookRequest {
  EBookRequest copyWith({
    String? instructor,
    String? title,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
  }) {
    return EBookRequest(
      instructor: instructor ?? this.instructor,
      title: title ?? this.title,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
    );
  }

  EBookRequest copyWithWrapped({
    Wrapped<String>? instructor,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String>? pdfFile,
  }) {
    return EBookRequest(
      instructor: (instructor != null ? instructor.value : this.instructor),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Enrollment {
  const Enrollment({
    this.id,
    required this.course,
    this.courseTitle,
    this.courseSlug,
    this.courseThumbnail,
    this.enrolledAt,
    this.completed,
    this.completionPercentage,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentFromJson(json);

  static const toJsonFactory = _$EnrollmentToJson;
  Map<String, dynamic> toJson() => _$EnrollmentToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'course')
  final String course;
  @JsonKey(name: 'course_title')
  final String? courseTitle;
  @JsonKey(name: 'course_slug')
  final String? courseSlug;
  @JsonKey(name: 'course_thumbnail')
  final String? courseThumbnail;
  @JsonKey(name: 'enrolled_at')
  final DateTime? enrolledAt;
  @JsonKey(name: 'completed')
  final bool? completed;
  @JsonKey(name: 'completion_percentage')
  final double? completionPercentage;
  static const fromJsonFactory = _$EnrollmentFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Enrollment &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.course, course) ||
                const DeepCollectionEquality().equals(other.course, course)) &&
            (identical(other.courseTitle, courseTitle) ||
                const DeepCollectionEquality().equals(
                  other.courseTitle,
                  courseTitle,
                )) &&
            (identical(other.courseSlug, courseSlug) ||
                const DeepCollectionEquality().equals(
                  other.courseSlug,
                  courseSlug,
                )) &&
            (identical(other.courseThumbnail, courseThumbnail) ||
                const DeepCollectionEquality().equals(
                  other.courseThumbnail,
                  courseThumbnail,
                )) &&
            (identical(other.enrolledAt, enrolledAt) ||
                const DeepCollectionEquality().equals(
                  other.enrolledAt,
                  enrolledAt,
                )) &&
            (identical(other.completed, completed) ||
                const DeepCollectionEquality().equals(
                  other.completed,
                  completed,
                )) &&
            (identical(other.completionPercentage, completionPercentage) ||
                const DeepCollectionEquality().equals(
                  other.completionPercentage,
                  completionPercentage,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(course) ^
      const DeepCollectionEquality().hash(courseTitle) ^
      const DeepCollectionEquality().hash(courseSlug) ^
      const DeepCollectionEquality().hash(courseThumbnail) ^
      const DeepCollectionEquality().hash(enrolledAt) ^
      const DeepCollectionEquality().hash(completed) ^
      const DeepCollectionEquality().hash(completionPercentage) ^
      runtimeType.hashCode;
}

extension $EnrollmentExtension on Enrollment {
  Enrollment copyWith({
    String? id,
    String? course,
    String? courseTitle,
    String? courseSlug,
    String? courseThumbnail,
    DateTime? enrolledAt,
    bool? completed,
    double? completionPercentage,
  }) {
    return Enrollment(
      id: id ?? this.id,
      course: course ?? this.course,
      courseTitle: courseTitle ?? this.courseTitle,
      courseSlug: courseSlug ?? this.courseSlug,
      courseThumbnail: courseThumbnail ?? this.courseThumbnail,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completed: completed ?? this.completed,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  Enrollment copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? course,
    Wrapped<String?>? courseTitle,
    Wrapped<String?>? courseSlug,
    Wrapped<String?>? courseThumbnail,
    Wrapped<DateTime?>? enrolledAt,
    Wrapped<bool?>? completed,
    Wrapped<double?>? completionPercentage,
  }) {
    return Enrollment(
      id: (id != null ? id.value : this.id),
      course: (course != null ? course.value : this.course),
      courseTitle: (courseTitle != null ? courseTitle.value : this.courseTitle),
      courseSlug: (courseSlug != null ? courseSlug.value : this.courseSlug),
      courseThumbnail: (courseThumbnail != null
          ? courseThumbnail.value
          : this.courseThumbnail),
      enrolledAt: (enrolledAt != null ? enrolledAt.value : this.enrolledAt),
      completed: (completed != null ? completed.value : this.completed),
      completionPercentage: (completionPercentage != null
          ? completionPercentage.value
          : this.completionPercentage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FCMTokenRequest {
  const FCMTokenRequest({required this.fcmToken, this.deviceType});

  factory FCMTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$FCMTokenRequestFromJson(json);

  static const toJsonFactory = _$FCMTokenRequestToJson;
  Map<String, dynamic> toJson() => _$FCMTokenRequestToJson(this);

  @JsonKey(name: 'fcm_token')
  final String fcmToken;
  @JsonKey(
    name: 'device_type',
    toJson: deviceTypeEnumNullableToJson,
    fromJson: deviceTypeEnumDeviceTypeNullableFromJson,
  )
  final enums.DeviceTypeEnum? deviceType;
  static enums.DeviceTypeEnum? deviceTypeEnumDeviceTypeNullableFromJson(
    Object? value,
  ) => deviceTypeEnumNullableFromJson(value, enums.DeviceTypeEnum.android);

  static const fromJsonFactory = _$FCMTokenRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is FCMTokenRequest &&
            (identical(other.fcmToken, fcmToken) ||
                const DeepCollectionEquality().equals(
                  other.fcmToken,
                  fcmToken,
                )) &&
            (identical(other.deviceType, deviceType) ||
                const DeepCollectionEquality().equals(
                  other.deviceType,
                  deviceType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fcmToken) ^
      const DeepCollectionEquality().hash(deviceType) ^
      runtimeType.hashCode;
}

extension $FCMTokenRequestExtension on FCMTokenRequest {
  FCMTokenRequest copyWith({
    String? fcmToken,
    enums.DeviceTypeEnum? deviceType,
  }) {
    return FCMTokenRequest(
      fcmToken: fcmToken ?? this.fcmToken,
      deviceType: deviceType ?? this.deviceType,
    );
  }

  FCMTokenRequest copyWithWrapped({
    Wrapped<String>? fcmToken,
    Wrapped<enums.DeviceTypeEnum?>? deviceType,
  }) {
    return FCMTokenRequest(
      fcmToken: (fcmToken != null ? fcmToken.value : this.fcmToken),
      deviceType: (deviceType != null ? deviceType.value : this.deviceType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ForgotPassword {
  const ForgotPassword({required this.email});

  factory ForgotPassword.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordFromJson(json);

  static const toJsonFactory = _$ForgotPasswordToJson;
  Map<String, dynamic> toJson() => _$ForgotPasswordToJson(this);

  @JsonKey(name: 'email')
  final String email;
  static const fromJsonFactory = _$ForgotPasswordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ForgotPassword &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^ runtimeType.hashCode;
}

extension $ForgotPasswordExtension on ForgotPassword {
  ForgotPassword copyWith({String? email}) {
    return ForgotPassword(email: email ?? this.email);
  }

  ForgotPassword copyWithWrapped({Wrapped<String>? email}) {
    return ForgotPassword(email: (email != null ? email.value : this.email));
  }
}

@JsonSerializable(explicitToJson: true)
class ForgotPasswordRequest {
  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestFromJson(json);

  static const toJsonFactory = _$ForgotPasswordRequestToJson;
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);

  @JsonKey(name: 'email')
  final String email;
  static const fromJsonFactory = _$ForgotPasswordRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ForgotPasswordRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^ runtimeType.hashCode;
}

extension $ForgotPasswordRequestExtension on ForgotPasswordRequest {
  ForgotPasswordRequest copyWith({String? email}) {
    return ForgotPasswordRequest(email: email ?? this.email);
  }

  ForgotPasswordRequest copyWithWrapped({Wrapped<String>? email}) {
    return ForgotPasswordRequest(
      email: (email != null ? email.value : this.email),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class InstructorProfile {
  const InstructorProfile({
    this.bio,
    this.expertiseTags,
    this.website,
    this.yearsOfExperience,
    this.specialtyCrops,
    this.socialLink,
    this.qualifications,
    this.currentOccupation,
    this.verificationStatus,
    this.rejectionCounter,
    this.totalStudents,
    this.totalRevenue,
    this.kycVerified,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.kycDocumentType,
    this.kycDocumentNumber,
    this.kycDocumentImage,
    this.createdAt,
  });

  factory InstructorProfile.fromJson(Map<String, dynamic> json) =>
      _$InstructorProfileFromJson(json);

  static const toJsonFactory = _$InstructorProfileToJson;
  Map<String, dynamic> toJson() => _$InstructorProfileToJson(this);

  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'expertise_tags')
  final String? expertiseTags;
  @JsonKey(name: 'website')
  final String? website;
  @JsonKey(name: 'years_of_experience')
  final int? yearsOfExperience;
  @JsonKey(name: 'specialty_crops')
  final String? specialtyCrops;
  @JsonKey(name: 'social_link')
  final String? socialLink;
  @JsonKey(name: 'qualifications')
  final String? qualifications;
  @JsonKey(name: 'current_occupation')
  final String? currentOccupation;
  @JsonKey(
    name: 'verification_status',
    toJson: verificationStatusEnumNullableToJson,
    fromJson: verificationStatusEnumNullableFromJson,
  )
  final enums.VerificationStatusEnum? verificationStatus;
  @JsonKey(name: 'rejection_counter')
  final int? rejectionCounter;
  @JsonKey(name: 'total_students')
  final int? totalStudents;
  @JsonKey(name: 'total_revenue')
  final String? totalRevenue;
  @JsonKey(name: 'kyc_verified')
  final bool? kycVerified;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_account_name')
  final String? bankAccountName;
  @JsonKey(name: 'bank_account_number')
  final String? bankAccountNumber;
  @JsonKey(name: 'bank_ifsc_code')
  final String? bankIfscCode;
  @JsonKey(name: 'kyc_document_type')
  final dynamic kycDocumentType;
  @JsonKey(name: 'kyc_document_number')
  final String? kycDocumentNumber;
  @JsonKey(name: 'kyc_document_image')
  final String? kycDocumentImage;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$InstructorProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is InstructorProfile &&
            (identical(other.bio, bio) ||
                const DeepCollectionEquality().equals(other.bio, bio)) &&
            (identical(other.expertiseTags, expertiseTags) ||
                const DeepCollectionEquality().equals(
                  other.expertiseTags,
                  expertiseTags,
                )) &&
            (identical(other.website, website) ||
                const DeepCollectionEquality().equals(
                  other.website,
                  website,
                )) &&
            (identical(other.yearsOfExperience, yearsOfExperience) ||
                const DeepCollectionEquality().equals(
                  other.yearsOfExperience,
                  yearsOfExperience,
                )) &&
            (identical(other.specialtyCrops, specialtyCrops) ||
                const DeepCollectionEquality().equals(
                  other.specialtyCrops,
                  specialtyCrops,
                )) &&
            (identical(other.socialLink, socialLink) ||
                const DeepCollectionEquality().equals(
                  other.socialLink,
                  socialLink,
                )) &&
            (identical(other.qualifications, qualifications) ||
                const DeepCollectionEquality().equals(
                  other.qualifications,
                  qualifications,
                )) &&
            (identical(other.currentOccupation, currentOccupation) ||
                const DeepCollectionEquality().equals(
                  other.currentOccupation,
                  currentOccupation,
                )) &&
            (identical(other.verificationStatus, verificationStatus) ||
                const DeepCollectionEquality().equals(
                  other.verificationStatus,
                  verificationStatus,
                )) &&
            (identical(other.rejectionCounter, rejectionCounter) ||
                const DeepCollectionEquality().equals(
                  other.rejectionCounter,
                  rejectionCounter,
                )) &&
            (identical(other.totalStudents, totalStudents) ||
                const DeepCollectionEquality().equals(
                  other.totalStudents,
                  totalStudents,
                )) &&
            (identical(other.totalRevenue, totalRevenue) ||
                const DeepCollectionEquality().equals(
                  other.totalRevenue,
                  totalRevenue,
                )) &&
            (identical(other.kycVerified, kycVerified) ||
                const DeepCollectionEquality().equals(
                  other.kycVerified,
                  kycVerified,
                )) &&
            (identical(other.bankName, bankName) ||
                const DeepCollectionEquality().equals(
                  other.bankName,
                  bankName,
                )) &&
            (identical(other.bankAccountName, bankAccountName) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountName,
                  bankAccountName,
                )) &&
            (identical(other.bankAccountNumber, bankAccountNumber) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountNumber,
                  bankAccountNumber,
                )) &&
            (identical(other.bankIfscCode, bankIfscCode) ||
                const DeepCollectionEquality().equals(
                  other.bankIfscCode,
                  bankIfscCode,
                )) &&
            (identical(other.kycDocumentType, kycDocumentType) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentType,
                  kycDocumentType,
                )) &&
            (identical(other.kycDocumentNumber, kycDocumentNumber) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentNumber,
                  kycDocumentNumber,
                )) &&
            (identical(other.kycDocumentImage, kycDocumentImage) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentImage,
                  kycDocumentImage,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bio) ^
      const DeepCollectionEquality().hash(expertiseTags) ^
      const DeepCollectionEquality().hash(website) ^
      const DeepCollectionEquality().hash(yearsOfExperience) ^
      const DeepCollectionEquality().hash(specialtyCrops) ^
      const DeepCollectionEquality().hash(socialLink) ^
      const DeepCollectionEquality().hash(qualifications) ^
      const DeepCollectionEquality().hash(currentOccupation) ^
      const DeepCollectionEquality().hash(verificationStatus) ^
      const DeepCollectionEquality().hash(rejectionCounter) ^
      const DeepCollectionEquality().hash(totalStudents) ^
      const DeepCollectionEquality().hash(totalRevenue) ^
      const DeepCollectionEquality().hash(kycVerified) ^
      const DeepCollectionEquality().hash(bankName) ^
      const DeepCollectionEquality().hash(bankAccountName) ^
      const DeepCollectionEquality().hash(bankAccountNumber) ^
      const DeepCollectionEquality().hash(bankIfscCode) ^
      const DeepCollectionEquality().hash(kycDocumentType) ^
      const DeepCollectionEquality().hash(kycDocumentNumber) ^
      const DeepCollectionEquality().hash(kycDocumentImage) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $InstructorProfileExtension on InstructorProfile {
  InstructorProfile copyWith({
    String? bio,
    String? expertiseTags,
    String? website,
    int? yearsOfExperience,
    String? specialtyCrops,
    String? socialLink,
    String? qualifications,
    String? currentOccupation,
    enums.VerificationStatusEnum? verificationStatus,
    int? rejectionCounter,
    int? totalStudents,
    String? totalRevenue,
    bool? kycVerified,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    dynamic kycDocumentType,
    String? kycDocumentNumber,
    String? kycDocumentImage,
    DateTime? createdAt,
  }) {
    return InstructorProfile(
      bio: bio ?? this.bio,
      expertiseTags: expertiseTags ?? this.expertiseTags,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialtyCrops: specialtyCrops ?? this.specialtyCrops,
      socialLink: socialLink ?? this.socialLink,
      qualifications: qualifications ?? this.qualifications,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionCounter: rejectionCounter ?? this.rejectionCounter,
      totalStudents: totalStudents ?? this.totalStudents,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      kycVerified: kycVerified ?? this.kycVerified,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      kycDocumentType: kycDocumentType ?? this.kycDocumentType,
      kycDocumentNumber: kycDocumentNumber ?? this.kycDocumentNumber,
      kycDocumentImage: kycDocumentImage ?? this.kycDocumentImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  InstructorProfile copyWithWrapped({
    Wrapped<String?>? bio,
    Wrapped<String?>? expertiseTags,
    Wrapped<String?>? website,
    Wrapped<int?>? yearsOfExperience,
    Wrapped<String?>? specialtyCrops,
    Wrapped<String?>? socialLink,
    Wrapped<String?>? qualifications,
    Wrapped<String?>? currentOccupation,
    Wrapped<enums.VerificationStatusEnum?>? verificationStatus,
    Wrapped<int?>? rejectionCounter,
    Wrapped<int?>? totalStudents,
    Wrapped<String?>? totalRevenue,
    Wrapped<bool?>? kycVerified,
    Wrapped<String?>? bankName,
    Wrapped<String?>? bankAccountName,
    Wrapped<String?>? bankAccountNumber,
    Wrapped<String?>? bankIfscCode,
    Wrapped<dynamic>? kycDocumentType,
    Wrapped<String?>? kycDocumentNumber,
    Wrapped<String?>? kycDocumentImage,
    Wrapped<DateTime?>? createdAt,
  }) {
    return InstructorProfile(
      bio: (bio != null ? bio.value : this.bio),
      expertiseTags: (expertiseTags != null
          ? expertiseTags.value
          : this.expertiseTags),
      website: (website != null ? website.value : this.website),
      yearsOfExperience: (yearsOfExperience != null
          ? yearsOfExperience.value
          : this.yearsOfExperience),
      specialtyCrops: (specialtyCrops != null
          ? specialtyCrops.value
          : this.specialtyCrops),
      socialLink: (socialLink != null ? socialLink.value : this.socialLink),
      qualifications: (qualifications != null
          ? qualifications.value
          : this.qualifications),
      currentOccupation: (currentOccupation != null
          ? currentOccupation.value
          : this.currentOccupation),
      verificationStatus: (verificationStatus != null
          ? verificationStatus.value
          : this.verificationStatus),
      rejectionCounter: (rejectionCounter != null
          ? rejectionCounter.value
          : this.rejectionCounter),
      totalStudents: (totalStudents != null
          ? totalStudents.value
          : this.totalStudents),
      totalRevenue: (totalRevenue != null
          ? totalRevenue.value
          : this.totalRevenue),
      kycVerified: (kycVerified != null ? kycVerified.value : this.kycVerified),
      bankName: (bankName != null ? bankName.value : this.bankName),
      bankAccountName: (bankAccountName != null
          ? bankAccountName.value
          : this.bankAccountName),
      bankAccountNumber: (bankAccountNumber != null
          ? bankAccountNumber.value
          : this.bankAccountNumber),
      bankIfscCode: (bankIfscCode != null
          ? bankIfscCode.value
          : this.bankIfscCode),
      kycDocumentType: (kycDocumentType != null
          ? kycDocumentType.value
          : this.kycDocumentType),
      kycDocumentNumber: (kycDocumentNumber != null
          ? kycDocumentNumber.value
          : this.kycDocumentNumber),
      kycDocumentImage: (kycDocumentImage != null
          ? kycDocumentImage.value
          : this.kycDocumentImage),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class InstructorProfileRequest {
  const InstructorProfileRequest({
    this.bio,
    this.expertiseTags,
    this.website,
    this.yearsOfExperience,
    this.specialtyCrops,
    this.socialLink,
    this.qualifications,
    this.currentOccupation,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.kycDocumentType,
    this.kycDocumentNumber,
    this.kycDocumentImage,
  });

  factory InstructorProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$InstructorProfileRequestFromJson(json);

  static const toJsonFactory = _$InstructorProfileRequestToJson;
  Map<String, dynamic> toJson() => _$InstructorProfileRequestToJson(this);

  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'expertise_tags')
  final String? expertiseTags;
  @JsonKey(name: 'website')
  final String? website;
  @JsonKey(name: 'years_of_experience')
  final int? yearsOfExperience;
  @JsonKey(name: 'specialty_crops')
  final String? specialtyCrops;
  @JsonKey(name: 'social_link')
  final String? socialLink;
  @JsonKey(name: 'qualifications')
  final String? qualifications;
  @JsonKey(name: 'current_occupation')
  final String? currentOccupation;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_account_name')
  final String? bankAccountName;
  @JsonKey(name: 'bank_account_number')
  final String? bankAccountNumber;
  @JsonKey(name: 'bank_ifsc_code')
  final String? bankIfscCode;
  @JsonKey(name: 'kyc_document_type')
  final dynamic kycDocumentType;
  @JsonKey(name: 'kyc_document_number')
  final String? kycDocumentNumber;
  @JsonKey(name: 'kyc_document_image')
  final String? kycDocumentImage;
  static const fromJsonFactory = _$InstructorProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is InstructorProfileRequest &&
            (identical(other.bio, bio) ||
                const DeepCollectionEquality().equals(other.bio, bio)) &&
            (identical(other.expertiseTags, expertiseTags) ||
                const DeepCollectionEquality().equals(
                  other.expertiseTags,
                  expertiseTags,
                )) &&
            (identical(other.website, website) ||
                const DeepCollectionEquality().equals(
                  other.website,
                  website,
                )) &&
            (identical(other.yearsOfExperience, yearsOfExperience) ||
                const DeepCollectionEquality().equals(
                  other.yearsOfExperience,
                  yearsOfExperience,
                )) &&
            (identical(other.specialtyCrops, specialtyCrops) ||
                const DeepCollectionEquality().equals(
                  other.specialtyCrops,
                  specialtyCrops,
                )) &&
            (identical(other.socialLink, socialLink) ||
                const DeepCollectionEquality().equals(
                  other.socialLink,
                  socialLink,
                )) &&
            (identical(other.qualifications, qualifications) ||
                const DeepCollectionEquality().equals(
                  other.qualifications,
                  qualifications,
                )) &&
            (identical(other.currentOccupation, currentOccupation) ||
                const DeepCollectionEquality().equals(
                  other.currentOccupation,
                  currentOccupation,
                )) &&
            (identical(other.bankName, bankName) ||
                const DeepCollectionEquality().equals(
                  other.bankName,
                  bankName,
                )) &&
            (identical(other.bankAccountName, bankAccountName) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountName,
                  bankAccountName,
                )) &&
            (identical(other.bankAccountNumber, bankAccountNumber) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountNumber,
                  bankAccountNumber,
                )) &&
            (identical(other.bankIfscCode, bankIfscCode) ||
                const DeepCollectionEquality().equals(
                  other.bankIfscCode,
                  bankIfscCode,
                )) &&
            (identical(other.kycDocumentType, kycDocumentType) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentType,
                  kycDocumentType,
                )) &&
            (identical(other.kycDocumentNumber, kycDocumentNumber) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentNumber,
                  kycDocumentNumber,
                )) &&
            (identical(other.kycDocumentImage, kycDocumentImage) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentImage,
                  kycDocumentImage,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bio) ^
      const DeepCollectionEquality().hash(expertiseTags) ^
      const DeepCollectionEquality().hash(website) ^
      const DeepCollectionEquality().hash(yearsOfExperience) ^
      const DeepCollectionEquality().hash(specialtyCrops) ^
      const DeepCollectionEquality().hash(socialLink) ^
      const DeepCollectionEquality().hash(qualifications) ^
      const DeepCollectionEquality().hash(currentOccupation) ^
      const DeepCollectionEquality().hash(bankName) ^
      const DeepCollectionEquality().hash(bankAccountName) ^
      const DeepCollectionEquality().hash(bankAccountNumber) ^
      const DeepCollectionEquality().hash(bankIfscCode) ^
      const DeepCollectionEquality().hash(kycDocumentType) ^
      const DeepCollectionEquality().hash(kycDocumentNumber) ^
      const DeepCollectionEquality().hash(kycDocumentImage) ^
      runtimeType.hashCode;
}

extension $InstructorProfileRequestExtension on InstructorProfileRequest {
  InstructorProfileRequest copyWith({
    String? bio,
    String? expertiseTags,
    String? website,
    int? yearsOfExperience,
    String? specialtyCrops,
    String? socialLink,
    String? qualifications,
    String? currentOccupation,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    dynamic kycDocumentType,
    String? kycDocumentNumber,
    String? kycDocumentImage,
  }) {
    return InstructorProfileRequest(
      bio: bio ?? this.bio,
      expertiseTags: expertiseTags ?? this.expertiseTags,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialtyCrops: specialtyCrops ?? this.specialtyCrops,
      socialLink: socialLink ?? this.socialLink,
      qualifications: qualifications ?? this.qualifications,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      kycDocumentType: kycDocumentType ?? this.kycDocumentType,
      kycDocumentNumber: kycDocumentNumber ?? this.kycDocumentNumber,
      kycDocumentImage: kycDocumentImage ?? this.kycDocumentImage,
    );
  }

  InstructorProfileRequest copyWithWrapped({
    Wrapped<String?>? bio,
    Wrapped<String?>? expertiseTags,
    Wrapped<String?>? website,
    Wrapped<int?>? yearsOfExperience,
    Wrapped<String?>? specialtyCrops,
    Wrapped<String?>? socialLink,
    Wrapped<String?>? qualifications,
    Wrapped<String?>? currentOccupation,
    Wrapped<String?>? bankName,
    Wrapped<String?>? bankAccountName,
    Wrapped<String?>? bankAccountNumber,
    Wrapped<String?>? bankIfscCode,
    Wrapped<dynamic>? kycDocumentType,
    Wrapped<String?>? kycDocumentNumber,
    Wrapped<String?>? kycDocumentImage,
  }) {
    return InstructorProfileRequest(
      bio: (bio != null ? bio.value : this.bio),
      expertiseTags: (expertiseTags != null
          ? expertiseTags.value
          : this.expertiseTags),
      website: (website != null ? website.value : this.website),
      yearsOfExperience: (yearsOfExperience != null
          ? yearsOfExperience.value
          : this.yearsOfExperience),
      specialtyCrops: (specialtyCrops != null
          ? specialtyCrops.value
          : this.specialtyCrops),
      socialLink: (socialLink != null ? socialLink.value : this.socialLink),
      qualifications: (qualifications != null
          ? qualifications.value
          : this.qualifications),
      currentOccupation: (currentOccupation != null
          ? currentOccupation.value
          : this.currentOccupation),
      bankName: (bankName != null ? bankName.value : this.bankName),
      bankAccountName: (bankAccountName != null
          ? bankAccountName.value
          : this.bankAccountName),
      bankAccountNumber: (bankAccountNumber != null
          ? bankAccountNumber.value
          : this.bankAccountNumber),
      bankIfscCode: (bankIfscCode != null
          ? bankIfscCode.value
          : this.bankIfscCode),
      kycDocumentType: (kycDocumentType != null
          ? kycDocumentType.value
          : this.kycDocumentType),
      kycDocumentNumber: (kycDocumentNumber != null
          ? kycDocumentNumber.value
          : this.kycDocumentNumber),
      kycDocumentImage: (kycDocumentImage != null
          ? kycDocumentImage.value
          : this.kycDocumentImage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Lecture {
  const Lecture({
    this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.durationFormatted,
    this.sortOrder,
    this.isPreview,
    this.resources,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) =>
      _$LectureFromJson(json);

  static const toJsonFactory = _$LectureToJson;
  Map<String, dynamic> toJson() => _$LectureToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'bunny_video_id')
  final String? bunnyVideoId;
  @JsonKey(
    name: 'bunny_status',
    toJson: bunnyStatusEnumNullableToJson,
    fromJson: bunnyStatusEnumNullableFromJson,
  )
  final enums.BunnyStatusEnum? bunnyStatus;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'duration_formatted')
  final String? durationFormatted;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_preview')
  final bool? isPreview;
  @JsonKey(name: 'resources', defaultValue: <LectureResource>[])
  final List<LectureResource>? resources;
  static const fromJsonFactory = _$LectureFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Lecture &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.videoUrl, videoUrl) ||
                const DeepCollectionEquality().equals(
                  other.videoUrl,
                  videoUrl,
                )) &&
            (identical(other.bunnyVideoId, bunnyVideoId) ||
                const DeepCollectionEquality().equals(
                  other.bunnyVideoId,
                  bunnyVideoId,
                )) &&
            (identical(other.bunnyStatus, bunnyStatus) ||
                const DeepCollectionEquality().equals(
                  other.bunnyStatus,
                  bunnyStatus,
                )) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )) &&
            (identical(other.durationFormatted, durationFormatted) ||
                const DeepCollectionEquality().equals(
                  other.durationFormatted,
                  durationFormatted,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.isPreview, isPreview) ||
                const DeepCollectionEquality().equals(
                  other.isPreview,
                  isPreview,
                )) &&
            (identical(other.resources, resources) ||
                const DeepCollectionEquality().equals(
                  other.resources,
                  resources,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(videoUrl) ^
      const DeepCollectionEquality().hash(bunnyVideoId) ^
      const DeepCollectionEquality().hash(bunnyStatus) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(durationFormatted) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(isPreview) ^
      const DeepCollectionEquality().hash(resources) ^
      runtimeType.hashCode;
}

extension $LectureExtension on Lecture {
  Lecture copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? bunnyVideoId,
    enums.BunnyStatusEnum? bunnyStatus,
    int? duration,
    String? durationFormatted,
    int? sortOrder,
    bool? isPreview,
    List<LectureResource>? resources,
  }) {
    return Lecture(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      bunnyVideoId: bunnyVideoId ?? this.bunnyVideoId,
      bunnyStatus: bunnyStatus ?? this.bunnyStatus,
      duration: duration ?? this.duration,
      durationFormatted: durationFormatted ?? this.durationFormatted,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreview: isPreview ?? this.isPreview,
      resources: resources ?? this.resources,
    );
  }

  Lecture copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? videoUrl,
    Wrapped<String?>? bunnyVideoId,
    Wrapped<enums.BunnyStatusEnum?>? bunnyStatus,
    Wrapped<int?>? duration,
    Wrapped<String?>? durationFormatted,
    Wrapped<int?>? sortOrder,
    Wrapped<bool?>? isPreview,
    Wrapped<List<LectureResource>?>? resources,
  }) {
    return Lecture(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      videoUrl: (videoUrl != null ? videoUrl.value : this.videoUrl),
      bunnyVideoId: (bunnyVideoId != null
          ? bunnyVideoId.value
          : this.bunnyVideoId),
      bunnyStatus: (bunnyStatus != null ? bunnyStatus.value : this.bunnyStatus),
      duration: (duration != null ? duration.value : this.duration),
      durationFormatted: (durationFormatted != null
          ? durationFormatted.value
          : this.durationFormatted),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      isPreview: (isPreview != null ? isPreview.value : this.isPreview),
      resources: (resources != null ? resources.value : this.resources),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LectureCreate {
  const LectureCreate({
    this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.sortOrder,
    this.isPreview,
  });

  factory LectureCreate.fromJson(Map<String, dynamic> json) =>
      _$LectureCreateFromJson(json);

  static const toJsonFactory = _$LectureCreateToJson;
  Map<String, dynamic> toJson() => _$LectureCreateToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'bunny_video_id')
  final String? bunnyVideoId;
  @JsonKey(
    name: 'bunny_status',
    toJson: bunnyStatusEnumNullableToJson,
    fromJson: bunnyStatusEnumNullableFromJson,
  )
  final enums.BunnyStatusEnum? bunnyStatus;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_preview')
  final bool? isPreview;
  static const fromJsonFactory = _$LectureCreateFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LectureCreate &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.videoUrl, videoUrl) ||
                const DeepCollectionEquality().equals(
                  other.videoUrl,
                  videoUrl,
                )) &&
            (identical(other.bunnyVideoId, bunnyVideoId) ||
                const DeepCollectionEquality().equals(
                  other.bunnyVideoId,
                  bunnyVideoId,
                )) &&
            (identical(other.bunnyStatus, bunnyStatus) ||
                const DeepCollectionEquality().equals(
                  other.bunnyStatus,
                  bunnyStatus,
                )) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.isPreview, isPreview) ||
                const DeepCollectionEquality().equals(
                  other.isPreview,
                  isPreview,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(videoUrl) ^
      const DeepCollectionEquality().hash(bunnyVideoId) ^
      const DeepCollectionEquality().hash(bunnyStatus) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(isPreview) ^
      runtimeType.hashCode;
}

extension $LectureCreateExtension on LectureCreate {
  LectureCreate copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? bunnyVideoId,
    enums.BunnyStatusEnum? bunnyStatus,
    int? duration,
    int? sortOrder,
    bool? isPreview,
  }) {
    return LectureCreate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      bunnyVideoId: bunnyVideoId ?? this.bunnyVideoId,
      bunnyStatus: bunnyStatus ?? this.bunnyStatus,
      duration: duration ?? this.duration,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreview: isPreview ?? this.isPreview,
    );
  }

  LectureCreate copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? videoUrl,
    Wrapped<String?>? bunnyVideoId,
    Wrapped<enums.BunnyStatusEnum?>? bunnyStatus,
    Wrapped<int?>? duration,
    Wrapped<int?>? sortOrder,
    Wrapped<bool?>? isPreview,
  }) {
    return LectureCreate(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      videoUrl: (videoUrl != null ? videoUrl.value : this.videoUrl),
      bunnyVideoId: (bunnyVideoId != null
          ? bunnyVideoId.value
          : this.bunnyVideoId),
      bunnyStatus: (bunnyStatus != null ? bunnyStatus.value : this.bunnyStatus),
      duration: (duration != null ? duration.value : this.duration),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      isPreview: (isPreview != null ? isPreview.value : this.isPreview),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LectureCreateRequest {
  const LectureCreateRequest({
    required this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.sortOrder,
    this.isPreview,
  });

  factory LectureCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$LectureCreateRequestFromJson(json);

  static const toJsonFactory = _$LectureCreateRequestToJson;
  Map<String, dynamic> toJson() => _$LectureCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'bunny_video_id')
  final String? bunnyVideoId;
  @JsonKey(
    name: 'bunny_status',
    toJson: bunnyStatusEnumNullableToJson,
    fromJson: bunnyStatusEnumNullableFromJson,
  )
  final enums.BunnyStatusEnum? bunnyStatus;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_preview')
  final bool? isPreview;
  static const fromJsonFactory = _$LectureCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LectureCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.videoUrl, videoUrl) ||
                const DeepCollectionEquality().equals(
                  other.videoUrl,
                  videoUrl,
                )) &&
            (identical(other.bunnyVideoId, bunnyVideoId) ||
                const DeepCollectionEquality().equals(
                  other.bunnyVideoId,
                  bunnyVideoId,
                )) &&
            (identical(other.bunnyStatus, bunnyStatus) ||
                const DeepCollectionEquality().equals(
                  other.bunnyStatus,
                  bunnyStatus,
                )) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.isPreview, isPreview) ||
                const DeepCollectionEquality().equals(
                  other.isPreview,
                  isPreview,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(videoUrl) ^
      const DeepCollectionEquality().hash(bunnyVideoId) ^
      const DeepCollectionEquality().hash(bunnyStatus) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(isPreview) ^
      runtimeType.hashCode;
}

extension $LectureCreateRequestExtension on LectureCreateRequest {
  LectureCreateRequest copyWith({
    String? title,
    String? description,
    String? videoUrl,
    String? bunnyVideoId,
    enums.BunnyStatusEnum? bunnyStatus,
    int? duration,
    int? sortOrder,
    bool? isPreview,
  }) {
    return LectureCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      bunnyVideoId: bunnyVideoId ?? this.bunnyVideoId,
      bunnyStatus: bunnyStatus ?? this.bunnyStatus,
      duration: duration ?? this.duration,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreview: isPreview ?? this.isPreview,
    );
  }

  LectureCreateRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? videoUrl,
    Wrapped<String?>? bunnyVideoId,
    Wrapped<enums.BunnyStatusEnum?>? bunnyStatus,
    Wrapped<int?>? duration,
    Wrapped<int?>? sortOrder,
    Wrapped<bool?>? isPreview,
  }) {
    return LectureCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      videoUrl: (videoUrl != null ? videoUrl.value : this.videoUrl),
      bunnyVideoId: (bunnyVideoId != null
          ? bunnyVideoId.value
          : this.bunnyVideoId),
      bunnyStatus: (bunnyStatus != null ? bunnyStatus.value : this.bunnyStatus),
      duration: (duration != null ? duration.value : this.duration),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      isPreview: (isPreview != null ? isPreview.value : this.isPreview),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LectureRequest {
  const LectureRequest({
    required this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.sortOrder,
    this.isPreview,
  });

  factory LectureRequest.fromJson(Map<String, dynamic> json) =>
      _$LectureRequestFromJson(json);

  static const toJsonFactory = _$LectureRequestToJson;
  Map<String, dynamic> toJson() => _$LectureRequestToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'bunny_video_id')
  final String? bunnyVideoId;
  @JsonKey(
    name: 'bunny_status',
    toJson: bunnyStatusEnumNullableToJson,
    fromJson: bunnyStatusEnumNullableFromJson,
  )
  final enums.BunnyStatusEnum? bunnyStatus;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_preview')
  final bool? isPreview;
  static const fromJsonFactory = _$LectureRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LectureRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.videoUrl, videoUrl) ||
                const DeepCollectionEquality().equals(
                  other.videoUrl,
                  videoUrl,
                )) &&
            (identical(other.bunnyVideoId, bunnyVideoId) ||
                const DeepCollectionEquality().equals(
                  other.bunnyVideoId,
                  bunnyVideoId,
                )) &&
            (identical(other.bunnyStatus, bunnyStatus) ||
                const DeepCollectionEquality().equals(
                  other.bunnyStatus,
                  bunnyStatus,
                )) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.isPreview, isPreview) ||
                const DeepCollectionEquality().equals(
                  other.isPreview,
                  isPreview,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(videoUrl) ^
      const DeepCollectionEquality().hash(bunnyVideoId) ^
      const DeepCollectionEquality().hash(bunnyStatus) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(isPreview) ^
      runtimeType.hashCode;
}

extension $LectureRequestExtension on LectureRequest {
  LectureRequest copyWith({
    String? title,
    String? description,
    String? videoUrl,
    String? bunnyVideoId,
    enums.BunnyStatusEnum? bunnyStatus,
    int? duration,
    int? sortOrder,
    bool? isPreview,
  }) {
    return LectureRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      bunnyVideoId: bunnyVideoId ?? this.bunnyVideoId,
      bunnyStatus: bunnyStatus ?? this.bunnyStatus,
      duration: duration ?? this.duration,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreview: isPreview ?? this.isPreview,
    );
  }

  LectureRequest copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? videoUrl,
    Wrapped<String?>? bunnyVideoId,
    Wrapped<enums.BunnyStatusEnum?>? bunnyStatus,
    Wrapped<int?>? duration,
    Wrapped<int?>? sortOrder,
    Wrapped<bool?>? isPreview,
  }) {
    return LectureRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      videoUrl: (videoUrl != null ? videoUrl.value : this.videoUrl),
      bunnyVideoId: (bunnyVideoId != null
          ? bunnyVideoId.value
          : this.bunnyVideoId),
      bunnyStatus: (bunnyStatus != null ? bunnyStatus.value : this.bunnyStatus),
      duration: (duration != null ? duration.value : this.duration),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      isPreview: (isPreview != null ? isPreview.value : this.isPreview),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LectureResource {
  const LectureResource({
    this.id,
    required this.fileName,
    this.file,
    this.fileUrl,
    this.fileType,
    this.createdAt,
  });

  factory LectureResource.fromJson(Map<String, dynamic> json) =>
      _$LectureResourceFromJson(json);

  static const toJsonFactory = _$LectureResourceToJson;
  Map<String, dynamic> toJson() => _$LectureResourceToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'file_name')
  final String fileName;
  @JsonKey(name: 'file')
  final String? file;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(
    name: 'file_type',
    toJson: fileTypeEnumNullableToJson,
    fromJson: fileTypeEnumNullableFromJson,
  )
  final enums.FileTypeEnum? fileType;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$LectureResourceFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LectureResource &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.fileName, fileName) ||
                const DeepCollectionEquality().equals(
                  other.fileName,
                  fileName,
                )) &&
            (identical(other.file, file) ||
                const DeepCollectionEquality().equals(other.file, file)) &&
            (identical(other.fileUrl, fileUrl) ||
                const DeepCollectionEquality().equals(
                  other.fileUrl,
                  fileUrl,
                )) &&
            (identical(other.fileType, fileType) ||
                const DeepCollectionEquality().equals(
                  other.fileType,
                  fileType,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(fileName) ^
      const DeepCollectionEquality().hash(file) ^
      const DeepCollectionEquality().hash(fileUrl) ^
      const DeepCollectionEquality().hash(fileType) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $LectureResourceExtension on LectureResource {
  LectureResource copyWith({
    String? id,
    String? fileName,
    String? file,
    String? fileUrl,
    enums.FileTypeEnum? fileType,
    DateTime? createdAt,
  }) {
    return LectureResource(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      file: file ?? this.file,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  LectureResource copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? fileName,
    Wrapped<String?>? file,
    Wrapped<String?>? fileUrl,
    Wrapped<enums.FileTypeEnum?>? fileType,
    Wrapped<DateTime?>? createdAt,
  }) {
    return LectureResource(
      id: (id != null ? id.value : this.id),
      fileName: (fileName != null ? fileName.value : this.fileName),
      file: (file != null ? file.value : this.file),
      fileUrl: (fileUrl != null ? fileUrl.value : this.fileUrl),
      fileType: (fileType != null ? fileType.value : this.fileType),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class LectureResourceRequest {
  const LectureResourceRequest({
    required this.fileName,
    this.file,
    this.fileUrl,
    this.fileType,
  });

  factory LectureResourceRequest.fromJson(Map<String, dynamic> json) =>
      _$LectureResourceRequestFromJson(json);

  static const toJsonFactory = _$LectureResourceRequestToJson;
  Map<String, dynamic> toJson() => _$LectureResourceRequestToJson(this);

  @JsonKey(name: 'file_name')
  final String fileName;
  @JsonKey(name: 'file')
  final String? file;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  @JsonKey(
    name: 'file_type',
    toJson: fileTypeEnumNullableToJson,
    fromJson: fileTypeEnumNullableFromJson,
  )
  final enums.FileTypeEnum? fileType;
  static const fromJsonFactory = _$LectureResourceRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is LectureResourceRequest &&
            (identical(other.fileName, fileName) ||
                const DeepCollectionEquality().equals(
                  other.fileName,
                  fileName,
                )) &&
            (identical(other.file, file) ||
                const DeepCollectionEquality().equals(other.file, file)) &&
            (identical(other.fileUrl, fileUrl) ||
                const DeepCollectionEquality().equals(
                  other.fileUrl,
                  fileUrl,
                )) &&
            (identical(other.fileType, fileType) ||
                const DeepCollectionEquality().equals(
                  other.fileType,
                  fileType,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fileName) ^
      const DeepCollectionEquality().hash(file) ^
      const DeepCollectionEquality().hash(fileUrl) ^
      const DeepCollectionEquality().hash(fileType) ^
      runtimeType.hashCode;
}

extension $LectureResourceRequestExtension on LectureResourceRequest {
  LectureResourceRequest copyWith({
    String? fileName,
    String? file,
    String? fileUrl,
    enums.FileTypeEnum? fileType,
  }) {
    return LectureResourceRequest(
      fileName: fileName ?? this.fileName,
      file: file ?? this.file,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
    );
  }

  LectureResourceRequest copyWithWrapped({
    Wrapped<String>? fileName,
    Wrapped<String?>? file,
    Wrapped<String?>? fileUrl,
    Wrapped<enums.FileTypeEnum?>? fileType,
  }) {
    return LectureResourceRequest(
      fileName: (fileName != null ? fileName.value : this.fileName),
      file: (file != null ? file.value : this.file),
      fileUrl: (fileUrl != null ? fileUrl.value : this.fileUrl),
      fileType: (fileType != null ? fileType.value : this.fileType),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ModerationLog {
  const ModerationLog({
    this.id,
    this.courseId,
    this.courseTitle,
    required this.failedStep,
    this.rejectedTokens,
    this.fullAnalysis,
    this.createdAt,
  });

  factory ModerationLog.fromJson(Map<String, dynamic> json) =>
      _$ModerationLogFromJson(json);

  static const toJsonFactory = _$ModerationLogToJson;
  Map<String, dynamic> toJson() => _$ModerationLogToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'course_id')
  final String? courseId;
  @JsonKey(name: 'course_title')
  final String? courseTitle;
  @JsonKey(
    name: 'failed_step',
    toJson: failedStepEnumToJson,
    fromJson: failedStepEnumFromJson,
  )
  final enums.FailedStepEnum failedStep;
  @JsonKey(name: 'rejected_tokens')
  final dynamic rejectedTokens;
  @JsonKey(name: 'full_analysis')
  final dynamic fullAnalysis;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$ModerationLogFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ModerationLog &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.courseId, courseId) ||
                const DeepCollectionEquality().equals(
                  other.courseId,
                  courseId,
                )) &&
            (identical(other.courseTitle, courseTitle) ||
                const DeepCollectionEquality().equals(
                  other.courseTitle,
                  courseTitle,
                )) &&
            (identical(other.failedStep, failedStep) ||
                const DeepCollectionEquality().equals(
                  other.failedStep,
                  failedStep,
                )) &&
            (identical(other.rejectedTokens, rejectedTokens) ||
                const DeepCollectionEquality().equals(
                  other.rejectedTokens,
                  rejectedTokens,
                )) &&
            (identical(other.fullAnalysis, fullAnalysis) ||
                const DeepCollectionEquality().equals(
                  other.fullAnalysis,
                  fullAnalysis,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(courseId) ^
      const DeepCollectionEquality().hash(courseTitle) ^
      const DeepCollectionEquality().hash(failedStep) ^
      const DeepCollectionEquality().hash(rejectedTokens) ^
      const DeepCollectionEquality().hash(fullAnalysis) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $ModerationLogExtension on ModerationLog {
  ModerationLog copyWith({
    String? id,
    String? courseId,
    String? courseTitle,
    enums.FailedStepEnum? failedStep,
    dynamic rejectedTokens,
    dynamic fullAnalysis,
    DateTime? createdAt,
  }) {
    return ModerationLog(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      failedStep: failedStep ?? this.failedStep,
      rejectedTokens: rejectedTokens ?? this.rejectedTokens,
      fullAnalysis: fullAnalysis ?? this.fullAnalysis,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  ModerationLog copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? courseId,
    Wrapped<String?>? courseTitle,
    Wrapped<enums.FailedStepEnum>? failedStep,
    Wrapped<dynamic>? rejectedTokens,
    Wrapped<dynamic>? fullAnalysis,
    Wrapped<DateTime?>? createdAt,
  }) {
    return ModerationLog(
      id: (id != null ? id.value : this.id),
      courseId: (courseId != null ? courseId.value : this.courseId),
      courseTitle: (courseTitle != null ? courseTitle.value : this.courseTitle),
      failedStep: (failedStep != null ? failedStep.value : this.failedStep),
      rejectedTokens: (rejectedTokens != null
          ? rejectedTokens.value
          : this.rejectedTokens),
      fullAnalysis: (fullAnalysis != null
          ? fullAnalysis.value
          : this.fullAnalysis),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Notification {
  const Notification({
    this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.course,
    this.isRead,
    this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  static const toJsonFactory = _$NotificationToJson;
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'notification_type',
    toJson: notificationNotificationTypeEnumToJson,
    fromJson: notificationNotificationTypeEnumFromJson,
  )
  final enums.NotificationNotificationTypeEnum notificationType;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'course')
  final String? course;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$NotificationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Notification &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.course, course) ||
                const DeepCollectionEquality().equals(other.course, course)) &&
            (identical(other.isRead, isRead) ||
                const DeepCollectionEquality().equals(other.isRead, isRead)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(course) ^
      const DeepCollectionEquality().hash(isRead) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $NotificationExtension on Notification {
  Notification copyWith({
    String? id,
    enums.NotificationNotificationTypeEnum? notificationType,
    String? title,
    String? message,
    String? course,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      course: course ?? this.course,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Notification copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<enums.NotificationNotificationTypeEnum>? notificationType,
    Wrapped<String>? title,
    Wrapped<String>? message,
    Wrapped<String?>? course,
    Wrapped<bool?>? isRead,
    Wrapped<DateTime?>? createdAt,
  }) {
    return Notification(
      id: (id != null ? id.value : this.id),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      title: (title != null ? title.value : this.title),
      message: (message != null ? message.value : this.message),
      course: (course != null ? course.value : this.course),
      isRead: (isRead != null ? isRead.value : this.isRead),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Order {
  const Order({
    this.id,
    required this.totalAmount,
    this.gatewayReference,
    this.gatewayName,
    this.status,
    this.paymentMethod,
    this.items,
    this.createdAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  static const toJsonFactory = _$OrderToJson;
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'gateway_reference')
  final String? gatewayReference;
  @JsonKey(name: 'gateway_name')
  final String? gatewayName;
  @JsonKey(
    name: 'status',
    toJson: orderStatusEnumNullableToJson,
    fromJson: orderStatusEnumNullableFromJson,
  )
  final enums.OrderStatusEnum? status;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'items', defaultValue: <OrderItem>[])
  final List<OrderItem>? items;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  static const fromJsonFactory = _$OrderFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Order &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.totalAmount, totalAmount) ||
                const DeepCollectionEquality().equals(
                  other.totalAmount,
                  totalAmount,
                )) &&
            (identical(other.gatewayReference, gatewayReference) ||
                const DeepCollectionEquality().equals(
                  other.gatewayReference,
                  gatewayReference,
                )) &&
            (identical(other.gatewayName, gatewayName) ||
                const DeepCollectionEquality().equals(
                  other.gatewayName,
                  gatewayName,
                )) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.paymentMethod, paymentMethod) ||
                const DeepCollectionEquality().equals(
                  other.paymentMethod,
                  paymentMethod,
                )) &&
            (identical(other.items, items) ||
                const DeepCollectionEquality().equals(other.items, items)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )) &&
            (identical(other.completedAt, completedAt) ||
                const DeepCollectionEquality().equals(
                  other.completedAt,
                  completedAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(totalAmount) ^
      const DeepCollectionEquality().hash(gatewayReference) ^
      const DeepCollectionEquality().hash(gatewayName) ^
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(paymentMethod) ^
      const DeepCollectionEquality().hash(items) ^
      const DeepCollectionEquality().hash(createdAt) ^
      const DeepCollectionEquality().hash(completedAt) ^
      runtimeType.hashCode;
}

extension $OrderExtension on Order {
  Order copyWith({
    String? id,
    String? totalAmount,
    String? gatewayReference,
    String? gatewayName,
    enums.OrderStatusEnum? status,
    String? paymentMethod,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      totalAmount: totalAmount ?? this.totalAmount,
      gatewayReference: gatewayReference ?? this.gatewayReference,
      gatewayName: gatewayName ?? this.gatewayName,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Order copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? totalAmount,
    Wrapped<String?>? gatewayReference,
    Wrapped<String?>? gatewayName,
    Wrapped<enums.OrderStatusEnum?>? status,
    Wrapped<String?>? paymentMethod,
    Wrapped<List<OrderItem>?>? items,
    Wrapped<DateTime?>? createdAt,
    Wrapped<DateTime?>? completedAt,
  }) {
    return Order(
      id: (id != null ? id.value : this.id),
      totalAmount: (totalAmount != null ? totalAmount.value : this.totalAmount),
      gatewayReference: (gatewayReference != null
          ? gatewayReference.value
          : this.gatewayReference),
      gatewayName: (gatewayName != null ? gatewayName.value : this.gatewayName),
      status: (status != null ? status.value : this.status),
      paymentMethod: (paymentMethod != null
          ? paymentMethod.value
          : this.paymentMethod),
      items: (items != null ? items.value : this.items),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
      completedAt: (completedAt != null ? completedAt.value : this.completedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class OrderItem {
  const OrderItem({
    this.id,
    this.course,
    this.courseTitle,
    this.courseSlug,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  static const toJsonFactory = _$OrderItemToJson;
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'course')
  final String? course;
  @JsonKey(name: 'course_title')
  final String? courseTitle;
  @JsonKey(name: 'course_slug')
  final String? courseSlug;
  @JsonKey(name: 'price_at_purchase')
  final String priceAtPurchase;
  static const fromJsonFactory = _$OrderItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OrderItem &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.course, course) ||
                const DeepCollectionEquality().equals(other.course, course)) &&
            (identical(other.courseTitle, courseTitle) ||
                const DeepCollectionEquality().equals(
                  other.courseTitle,
                  courseTitle,
                )) &&
            (identical(other.courseSlug, courseSlug) ||
                const DeepCollectionEquality().equals(
                  other.courseSlug,
                  courseSlug,
                )) &&
            (identical(other.priceAtPurchase, priceAtPurchase) ||
                const DeepCollectionEquality().equals(
                  other.priceAtPurchase,
                  priceAtPurchase,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(course) ^
      const DeepCollectionEquality().hash(courseTitle) ^
      const DeepCollectionEquality().hash(courseSlug) ^
      const DeepCollectionEquality().hash(priceAtPurchase) ^
      runtimeType.hashCode;
}

extension $OrderItemExtension on OrderItem {
  OrderItem copyWith({
    String? id,
    String? course,
    String? courseTitle,
    String? courseSlug,
    String? priceAtPurchase,
  }) {
    return OrderItem(
      id: id ?? this.id,
      course: course ?? this.course,
      courseTitle: courseTitle ?? this.courseTitle,
      courseSlug: courseSlug ?? this.courseSlug,
      priceAtPurchase: priceAtPurchase ?? this.priceAtPurchase,
    );
  }

  OrderItem copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? course,
    Wrapped<String?>? courseTitle,
    Wrapped<String?>? courseSlug,
    Wrapped<String>? priceAtPurchase,
  }) {
    return OrderItem(
      id: (id != null ? id.value : this.id),
      course: (course != null ? course.value : this.course),
      courseTitle: (courseTitle != null ? courseTitle.value : this.courseTitle),
      courseSlug: (courseSlug != null ? courseSlug.value : this.courseSlug),
      priceAtPurchase: (priceAtPurchase != null
          ? priceAtPurchase.value
          : this.priceAtPurchase),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedAdminUserList {
  const PaginatedAdminUserList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedAdminUserList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedAdminUserListFromJson(json);

  static const toJsonFactory = _$PaginatedAdminUserListToJson;
  Map<String, dynamic> toJson() => _$PaginatedAdminUserListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <AdminUser>[])
  final List<AdminUser> results;
  static const fromJsonFactory = _$PaginatedAdminUserListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedAdminUserList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedAdminUserListExtension on PaginatedAdminUserList {
  PaginatedAdminUserList copyWith({
    int? count,
    String? next,
    String? previous,
    List<AdminUser>? results,
  }) {
    return PaginatedAdminUserList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedAdminUserList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<AdminUser>>? results,
  }) {
    return PaginatedAdminUserList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCategoryAdminList {
  const PaginatedCategoryAdminList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCategoryAdminList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCategoryAdminListFromJson(json);

  static const toJsonFactory = _$PaginatedCategoryAdminListToJson;
  Map<String, dynamic> toJson() => _$PaginatedCategoryAdminListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <CategoryAdmin>[])
  final List<CategoryAdmin> results;
  static const fromJsonFactory = _$PaginatedCategoryAdminListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCategoryAdminList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCategoryAdminListExtension on PaginatedCategoryAdminList {
  PaginatedCategoryAdminList copyWith({
    int? count,
    String? next,
    String? previous,
    List<CategoryAdmin>? results,
  }) {
    return PaginatedCategoryAdminList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCategoryAdminList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<CategoryAdmin>>? results,
  }) {
    return PaginatedCategoryAdminList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCategoryList {
  const PaginatedCategoryList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCategoryList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCategoryListFromJson(json);

  static const toJsonFactory = _$PaginatedCategoryListToJson;
  Map<String, dynamic> toJson() => _$PaginatedCategoryListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <Category>[])
  final List<Category> results;
  static const fromJsonFactory = _$PaginatedCategoryListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCategoryList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCategoryListExtension on PaginatedCategoryList {
  PaginatedCategoryList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Category>? results,
  }) {
    return PaginatedCategoryList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCategoryList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Category>>? results,
  }) {
    return PaginatedCategoryList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCertificateTemplateList {
  const PaginatedCertificateTemplateList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCertificateTemplateList.fromJson(
    Map<String, dynamic> json,
  ) => _$PaginatedCertificateTemplateListFromJson(json);

  static const toJsonFactory = _$PaginatedCertificateTemplateListToJson;
  Map<String, dynamic> toJson() =>
      _$PaginatedCertificateTemplateListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <CertificateTemplate>[])
  final List<CertificateTemplate> results;
  static const fromJsonFactory = _$PaginatedCertificateTemplateListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCertificateTemplateList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCertificateTemplateListExtension
    on PaginatedCertificateTemplateList {
  PaginatedCertificateTemplateList copyWith({
    int? count,
    String? next,
    String? previous,
    List<CertificateTemplate>? results,
  }) {
    return PaginatedCertificateTemplateList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCertificateTemplateList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<CertificateTemplate>>? results,
  }) {
    return PaginatedCertificateTemplateList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCourseDetailList {
  const PaginatedCourseDetailList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCourseDetailList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCourseDetailListFromJson(json);

  static const toJsonFactory = _$PaginatedCourseDetailListToJson;
  Map<String, dynamic> toJson() => _$PaginatedCourseDetailListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <CourseDetail>[])
  final List<CourseDetail> results;
  static const fromJsonFactory = _$PaginatedCourseDetailListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCourseDetailList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCourseDetailListExtension on PaginatedCourseDetailList {
  PaginatedCourseDetailList copyWith({
    int? count,
    String? next,
    String? previous,
    List<CourseDetail>? results,
  }) {
    return PaginatedCourseDetailList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCourseDetailList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<CourseDetail>>? results,
  }) {
    return PaginatedCourseDetailList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCourseListList {
  const PaginatedCourseListList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCourseListList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCourseListListFromJson(json);

  static const toJsonFactory = _$PaginatedCourseListListToJson;
  Map<String, dynamic> toJson() => _$PaginatedCourseListListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <CourseList>[])
  final List<CourseList> results;
  static const fromJsonFactory = _$PaginatedCourseListListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCourseListList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCourseListListExtension on PaginatedCourseListList {
  PaginatedCourseListList copyWith({
    int? count,
    String? next,
    String? previous,
    List<CourseList>? results,
  }) {
    return PaginatedCourseListList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCourseListList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<CourseList>>? results,
  }) {
    return PaginatedCourseListList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedCourseSectionList {
  const PaginatedCourseSectionList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCourseSectionList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCourseSectionListFromJson(json);

  static const toJsonFactory = _$PaginatedCourseSectionListToJson;
  Map<String, dynamic> toJson() => _$PaginatedCourseSectionListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <CourseSection>[])
  final List<CourseSection> results;
  static const fromJsonFactory = _$PaginatedCourseSectionListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedCourseSectionList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedCourseSectionListExtension on PaginatedCourseSectionList {
  PaginatedCourseSectionList copyWith({
    int? count,
    String? next,
    String? previous,
    List<CourseSection>? results,
  }) {
    return PaginatedCourseSectionList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedCourseSectionList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<CourseSection>>? results,
  }) {
    return PaginatedCourseSectionList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedEBookList {
  const PaginatedEBookList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedEBookList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedEBookListFromJson(json);

  static const toJsonFactory = _$PaginatedEBookListToJson;
  Map<String, dynamic> toJson() => _$PaginatedEBookListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <EBook>[])
  final List<EBook> results;
  static const fromJsonFactory = _$PaginatedEBookListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedEBookList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedEBookListExtension on PaginatedEBookList {
  PaginatedEBookList copyWith({
    int? count,
    String? next,
    String? previous,
    List<EBook>? results,
  }) {
    return PaginatedEBookList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedEBookList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<EBook>>? results,
  }) {
    return PaginatedEBookList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedEnrollmentList {
  const PaginatedEnrollmentList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedEnrollmentList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedEnrollmentListFromJson(json);

  static const toJsonFactory = _$PaginatedEnrollmentListToJson;
  Map<String, dynamic> toJson() => _$PaginatedEnrollmentListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <Enrollment>[])
  final List<Enrollment> results;
  static const fromJsonFactory = _$PaginatedEnrollmentListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedEnrollmentList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedEnrollmentListExtension on PaginatedEnrollmentList {
  PaginatedEnrollmentList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Enrollment>? results,
  }) {
    return PaginatedEnrollmentList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedEnrollmentList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Enrollment>>? results,
  }) {
    return PaginatedEnrollmentList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedLectureList {
  const PaginatedLectureList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedLectureList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedLectureListFromJson(json);

  static const toJsonFactory = _$PaginatedLectureListToJson;
  Map<String, dynamic> toJson() => _$PaginatedLectureListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <Lecture>[])
  final List<Lecture> results;
  static const fromJsonFactory = _$PaginatedLectureListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedLectureList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedLectureListExtension on PaginatedLectureList {
  PaginatedLectureList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Lecture>? results,
  }) {
    return PaginatedLectureList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedLectureList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Lecture>>? results,
  }) {
    return PaginatedLectureList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedModerationLogList {
  const PaginatedModerationLogList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedModerationLogList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedModerationLogListFromJson(json);

  static const toJsonFactory = _$PaginatedModerationLogListToJson;
  Map<String, dynamic> toJson() => _$PaginatedModerationLogListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <ModerationLog>[])
  final List<ModerationLog> results;
  static const fromJsonFactory = _$PaginatedModerationLogListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedModerationLogList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedModerationLogListExtension on PaginatedModerationLogList {
  PaginatedModerationLogList copyWith({
    int? count,
    String? next,
    String? previous,
    List<ModerationLog>? results,
  }) {
    return PaginatedModerationLogList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedModerationLogList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<ModerationLog>>? results,
  }) {
    return PaginatedModerationLogList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PaginatedOrderList {
  const PaginatedOrderList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedOrderList.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOrderListFromJson(json);

  static const toJsonFactory = _$PaginatedOrderListToJson;
  Map<String, dynamic> toJson() => _$PaginatedOrderListToJson(this);

  @JsonKey(name: 'count')
  final int count;
  @JsonKey(name: 'next')
  final String? next;
  @JsonKey(name: 'previous')
  final String? previous;
  @JsonKey(name: 'results', defaultValue: <Order>[])
  final List<Order> results;
  static const fromJsonFactory = _$PaginatedOrderListFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PaginatedOrderList &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.next, next) ||
                const DeepCollectionEquality().equals(other.next, next)) &&
            (identical(other.previous, previous) ||
                const DeepCollectionEquality().equals(
                  other.previous,
                  previous,
                )) &&
            (identical(other.results, results) ||
                const DeepCollectionEquality().equals(other.results, results)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(next) ^
      const DeepCollectionEquality().hash(previous) ^
      const DeepCollectionEquality().hash(results) ^
      runtimeType.hashCode;
}

extension $PaginatedOrderListExtension on PaginatedOrderList {
  PaginatedOrderList copyWith({
    int? count,
    String? next,
    String? previous,
    List<Order>? results,
  }) {
    return PaginatedOrderList(
      count: count ?? this.count,
      next: next ?? this.next,
      previous: previous ?? this.previous,
      results: results ?? this.results,
    );
  }

  PaginatedOrderList copyWithWrapped({
    Wrapped<int>? count,
    Wrapped<String?>? next,
    Wrapped<String?>? previous,
    Wrapped<List<Order>>? results,
  }) {
    return PaginatedOrderList(
      count: (count != null ? count.value : this.count),
      next: (next != null ? next.value : this.next),
      previous: (previous != null ? previous.value : this.previous),
      results: (results != null ? results.value : this.results),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedAdminUserRequest {
  const PatchedAdminUserRequest({
    this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.isActive,
    this.isStaff,
    this.isSuperuser,
    this.password,
  });

  factory PatchedAdminUserRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedAdminUserRequestFromJson(json);

  static const toJsonFactory = _$PatchedAdminUserRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedAdminUserRequestToJson(this);

  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'is_staff')
  final bool? isStaff;
  @JsonKey(name: 'is_superuser')
  final bool? isSuperuser;
  @JsonKey(name: 'password')
  final String? password;
  static const fromJsonFactory = _$PatchedAdminUserRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedAdminUserRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.isStaff, isStaff) ||
                const DeepCollectionEquality().equals(
                  other.isStaff,
                  isStaff,
                )) &&
            (identical(other.isSuperuser, isSuperuser) ||
                const DeepCollectionEquality().equals(
                  other.isSuperuser,
                  isSuperuser,
                )) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(isStaff) ^
      const DeepCollectionEquality().hash(isSuperuser) ^
      const DeepCollectionEquality().hash(password) ^
      runtimeType.hashCode;
}

extension $PatchedAdminUserRequestExtension on PatchedAdminUserRequest {
  PatchedAdminUserRequest copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? password,
  }) {
    return PatchedAdminUserRequest(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      password: password ?? this.password,
    );
  }

  PatchedAdminUserRequest copyWithWrapped({
    Wrapped<String?>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
    Wrapped<bool?>? isActive,
    Wrapped<bool?>? isStaff,
    Wrapped<bool?>? isSuperuser,
    Wrapped<String?>? password,
  }) {
    return PatchedAdminUserRequest(
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
      isActive: (isActive != null ? isActive.value : this.isActive),
      isStaff: (isStaff != null ? isStaff.value : this.isStaff),
      isSuperuser: (isSuperuser != null ? isSuperuser.value : this.isSuperuser),
      password: (password != null ? password.value : this.password),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedCategoryAdminRequest {
  const PatchedCategoryAdminRequest({
    this.slug,
    this.contentType,
    this.isActive,
    this.sortOrder,
    this.nameEn,
    this.descriptionEn,
    this.nameHi,
    this.descriptionHi,
    this.nameMr,
    this.descriptionMr,
  });

  factory PatchedCategoryAdminRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedCategoryAdminRequestFromJson(json);

  static const toJsonFactory = _$PatchedCategoryAdminRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedCategoryAdminRequestToJson(this);

  @JsonKey(name: 'slug')
  final String? slug;
  @JsonKey(
    name: 'content_type',
    toJson: contentTypeEnumNullableToJson,
    fromJson: contentTypeEnumNullableFromJson,
  )
  final enums.ContentTypeEnum? contentType;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'name_en')
  final String? nameEn;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @JsonKey(name: 'name_hi')
  final String? nameHi;
  @JsonKey(name: 'description_hi')
  final String? descriptionHi;
  @JsonKey(name: 'name_mr')
  final String? nameMr;
  @JsonKey(name: 'description_mr')
  final String? descriptionMr;
  static const fromJsonFactory = _$PatchedCategoryAdminRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedCategoryAdminRequest &&
            (identical(other.slug, slug) ||
                const DeepCollectionEquality().equals(other.slug, slug)) &&
            (identical(other.contentType, contentType) ||
                const DeepCollectionEquality().equals(
                  other.contentType,
                  contentType,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.nameEn, nameEn) ||
                const DeepCollectionEquality().equals(other.nameEn, nameEn)) &&
            (identical(other.descriptionEn, descriptionEn) ||
                const DeepCollectionEquality().equals(
                  other.descriptionEn,
                  descriptionEn,
                )) &&
            (identical(other.nameHi, nameHi) ||
                const DeepCollectionEquality().equals(other.nameHi, nameHi)) &&
            (identical(other.descriptionHi, descriptionHi) ||
                const DeepCollectionEquality().equals(
                  other.descriptionHi,
                  descriptionHi,
                )) &&
            (identical(other.nameMr, nameMr) ||
                const DeepCollectionEquality().equals(other.nameMr, nameMr)) &&
            (identical(other.descriptionMr, descriptionMr) ||
                const DeepCollectionEquality().equals(
                  other.descriptionMr,
                  descriptionMr,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(slug) ^
      const DeepCollectionEquality().hash(contentType) ^
      const DeepCollectionEquality().hash(isActive) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(nameEn) ^
      const DeepCollectionEquality().hash(descriptionEn) ^
      const DeepCollectionEquality().hash(nameHi) ^
      const DeepCollectionEquality().hash(descriptionHi) ^
      const DeepCollectionEquality().hash(nameMr) ^
      const DeepCollectionEquality().hash(descriptionMr) ^
      runtimeType.hashCode;
}

extension $PatchedCategoryAdminRequestExtension on PatchedCategoryAdminRequest {
  PatchedCategoryAdminRequest copyWith({
    String? slug,
    enums.ContentTypeEnum? contentType,
    bool? isActive,
    int? sortOrder,
    String? nameEn,
    String? descriptionEn,
    String? nameHi,
    String? descriptionHi,
    String? nameMr,
    String? descriptionMr,
  }) {
    return PatchedCategoryAdminRequest(
      slug: slug ?? this.slug,
      contentType: contentType ?? this.contentType,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      nameEn: nameEn ?? this.nameEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      nameHi: nameHi ?? this.nameHi,
      descriptionHi: descriptionHi ?? this.descriptionHi,
      nameMr: nameMr ?? this.nameMr,
      descriptionMr: descriptionMr ?? this.descriptionMr,
    );
  }

  PatchedCategoryAdminRequest copyWithWrapped({
    Wrapped<String?>? slug,
    Wrapped<enums.ContentTypeEnum?>? contentType,
    Wrapped<bool?>? isActive,
    Wrapped<int?>? sortOrder,
    Wrapped<String?>? nameEn,
    Wrapped<String?>? descriptionEn,
    Wrapped<String?>? nameHi,
    Wrapped<String?>? descriptionHi,
    Wrapped<String?>? nameMr,
    Wrapped<String?>? descriptionMr,
  }) {
    return PatchedCategoryAdminRequest(
      slug: (slug != null ? slug.value : this.slug),
      contentType: (contentType != null ? contentType.value : this.contentType),
      isActive: (isActive != null ? isActive.value : this.isActive),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      nameEn: (nameEn != null ? nameEn.value : this.nameEn),
      descriptionEn: (descriptionEn != null
          ? descriptionEn.value
          : this.descriptionEn),
      nameHi: (nameHi != null ? nameHi.value : this.nameHi),
      descriptionHi: (descriptionHi != null
          ? descriptionHi.value
          : this.descriptionHi),
      nameMr: (nameMr != null ? nameMr.value : this.nameMr),
      descriptionMr: (descriptionMr != null
          ? descriptionMr.value
          : this.descriptionMr),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedCertificateTemplateRequest {
  const PatchedCertificateTemplateRequest({
    this.title,
    this.templateImage,
    this.isActive,
  });

  factory PatchedCertificateTemplateRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PatchedCertificateTemplateRequestFromJson(json);

  static const toJsonFactory = _$PatchedCertificateTemplateRequestToJson;
  Map<String, dynamic> toJson() =>
      _$PatchedCertificateTemplateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'template_image')
  final String? templateImage;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  static const fromJsonFactory = _$PatchedCertificateTemplateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedCertificateTemplateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.templateImage, templateImage) ||
                const DeepCollectionEquality().equals(
                  other.templateImage,
                  templateImage,
                )) &&
            (identical(other.isActive, isActive) ||
                const DeepCollectionEquality().equals(
                  other.isActive,
                  isActive,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(templateImage) ^
      const DeepCollectionEquality().hash(isActive) ^
      runtimeType.hashCode;
}

extension $PatchedCertificateTemplateRequestExtension
    on PatchedCertificateTemplateRequest {
  PatchedCertificateTemplateRequest copyWith({
    String? title,
    String? templateImage,
    bool? isActive,
  }) {
    return PatchedCertificateTemplateRequest(
      title: title ?? this.title,
      templateImage: templateImage ?? this.templateImage,
      isActive: isActive ?? this.isActive,
    );
  }

  PatchedCertificateTemplateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String?>? templateImage,
    Wrapped<bool?>? isActive,
  }) {
    return PatchedCertificateTemplateRequest(
      title: (title != null ? title.value : this.title),
      templateImage: (templateImage != null
          ? templateImage.value
          : this.templateImage),
      isActive: (isActive != null ? isActive.value : this.isActive),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedCourseCreateRequest {
  const PatchedCourseCreateRequest({
    this.title,
    this.description,
    this.shortDescription,
    this.categoryId,
    this.level,
    this.price,
    this.thumbnail,
    this.previewVideoUrl,
    this.language,
    this.whatYouLearn,
    this.requirements,
    this.tags,
  });

  factory PatchedCourseCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedCourseCreateRequestFromJson(json);

  static const toJsonFactory = _$PatchedCourseCreateRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedCourseCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'short_description')
  final String? shortDescription;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(
    name: 'level',
    toJson: levelEnumNullableToJson,
    fromJson: levelEnumNullableFromJson,
  )
  final enums.LevelEnum? level;
  @JsonKey(name: 'price')
  final String? price;
  @JsonKey(name: 'thumbnail')
  final String? thumbnail;
  @JsonKey(name: 'preview_video_url')
  final String? previewVideoUrl;
  @JsonKey(name: 'language')
  final String? language;
  @JsonKey(name: 'what_you_learn')
  final String? whatYouLearn;
  @JsonKey(name: 'requirements')
  final String? requirements;
  @JsonKey(name: 'tags')
  final String? tags;
  static const fromJsonFactory = _$PatchedCourseCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedCourseCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.shortDescription, shortDescription) ||
                const DeepCollectionEquality().equals(
                  other.shortDescription,
                  shortDescription,
                )) &&
            (identical(other.categoryId, categoryId) ||
                const DeepCollectionEquality().equals(
                  other.categoryId,
                  categoryId,
                )) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.price, price) ||
                const DeepCollectionEquality().equals(other.price, price)) &&
            (identical(other.thumbnail, thumbnail) ||
                const DeepCollectionEquality().equals(
                  other.thumbnail,
                  thumbnail,
                )) &&
            (identical(other.previewVideoUrl, previewVideoUrl) ||
                const DeepCollectionEquality().equals(
                  other.previewVideoUrl,
                  previewVideoUrl,
                )) &&
            (identical(other.language, language) ||
                const DeepCollectionEquality().equals(
                  other.language,
                  language,
                )) &&
            (identical(other.whatYouLearn, whatYouLearn) ||
                const DeepCollectionEquality().equals(
                  other.whatYouLearn,
                  whatYouLearn,
                )) &&
            (identical(other.requirements, requirements) ||
                const DeepCollectionEquality().equals(
                  other.requirements,
                  requirements,
                )) &&
            (identical(other.tags, tags) ||
                const DeepCollectionEquality().equals(other.tags, tags)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(shortDescription) ^
      const DeepCollectionEquality().hash(categoryId) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(price) ^
      const DeepCollectionEquality().hash(thumbnail) ^
      const DeepCollectionEquality().hash(previewVideoUrl) ^
      const DeepCollectionEquality().hash(language) ^
      const DeepCollectionEquality().hash(whatYouLearn) ^
      const DeepCollectionEquality().hash(requirements) ^
      const DeepCollectionEquality().hash(tags) ^
      runtimeType.hashCode;
}

extension $PatchedCourseCreateRequestExtension on PatchedCourseCreateRequest {
  PatchedCourseCreateRequest copyWith({
    String? title,
    String? description,
    String? shortDescription,
    String? categoryId,
    enums.LevelEnum? level,
    String? price,
    String? thumbnail,
    String? previewVideoUrl,
    String? language,
    String? whatYouLearn,
    String? requirements,
    String? tags,
  }) {
    return PatchedCourseCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      categoryId: categoryId ?? this.categoryId,
      level: level ?? this.level,
      price: price ?? this.price,
      thumbnail: thumbnail ?? this.thumbnail,
      previewVideoUrl: previewVideoUrl ?? this.previewVideoUrl,
      language: language ?? this.language,
      whatYouLearn: whatYouLearn ?? this.whatYouLearn,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
    );
  }

  PatchedCourseCreateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? shortDescription,
    Wrapped<String?>? categoryId,
    Wrapped<enums.LevelEnum?>? level,
    Wrapped<String?>? price,
    Wrapped<String?>? thumbnail,
    Wrapped<String?>? previewVideoUrl,
    Wrapped<String?>? language,
    Wrapped<String?>? whatYouLearn,
    Wrapped<String?>? requirements,
    Wrapped<String?>? tags,
  }) {
    return PatchedCourseCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      shortDescription: (shortDescription != null
          ? shortDescription.value
          : this.shortDescription),
      categoryId: (categoryId != null ? categoryId.value : this.categoryId),
      level: (level != null ? level.value : this.level),
      price: (price != null ? price.value : this.price),
      thumbnail: (thumbnail != null ? thumbnail.value : this.thumbnail),
      previewVideoUrl: (previewVideoUrl != null
          ? previewVideoUrl.value
          : this.previewVideoUrl),
      language: (language != null ? language.value : this.language),
      whatYouLearn: (whatYouLearn != null
          ? whatYouLearn.value
          : this.whatYouLearn),
      requirements: (requirements != null
          ? requirements.value
          : this.requirements),
      tags: (tags != null ? tags.value : this.tags),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedCourseSectionCreateRequest {
  const PatchedCourseSectionCreateRequest({
    this.title,
    this.description,
    this.sortOrder,
  });

  factory PatchedCourseSectionCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$PatchedCourseSectionCreateRequestFromJson(json);

  static const toJsonFactory = _$PatchedCourseSectionCreateRequestToJson;
  Map<String, dynamic> toJson() =>
      _$PatchedCourseSectionCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  static const fromJsonFactory = _$PatchedCourseSectionCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedCourseSectionCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      runtimeType.hashCode;
}

extension $PatchedCourseSectionCreateRequestExtension
    on PatchedCourseSectionCreateRequest {
  PatchedCourseSectionCreateRequest copyWith({
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return PatchedCourseSectionCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  PatchedCourseSectionCreateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String?>? description,
    Wrapped<int?>? sortOrder,
  }) {
    return PatchedCourseSectionCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedEBookCreateUpdateRequest {
  const PatchedEBookCreateUpdateRequest({
    this.title,
    this.description,
    this.authorName,
    this.coverImage,
    this.pdfFile,
    this.categoryId,
  });

  factory PatchedEBookCreateUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedEBookCreateUpdateRequestFromJson(json);

  static const toJsonFactory = _$PatchedEBookCreateUpdateRequestToJson;
  Map<String, dynamic> toJson() =>
      _$PatchedEBookCreateUpdateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String? pdfFile;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  static const fromJsonFactory = _$PatchedEBookCreateUpdateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedEBookCreateUpdateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(
                  other.pdfFile,
                  pdfFile,
                )) &&
            (identical(other.categoryId, categoryId) ||
                const DeepCollectionEquality().equals(
                  other.categoryId,
                  categoryId,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      const DeepCollectionEquality().hash(categoryId) ^
      runtimeType.hashCode;
}

extension $PatchedEBookCreateUpdateRequestExtension
    on PatchedEBookCreateUpdateRequest {
  PatchedEBookCreateUpdateRequest copyWith({
    String? title,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
    String? categoryId,
  }) {
    return PatchedEBookCreateUpdateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  PatchedEBookCreateUpdateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String?>? pdfFile,
    Wrapped<String?>? categoryId,
  }) {
    return PatchedEBookCreateUpdateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
      categoryId: (categoryId != null ? categoryId.value : this.categoryId),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedEBookRequest {
  const PatchedEBookRequest({
    this.instructor,
    this.title,
    this.description,
    this.authorName,
    this.coverImage,
    this.pdfFile,
  });

  factory PatchedEBookRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedEBookRequestFromJson(json);

  static const toJsonFactory = _$PatchedEBookRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedEBookRequestToJson(this);

  @JsonKey(name: 'instructor')
  final String? instructor;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'cover_image')
  final String? coverImage;
  @JsonKey(name: 'pdf_file')
  final String? pdfFile;
  static const fromJsonFactory = _$PatchedEBookRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedEBookRequest &&
            (identical(other.instructor, instructor) ||
                const DeepCollectionEquality().equals(
                  other.instructor,
                  instructor,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.authorName, authorName) ||
                const DeepCollectionEquality().equals(
                  other.authorName,
                  authorName,
                )) &&
            (identical(other.coverImage, coverImage) ||
                const DeepCollectionEquality().equals(
                  other.coverImage,
                  coverImage,
                )) &&
            (identical(other.pdfFile, pdfFile) ||
                const DeepCollectionEquality().equals(other.pdfFile, pdfFile)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(instructor) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(authorName) ^
      const DeepCollectionEquality().hash(coverImage) ^
      const DeepCollectionEquality().hash(pdfFile) ^
      runtimeType.hashCode;
}

extension $PatchedEBookRequestExtension on PatchedEBookRequest {
  PatchedEBookRequest copyWith({
    String? instructor,
    String? title,
    String? description,
    String? authorName,
    String? coverImage,
    String? pdfFile,
  }) {
    return PatchedEBookRequest(
      instructor: instructor ?? this.instructor,
      title: title ?? this.title,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      coverImage: coverImage ?? this.coverImage,
      pdfFile: pdfFile ?? this.pdfFile,
    );
  }

  PatchedEBookRequest copyWithWrapped({
    Wrapped<String?>? instructor,
    Wrapped<String?>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? authorName,
    Wrapped<String?>? coverImage,
    Wrapped<String?>? pdfFile,
  }) {
    return PatchedEBookRequest(
      instructor: (instructor != null ? instructor.value : this.instructor),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      authorName: (authorName != null ? authorName.value : this.authorName),
      coverImage: (coverImage != null ? coverImage.value : this.coverImage),
      pdfFile: (pdfFile != null ? pdfFile.value : this.pdfFile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedInstructorProfileRequest {
  const PatchedInstructorProfileRequest({
    this.bio,
    this.expertiseTags,
    this.website,
    this.yearsOfExperience,
    this.specialtyCrops,
    this.socialLink,
    this.qualifications,
    this.currentOccupation,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.kycDocumentType,
    this.kycDocumentNumber,
    this.kycDocumentImage,
  });

  factory PatchedInstructorProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedInstructorProfileRequestFromJson(json);

  static const toJsonFactory = _$PatchedInstructorProfileRequestToJson;
  Map<String, dynamic> toJson() =>
      _$PatchedInstructorProfileRequestToJson(this);

  @JsonKey(name: 'bio')
  final String? bio;
  @JsonKey(name: 'expertise_tags')
  final String? expertiseTags;
  @JsonKey(name: 'website')
  final String? website;
  @JsonKey(name: 'years_of_experience')
  final int? yearsOfExperience;
  @JsonKey(name: 'specialty_crops')
  final String? specialtyCrops;
  @JsonKey(name: 'social_link')
  final String? socialLink;
  @JsonKey(name: 'qualifications')
  final String? qualifications;
  @JsonKey(name: 'current_occupation')
  final String? currentOccupation;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_account_name')
  final String? bankAccountName;
  @JsonKey(name: 'bank_account_number')
  final String? bankAccountNumber;
  @JsonKey(name: 'bank_ifsc_code')
  final String? bankIfscCode;
  @JsonKey(name: 'kyc_document_type')
  final dynamic kycDocumentType;
  @JsonKey(name: 'kyc_document_number')
  final String? kycDocumentNumber;
  @JsonKey(name: 'kyc_document_image')
  final String? kycDocumentImage;
  static const fromJsonFactory = _$PatchedInstructorProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedInstructorProfileRequest &&
            (identical(other.bio, bio) ||
                const DeepCollectionEquality().equals(other.bio, bio)) &&
            (identical(other.expertiseTags, expertiseTags) ||
                const DeepCollectionEquality().equals(
                  other.expertiseTags,
                  expertiseTags,
                )) &&
            (identical(other.website, website) ||
                const DeepCollectionEquality().equals(
                  other.website,
                  website,
                )) &&
            (identical(other.yearsOfExperience, yearsOfExperience) ||
                const DeepCollectionEquality().equals(
                  other.yearsOfExperience,
                  yearsOfExperience,
                )) &&
            (identical(other.specialtyCrops, specialtyCrops) ||
                const DeepCollectionEquality().equals(
                  other.specialtyCrops,
                  specialtyCrops,
                )) &&
            (identical(other.socialLink, socialLink) ||
                const DeepCollectionEquality().equals(
                  other.socialLink,
                  socialLink,
                )) &&
            (identical(other.qualifications, qualifications) ||
                const DeepCollectionEquality().equals(
                  other.qualifications,
                  qualifications,
                )) &&
            (identical(other.currentOccupation, currentOccupation) ||
                const DeepCollectionEquality().equals(
                  other.currentOccupation,
                  currentOccupation,
                )) &&
            (identical(other.bankName, bankName) ||
                const DeepCollectionEquality().equals(
                  other.bankName,
                  bankName,
                )) &&
            (identical(other.bankAccountName, bankAccountName) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountName,
                  bankAccountName,
                )) &&
            (identical(other.bankAccountNumber, bankAccountNumber) ||
                const DeepCollectionEquality().equals(
                  other.bankAccountNumber,
                  bankAccountNumber,
                )) &&
            (identical(other.bankIfscCode, bankIfscCode) ||
                const DeepCollectionEquality().equals(
                  other.bankIfscCode,
                  bankIfscCode,
                )) &&
            (identical(other.kycDocumentType, kycDocumentType) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentType,
                  kycDocumentType,
                )) &&
            (identical(other.kycDocumentNumber, kycDocumentNumber) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentNumber,
                  kycDocumentNumber,
                )) &&
            (identical(other.kycDocumentImage, kycDocumentImage) ||
                const DeepCollectionEquality().equals(
                  other.kycDocumentImage,
                  kycDocumentImage,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(bio) ^
      const DeepCollectionEquality().hash(expertiseTags) ^
      const DeepCollectionEquality().hash(website) ^
      const DeepCollectionEquality().hash(yearsOfExperience) ^
      const DeepCollectionEquality().hash(specialtyCrops) ^
      const DeepCollectionEquality().hash(socialLink) ^
      const DeepCollectionEquality().hash(qualifications) ^
      const DeepCollectionEquality().hash(currentOccupation) ^
      const DeepCollectionEquality().hash(bankName) ^
      const DeepCollectionEquality().hash(bankAccountName) ^
      const DeepCollectionEquality().hash(bankAccountNumber) ^
      const DeepCollectionEquality().hash(bankIfscCode) ^
      const DeepCollectionEquality().hash(kycDocumentType) ^
      const DeepCollectionEquality().hash(kycDocumentNumber) ^
      const DeepCollectionEquality().hash(kycDocumentImage) ^
      runtimeType.hashCode;
}

extension $PatchedInstructorProfileRequestExtension
    on PatchedInstructorProfileRequest {
  PatchedInstructorProfileRequest copyWith({
    String? bio,
    String? expertiseTags,
    String? website,
    int? yearsOfExperience,
    String? specialtyCrops,
    String? socialLink,
    String? qualifications,
    String? currentOccupation,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankIfscCode,
    dynamic kycDocumentType,
    String? kycDocumentNumber,
    String? kycDocumentImage,
  }) {
    return PatchedInstructorProfileRequest(
      bio: bio ?? this.bio,
      expertiseTags: expertiseTags ?? this.expertiseTags,
      website: website ?? this.website,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      specialtyCrops: specialtyCrops ?? this.specialtyCrops,
      socialLink: socialLink ?? this.socialLink,
      qualifications: qualifications ?? this.qualifications,
      currentOccupation: currentOccupation ?? this.currentOccupation,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      kycDocumentType: kycDocumentType ?? this.kycDocumentType,
      kycDocumentNumber: kycDocumentNumber ?? this.kycDocumentNumber,
      kycDocumentImage: kycDocumentImage ?? this.kycDocumentImage,
    );
  }

  PatchedInstructorProfileRequest copyWithWrapped({
    Wrapped<String?>? bio,
    Wrapped<String?>? expertiseTags,
    Wrapped<String?>? website,
    Wrapped<int?>? yearsOfExperience,
    Wrapped<String?>? specialtyCrops,
    Wrapped<String?>? socialLink,
    Wrapped<String?>? qualifications,
    Wrapped<String?>? currentOccupation,
    Wrapped<String?>? bankName,
    Wrapped<String?>? bankAccountName,
    Wrapped<String?>? bankAccountNumber,
    Wrapped<String?>? bankIfscCode,
    Wrapped<dynamic>? kycDocumentType,
    Wrapped<String?>? kycDocumentNumber,
    Wrapped<String?>? kycDocumentImage,
  }) {
    return PatchedInstructorProfileRequest(
      bio: (bio != null ? bio.value : this.bio),
      expertiseTags: (expertiseTags != null
          ? expertiseTags.value
          : this.expertiseTags),
      website: (website != null ? website.value : this.website),
      yearsOfExperience: (yearsOfExperience != null
          ? yearsOfExperience.value
          : this.yearsOfExperience),
      specialtyCrops: (specialtyCrops != null
          ? specialtyCrops.value
          : this.specialtyCrops),
      socialLink: (socialLink != null ? socialLink.value : this.socialLink),
      qualifications: (qualifications != null
          ? qualifications.value
          : this.qualifications),
      currentOccupation: (currentOccupation != null
          ? currentOccupation.value
          : this.currentOccupation),
      bankName: (bankName != null ? bankName.value : this.bankName),
      bankAccountName: (bankAccountName != null
          ? bankAccountName.value
          : this.bankAccountName),
      bankAccountNumber: (bankAccountNumber != null
          ? bankAccountNumber.value
          : this.bankAccountNumber),
      bankIfscCode: (bankIfscCode != null
          ? bankIfscCode.value
          : this.bankIfscCode),
      kycDocumentType: (kycDocumentType != null
          ? kycDocumentType.value
          : this.kycDocumentType),
      kycDocumentNumber: (kycDocumentNumber != null
          ? kycDocumentNumber.value
          : this.kycDocumentNumber),
      kycDocumentImage: (kycDocumentImage != null
          ? kycDocumentImage.value
          : this.kycDocumentImage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedLectureCreateRequest {
  const PatchedLectureCreateRequest({
    this.title,
    this.description,
    this.videoUrl,
    this.bunnyVideoId,
    this.bunnyStatus,
    this.duration,
    this.sortOrder,
    this.isPreview,
  });

  factory PatchedLectureCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedLectureCreateRequestFromJson(json);

  static const toJsonFactory = _$PatchedLectureCreateRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedLectureCreateRequestToJson(this);

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'description')
  final String? description;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'bunny_video_id')
  final String? bunnyVideoId;
  @JsonKey(
    name: 'bunny_status',
    toJson: bunnyStatusEnumNullableToJson,
    fromJson: bunnyStatusEnumNullableFromJson,
  )
  final enums.BunnyStatusEnum? bunnyStatus;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_preview')
  final bool? isPreview;
  static const fromJsonFactory = _$PatchedLectureCreateRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedLectureCreateRequest &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.videoUrl, videoUrl) ||
                const DeepCollectionEquality().equals(
                  other.videoUrl,
                  videoUrl,
                )) &&
            (identical(other.bunnyVideoId, bunnyVideoId) ||
                const DeepCollectionEquality().equals(
                  other.bunnyVideoId,
                  bunnyVideoId,
                )) &&
            (identical(other.bunnyStatus, bunnyStatus) ||
                const DeepCollectionEquality().equals(
                  other.bunnyStatus,
                  bunnyStatus,
                )) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )) &&
            (identical(other.sortOrder, sortOrder) ||
                const DeepCollectionEquality().equals(
                  other.sortOrder,
                  sortOrder,
                )) &&
            (identical(other.isPreview, isPreview) ||
                const DeepCollectionEquality().equals(
                  other.isPreview,
                  isPreview,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(videoUrl) ^
      const DeepCollectionEquality().hash(bunnyVideoId) ^
      const DeepCollectionEquality().hash(bunnyStatus) ^
      const DeepCollectionEquality().hash(duration) ^
      const DeepCollectionEquality().hash(sortOrder) ^
      const DeepCollectionEquality().hash(isPreview) ^
      runtimeType.hashCode;
}

extension $PatchedLectureCreateRequestExtension on PatchedLectureCreateRequest {
  PatchedLectureCreateRequest copyWith({
    String? title,
    String? description,
    String? videoUrl,
    String? bunnyVideoId,
    enums.BunnyStatusEnum? bunnyStatus,
    int? duration,
    int? sortOrder,
    bool? isPreview,
  }) {
    return PatchedLectureCreateRequest(
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      bunnyVideoId: bunnyVideoId ?? this.bunnyVideoId,
      bunnyStatus: bunnyStatus ?? this.bunnyStatus,
      duration: duration ?? this.duration,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreview: isPreview ?? this.isPreview,
    );
  }

  PatchedLectureCreateRequest copyWithWrapped({
    Wrapped<String?>? title,
    Wrapped<String?>? description,
    Wrapped<String?>? videoUrl,
    Wrapped<String?>? bunnyVideoId,
    Wrapped<enums.BunnyStatusEnum?>? bunnyStatus,
    Wrapped<int?>? duration,
    Wrapped<int?>? sortOrder,
    Wrapped<bool?>? isPreview,
  }) {
    return PatchedLectureCreateRequest(
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      videoUrl: (videoUrl != null ? videoUrl.value : this.videoUrl),
      bunnyVideoId: (bunnyVideoId != null
          ? bunnyVideoId.value
          : this.bunnyVideoId),
      bunnyStatus: (bunnyStatus != null ? bunnyStatus.value : this.bunnyStatus),
      duration: (duration != null ? duration.value : this.duration),
      sortOrder: (sortOrder != null ? sortOrder.value : this.sortOrder),
      isPreview: (isPreview != null ? isPreview.value : this.isPreview),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PatchedUserProfileRequest {
  const PatchedUserProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
  });

  factory PatchedUserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedUserProfileRequestFromJson(json);

  static const toJsonFactory = _$PatchedUserProfileRequestToJson;
  Map<String, dynamic> toJson() => _$PatchedUserProfileRequestToJson(this);

  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  static const fromJsonFactory = _$PatchedUserProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PatchedUserProfileRequest &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      runtimeType.hashCode;
}

extension $PatchedUserProfileRequestExtension on PatchedUserProfileRequest {
  PatchedUserProfileRequest copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
  }) {
    return PatchedUserProfileRequest(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
    );
  }

  PatchedUserProfileRequest copyWithWrapped({
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
  }) {
    return PatchedUserProfileRequest(
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class Register {
  const Register({
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
  });

  factory Register.fromJson(Map<String, dynamic> json) =>
      _$RegisterFromJson(json);

  static const toJsonFactory = _$RegisterToJson;
  Map<String, dynamic> toJson() => _$RegisterToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  static const fromJsonFactory = _$RegisterFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Register &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      runtimeType.hashCode;
}

extension $RegisterExtension on Register {
  Register copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
  }) {
    return Register(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  Register copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
  }) {
    return Register(
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class RegisterRequest {
  const RegisterRequest({
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.password,
    this.passwordConfirm,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  static const toJsonFactory = _$RegisterRequestToJson;
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  @JsonKey(name: 'password')
  final String? password;
  @JsonKey(name: 'password_confirm')
  final String? passwordConfirm;
  static const fromJsonFactory = _$RegisterRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RegisterRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.password, password) ||
                const DeepCollectionEquality().equals(
                  other.password,
                  password,
                )) &&
            (identical(other.passwordConfirm, passwordConfirm) ||
                const DeepCollectionEquality().equals(
                  other.passwordConfirm,
                  passwordConfirm,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(password) ^
      const DeepCollectionEquality().hash(passwordConfirm) ^
      runtimeType.hashCode;
}

extension $RegisterRequestExtension on RegisterRequest {
  RegisterRequest copyWith({
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
    String? password,
    String? passwordConfirm,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
    );
  }

  RegisterRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
    Wrapped<String?>? password,
    Wrapped<String?>? passwordConfirm,
  }) {
    return RegisterRequest(
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
      password: (password != null ? password.value : this.password),
      passwordConfirm: (passwordConfirm != null
          ? passwordConfirm.value
          : this.passwordConfirm),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ResendOTP {
  const ResendOTP({required this.email, this.purpose});

  factory ResendOTP.fromJson(Map<String, dynamic> json) =>
      _$ResendOTPFromJson(json);

  static const toJsonFactory = _$ResendOTPToJson;
  Map<String, dynamic> toJson() => _$ResendOTPToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(
    name: 'purpose',
    toJson: purposeEnumNullableToJson,
    fromJson: purposeEnumPurposeNullableFromJson,
  )
  final enums.PurposeEnum? purpose;
  static enums.PurposeEnum? purposeEnumPurposeNullableFromJson(Object? value) =>
      purposeEnumNullableFromJson(value, enums.PurposeEnum.passwordReset);

  static const fromJsonFactory = _$ResendOTPFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResendOTP &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.purpose, purpose) ||
                const DeepCollectionEquality().equals(other.purpose, purpose)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(purpose) ^
      runtimeType.hashCode;
}

extension $ResendOTPExtension on ResendOTP {
  ResendOTP copyWith({String? email, enums.PurposeEnum? purpose}) {
    return ResendOTP(
      email: email ?? this.email,
      purpose: purpose ?? this.purpose,
    );
  }

  ResendOTP copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<enums.PurposeEnum?>? purpose,
  }) {
    return ResendOTP(
      email: (email != null ? email.value : this.email),
      purpose: (purpose != null ? purpose.value : this.purpose),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ResendOTPRequest {
  const ResendOTPRequest({required this.email, this.purpose});

  factory ResendOTPRequest.fromJson(Map<String, dynamic> json) =>
      _$ResendOTPRequestFromJson(json);

  static const toJsonFactory = _$ResendOTPRequestToJson;
  Map<String, dynamic> toJson() => _$ResendOTPRequestToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(
    name: 'purpose',
    toJson: purposeEnumNullableToJson,
    fromJson: purposeEnumPurposeNullableFromJson,
  )
  final enums.PurposeEnum? purpose;
  static enums.PurposeEnum? purposeEnumPurposeNullableFromJson(Object? value) =>
      purposeEnumNullableFromJson(value, enums.PurposeEnum.passwordReset);

  static const fromJsonFactory = _$ResendOTPRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResendOTPRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.purpose, purpose) ||
                const DeepCollectionEquality().equals(other.purpose, purpose)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(purpose) ^
      runtimeType.hashCode;
}

extension $ResendOTPRequestExtension on ResendOTPRequest {
  ResendOTPRequest copyWith({String? email, enums.PurposeEnum? purpose}) {
    return ResendOTPRequest(
      email: email ?? this.email,
      purpose: purpose ?? this.purpose,
    );
  }

  ResendOTPRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<enums.PurposeEnum?>? purpose,
  }) {
    return ResendOTPRequest(
      email: (email != null ? email.value : this.email),
      purpose: (purpose != null ? purpose.value : this.purpose),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ResetPassword {
  const ResetPassword({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPassword.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordFromJson(json);

  static const toJsonFactory = _$ResetPasswordToJson;
  Map<String, dynamic> toJson() => _$ResetPasswordToJson(this);

  @JsonKey(name: 'reset_token')
  final String resetToken;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  static const fromJsonFactory = _$ResetPasswordFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResetPassword &&
            (identical(other.resetToken, resetToken) ||
                const DeepCollectionEquality().equals(
                  other.resetToken,
                  resetToken,
                )) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )) &&
            (identical(other.confirmPassword, confirmPassword) ||
                const DeepCollectionEquality().equals(
                  other.confirmPassword,
                  confirmPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(resetToken) ^
      const DeepCollectionEquality().hash(newPassword) ^
      const DeepCollectionEquality().hash(confirmPassword) ^
      runtimeType.hashCode;
}

extension $ResetPasswordExtension on ResetPassword {
  ResetPassword copyWith({
    String? resetToken,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ResetPassword(
      resetToken: resetToken ?? this.resetToken,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  ResetPassword copyWithWrapped({
    Wrapped<String>? resetToken,
    Wrapped<String>? newPassword,
    Wrapped<String>? confirmPassword,
  }) {
    return ResetPassword(
      resetToken: (resetToken != null ? resetToken.value : this.resetToken),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
      confirmPassword: (confirmPassword != null
          ? confirmPassword.value
          : this.confirmPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);

  static const toJsonFactory = _$ResetPasswordRequestToJson;
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);

  @JsonKey(name: 'reset_token')
  final String resetToken;
  @JsonKey(name: 'new_password')
  final String newPassword;
  @JsonKey(name: 'confirm_password')
  final String confirmPassword;
  static const fromJsonFactory = _$ResetPasswordRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ResetPasswordRequest &&
            (identical(other.resetToken, resetToken) ||
                const DeepCollectionEquality().equals(
                  other.resetToken,
                  resetToken,
                )) &&
            (identical(other.newPassword, newPassword) ||
                const DeepCollectionEquality().equals(
                  other.newPassword,
                  newPassword,
                )) &&
            (identical(other.confirmPassword, confirmPassword) ||
                const DeepCollectionEquality().equals(
                  other.confirmPassword,
                  confirmPassword,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(resetToken) ^
      const DeepCollectionEquality().hash(newPassword) ^
      const DeepCollectionEquality().hash(confirmPassword) ^
      runtimeType.hashCode;
}

extension $ResetPasswordRequestExtension on ResetPasswordRequest {
  ResetPasswordRequest copyWith({
    String? resetToken,
    String? newPassword,
    String? confirmPassword,
  }) {
    return ResetPasswordRequest(
      resetToken: resetToken ?? this.resetToken,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  ResetPasswordRequest copyWithWrapped({
    Wrapped<String>? resetToken,
    Wrapped<String>? newPassword,
    Wrapped<String>? confirmPassword,
  }) {
    return ResetPasswordRequest(
      resetToken: (resetToken != null ? resetToken.value : this.resetToken),
      newPassword: (newPassword != null ? newPassword.value : this.newPassword),
      confirmPassword: (confirmPassword != null
          ? confirmPassword.value
          : this.confirmPassword),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class StudentNotification {
  const StudentNotification({
    this.id,
    required this.notificationType,
    required this.title,
    required this.message,
    this.course,
    this.courseSlug,
    this.courseTitle,
    this.ebook,
    this.ebookId,
    this.ebookTitle,
    this.isRead,
    this.createdAt,
  });

  factory StudentNotification.fromJson(Map<String, dynamic> json) =>
      _$StudentNotificationFromJson(json);

  static const toJsonFactory = _$StudentNotificationToJson;
  Map<String, dynamic> toJson() => _$StudentNotificationToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(
    name: 'notification_type',
    toJson: studentNotificationNotificationTypeEnumToJson,
    fromJson: studentNotificationNotificationTypeEnumFromJson,
  )
  final enums.StudentNotificationNotificationTypeEnum notificationType;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'course')
  final String? course;
  @JsonKey(name: 'course_slug')
  final String? courseSlug;
  @JsonKey(name: 'course_title')
  final String? courseTitle;
  @JsonKey(name: 'ebook')
  final String? ebook;
  @JsonKey(name: 'ebook_id')
  final String? ebookId;
  @JsonKey(name: 'ebook_title')
  final String? ebookTitle;
  @JsonKey(name: 'is_read')
  final bool? isRead;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  static const fromJsonFactory = _$StudentNotificationFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is StudentNotification &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.notificationType, notificationType) ||
                const DeepCollectionEquality().equals(
                  other.notificationType,
                  notificationType,
                )) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.course, course) ||
                const DeepCollectionEquality().equals(other.course, course)) &&
            (identical(other.courseSlug, courseSlug) ||
                const DeepCollectionEquality().equals(
                  other.courseSlug,
                  courseSlug,
                )) &&
            (identical(other.courseTitle, courseTitle) ||
                const DeepCollectionEquality().equals(
                  other.courseTitle,
                  courseTitle,
                )) &&
            (identical(other.ebook, ebook) ||
                const DeepCollectionEquality().equals(other.ebook, ebook)) &&
            (identical(other.ebookId, ebookId) ||
                const DeepCollectionEquality().equals(
                  other.ebookId,
                  ebookId,
                )) &&
            (identical(other.ebookTitle, ebookTitle) ||
                const DeepCollectionEquality().equals(
                  other.ebookTitle,
                  ebookTitle,
                )) &&
            (identical(other.isRead, isRead) ||
                const DeepCollectionEquality().equals(other.isRead, isRead)) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(notificationType) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(course) ^
      const DeepCollectionEquality().hash(courseSlug) ^
      const DeepCollectionEquality().hash(courseTitle) ^
      const DeepCollectionEquality().hash(ebook) ^
      const DeepCollectionEquality().hash(ebookId) ^
      const DeepCollectionEquality().hash(ebookTitle) ^
      const DeepCollectionEquality().hash(isRead) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $StudentNotificationExtension on StudentNotification {
  StudentNotification copyWith({
    String? id,
    enums.StudentNotificationNotificationTypeEnum? notificationType,
    String? title,
    String? message,
    String? course,
    String? courseSlug,
    String? courseTitle,
    String? ebook,
    String? ebookId,
    String? ebookTitle,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return StudentNotification(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      message: message ?? this.message,
      course: course ?? this.course,
      courseSlug: courseSlug ?? this.courseSlug,
      courseTitle: courseTitle ?? this.courseTitle,
      ebook: ebook ?? this.ebook,
      ebookId: ebookId ?? this.ebookId,
      ebookTitle: ebookTitle ?? this.ebookTitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  StudentNotification copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<enums.StudentNotificationNotificationTypeEnum>? notificationType,
    Wrapped<String>? title,
    Wrapped<String>? message,
    Wrapped<String?>? course,
    Wrapped<String?>? courseSlug,
    Wrapped<String?>? courseTitle,
    Wrapped<String?>? ebook,
    Wrapped<String?>? ebookId,
    Wrapped<String?>? ebookTitle,
    Wrapped<bool?>? isRead,
    Wrapped<DateTime?>? createdAt,
  }) {
    return StudentNotification(
      id: (id != null ? id.value : this.id),
      notificationType: (notificationType != null
          ? notificationType.value
          : this.notificationType),
      title: (title != null ? title.value : this.title),
      message: (message != null ? message.value : this.message),
      course: (course != null ? course.value : this.course),
      courseSlug: (courseSlug != null ? courseSlug.value : this.courseSlug),
      courseTitle: (courseTitle != null ? courseTitle.value : this.courseTitle),
      ebook: (ebook != null ? ebook.value : this.ebook),
      ebookId: (ebookId != null ? ebookId.value : this.ebookId),
      ebookTitle: (ebookTitle != null ? ebookTitle.value : this.ebookTitle),
      isRead: (isRead != null ? isRead.value : this.isRead),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TokenRefresh {
  const TokenRefresh({this.access, required this.refresh});

  factory TokenRefresh.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshFromJson(json);

  static const toJsonFactory = _$TokenRefreshToJson;
  Map<String, dynamic> toJson() => _$TokenRefreshToJson(this);

  @JsonKey(name: 'access')
  final String? access;
  @JsonKey(name: 'refresh')
  final String refresh;
  static const fromJsonFactory = _$TokenRefreshFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenRefresh &&
            (identical(other.access, access) ||
                const DeepCollectionEquality().equals(other.access, access)) &&
            (identical(other.refresh, refresh) ||
                const DeepCollectionEquality().equals(other.refresh, refresh)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(access) ^
      const DeepCollectionEquality().hash(refresh) ^
      runtimeType.hashCode;
}

extension $TokenRefreshExtension on TokenRefresh {
  TokenRefresh copyWith({String? access, String? refresh}) {
    return TokenRefresh(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
    );
  }

  TokenRefresh copyWithWrapped({
    Wrapped<String?>? access,
    Wrapped<String>? refresh,
  }) {
    return TokenRefresh(
      access: (access != null ? access.value : this.access),
      refresh: (refresh != null ? refresh.value : this.refresh),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class TokenRefreshRequest {
  const TokenRefreshRequest({required this.refresh});

  factory TokenRefreshRequest.fromJson(Map<String, dynamic> json) =>
      _$TokenRefreshRequestFromJson(json);

  static const toJsonFactory = _$TokenRefreshRequestToJson;
  Map<String, dynamic> toJson() => _$TokenRefreshRequestToJson(this);

  @JsonKey(name: 'refresh')
  final String refresh;
  static const fromJsonFactory = _$TokenRefreshRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TokenRefreshRequest &&
            (identical(other.refresh, refresh) ||
                const DeepCollectionEquality().equals(other.refresh, refresh)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(refresh) ^ runtimeType.hashCode;
}

extension $TokenRefreshRequestExtension on TokenRefreshRequest {
  TokenRefreshRequest copyWith({String? refresh}) {
    return TokenRefreshRequest(refresh: refresh ?? this.refresh);
  }

  TokenRefreshRequest copyWithWrapped({Wrapped<String>? refresh}) {
    return TokenRefreshRequest(
      refresh: (refresh != null ? refresh.value : this.refresh),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserProfile {
  const UserProfile({
    this.id,
    this.email,
    this.fullName,
    this.phoneNumber,
    this.role,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
    this.dateJoined,
    this.instructorProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  static const toJsonFactory = _$UserProfileToJson;
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(
    name: 'role',
    toJson: roleEnumNullableToJson,
    fromJson: roleEnumNullableFromJson,
  )
  final enums.RoleEnum? role;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  @JsonKey(name: 'date_joined')
  final DateTime? dateJoined;
  @JsonKey(name: 'instructor_profile')
  final dynamic instructorProfile;
  static const fromJsonFactory = _$UserProfileFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserProfile &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )) &&
            (identical(other.dateJoined, dateJoined) ||
                const DeepCollectionEquality().equals(
                  other.dateJoined,
                  dateJoined,
                )) &&
            (identical(other.instructorProfile, instructorProfile) ||
                const DeepCollectionEquality().equals(
                  other.instructorProfile,
                  instructorProfile,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      const DeepCollectionEquality().hash(dateJoined) ^
      const DeepCollectionEquality().hash(instructorProfile) ^
      runtimeType.hashCode;
}

extension $UserProfileExtension on UserProfile {
  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    enums.RoleEnum? role,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
    DateTime? dateJoined,
    String? instructorProfile,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
      dateJoined: dateJoined ?? this.dateJoined,
      instructorProfile: instructorProfile ?? this.instructorProfile,
    );
  }

  UserProfile copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String?>? email,
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<enums.RoleEnum?>? role,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
    Wrapped<DateTime?>? dateJoined,
    Wrapped<String?>? instructorProfile,
  }) {
    return UserProfile(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      role: (role != null ? role.value : this.role),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
      dateJoined: (dateJoined != null ? dateJoined.value : this.dateJoined),
      instructorProfile: (instructorProfile != null
          ? instructorProfile.value
          : this.instructorProfile),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserProfileRequest {
  const UserProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.avatar,
    this.locationState,
    this.locationDistrict,
    this.farmingExperience,
    this.areasOfInterest,
  });

  factory UserProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UserProfileRequestFromJson(json);

  static const toJsonFactory = _$UserProfileRequestToJson;
  Map<String, dynamic> toJson() => _$UserProfileRequestToJson(this);

  @JsonKey(name: 'full_name')
  final String? fullName;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'avatar')
  final String? avatar;
  @JsonKey(name: 'location_state')
  final String? locationState;
  @JsonKey(name: 'location_district')
  final String? locationDistrict;
  @JsonKey(name: 'farming_experience')
  final dynamic farmingExperience;
  @JsonKey(name: 'areas_of_interest')
  final dynamic areasOfInterest;
  static const fromJsonFactory = _$UserProfileRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserProfileRequest &&
            (identical(other.fullName, fullName) ||
                const DeepCollectionEquality().equals(
                  other.fullName,
                  fullName,
                )) &&
            (identical(other.phoneNumber, phoneNumber) ||
                const DeepCollectionEquality().equals(
                  other.phoneNumber,
                  phoneNumber,
                )) &&
            (identical(other.avatar, avatar) ||
                const DeepCollectionEquality().equals(other.avatar, avatar)) &&
            (identical(other.locationState, locationState) ||
                const DeepCollectionEquality().equals(
                  other.locationState,
                  locationState,
                )) &&
            (identical(other.locationDistrict, locationDistrict) ||
                const DeepCollectionEquality().equals(
                  other.locationDistrict,
                  locationDistrict,
                )) &&
            (identical(other.farmingExperience, farmingExperience) ||
                const DeepCollectionEquality().equals(
                  other.farmingExperience,
                  farmingExperience,
                )) &&
            (identical(other.areasOfInterest, areasOfInterest) ||
                const DeepCollectionEquality().equals(
                  other.areasOfInterest,
                  areasOfInterest,
                )));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(fullName) ^
      const DeepCollectionEquality().hash(phoneNumber) ^
      const DeepCollectionEquality().hash(avatar) ^
      const DeepCollectionEquality().hash(locationState) ^
      const DeepCollectionEquality().hash(locationDistrict) ^
      const DeepCollectionEquality().hash(farmingExperience) ^
      const DeepCollectionEquality().hash(areasOfInterest) ^
      runtimeType.hashCode;
}

extension $UserProfileRequestExtension on UserProfileRequest {
  UserProfileRequest copyWith({
    String? fullName,
    String? phoneNumber,
    String? avatar,
    String? locationState,
    String? locationDistrict,
    dynamic farmingExperience,
    dynamic areasOfInterest,
  }) {
    return UserProfileRequest(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      locationState: locationState ?? this.locationState,
      locationDistrict: locationDistrict ?? this.locationDistrict,
      farmingExperience: farmingExperience ?? this.farmingExperience,
      areasOfInterest: areasOfInterest ?? this.areasOfInterest,
    );
  }

  UserProfileRequest copyWithWrapped({
    Wrapped<String?>? fullName,
    Wrapped<String?>? phoneNumber,
    Wrapped<String?>? avatar,
    Wrapped<String?>? locationState,
    Wrapped<String?>? locationDistrict,
    Wrapped<dynamic>? farmingExperience,
    Wrapped<dynamic>? areasOfInterest,
  }) {
    return UserProfileRequest(
      fullName: (fullName != null ? fullName.value : this.fullName),
      phoneNumber: (phoneNumber != null ? phoneNumber.value : this.phoneNumber),
      avatar: (avatar != null ? avatar.value : this.avatar),
      locationState: (locationState != null
          ? locationState.value
          : this.locationState),
      locationDistrict: (locationDistrict != null
          ? locationDistrict.value
          : this.locationDistrict),
      farmingExperience: (farmingExperience != null
          ? farmingExperience.value
          : this.farmingExperience),
      areasOfInterest: (areasOfInterest != null
          ? areasOfInterest.value
          : this.areasOfInterest),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VerifyResetOTP {
  const VerifyResetOTP({required this.email, required this.otp});

  factory VerifyResetOTP.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOTPFromJson(json);

  static const toJsonFactory = _$VerifyResetOTPToJson;
  Map<String, dynamic> toJson() => _$VerifyResetOTPToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'otp')
  final String otp;
  static const fromJsonFactory = _$VerifyResetOTPFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VerifyResetOTP &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.otp, otp) ||
                const DeepCollectionEquality().equals(other.otp, otp)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(otp) ^
      runtimeType.hashCode;
}

extension $VerifyResetOTPExtension on VerifyResetOTP {
  VerifyResetOTP copyWith({String? email, String? otp}) {
    return VerifyResetOTP(email: email ?? this.email, otp: otp ?? this.otp);
  }

  VerifyResetOTP copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? otp,
  }) {
    return VerifyResetOTP(
      email: (email != null ? email.value : this.email),
      otp: (otp != null ? otp.value : this.otp),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VerifyResetOTPRequest {
  const VerifyResetOTPRequest({required this.email, required this.otp});

  factory VerifyResetOTPRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetOTPRequestFromJson(json);

  static const toJsonFactory = _$VerifyResetOTPRequestToJson;
  Map<String, dynamic> toJson() => _$VerifyResetOTPRequestToJson(this);

  @JsonKey(name: 'email')
  final String email;
  @JsonKey(name: 'otp')
  final String otp;
  static const fromJsonFactory = _$VerifyResetOTPRequestFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is VerifyResetOTPRequest &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)) &&
            (identical(other.otp, otp) ||
                const DeepCollectionEquality().equals(other.otp, otp)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(email) ^
      const DeepCollectionEquality().hash(otp) ^
      runtimeType.hashCode;
}

extension $VerifyResetOTPRequestExtension on VerifyResetOTPRequest {
  VerifyResetOTPRequest copyWith({String? email, String? otp}) {
    return VerifyResetOTPRequest(
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }

  VerifyResetOTPRequest copyWithWrapped({
    Wrapped<String>? email,
    Wrapped<String>? otp,
  }) {
    return VerifyResetOTPRequest(
      email: (email != null ? email.value : this.email),
      otp: (otp != null ? otp.value : this.otp),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ApiV1AuthFcmTokenPost$Response {
  const ApiV1AuthFcmTokenPost$Response({this.message});

  factory ApiV1AuthFcmTokenPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ApiV1AuthFcmTokenPost$ResponseFromJson(json);

  static const toJsonFactory = _$ApiV1AuthFcmTokenPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ApiV1AuthFcmTokenPost$ResponseToJson(this);

  @JsonKey(name: 'message')
  final String? message;
  static const fromJsonFactory = _$ApiV1AuthFcmTokenPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ApiV1AuthFcmTokenPost$Response &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  String toString() => jsonEncode(this);

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^ runtimeType.hashCode;
}

extension $ApiV1AuthFcmTokenPost$ResponseExtension
    on ApiV1AuthFcmTokenPost$Response {
  ApiV1AuthFcmTokenPost$Response copyWith({String? message}) {
    return ApiV1AuthFcmTokenPost$Response(message: message ?? this.message);
  }

  ApiV1AuthFcmTokenPost$Response copyWithWrapped({Wrapped<String?>? message}) {
    return ApiV1AuthFcmTokenPost$Response(
      message: (message != null ? message.value : this.message),
    );
  }
}

String? adminNotificationNotificationTypeEnumNullableToJson(
  enums.AdminNotificationNotificationTypeEnum?
  adminNotificationNotificationTypeEnum,
) {
  return adminNotificationNotificationTypeEnum?.value;
}

String? adminNotificationNotificationTypeEnumToJson(
  enums.AdminNotificationNotificationTypeEnum
  adminNotificationNotificationTypeEnum,
) {
  return adminNotificationNotificationTypeEnum.value;
}

enums.AdminNotificationNotificationTypeEnum
adminNotificationNotificationTypeEnumFromJson(
  Object? adminNotificationNotificationTypeEnum, [
  enums.AdminNotificationNotificationTypeEnum? defaultValue,
]) {
  return enums.AdminNotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == adminNotificationNotificationTypeEnum,
      ) ??
      defaultValue ??
      enums.AdminNotificationNotificationTypeEnum.swaggerGeneratedUnknown;
}

enums.AdminNotificationNotificationTypeEnum?
adminNotificationNotificationTypeEnumNullableFromJson(
  Object? adminNotificationNotificationTypeEnum, [
  enums.AdminNotificationNotificationTypeEnum? defaultValue,
]) {
  if (adminNotificationNotificationTypeEnum == null) {
    return null;
  }
  return enums.AdminNotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == adminNotificationNotificationTypeEnum,
      ) ??
      defaultValue;
}

String adminNotificationNotificationTypeEnumExplodedListToJson(
  List<enums.AdminNotificationNotificationTypeEnum>?
  adminNotificationNotificationTypeEnum,
) {
  return adminNotificationNotificationTypeEnum
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> adminNotificationNotificationTypeEnumListToJson(
  List<enums.AdminNotificationNotificationTypeEnum>?
  adminNotificationNotificationTypeEnum,
) {
  if (adminNotificationNotificationTypeEnum == null) {
    return [];
  }

  return adminNotificationNotificationTypeEnum.map((e) => e.value!).toList();
}

List<enums.AdminNotificationNotificationTypeEnum>
adminNotificationNotificationTypeEnumListFromJson(
  List? adminNotificationNotificationTypeEnum, [
  List<enums.AdminNotificationNotificationTypeEnum>? defaultValue,
]) {
  if (adminNotificationNotificationTypeEnum == null) {
    return defaultValue ?? [];
  }

  return adminNotificationNotificationTypeEnum
      .map((e) => adminNotificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.AdminNotificationNotificationTypeEnum>?
adminNotificationNotificationTypeEnumNullableListFromJson(
  List? adminNotificationNotificationTypeEnum, [
  List<enums.AdminNotificationNotificationTypeEnum>? defaultValue,
]) {
  if (adminNotificationNotificationTypeEnum == null) {
    return defaultValue;
  }

  return adminNotificationNotificationTypeEnum
      .map((e) => adminNotificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

String? blankEnumNullableToJson(enums.BlankEnum? blankEnum) {
  return blankEnum?.value;
}

String? blankEnumToJson(enums.BlankEnum blankEnum) {
  return blankEnum.value;
}

enums.BlankEnum blankEnumFromJson(
  Object? blankEnum, [
  enums.BlankEnum? defaultValue,
]) {
  return enums.BlankEnum.values.firstWhereOrNull((e) => e.value == blankEnum) ??
      defaultValue ??
      enums.BlankEnum.swaggerGeneratedUnknown;
}

enums.BlankEnum? blankEnumNullableFromJson(
  Object? blankEnum, [
  enums.BlankEnum? defaultValue,
]) {
  if (blankEnum == null) {
    return null;
  }
  return enums.BlankEnum.values.firstWhereOrNull((e) => e.value == blankEnum) ??
      defaultValue;
}

String blankEnumExplodedListToJson(List<enums.BlankEnum>? blankEnum) {
  return blankEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> blankEnumListToJson(List<enums.BlankEnum>? blankEnum) {
  if (blankEnum == null) {
    return [];
  }

  return blankEnum.map((e) => e.value!).toList();
}

List<enums.BlankEnum> blankEnumListFromJson(
  List? blankEnum, [
  List<enums.BlankEnum>? defaultValue,
]) {
  if (blankEnum == null) {
    return defaultValue ?? [];
  }

  return blankEnum.map((e) => blankEnumFromJson(e.toString())).toList();
}

List<enums.BlankEnum>? blankEnumNullableListFromJson(
  List? blankEnum, [
  List<enums.BlankEnum>? defaultValue,
]) {
  if (blankEnum == null) {
    return defaultValue;
  }

  return blankEnum.map((e) => blankEnumFromJson(e.toString())).toList();
}

int? bunnyStatusEnumNullableToJson(enums.BunnyStatusEnum? bunnyStatusEnum) {
  return bunnyStatusEnum?.value;
}

int? bunnyStatusEnumToJson(enums.BunnyStatusEnum bunnyStatusEnum) {
  return bunnyStatusEnum.value;
}

enums.BunnyStatusEnum bunnyStatusEnumFromJson(
  Object? bunnyStatusEnum, [
  enums.BunnyStatusEnum? defaultValue,
]) {
  return enums.BunnyStatusEnum.values.firstWhereOrNull(
        (e) => e.value == bunnyStatusEnum,
      ) ??
      defaultValue ??
      enums.BunnyStatusEnum.swaggerGeneratedUnknown;
}

enums.BunnyStatusEnum? bunnyStatusEnumNullableFromJson(
  Object? bunnyStatusEnum, [
  enums.BunnyStatusEnum? defaultValue,
]) {
  if (bunnyStatusEnum == null) {
    return null;
  }
  return enums.BunnyStatusEnum.values.firstWhereOrNull(
        (e) => e.value == bunnyStatusEnum,
      ) ??
      defaultValue;
}

String bunnyStatusEnumExplodedListToJson(
  List<enums.BunnyStatusEnum>? bunnyStatusEnum,
) {
  return bunnyStatusEnum?.map((e) => e.value!).join(',') ?? '';
}

List<int> bunnyStatusEnumListToJson(
  List<enums.BunnyStatusEnum>? bunnyStatusEnum,
) {
  if (bunnyStatusEnum == null) {
    return [];
  }

  return bunnyStatusEnum.map((e) => e.value!).toList();
}

List<enums.BunnyStatusEnum> bunnyStatusEnumListFromJson(
  List? bunnyStatusEnum, [
  List<enums.BunnyStatusEnum>? defaultValue,
]) {
  if (bunnyStatusEnum == null) {
    return defaultValue ?? [];
  }

  return bunnyStatusEnum.map((e) => bunnyStatusEnumFromJson(e)).toList();
}

List<enums.BunnyStatusEnum>? bunnyStatusEnumNullableListFromJson(
  List? bunnyStatusEnum, [
  List<enums.BunnyStatusEnum>? defaultValue,
]) {
  if (bunnyStatusEnum == null) {
    return defaultValue;
  }

  return bunnyStatusEnum.map((e) => bunnyStatusEnumFromJson(e)).toList();
}

String? contentTypeEnumNullableToJson(enums.ContentTypeEnum? contentTypeEnum) {
  return contentTypeEnum?.value;
}

String? contentTypeEnumToJson(enums.ContentTypeEnum contentTypeEnum) {
  return contentTypeEnum.value;
}

enums.ContentTypeEnum contentTypeEnumFromJson(
  Object? contentTypeEnum, [
  enums.ContentTypeEnum? defaultValue,
]) {
  return enums.ContentTypeEnum.values.firstWhereOrNull(
        (e) => e.value == contentTypeEnum,
      ) ??
      defaultValue ??
      enums.ContentTypeEnum.swaggerGeneratedUnknown;
}

enums.ContentTypeEnum? contentTypeEnumNullableFromJson(
  Object? contentTypeEnum, [
  enums.ContentTypeEnum? defaultValue,
]) {
  if (contentTypeEnum == null) {
    return null;
  }
  return enums.ContentTypeEnum.values.firstWhereOrNull(
        (e) => e.value == contentTypeEnum,
      ) ??
      defaultValue;
}

String contentTypeEnumExplodedListToJson(
  List<enums.ContentTypeEnum>? contentTypeEnum,
) {
  return contentTypeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> contentTypeEnumListToJson(
  List<enums.ContentTypeEnum>? contentTypeEnum,
) {
  if (contentTypeEnum == null) {
    return [];
  }

  return contentTypeEnum.map((e) => e.value!).toList();
}

List<enums.ContentTypeEnum> contentTypeEnumListFromJson(
  List? contentTypeEnum, [
  List<enums.ContentTypeEnum>? defaultValue,
]) {
  if (contentTypeEnum == null) {
    return defaultValue ?? [];
  }

  return contentTypeEnum
      .map((e) => contentTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.ContentTypeEnum>? contentTypeEnumNullableListFromJson(
  List? contentTypeEnum, [
  List<enums.ContentTypeEnum>? defaultValue,
]) {
  if (contentTypeEnum == null) {
    return defaultValue;
  }

  return contentTypeEnum
      .map((e) => contentTypeEnumFromJson(e.toString()))
      .toList();
}

String? deviceTypeEnumNullableToJson(enums.DeviceTypeEnum? deviceTypeEnum) {
  return deviceTypeEnum?.value;
}

String? deviceTypeEnumToJson(enums.DeviceTypeEnum deviceTypeEnum) {
  return deviceTypeEnum.value;
}

enums.DeviceTypeEnum deviceTypeEnumFromJson(
  Object? deviceTypeEnum, [
  enums.DeviceTypeEnum? defaultValue,
]) {
  return enums.DeviceTypeEnum.values.firstWhereOrNull(
        (e) => e.value == deviceTypeEnum,
      ) ??
      defaultValue ??
      enums.DeviceTypeEnum.swaggerGeneratedUnknown;
}

enums.DeviceTypeEnum? deviceTypeEnumNullableFromJson(
  Object? deviceTypeEnum, [
  enums.DeviceTypeEnum? defaultValue,
]) {
  if (deviceTypeEnum == null) {
    return null;
  }
  return enums.DeviceTypeEnum.values.firstWhereOrNull(
        (e) => e.value == deviceTypeEnum,
      ) ??
      defaultValue;
}

String deviceTypeEnumExplodedListToJson(
  List<enums.DeviceTypeEnum>? deviceTypeEnum,
) {
  return deviceTypeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> deviceTypeEnumListToJson(
  List<enums.DeviceTypeEnum>? deviceTypeEnum,
) {
  if (deviceTypeEnum == null) {
    return [];
  }

  return deviceTypeEnum.map((e) => e.value!).toList();
}

List<enums.DeviceTypeEnum> deviceTypeEnumListFromJson(
  List? deviceTypeEnum, [
  List<enums.DeviceTypeEnum>? defaultValue,
]) {
  if (deviceTypeEnum == null) {
    return defaultValue ?? [];
  }

  return deviceTypeEnum
      .map((e) => deviceTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.DeviceTypeEnum>? deviceTypeEnumNullableListFromJson(
  List? deviceTypeEnum, [
  List<enums.DeviceTypeEnum>? defaultValue,
]) {
  if (deviceTypeEnum == null) {
    return defaultValue;
  }

  return deviceTypeEnum
      .map((e) => deviceTypeEnumFromJson(e.toString()))
      .toList();
}

String? failedStepEnumNullableToJson(enums.FailedStepEnum? failedStepEnum) {
  return failedStepEnum?.value;
}

String? failedStepEnumToJson(enums.FailedStepEnum failedStepEnum) {
  return failedStepEnum.value;
}

enums.FailedStepEnum failedStepEnumFromJson(
  Object? failedStepEnum, [
  enums.FailedStepEnum? defaultValue,
]) {
  return enums.FailedStepEnum.values.firstWhereOrNull(
        (e) => e.value == failedStepEnum,
      ) ??
      defaultValue ??
      enums.FailedStepEnum.swaggerGeneratedUnknown;
}

enums.FailedStepEnum? failedStepEnumNullableFromJson(
  Object? failedStepEnum, [
  enums.FailedStepEnum? defaultValue,
]) {
  if (failedStepEnum == null) {
    return null;
  }
  return enums.FailedStepEnum.values.firstWhereOrNull(
        (e) => e.value == failedStepEnum,
      ) ??
      defaultValue;
}

String failedStepEnumExplodedListToJson(
  List<enums.FailedStepEnum>? failedStepEnum,
) {
  return failedStepEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> failedStepEnumListToJson(
  List<enums.FailedStepEnum>? failedStepEnum,
) {
  if (failedStepEnum == null) {
    return [];
  }

  return failedStepEnum.map((e) => e.value!).toList();
}

List<enums.FailedStepEnum> failedStepEnumListFromJson(
  List? failedStepEnum, [
  List<enums.FailedStepEnum>? defaultValue,
]) {
  if (failedStepEnum == null) {
    return defaultValue ?? [];
  }

  return failedStepEnum
      .map((e) => failedStepEnumFromJson(e.toString()))
      .toList();
}

List<enums.FailedStepEnum>? failedStepEnumNullableListFromJson(
  List? failedStepEnum, [
  List<enums.FailedStepEnum>? defaultValue,
]) {
  if (failedStepEnum == null) {
    return defaultValue;
  }

  return failedStepEnum
      .map((e) => failedStepEnumFromJson(e.toString()))
      .toList();
}

String? farmingExperienceEnumNullableToJson(
  enums.FarmingExperienceEnum? farmingExperienceEnum,
) {
  return farmingExperienceEnum?.value;
}

String? farmingExperienceEnumToJson(
  enums.FarmingExperienceEnum farmingExperienceEnum,
) {
  return farmingExperienceEnum.value;
}

enums.FarmingExperienceEnum farmingExperienceEnumFromJson(
  Object? farmingExperienceEnum, [
  enums.FarmingExperienceEnum? defaultValue,
]) {
  return enums.FarmingExperienceEnum.values.firstWhereOrNull(
        (e) => e.value == farmingExperienceEnum,
      ) ??
      defaultValue ??
      enums.FarmingExperienceEnum.swaggerGeneratedUnknown;
}

enums.FarmingExperienceEnum? farmingExperienceEnumNullableFromJson(
  Object? farmingExperienceEnum, [
  enums.FarmingExperienceEnum? defaultValue,
]) {
  if (farmingExperienceEnum == null) {
    return null;
  }
  return enums.FarmingExperienceEnum.values.firstWhereOrNull(
        (e) => e.value == farmingExperienceEnum,
      ) ??
      defaultValue;
}

String farmingExperienceEnumExplodedListToJson(
  List<enums.FarmingExperienceEnum>? farmingExperienceEnum,
) {
  return farmingExperienceEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> farmingExperienceEnumListToJson(
  List<enums.FarmingExperienceEnum>? farmingExperienceEnum,
) {
  if (farmingExperienceEnum == null) {
    return [];
  }

  return farmingExperienceEnum.map((e) => e.value!).toList();
}

List<enums.FarmingExperienceEnum> farmingExperienceEnumListFromJson(
  List? farmingExperienceEnum, [
  List<enums.FarmingExperienceEnum>? defaultValue,
]) {
  if (farmingExperienceEnum == null) {
    return defaultValue ?? [];
  }

  return farmingExperienceEnum
      .map((e) => farmingExperienceEnumFromJson(e.toString()))
      .toList();
}

List<enums.FarmingExperienceEnum>? farmingExperienceEnumNullableListFromJson(
  List? farmingExperienceEnum, [
  List<enums.FarmingExperienceEnum>? defaultValue,
]) {
  if (farmingExperienceEnum == null) {
    return defaultValue;
  }

  return farmingExperienceEnum
      .map((e) => farmingExperienceEnumFromJson(e.toString()))
      .toList();
}

String? fileTypeEnumNullableToJson(enums.FileTypeEnum? fileTypeEnum) {
  return fileTypeEnum?.value;
}

String? fileTypeEnumToJson(enums.FileTypeEnum fileTypeEnum) {
  return fileTypeEnum.value;
}

enums.FileTypeEnum fileTypeEnumFromJson(
  Object? fileTypeEnum, [
  enums.FileTypeEnum? defaultValue,
]) {
  return enums.FileTypeEnum.values.firstWhereOrNull(
        (e) => e.value == fileTypeEnum,
      ) ??
      defaultValue ??
      enums.FileTypeEnum.swaggerGeneratedUnknown;
}

enums.FileTypeEnum? fileTypeEnumNullableFromJson(
  Object? fileTypeEnum, [
  enums.FileTypeEnum? defaultValue,
]) {
  if (fileTypeEnum == null) {
    return null;
  }
  return enums.FileTypeEnum.values.firstWhereOrNull(
        (e) => e.value == fileTypeEnum,
      ) ??
      defaultValue;
}

String fileTypeEnumExplodedListToJson(List<enums.FileTypeEnum>? fileTypeEnum) {
  return fileTypeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> fileTypeEnumListToJson(List<enums.FileTypeEnum>? fileTypeEnum) {
  if (fileTypeEnum == null) {
    return [];
  }

  return fileTypeEnum.map((e) => e.value!).toList();
}

List<enums.FileTypeEnum> fileTypeEnumListFromJson(
  List? fileTypeEnum, [
  List<enums.FileTypeEnum>? defaultValue,
]) {
  if (fileTypeEnum == null) {
    return defaultValue ?? [];
  }

  return fileTypeEnum.map((e) => fileTypeEnumFromJson(e.toString())).toList();
}

List<enums.FileTypeEnum>? fileTypeEnumNullableListFromJson(
  List? fileTypeEnum, [
  List<enums.FileTypeEnum>? defaultValue,
]) {
  if (fileTypeEnum == null) {
    return defaultValue;
  }

  return fileTypeEnum.map((e) => fileTypeEnumFromJson(e.toString())).toList();
}

String? kycDocumentTypeEnumNullableToJson(
  enums.KycDocumentTypeEnum? kycDocumentTypeEnum,
) {
  return kycDocumentTypeEnum?.value;
}

String? kycDocumentTypeEnumToJson(
  enums.KycDocumentTypeEnum kycDocumentTypeEnum,
) {
  return kycDocumentTypeEnum.value;
}

enums.KycDocumentTypeEnum kycDocumentTypeEnumFromJson(
  Object? kycDocumentTypeEnum, [
  enums.KycDocumentTypeEnum? defaultValue,
]) {
  return enums.KycDocumentTypeEnum.values.firstWhereOrNull(
        (e) => e.value == kycDocumentTypeEnum,
      ) ??
      defaultValue ??
      enums.KycDocumentTypeEnum.swaggerGeneratedUnknown;
}

enums.KycDocumentTypeEnum? kycDocumentTypeEnumNullableFromJson(
  Object? kycDocumentTypeEnum, [
  enums.KycDocumentTypeEnum? defaultValue,
]) {
  if (kycDocumentTypeEnum == null) {
    return null;
  }
  return enums.KycDocumentTypeEnum.values.firstWhereOrNull(
        (e) => e.value == kycDocumentTypeEnum,
      ) ??
      defaultValue;
}

String kycDocumentTypeEnumExplodedListToJson(
  List<enums.KycDocumentTypeEnum>? kycDocumentTypeEnum,
) {
  return kycDocumentTypeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> kycDocumentTypeEnumListToJson(
  List<enums.KycDocumentTypeEnum>? kycDocumentTypeEnum,
) {
  if (kycDocumentTypeEnum == null) {
    return [];
  }

  return kycDocumentTypeEnum.map((e) => e.value!).toList();
}

List<enums.KycDocumentTypeEnum> kycDocumentTypeEnumListFromJson(
  List? kycDocumentTypeEnum, [
  List<enums.KycDocumentTypeEnum>? defaultValue,
]) {
  if (kycDocumentTypeEnum == null) {
    return defaultValue ?? [];
  }

  return kycDocumentTypeEnum
      .map((e) => kycDocumentTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.KycDocumentTypeEnum>? kycDocumentTypeEnumNullableListFromJson(
  List? kycDocumentTypeEnum, [
  List<enums.KycDocumentTypeEnum>? defaultValue,
]) {
  if (kycDocumentTypeEnum == null) {
    return defaultValue;
  }

  return kycDocumentTypeEnum
      .map((e) => kycDocumentTypeEnumFromJson(e.toString()))
      .toList();
}

String? levelEnumNullableToJson(enums.LevelEnum? levelEnum) {
  return levelEnum?.value;
}

String? levelEnumToJson(enums.LevelEnum levelEnum) {
  return levelEnum.value;
}

enums.LevelEnum levelEnumFromJson(
  Object? levelEnum, [
  enums.LevelEnum? defaultValue,
]) {
  return enums.LevelEnum.values.firstWhereOrNull((e) => e.value == levelEnum) ??
      defaultValue ??
      enums.LevelEnum.swaggerGeneratedUnknown;
}

enums.LevelEnum? levelEnumNullableFromJson(
  Object? levelEnum, [
  enums.LevelEnum? defaultValue,
]) {
  if (levelEnum == null) {
    return null;
  }
  return enums.LevelEnum.values.firstWhereOrNull((e) => e.value == levelEnum) ??
      defaultValue;
}

String levelEnumExplodedListToJson(List<enums.LevelEnum>? levelEnum) {
  return levelEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> levelEnumListToJson(List<enums.LevelEnum>? levelEnum) {
  if (levelEnum == null) {
    return [];
  }

  return levelEnum.map((e) => e.value!).toList();
}

List<enums.LevelEnum> levelEnumListFromJson(
  List? levelEnum, [
  List<enums.LevelEnum>? defaultValue,
]) {
  if (levelEnum == null) {
    return defaultValue ?? [];
  }

  return levelEnum.map((e) => levelEnumFromJson(e.toString())).toList();
}

List<enums.LevelEnum>? levelEnumNullableListFromJson(
  List? levelEnum, [
  List<enums.LevelEnum>? defaultValue,
]) {
  if (levelEnum == null) {
    return defaultValue;
  }

  return levelEnum.map((e) => levelEnumFromJson(e.toString())).toList();
}

String? notificationNotificationTypeEnumNullableToJson(
  enums.NotificationNotificationTypeEnum? notificationNotificationTypeEnum,
) {
  return notificationNotificationTypeEnum?.value;
}

String? notificationNotificationTypeEnumToJson(
  enums.NotificationNotificationTypeEnum notificationNotificationTypeEnum,
) {
  return notificationNotificationTypeEnum.value;
}

enums.NotificationNotificationTypeEnum notificationNotificationTypeEnumFromJson(
  Object? notificationNotificationTypeEnum, [
  enums.NotificationNotificationTypeEnum? defaultValue,
]) {
  return enums.NotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == notificationNotificationTypeEnum,
      ) ??
      defaultValue ??
      enums.NotificationNotificationTypeEnum.swaggerGeneratedUnknown;
}

enums.NotificationNotificationTypeEnum?
notificationNotificationTypeEnumNullableFromJson(
  Object? notificationNotificationTypeEnum, [
  enums.NotificationNotificationTypeEnum? defaultValue,
]) {
  if (notificationNotificationTypeEnum == null) {
    return null;
  }
  return enums.NotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == notificationNotificationTypeEnum,
      ) ??
      defaultValue;
}

String notificationNotificationTypeEnumExplodedListToJson(
  List<enums.NotificationNotificationTypeEnum>?
  notificationNotificationTypeEnum,
) {
  return notificationNotificationTypeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> notificationNotificationTypeEnumListToJson(
  List<enums.NotificationNotificationTypeEnum>?
  notificationNotificationTypeEnum,
) {
  if (notificationNotificationTypeEnum == null) {
    return [];
  }

  return notificationNotificationTypeEnum.map((e) => e.value!).toList();
}

List<enums.NotificationNotificationTypeEnum>
notificationNotificationTypeEnumListFromJson(
  List? notificationNotificationTypeEnum, [
  List<enums.NotificationNotificationTypeEnum>? defaultValue,
]) {
  if (notificationNotificationTypeEnum == null) {
    return defaultValue ?? [];
  }

  return notificationNotificationTypeEnum
      .map((e) => notificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.NotificationNotificationTypeEnum>?
notificationNotificationTypeEnumNullableListFromJson(
  List? notificationNotificationTypeEnum, [
  List<enums.NotificationNotificationTypeEnum>? defaultValue,
]) {
  if (notificationNotificationTypeEnum == null) {
    return defaultValue;
  }

  return notificationNotificationTypeEnum
      .map((e) => notificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

String? nullEnumNullableToJson(enums.NullEnum? nullEnum) {
  return nullEnum?.value;
}

String? nullEnumToJson(enums.NullEnum nullEnum) {
  return nullEnum.value;
}

enums.NullEnum nullEnumFromJson(
  Object? nullEnum, [
  enums.NullEnum? defaultValue,
]) {
  return enums.NullEnum.values.firstWhereOrNull((e) => e.value == nullEnum) ??
      defaultValue ??
      enums.NullEnum.swaggerGeneratedUnknown;
}

enums.NullEnum? nullEnumNullableFromJson(
  Object? nullEnum, [
  enums.NullEnum? defaultValue,
]) {
  if (nullEnum == null) {
    return null;
  }
  return enums.NullEnum.values.firstWhereOrNull((e) => e.value == nullEnum) ??
      defaultValue;
}

String nullEnumExplodedListToJson(List<enums.NullEnum>? nullEnum) {
  return nullEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> nullEnumListToJson(List<enums.NullEnum>? nullEnum) {
  if (nullEnum == null) {
    return [];
  }

  return nullEnum.map((e) => e.value!).toList();
}

List<enums.NullEnum> nullEnumListFromJson(
  List? nullEnum, [
  List<enums.NullEnum>? defaultValue,
]) {
  if (nullEnum == null) {
    return defaultValue ?? [];
  }

  return nullEnum.map((e) => nullEnumFromJson(e.toString())).toList();
}

List<enums.NullEnum>? nullEnumNullableListFromJson(
  List? nullEnum, [
  List<enums.NullEnum>? defaultValue,
]) {
  if (nullEnum == null) {
    return defaultValue;
  }

  return nullEnum.map((e) => nullEnumFromJson(e.toString())).toList();
}

String? orderStatusEnumNullableToJson(enums.OrderStatusEnum? orderStatusEnum) {
  return orderStatusEnum?.value;
}

String? orderStatusEnumToJson(enums.OrderStatusEnum orderStatusEnum) {
  return orderStatusEnum.value;
}

enums.OrderStatusEnum orderStatusEnumFromJson(
  Object? orderStatusEnum, [
  enums.OrderStatusEnum? defaultValue,
]) {
  return enums.OrderStatusEnum.values.firstWhereOrNull(
        (e) => e.value == orderStatusEnum,
      ) ??
      defaultValue ??
      enums.OrderStatusEnum.swaggerGeneratedUnknown;
}

enums.OrderStatusEnum? orderStatusEnumNullableFromJson(
  Object? orderStatusEnum, [
  enums.OrderStatusEnum? defaultValue,
]) {
  if (orderStatusEnum == null) {
    return null;
  }
  return enums.OrderStatusEnum.values.firstWhereOrNull(
        (e) => e.value == orderStatusEnum,
      ) ??
      defaultValue;
}

String orderStatusEnumExplodedListToJson(
  List<enums.OrderStatusEnum>? orderStatusEnum,
) {
  return orderStatusEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> orderStatusEnumListToJson(
  List<enums.OrderStatusEnum>? orderStatusEnum,
) {
  if (orderStatusEnum == null) {
    return [];
  }

  return orderStatusEnum.map((e) => e.value!).toList();
}

List<enums.OrderStatusEnum> orderStatusEnumListFromJson(
  List? orderStatusEnum, [
  List<enums.OrderStatusEnum>? defaultValue,
]) {
  if (orderStatusEnum == null) {
    return defaultValue ?? [];
  }

  return orderStatusEnum
      .map((e) => orderStatusEnumFromJson(e.toString()))
      .toList();
}

List<enums.OrderStatusEnum>? orderStatusEnumNullableListFromJson(
  List? orderStatusEnum, [
  List<enums.OrderStatusEnum>? defaultValue,
]) {
  if (orderStatusEnum == null) {
    return defaultValue;
  }

  return orderStatusEnum
      .map((e) => orderStatusEnumFromJson(e.toString()))
      .toList();
}

String? purposeEnumNullableToJson(enums.PurposeEnum? purposeEnum) {
  return purposeEnum?.value;
}

String? purposeEnumToJson(enums.PurposeEnum purposeEnum) {
  return purposeEnum.value;
}

enums.PurposeEnum purposeEnumFromJson(
  Object? purposeEnum, [
  enums.PurposeEnum? defaultValue,
]) {
  return enums.PurposeEnum.values.firstWhereOrNull(
        (e) => e.value == purposeEnum,
      ) ??
      defaultValue ??
      enums.PurposeEnum.swaggerGeneratedUnknown;
}

enums.PurposeEnum? purposeEnumNullableFromJson(
  Object? purposeEnum, [
  enums.PurposeEnum? defaultValue,
]) {
  if (purposeEnum == null) {
    return null;
  }
  return enums.PurposeEnum.values.firstWhereOrNull(
        (e) => e.value == purposeEnum,
      ) ??
      defaultValue;
}

String purposeEnumExplodedListToJson(List<enums.PurposeEnum>? purposeEnum) {
  return purposeEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> purposeEnumListToJson(List<enums.PurposeEnum>? purposeEnum) {
  if (purposeEnum == null) {
    return [];
  }

  return purposeEnum.map((e) => e.value!).toList();
}

List<enums.PurposeEnum> purposeEnumListFromJson(
  List? purposeEnum, [
  List<enums.PurposeEnum>? defaultValue,
]) {
  if (purposeEnum == null) {
    return defaultValue ?? [];
  }

  return purposeEnum.map((e) => purposeEnumFromJson(e.toString())).toList();
}

List<enums.PurposeEnum>? purposeEnumNullableListFromJson(
  List? purposeEnum, [
  List<enums.PurposeEnum>? defaultValue,
]) {
  if (purposeEnum == null) {
    return defaultValue;
  }

  return purposeEnum.map((e) => purposeEnumFromJson(e.toString())).toList();
}

String? roleEnumNullableToJson(enums.RoleEnum? roleEnum) {
  return roleEnum?.value;
}

String? roleEnumToJson(enums.RoleEnum roleEnum) {
  return roleEnum.value;
}

enums.RoleEnum roleEnumFromJson(
  Object? roleEnum, [
  enums.RoleEnum? defaultValue,
]) {
  return enums.RoleEnum.values.firstWhereOrNull((e) => e.value == roleEnum) ??
      defaultValue ??
      enums.RoleEnum.swaggerGeneratedUnknown;
}

enums.RoleEnum? roleEnumNullableFromJson(
  Object? roleEnum, [
  enums.RoleEnum? defaultValue,
]) {
  if (roleEnum == null) {
    return null;
  }
  return enums.RoleEnum.values.firstWhereOrNull((e) => e.value == roleEnum) ??
      defaultValue;
}

String roleEnumExplodedListToJson(List<enums.RoleEnum>? roleEnum) {
  return roleEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> roleEnumListToJson(List<enums.RoleEnum>? roleEnum) {
  if (roleEnum == null) {
    return [];
  }

  return roleEnum.map((e) => e.value!).toList();
}

List<enums.RoleEnum> roleEnumListFromJson(
  List? roleEnum, [
  List<enums.RoleEnum>? defaultValue,
]) {
  if (roleEnum == null) {
    return defaultValue ?? [];
  }

  return roleEnum.map((e) => roleEnumFromJson(e.toString())).toList();
}

List<enums.RoleEnum>? roleEnumNullableListFromJson(
  List? roleEnum, [
  List<enums.RoleEnum>? defaultValue,
]) {
  if (roleEnum == null) {
    return defaultValue;
  }

  return roleEnum.map((e) => roleEnumFromJson(e.toString())).toList();
}

String? status1bcEnumNullableToJson(enums.Status1bcEnum? status1bcEnum) {
  return status1bcEnum?.value;
}

String? status1bcEnumToJson(enums.Status1bcEnum status1bcEnum) {
  return status1bcEnum.value;
}

enums.Status1bcEnum status1bcEnumFromJson(
  Object? status1bcEnum, [
  enums.Status1bcEnum? defaultValue,
]) {
  return enums.Status1bcEnum.values.firstWhereOrNull(
        (e) => e.value == status1bcEnum,
      ) ??
      defaultValue ??
      enums.Status1bcEnum.swaggerGeneratedUnknown;
}

enums.Status1bcEnum? status1bcEnumNullableFromJson(
  Object? status1bcEnum, [
  enums.Status1bcEnum? defaultValue,
]) {
  if (status1bcEnum == null) {
    return null;
  }
  return enums.Status1bcEnum.values.firstWhereOrNull(
        (e) => e.value == status1bcEnum,
      ) ??
      defaultValue;
}

String status1bcEnumExplodedListToJson(
  List<enums.Status1bcEnum>? status1bcEnum,
) {
  return status1bcEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> status1bcEnumListToJson(List<enums.Status1bcEnum>? status1bcEnum) {
  if (status1bcEnum == null) {
    return [];
  }

  return status1bcEnum.map((e) => e.value!).toList();
}

List<enums.Status1bcEnum> status1bcEnumListFromJson(
  List? status1bcEnum, [
  List<enums.Status1bcEnum>? defaultValue,
]) {
  if (status1bcEnum == null) {
    return defaultValue ?? [];
  }

  return status1bcEnum.map((e) => status1bcEnumFromJson(e.toString())).toList();
}

List<enums.Status1bcEnum>? status1bcEnumNullableListFromJson(
  List? status1bcEnum, [
  List<enums.Status1bcEnum>? defaultValue,
]) {
  if (status1bcEnum == null) {
    return defaultValue;
  }

  return status1bcEnum.map((e) => status1bcEnumFromJson(e.toString())).toList();
}

String? status76eEnumNullableToJson(enums.Status76eEnum? status76eEnum) {
  return status76eEnum?.value;
}

String? status76eEnumToJson(enums.Status76eEnum status76eEnum) {
  return status76eEnum.value;
}

enums.Status76eEnum status76eEnumFromJson(
  Object? status76eEnum, [
  enums.Status76eEnum? defaultValue,
]) {
  return enums.Status76eEnum.values.firstWhereOrNull(
        (e) => e.value == status76eEnum,
      ) ??
      defaultValue ??
      enums.Status76eEnum.swaggerGeneratedUnknown;
}

enums.Status76eEnum? status76eEnumNullableFromJson(
  Object? status76eEnum, [
  enums.Status76eEnum? defaultValue,
]) {
  if (status76eEnum == null) {
    return null;
  }
  return enums.Status76eEnum.values.firstWhereOrNull(
        (e) => e.value == status76eEnum,
      ) ??
      defaultValue;
}

String status76eEnumExplodedListToJson(
  List<enums.Status76eEnum>? status76eEnum,
) {
  return status76eEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> status76eEnumListToJson(List<enums.Status76eEnum>? status76eEnum) {
  if (status76eEnum == null) {
    return [];
  }

  return status76eEnum.map((e) => e.value!).toList();
}

List<enums.Status76eEnum> status76eEnumListFromJson(
  List? status76eEnum, [
  List<enums.Status76eEnum>? defaultValue,
]) {
  if (status76eEnum == null) {
    return defaultValue ?? [];
  }

  return status76eEnum.map((e) => status76eEnumFromJson(e.toString())).toList();
}

List<enums.Status76eEnum>? status76eEnumNullableListFromJson(
  List? status76eEnum, [
  List<enums.Status76eEnum>? defaultValue,
]) {
  if (status76eEnum == null) {
    return defaultValue;
  }

  return status76eEnum.map((e) => status76eEnumFromJson(e.toString())).toList();
}

String? statusC09EnumNullableToJson(enums.StatusC09Enum? statusC09Enum) {
  return statusC09Enum?.value;
}

String? statusC09EnumToJson(enums.StatusC09Enum statusC09Enum) {
  return statusC09Enum.value;
}

enums.StatusC09Enum statusC09EnumFromJson(
  Object? statusC09Enum, [
  enums.StatusC09Enum? defaultValue,
]) {
  return enums.StatusC09Enum.values.firstWhereOrNull(
        (e) => e.value == statusC09Enum,
      ) ??
      defaultValue ??
      enums.StatusC09Enum.swaggerGeneratedUnknown;
}

enums.StatusC09Enum? statusC09EnumNullableFromJson(
  Object? statusC09Enum, [
  enums.StatusC09Enum? defaultValue,
]) {
  if (statusC09Enum == null) {
    return null;
  }
  return enums.StatusC09Enum.values.firstWhereOrNull(
        (e) => e.value == statusC09Enum,
      ) ??
      defaultValue;
}

String statusC09EnumExplodedListToJson(
  List<enums.StatusC09Enum>? statusC09Enum,
) {
  return statusC09Enum?.map((e) => e.value!).join(',') ?? '';
}

List<String> statusC09EnumListToJson(List<enums.StatusC09Enum>? statusC09Enum) {
  if (statusC09Enum == null) {
    return [];
  }

  return statusC09Enum.map((e) => e.value!).toList();
}

List<enums.StatusC09Enum> statusC09EnumListFromJson(
  List? statusC09Enum, [
  List<enums.StatusC09Enum>? defaultValue,
]) {
  if (statusC09Enum == null) {
    return defaultValue ?? [];
  }

  return statusC09Enum.map((e) => statusC09EnumFromJson(e.toString())).toList();
}

List<enums.StatusC09Enum>? statusC09EnumNullableListFromJson(
  List? statusC09Enum, [
  List<enums.StatusC09Enum>? defaultValue,
]) {
  if (statusC09Enum == null) {
    return defaultValue;
  }

  return statusC09Enum.map((e) => statusC09EnumFromJson(e.toString())).toList();
}

String? studentNotificationNotificationTypeEnumNullableToJson(
  enums.StudentNotificationNotificationTypeEnum?
  studentNotificationNotificationTypeEnum,
) {
  return studentNotificationNotificationTypeEnum?.value;
}

String? studentNotificationNotificationTypeEnumToJson(
  enums.StudentNotificationNotificationTypeEnum
  studentNotificationNotificationTypeEnum,
) {
  return studentNotificationNotificationTypeEnum.value;
}

enums.StudentNotificationNotificationTypeEnum
studentNotificationNotificationTypeEnumFromJson(
  Object? studentNotificationNotificationTypeEnum, [
  enums.StudentNotificationNotificationTypeEnum? defaultValue,
]) {
  return enums.StudentNotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == studentNotificationNotificationTypeEnum,
      ) ??
      defaultValue ??
      enums.StudentNotificationNotificationTypeEnum.swaggerGeneratedUnknown;
}

enums.StudentNotificationNotificationTypeEnum?
studentNotificationNotificationTypeEnumNullableFromJson(
  Object? studentNotificationNotificationTypeEnum, [
  enums.StudentNotificationNotificationTypeEnum? defaultValue,
]) {
  if (studentNotificationNotificationTypeEnum == null) {
    return null;
  }
  return enums.StudentNotificationNotificationTypeEnum.values.firstWhereOrNull(
        (e) => e.value == studentNotificationNotificationTypeEnum,
      ) ??
      defaultValue;
}

String studentNotificationNotificationTypeEnumExplodedListToJson(
  List<enums.StudentNotificationNotificationTypeEnum>?
  studentNotificationNotificationTypeEnum,
) {
  return studentNotificationNotificationTypeEnum
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> studentNotificationNotificationTypeEnumListToJson(
  List<enums.StudentNotificationNotificationTypeEnum>?
  studentNotificationNotificationTypeEnum,
) {
  if (studentNotificationNotificationTypeEnum == null) {
    return [];
  }

  return studentNotificationNotificationTypeEnum.map((e) => e.value!).toList();
}

List<enums.StudentNotificationNotificationTypeEnum>
studentNotificationNotificationTypeEnumListFromJson(
  List? studentNotificationNotificationTypeEnum, [
  List<enums.StudentNotificationNotificationTypeEnum>? defaultValue,
]) {
  if (studentNotificationNotificationTypeEnum == null) {
    return defaultValue ?? [];
  }

  return studentNotificationNotificationTypeEnum
      .map((e) => studentNotificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

List<enums.StudentNotificationNotificationTypeEnum>?
studentNotificationNotificationTypeEnumNullableListFromJson(
  List? studentNotificationNotificationTypeEnum, [
  List<enums.StudentNotificationNotificationTypeEnum>? defaultValue,
]) {
  if (studentNotificationNotificationTypeEnum == null) {
    return defaultValue;
  }

  return studentNotificationNotificationTypeEnum
      .map((e) => studentNotificationNotificationTypeEnumFromJson(e.toString()))
      .toList();
}

String? verificationStatusEnumNullableToJson(
  enums.VerificationStatusEnum? verificationStatusEnum,
) {
  return verificationStatusEnum?.value;
}

String? verificationStatusEnumToJson(
  enums.VerificationStatusEnum verificationStatusEnum,
) {
  return verificationStatusEnum.value;
}

enums.VerificationStatusEnum verificationStatusEnumFromJson(
  Object? verificationStatusEnum, [
  enums.VerificationStatusEnum? defaultValue,
]) {
  return enums.VerificationStatusEnum.values.firstWhereOrNull(
        (e) => e.value == verificationStatusEnum,
      ) ??
      defaultValue ??
      enums.VerificationStatusEnum.swaggerGeneratedUnknown;
}

enums.VerificationStatusEnum? verificationStatusEnumNullableFromJson(
  Object? verificationStatusEnum, [
  enums.VerificationStatusEnum? defaultValue,
]) {
  if (verificationStatusEnum == null) {
    return null;
  }
  return enums.VerificationStatusEnum.values.firstWhereOrNull(
        (e) => e.value == verificationStatusEnum,
      ) ??
      defaultValue;
}

String verificationStatusEnumExplodedListToJson(
  List<enums.VerificationStatusEnum>? verificationStatusEnum,
) {
  return verificationStatusEnum?.map((e) => e.value!).join(',') ?? '';
}

List<String> verificationStatusEnumListToJson(
  List<enums.VerificationStatusEnum>? verificationStatusEnum,
) {
  if (verificationStatusEnum == null) {
    return [];
  }

  return verificationStatusEnum.map((e) => e.value!).toList();
}

List<enums.VerificationStatusEnum> verificationStatusEnumListFromJson(
  List? verificationStatusEnum, [
  List<enums.VerificationStatusEnum>? defaultValue,
]) {
  if (verificationStatusEnum == null) {
    return defaultValue ?? [];
  }

  return verificationStatusEnum
      .map((e) => verificationStatusEnumFromJson(e.toString()))
      .toList();
}

List<enums.VerificationStatusEnum>? verificationStatusEnumNullableListFromJson(
  List? verificationStatusEnum, [
  List<enums.VerificationStatusEnum>? defaultValue,
]) {
  if (verificationStatusEnum == null) {
    return defaultValue;
  }

  return verificationStatusEnum
      .map((e) => verificationStatusEnumFromJson(e.toString()))
      .toList();
}

typedef $JsonFactory<T> = T Function(Map<String, dynamic> json);

class $CustomJsonDecoder {
  $CustomJsonDecoder(this.factories);

  final Map<Type, $JsonFactory> factories;

  dynamic decode<T>(dynamic entity) {
    if (entity is Iterable) {
      return _decodeList<T>(entity);
    }

    if (entity is T) {
      return entity;
    }

    if (isTypeOf<T, Map>()) {
      return entity;
    }

    if (isTypeOf<T, Iterable>()) {
      return entity;
    }

    if (entity is Map<String, dynamic>) {
      return _decodeMap<T>(entity);
    }

    return entity;
  }

  T _decodeMap<T>(Map<String, dynamic> values) {
    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! $JsonFactory<T>) {
      return throw "Could not find factory for type $T. Is '$T: $T.fromJsonFactory' included in the CustomJsonDecoder instance creation in bootstrapper.dart?";
    }

    return jsonFactory(values);
  }

  List<T> _decodeList<T>(Iterable values) =>
      values.where((v) => v != null).map<T>((v) => decode<T>(v) as T).toList();
}

class $JsonSerializableConverter extends chopper.JsonConverter {
  @override
  FutureOr<chopper.Response<ResultType>> convertResponse<ResultType, Item>(
    chopper.Response response,
  ) async {
    if (response.bodyString.isEmpty) {
      // In rare cases, when let's say 204 (no content) is returned -
      // we cannot decode the missing json with the result type specified
      return chopper.Response(response.base, null, error: response.error);
    }

    if (ResultType == String) {
      return response.copyWith();
    }

    if (ResultType == DateTime) {
      return response.copyWith(
        body:
            DateTime.parse((response.body as String).replaceAll('"', ''))
                as ResultType,
      );
    }

    final jsonRes = await super.convertResponse(response);
    return jsonRes.copyWith<ResultType>(
      body: $jsonDecoder.decode<Item>(jsonRes.body) as ResultType,
    );
  }
}

final $jsonDecoder = $CustomJsonDecoder(generatedMapping);

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}

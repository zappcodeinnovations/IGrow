class AppVersionResponse {
  final bool success;
  final AppVersionData? data;

  AppVersionResponse({
    required this.success,
    this.data,
  });

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) {
    return AppVersionResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? AppVersionData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AppVersionData {
  final AppPlatformConfig? android;
  final AppPlatformConfig? ios;

  AppVersionData({
    this.android,
    this.ios,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      android: json['android'] != null && json['android'] is Map<String, dynamic>
          ? AppPlatformConfig.fromJson(json['android'] as Map<String, dynamic>)
          : null,
      ios: json['ios'] != null && json['ios'] is Map<String, dynamic>
          ? AppPlatformConfig.fromJson(json['ios'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AppPlatformConfig {
  final String minVersion;
  final int minBuildNumber;
  final String latestVersion;
  final int latestBuildNumber;
  final bool forceUpdate;
  final String storeUrl;
  final String updateTitle;
  final String updateMessage;

  AppPlatformConfig({
    required this.minVersion,
    required this.minBuildNumber,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.forceUpdate,
    required this.storeUrl,
    required this.updateTitle,
    required this.updateMessage,
  });

  factory AppPlatformConfig.fromJson(Map<String, dynamic> json) {
    return AppPlatformConfig(
      minVersion: json['min_version']?.toString() ?? '1.0.0',
      minBuildNumber: _parseInt(json['min_build_number']),
      latestVersion: json['latest_version']?.toString() ?? '1.0.0',
      latestBuildNumber: _parseInt(json['latest_build_number']),
      forceUpdate: json['force_update'] as bool? ?? false,
      storeUrl: json['store_url']?.toString() ?? '',
      updateTitle: json['update_title']?.toString() ?? 'Update Available',
      updateMessage: json['update_message']?.toString() ??
          'A new version of IAgrow is available. Please update to continue.',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

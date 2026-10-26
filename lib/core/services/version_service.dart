import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../data/models/api_models/app_version_model.dart';

class VersionCheckResult {
  final bool isUpdateRequired;
  final String currentVersion;
  final int currentBuild;
  final AppPlatformConfig? config;

  VersionCheckResult({
    required this.isUpdateRequired,
    required this.currentVersion,
    required this.currentBuild,
    this.config,
  });
}

class VersionService {
  static const String _endpoint = 'https://iagrow.zappcode.in/api/app-version/';
  static const Duration _timeout = Duration(seconds: 4);

  /// Checks if an app update is required.
  /// Fails open (isUpdateRequired = false) if network fails, times out, or error occurs.
  static Future<VersionCheckResult> checkVersion({http.Client? client}) async {
    String currentVersion = '';
    int currentBuild = 0;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;
      currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      debugPrint('📱 [VersionService] Current App Version: $currentVersion, Build: $currentBuild');

      final httpClient = client ?? http.Client();
      final response = await httpClient
          .get(
            Uri.parse(_endpoint),
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final versionResponse = AppVersionResponse.fromJson(decoded);

        if (versionResponse.success && versionResponse.data != null) {
          final platformConfig = Platform.isIOS
              ? versionResponse.data!.ios
              : versionResponse.data!.android;

          if (platformConfig != null) {
            debugPrint(
              '🌐 [VersionService] Platform: ${Platform.operatingSystem}, '
              'Min Build: ${platformConfig.minBuildNumber}, Latest Build: ${platformConfig.latestBuildNumber}, '
              'Force: ${platformConfig.forceUpdate}',
            );

            // Trigger update if local build is below minimum build number
            // or below latest released build number.
            final bool isBelowMin = currentBuild < platformConfig.minBuildNumber;
            final bool isBelowLatest = currentBuild < platformConfig.latestBuildNumber;

            final bool needsUpdate = isBelowMin || isBelowLatest;

            return VersionCheckResult(
              isUpdateRequired: needsUpdate,
              currentVersion: currentVersion,
              currentBuild: currentBuild,
              config: platformConfig,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [VersionService] Error checking version (Fail-safe continue): $e');
    }

    // Fail-safe: Allow user to proceed if offline or on network error
    return VersionCheckResult(
      isUpdateRequired: false,
      currentVersion: currentVersion,
      currentBuild: currentBuild,
    );
  }
}

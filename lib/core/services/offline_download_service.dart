import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadedItem {
  DownloadedItem({
    required this.id,
    required this.title,
    required this.courseId,
    required this.localPath,
    required this.fileSizeBytes,
    required this.type, // 'video' or 'pdf'
    required this.downloadedAt,
  });

  final String id;
  final String title;
  final String courseId;
  final String localPath;
  final int fileSizeBytes;
  final String type;
  final DateTime downloadedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseId': courseId,
        'localPath': localPath,
        'fileSizeBytes': fileSizeBytes,
        'type': type,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory DownloadedItem.fromJson(Map<String, dynamic> json) => DownloadedItem(
        id: json['id'] as String,
        title: json['title'] as String,
        courseId: json['courseId'] as String? ?? '',
        localPath: json['localPath'] as String,
        fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
        type: json['type'] as String? ?? 'video',
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      );
}

class OfflineDownloadService {
  static const _indexKey = 'offline_downloads_index_v1';

  Future<Directory> _getOfflineDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final offlineDir = Directory('${docsDir.path}/offline_downloads');
    if (!await offlineDir.exists()) {
      await offlineDir.create(recursive: true);
    }
    return offlineDir;
  }

  Future<List<DownloadedItem>> getDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_indexKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final items = <DownloadedItem>[];
      for (final raw in list) {
        final item = DownloadedItem.fromJson(raw as Map<String, dynamic>);
        if (File(item.localPath).existsSync()) {
          items.add(item);
        }
      }
      return items;
    } catch (e) {
      debugPrint('⚠️ Error loading offline downloads index: $e');
      return [];
    }
  }

  Future<String?> getLocalPath(String id) async {
    final items = await getDownloadedItems();
    for (final item in items) {
      if (item.id == id && File(item.localPath).existsSync()) {
        return item.localPath;
      }
    }
    return null;
  }

  Future<bool> isDownloaded(String id) async {
    final path = await getLocalPath(id);
    return path != null;
  }

  Future<DownloadedItem?> downloadContent({
    required String id,
    required String title,
    required String courseId,
    required String remoteUrl,
    required String type, // 'video' | 'pdf'
    void Function(double progress)? onProgress,
  }) async {
    try {
      final offlineDir = await _getOfflineDir();
      final extension = type == 'pdf' ? 'pdf' : 'mp4';
      final fileName = '${type}_$id.$extension';
      final localFile = File('${offlineDir.path}/$fileName');

      debugPrint('📥 Starting download for $title -> ${localFile.path}');

      final request = http.Request('GET', Uri.parse(remoteUrl));
      final response = await http.Client().send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final sink = localFile.openWrite();

      await for (final chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();

      final fileLength = await localFile.length();
      final item = DownloadedItem(
        id: id,
        title: title,
        courseId: courseId,
        localPath: localFile.path,
        fileSizeBytes: fileLength,
        type: type,
        downloadedAt: DateTime.now(),
      );

      await _saveItemToIndex(item);
      debugPrint('✅ Download completed for $title (${fileLength ~/ (1024 * 1024)} MB)');
      return item;
    } catch (e) {
      debugPrint('❌ Download failed for $title: $e');
      return null;
    }
  }

  Future<void> _saveItemToIndex(DownloadedItem newItem) async {
    final items = await getDownloadedItems();
    items.removeWhere((i) => i.id == newItem.id);
    items.add(newItem);

    final prefs = await SharedPreferences.getInstance();
    final rawList = items.map((i) => i.toJson()).toList();
    await prefs.setString(_indexKey, jsonEncode(rawList));
  }

  Future<void> deleteDownload(String id) async {
    final items = await getDownloadedItems();
    final matchingIndex = items.indexWhere((i) => i.id == id);
    
    if (matchingIndex != -1) {
      final item = items[matchingIndex];
      items.removeAt(matchingIndex);

      final prefs = await SharedPreferences.getInstance();
      final rawList = items.map((i) => i.toJson()).toList();
      await prefs.setString(_indexKey, jsonEncode(rawList));

      final file = File(item.localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}

// ── Riverpod Provider ────────────────────────────────────────────────────────

final offlineDownloadServiceProvider = Provider<OfflineDownloadService>((ref) {
  return OfflineDownloadService();
});

final downloadedItemsProvider = FutureProvider<List<DownloadedItem>>((ref) async {
  final service = ref.watch(offlineDownloadServiceProvider);
  return service.getDownloadedItems();
});

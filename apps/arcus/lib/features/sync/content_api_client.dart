import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Production / staging base URL for the website content API.
///
/// Override at build time:
/// `flutter run --dart-define=ARCUS_API_BASE=https://api.your-site.com/v1`
const String kArcusApiBase = String.fromEnvironment(
  'ARCUS_API_BASE',
  defaultValue: 'https://api.example.com/v1',
);

class ContentManifest {
  const ContentManifest({
    required this.generatedAt,
    required this.guidesVersion,
    required this.chartsVersion,
    required this.announcementsVersion,
  });

  final String generatedAt;
  final String guidesVersion;
  final String chartsVersion;
  final String announcementsVersion;

  factory ContentManifest.fromJson(Map<String, dynamic> json) =>
      ContentManifest(
        generatedAt: json['generated_at'] as String? ?? '',
        guidesVersion: json['guides_version'] as String? ?? '',
        chartsVersion: json['charts_version'] as String? ?? '',
        announcementsVersion: json['announcements_version'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'generated_at': generatedAt,
        'guides_version': guidesVersion,
        'charts_version': chartsVersion,
        'announcements_version': announcementsVersion,
      };
}

class ContentGuide {
  const ContentGuide({
    required this.id,
    required this.title,
    required this.bodyMarkdown,
    required this.updatedAt,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String bodyMarkdown;
  final String updatedAt;
  final List<String> tags;

  factory ContentGuide.fromJson(Map<String, dynamic> json) => ContentGuide(
        id: json['id'] as String,
        title: json['title'] as String,
        bodyMarkdown: json['body_markdown'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body_markdown': bodyMarkdown,
        'updated_at': updatedAt,
        'tags': tags,
      };
}

class SyncBundle {
  const SyncBundle({
    required this.manifest,
    required this.guides,
    required this.fromCache,
  });

  final ContentManifest manifest;
  final List<ContentGuide> guides;
  final bool fromCache;
}

/// HTTP client for [docs/api/openapi.yaml] with disk cache, retry/backoff,
/// and offline fallback to the last successful bundle.
class ContentApiClient {
  ContentApiClient({
    http.Client? httpClient,
    this.baseUrl = kArcusApiBase,
    this.maxAttempts = 3,
    this.timeout = const Duration(seconds: 12),
    Directory? cacheDir,
  })  : _http = httpClient ?? http.Client(),
        _cacheDirOverride = cacheDir;

  final http.Client _http;
  final String baseUrl;
  final int maxAttempts;
  final Duration timeout;
  final Directory? _cacheDirOverride;

  static const _cacheFileName = 'arcus_content_cache_v1.json';

  Future<Directory> _cacheDir() async {
    final override = _cacheDirOverride;
    if (override != null) return override;
    return getApplicationSupportDirectory();
  }

  Future<File> _cacheFile() async {
    final dir = await _cacheDir();
    return File('${dir.path}/$_cacheFileName');
  }

  Future<SyncBundle> sync({String? since}) async {
    Object? lastError;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final manifest = await _getJson('/manifest', query: {
          if (since != null && since.isNotEmpty) 'since': since,
        });
        final guidesPayload = await _getJson('/guides', query: {
          if (since != null && since.isNotEmpty) 'updated_since': since,
        });
        final guides = ((guidesPayload['items'] as List?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(ContentGuide.fromJson)
            .toList();
        final bundle = SyncBundle(
          manifest: ContentManifest.fromJson(manifest),
          guides: guides,
          fromCache: false,
        );
        await _writeCache(bundle);
        return bundle;
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts - 1) {
          final delayMs = (250 * math.pow(2, attempt)).toInt();
          await Future<void>.delayed(Duration(milliseconds: delayMs));
        }
      }
    }

    final cached = await loadCache();
    if (cached != null) {
      return SyncBundle(
        manifest: cached.manifest,
        guides: cached.guides,
        fromCache: true,
      );
    }
    throw ContentApiException(
      'Sync failed and no offline cache is available: $lastError',
    );
  }

  Future<SyncBundle?> loadCache() async {
    try {
      final file = await _cacheFile();
      if (!await file.exists()) return null;
      final map = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final manifest = ContentManifest.fromJson(
        map['manifest'] as Map<String, dynamic>,
      );
      final guides = ((map['guides'] as List?) ?? [])
          .cast<Map<String, dynamic>>()
          .map(ContentGuide.fromJson)
          .toList();
      return SyncBundle(manifest: manifest, guides: guides, fromCache: true);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(SyncBundle bundle) async {
    final file = await _cacheFile();
    final payload = {
      'manifest': bundle.manifest.toJson(),
      'guides': bundle.guides.map((g) => g.toJson()).toList(),
    };
    await file.writeAsString(jsonEncode(payload));
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await _http.get(uri).timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ContentApiException(
        'HTTP ${response.statusCode} for $path',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ContentApiException('Expected JSON object from $path');
    }
    return decoded;
  }

  void close() => _http.close();
}

class ContentApiException implements Exception {
  ContentApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ContentApiException: $message';
}

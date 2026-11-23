import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_api_client.dart';

class SyncStatus {
  const SyncStatus({
    this.lastUpdatedLabel,
    this.message,
    this.fromCache = false,
    this.guideCount = 0,
    this.error,
  });

  final String? lastUpdatedLabel;
  final String? message;
  final bool fromCache;
  final int guideCount;
  final String? error;
}

class SyncStatusController extends StateNotifier<SyncStatus> {
  SyncStatusController({ContentApiClient? client})
      : _client = client ?? ContentApiClient(),
        super(const SyncStatus()) {
    _hydrateFromCache();
  }

  final ContentApiClient _client;

  Future<void> _hydrateFromCache() async {
    final cached = await _client.loadCache();
    if (cached == null) return;
    state = SyncStatus(
      lastUpdatedLabel: cached.manifest.generatedAt,
      message: 'Offline cache ready (${cached.guides.length} guides).',
      fromCache: true,
      guideCount: cached.guides.length,
    );
  }

  /// Pulls `/manifest` + `/guides` per OpenAPI; retries then falls back to cache.
  Future<void> refresh({String? since}) async {
    state = SyncStatus(
      lastUpdatedLabel: state.lastUpdatedLabel,
      message: 'Syncing…',
      fromCache: state.fromCache,
      guideCount: state.guideCount,
    );
    try {
      final bundle = await _client.sync(since: since);
      state = SyncStatus(
        lastUpdatedLabel: bundle.manifest.generatedAt,
        message: bundle.fromCache
            ? 'Using offline cache (network unavailable).'
            : 'Synced guides v${bundle.manifest.guidesVersion}.',
        fromCache: bundle.fromCache,
        guideCount: bundle.guides.length,
      );
    } catch (e) {
      state = SyncStatus(
        lastUpdatedLabel: state.lastUpdatedLabel,
        message: 'Sync unavailable — bundled offline content still works.',
        fromCache: state.fromCache,
        guideCount: state.guideCount,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusController, SyncStatus>(
  (ref) => SyncStatusController(),
);

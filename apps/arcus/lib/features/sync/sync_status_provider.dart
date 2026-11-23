import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncStatus {
  const SyncStatus({this.lastUpdatedLabel, this.message});
  final String? lastUpdatedLabel;
  final String? message;
}

class SyncStatusController extends StateNotifier<SyncStatus> {
  SyncStatusController() : super(const SyncStatus());

  /// Mock sync until the website implements docs/api/openapi.yaml.
  Future<void> refresh() async {
    state = const SyncStatus(message: 'Checking…');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = SyncStatus(
      lastUpdatedLabel: DateTime.now().toUtc().toIso8601String(),
      message: 'No remote updates (mock API). Bundled content unchanged.',
    );
  }
}

final syncStatusProvider =
    StateNotifierProvider<SyncStatusController, SyncStatus>(
  (ref) => SyncStatusController(),
);

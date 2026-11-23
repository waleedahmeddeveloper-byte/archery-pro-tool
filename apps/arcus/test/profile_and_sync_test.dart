import 'dart:io';

import 'package:arcus/features/profile/rig_profile.dart';
import 'package:arcus/features/sync/content_api_client.dart';
import 'package:archery_engine/archery_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RigProfileStore', () {
    test('save and load round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final store = RigProfileStore();
      final profile = RigProfile(
        name: 'Test Rig',
        bowType: BowType.compound,
        camStyle: CamStyle.aggressive,
        drawWeightPounds: 62,
        drawLengthInches: 28.5,
        iboFps: 330,
        letOffPercent: 80,
        gpi: 9.1,
        shaftLengthInches: 28,
        pointGrains: 125,
        insertGrains: 50,
        collarGrains: 0,
        nockGrains: 8,
        wrapGrains: 5,
        vaneGrainsEach: 6,
      );
      await store.save(profile);
      final loaded = await store.load();
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Test Rig');
      expect(loaded.camStyle, CamStyle.aggressive);
      expect(loaded.components.totalGrains, greaterThan(0));
      await store.clear();
      expect(await store.load(), isNull);
    });
  });

  group('ContentApiClient', () {
    test('success caches and returns guides', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_cache_');
      var calls = 0;
      final client = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        httpClient: MockClient((request) async {
          calls++;
          if (request.url.path.endsWith('/manifest')) {
            return http.Response(
              '{"generated_at":"2026-01-01T00:00:00Z","guides_version":"1","charts_version":"1","announcements_version":"1"}',
              200,
            );
          }
          return http.Response(
            '{"items":[{"id":"g1","title":"Guide","body_markdown":"Hi","updated_at":"2026-01-01T00:00:00Z","tags":["foc"]}]}',
            200,
          );
        }),
      );

      final bundle = await client.sync();
      expect(bundle.fromCache, isFalse);
      expect(bundle.guides, hasLength(1));
      expect(calls, 2);

      final cached = await client.loadCache();
      expect(cached, isNotNull);
      expect(cached!.guides.first.title, 'Guide');
      client.close();
      await dir.delete(recursive: true);
    });

    test('retries then falls back to cache', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_cache2_');
      // Seed cache
      final seed = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/manifest')) {
            return http.Response(
              '{"generated_at":"t","guides_version":"1","charts_version":"1","announcements_version":"1"}',
              200,
            );
          }
          return http.Response(
            '{"items":[{"id":"c","title":"Cached","body_markdown":"x","updated_at":"t"}]}',
            200,
          );
        }),
      );
      await seed.sync();
      seed.close();

      final failing = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        maxAttempts: 2,
        httpClient: MockClient((request) async {
          return http.Response('nope', 500);
        }),
      );
      final bundle = await failing.sync();
      expect(bundle.fromCache, isTrue);
      expect(bundle.guides.first.title, 'Cached');
      failing.close();
      await dir.delete(recursive: true);
    });
  });
}

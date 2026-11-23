import 'dart:io';

import 'package:arcus/app.dart';
import 'package:arcus/core/ads/ad_service.dart';
import 'package:arcus/core/l10n/app_strings.dart';
import 'package:arcus/core/router/onboarding_gate.dart';
import 'package:arcus/core/theme/theme_mode_provider.dart';
import 'package:arcus/features/calculators/generic_calculator_page.dart';
import 'package:arcus/features/calculators/widgets/foc_visual.dart';
import 'package:arcus/features/catalog/calculator_catalog.dart';
import 'package:arcus/features/assistant/setup_assistant_page.dart';
import 'package:arcus/features/home/calculators_tab.dart';
import 'package:arcus/features/home/home_tab.dart';
import 'package:arcus/features/home/library_tab.dart';
import 'package:arcus/features/home/more_tab.dart';
import 'package:arcus/features/legal/privacy_page.dart';
import 'package:arcus/features/legal/terms_page.dart';
import 'package:arcus/features/profile/rig_profile.dart';
import 'package:arcus/features/sync/content_api_client.dart';
import 'package:arcus/features/sync/sync_status_provider.dart';
import 'package:archery_engine/archery_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    OnboardingGate.resetCacheForTests();
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
  });

  test('ads remain disabled (no in-app installer download)', () async {
    expect(AdService.adsEnabled, isFalse);
    await AdService.instance.initialize();
    expect(AdService.instance.isReady, isFalse);
    expect(AdService.instance.bannerAdUnitId, contains('ca-app-pub'));
  });

  test('catalog exposes categories and byId', () {
    expect(CalculatorCatalog.items, isNotEmpty);
    expect(CalculatorCatalog.byId('foc'), isNotNull);
    expect(CalculatorCatalog.byId('missing'), isNull);
    for (final c in CalculatorCategory.values) {
      expect(CalculatorCatalog.categoryLabel(c), isNotEmpty);
    }
  });

  group('RigProfileStore', () {
    test('corrupt JSON returns null; defaults fill optional fields', () async {
      SharedPreferences.setMockInitialValues({
        RigProfileStore.prefsKey: '{not-json',
      });
      expect(await RigProfileStore().load(), isNull);

      final profile = RigProfile.fromJson({
        'name': 'Minimal',
        'bowType': 'recurve',
        'camStyle': 'soft',
        'drawWeightPounds': 40,
        'drawLengthInches': 28,
        'iboFps': 180,
        'gpi': 8,
        'shaftLengthInches': 29,
        'pointGrains': 100,
      });
      expect(profile.bowType, BowType.recurve);
      expect(profile.camStyle, CamStyle.soft);
      expect(profile.vaneCount, 3);
      expect(profile.insertGrains, 0);
    });
  });

  group('content download / sync offline', () {
    test('sync throws when network fails and cache empty', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_empty_');
      final client = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        maxAttempts: 1,
        httpClient: MockClient((_) async => http.Response('down', 503)),
      );
      expect(() => client.sync(), throwsA(isA<ContentApiException>()));
      client.close();
      await dir.delete(recursive: true);
    });

    test('loadCache returns null for corrupt file', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_bad_');
      await File('${dir.path}/arcus_content_cache_v1.json')
          .writeAsString('not-json');
      final client = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );
      expect(await client.loadCache(), isNull);
      client.close();
      await dir.delete(recursive: true);
    });

    test('SyncStatusController refresh success and offline fallback', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_sync_ui_');
      final ok = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        httpClient: MockClient((request) async {
          if (request.url.path.endsWith('/manifest')) {
            return http.Response(
              '{"generated_at":"t","guides_version":"9","charts_version":"1","announcements_version":"1"}',
              200,
            );
          }
          return http.Response(
            '{"items":[{"id":"g","title":"T","body_markdown":"b","updated_at":"t"}]}',
            200,
          );
        }),
      );
      final ctrl = SyncStatusController(client: ok);
      await ctrl.refresh();
      expect(ctrl.state.message, contains('Synced guides v9'));
      expect(ctrl.state.fromCache, isFalse);
      ctrl.dispose();

      final offline = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        maxAttempts: 1,
        httpClient: MockClient((_) async => http.Response('x', 500)),
      );
      final ctrl2 = SyncStatusController(client: offline);
      await Future<void>.delayed(Duration.zero);
      await ctrl2.refresh();
      expect(ctrl2.state.fromCache, isTrue);
      expect(ctrl2.state.message, contains('offline cache'));
      ctrl2.dispose();
      await dir.delete(recursive: true);
    });

    test('SyncStatusController surfaces hard failure message', () async {
      final dir = await Directory.systemTemp.createTemp('arcus_sync_fail_');
      final client = ContentApiClient(
        baseUrl: 'https://example.test/v1',
        cacheDir: dir,
        maxAttempts: 1,
        httpClient: MockClient((_) async => http.Response('x', 500)),
      );
      final ctrl = SyncStatusController(client: client);
      await ctrl.refresh();
      expect(ctrl.state.error, isNotNull);
      expect(ctrl.state.message, contains('bundled offline'));
      ctrl.dispose();
      await dir.delete(recursive: true);
    });
  });

  testWidgets('theme mode controller persists', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final c = ThemeModeController();
    await c.setMode(ThemeMode.dark);
    expect(c.state, ThemeMode.dark);
    await c.setMode(ThemeMode.light);
    expect(c.state, ThemeMode.light);
    await c.setMode(ThemeMode.system);
    expect(c.state, ThemeMode.system);
  });

  testWidgets('search filters catalog and empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CalculatorsTab()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculators-list')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('calculators-search')), 'FOC');
    await tester.pumpAndSettle();
    expect(find.text('FOC (measured)'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('calculators-search')),
      'zzzz-none',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('No tools match'), findsOneWidget);
  });

  testWidgets('home tab with go_router', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeTab()),
        GoRoute(
          path: '/assistant',
          builder: (_, __) => const Scaffold(body: Text('assistant-page')),
        ),
        GoRoute(
          path: '/calc/:id',
          builder: (_, s) =>
              Scaffold(body: Text('calc-${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('Featured tools'), findsOneWidget);
    expect(find.text('Setup Assistant'), findsOneWidget);
    await tester.ensureVisible(find.text('Start guided setup'));
    await tester.tap(find.text('Start guided setup'), warnIfMissed: false);
    await tester.pumpAndSettle();
    // Featured FOC tile also exercises navigation.
    router.go('/');
    await tester.pumpAndSettle();
    await tester.tap(find.text('FOC (measured)').first);
    await tester.pumpAndSettle();
    expect(find.text('calc-foc'), findsOneWidget);
  });

  testWidgets('library privacy terms more settings', (tester) async {
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
    final router = GoRouter(
      initialLocation: '/more',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SizedBox()),
        GoRoute(path: '/more', builder: (_, __) => const MoreTab()),
        GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPage()),
        GoRoute(path: '/terms', builder: (_, __) => const TermsPage()),
        GoRoute(path: '/library', builder: (_, __) => const LibraryTab()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Content sync'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<ThemeMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark navy').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('offline-first'), findsOneWidget);

    router.go('/terms');
    await tester.pumpAndSettle();
    expect(find.textContaining('planning estimates'), findsWidgets);

    router.go('/library');
    await tester.pumpAndSettle();
    expect(find.textContaining('Measuring FOC'), findsOneWidget);
    await tester.tap(find.textContaining('Measuring FOC').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('AMO front-of-center'), findsOneWidget);
  });

  testWidgets('text scale 200% calculators and home remain usable',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: const MaterialApp(home: CalculatorsTab()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calculators-search')), findsOneWidget);
    expect(find.textContaining('Arrow'), findsWidgets);

    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeTab()),
        GoRoute(path: '/assistant', builder: (_, __) => const SizedBox()),
        GoRoute(
          path: '/calc/:id',
          builder: (_, __) => const SizedBox(),
        ),
      ],
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.appName), findsWidgets);
  });

  testWidgets('FOC visual semantics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FocVisual(
            lengthInches: 29,
            balanceInches: 18,
            focPercent: 12.5,
          ),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('Arrow front-of-center')),
      findsOneWidget,
    );
  });

  testWidgets('onboarding skip then more sync offline path', (tester) async {
    SharedPreferences.setMockInitialValues({});
    OnboardingGate.resetCacheForTests();
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();
    expect(find.text('Featured tools'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    expect(find.text('Content sync'), findsOneWidget);
  });

  testWidgets('Setup Assistant steps save profile', (tester) async {
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
    final router = GoRouter(
      initialLocation: '/assistant',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('home'))),
        GoRoute(
          path: '/assistant',
          builder: (_, __) => const SetupAssistantPage(),
        ),
        GoRoute(
          path: '/calc/:id',
          builder: (_, __) => const Scaffold(body: Text('calc')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.textContaining('1. Bow'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2. Arrow'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('3. Components'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('4. Performance'), findsOneWidget);
    await tester.tap(find.text('Calculate performance'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Total weight:'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('5. Results'), findsOneWidget);
    await tester.tap(find.text('Save profile').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Saved profile'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
  });

  testWidgets('converter kinds cover all branches', (tester) async {
    for (final kind in [
      'weight',
      'length',
      'speed',
      'energy',
      'angle',
      'distance',
      'bad',
    ]) {
      await tester.pumpWidget(
        const MaterialApp(home: GenericCalculatorPage(calcId: 'converter')),
      );
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.first, kind);
      await tester.ensureVisible(find.text(AppStrings.calculate));
      await tester.tap(find.text(AppStrings.calculate));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('exercise every catalog calculator Calculate/Reset',
      (tester) async {
    for (final item in CalculatorCatalog.items) {
      await tester.pumpWidget(
        MaterialApp(home: GenericCalculatorPage(calcId: item.id)),
      );
      await tester.pump();
      if (find.textContaining('Unknown calculator').evaluate().isNotEmpty) {
        fail('Unknown calculator ${item.id}');
      }
      final calc = find.text(AppStrings.calculate);
      if (calc.evaluate().isEmpty) continue;
      await tester.ensureVisible(calc.first);
      await tester.tap(calc.first, warnIfMissed: false);
      await tester.pump();
      final reset = find.text(AppStrings.reset);
      if (reset.evaluate().isNotEmpty) {
        await tester.ensureVisible(reset.first);
        await tester.tap(reset.first, warnIfMissed: false);
        await tester.pump();
      }
    }
  });
}

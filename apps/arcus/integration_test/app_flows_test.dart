import 'package:arcus/app.dart';
import 'package:arcus/core/l10n/app_strings.dart';
import 'package:arcus/core/router/onboarding_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _finishOnboarding(WidgetTester tester) async {
  // Three pages: Continue, Continue, Get started — or Skip.
  for (var i = 0; i < 5; i++) {
    await tester.pumpAndSettle();
    if (find.text('Featured tools').evaluate().isNotEmpty) return;
    if (find.text(AppStrings.skip).evaluate().isNotEmpty &&
        find.text('Featured tools').evaluate().isEmpty &&
        i == 0) {
      // prefer walking through once when testing onboarding explicitly
    }
    if (find.text('Continue').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      continue;
    }
    if (find.text(AppStrings.getStarted).evaluate().isNotEmpty) {
      await tester.tap(find.text(AppStrings.getStarted));
      await tester.pumpAndSettle();
      return;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    OnboardingGate.resetCacheForTests();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('onboarding then offline home launch', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Build with confidence'), findsOneWidget);
    await _finishOnboarding(tester);
    expect(find.text('Featured tools'), findsOneWidget);
    expect(find.text('Setup Assistant'), findsOneWidget);
  });

  testWidgets('skip onboarding reaches home offline', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.skip));
    await tester.pumpAndSettle();
    expect(find.text('Setup Assistant'), findsOneWidget);
    expect(find.text('Featured tools'), findsOneWidget);
  });

  testWidgets('Setup Assistant 5 steps + save/load profile', (tester) async {
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
    OnboardingGate.resetCacheForTests();
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.navAssistant));
    await tester.pumpAndSettle();
    expect(find.text('Setup Assistant'), findsOneWidget);
    expect(find.textContaining('1. Bow'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'IT Rig');
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

  testWidgets('search and one calculator per category', (tester) async {
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
    OnboardingGate.resetCacheForTests();
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();

    Future<void> openCalculatorsTab() async {
      final outlined = find.byIcon(Icons.calculate_outlined);
      if (outlined.evaluate().isNotEmpty) {
        await tester.tap(outlined.first);
        await tester.pumpAndSettle();
      }
    }

    Future<void> searchTools(String query) async {
      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, query);
      await tester.pumpAndSettle();
    }

    await openCalculatorsTab();
    expect(find.byType(TextField), findsWidgets);

    await searchTools('zzzz-no-match');
    expect(find.textContaining('No tools match'), findsOneWidget);

    // Category smoke: search tokens that uniquely hit each category.
    final samples = <String, String>{
      'FOC': 'FOC (measured)',
      'Draw Length': 'Draw Length',
      'Kinetic Energy &': 'Kinetic Energy & Momentum',
      'Arrow Spine': 'Arrow Spine',
      'Crossbow Speed': 'Crossbow Speed',
      'Unit Converter': 'Unit Converter',
    };

    for (final e in samples.entries) {
      await openCalculatorsTab();
      await searchTools(e.key);
      expect(find.text(e.value), findsWidgets);
      await tester.tap(find.text(e.value).first);
      await tester.pumpAndSettle();
      expect(find.text(e.value), findsWidgets);
      final backBtn = find.byType(BackButton);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn.first);
        await tester.pumpAndSettle();
      }
    }
  });
}

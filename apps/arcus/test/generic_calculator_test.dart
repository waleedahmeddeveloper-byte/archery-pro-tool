import 'package:arcus/core/l10n/app_strings.dart';
import 'package:arcus/core/router/onboarding_gate.dart';
import 'package:arcus/features/calculators/generic_calculator_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    OnboardingGate.resetCacheForTests();
    SharedPreferences.setMockInitialValues({OnboardingGate.prefsKey: true});
  });

  testWidgets('FOC calculator validate calculate reset error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GenericCalculatorPage(calcId: 'foc')),
    );
    await tester.pumpAndSettle();

    expect(find.text('FOC (measured)'), findsOneWidget);
    expect(find.text(AppStrings.calculate), findsOneWidget);

    await tester.tap(find.text(AppStrings.calculate));
    await tester.pumpAndSettle();
    expect(find.textContaining('% FOC'), findsWidgets);

    // Force invalid length
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '0');
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pumpAndSettle();
    expect(find.textContaining('must be'), findsOneWidget);

    await tester.tap(find.text(AppStrings.reset));
    await tester.pumpAndSettle();

    // Recalculate then exercise Copy on the result breakdown.
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.copy), findsWidgets);
    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('GPP invalid draw weight shows error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GenericCalculatorPage(calcId: 'gpp')),
    );
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '0');
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pumpAndSettle();
    expect(find.textContaining('must be'), findsOneWidget);
  });

  testWidgets('unknown calculator id', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GenericCalculatorPage(calcId: 'no-such-tool')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Unknown calculator'), findsOneWidget);
  });
}

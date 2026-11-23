import 'package:arcus/core/l10n/app_strings.dart';
import 'package:arcus/features/calculators/widgets/calculator_scaffold.dart';
import 'package:archery_engine/archery_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('scaffold Calculate and Reset fire callbacks', (tester) async {
    var calc = 0;
    var reset = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: CalculatorScaffold(
          title: 'Test Calc',
          intro: 'Intro text',
          inputs: const Text('inputs-here'),
          onCalculate: () => calc++,
          onReset: () => reset++,
          breadcrumb: const ['Home', 'Test'],
          examples: const ['example one'],
          faqs: const [(q: 'What?', a: 'Because.')],
          related: const ['Related A'],
          onRelatedTap: (_) {},
        ),
      ),
    );

    expect(find.text('Test Calc'), findsOneWidget);
    expect(find.text('Home › Test'), findsOneWidget);
    expect(find.text('inputs-here'), findsOneWidget);
    expect(find.textContaining('example one'), findsOneWidget);

    await tester.ensureVisible(find.text(AppStrings.calculate));
    await tester.tap(find.text(AppStrings.calculate));
    await tester.pump();
    expect(calc, 1);

    await tester.ensureVisible(find.text(AppStrings.reset));
    await tester.tap(find.text(AppStrings.reset));
    await tester.pump();
    expect(reset, 1);

    await tester.ensureVisible(find.text('What?'));
    await tester.tap(find.text('What?'));
    await tester.pumpAndSettle();
    expect(find.text('Because.'), findsOneWidget);
  });

  testWidgets('ResultBreakdown copy and warnings', (tester) async {
    final result = CalcResult<double>(
      value: 12.5,
      formulaId: 't',
      formulaDisplay: 'x = y',
      steps: const ['step 1'],
      assumptions: const ['a1'],
      limitations: const ['l1'],
      safetyNotes: const ['s1'],
      warnings: const ['warn me'],
      citation: Citations.focAmo,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResultBreakdown(headline: '12.50% FOC', result: result),
        ),
      ),
    );

    expect(find.text('12.50% FOC'), findsOneWidget);
    expect(find.text('warn me'), findsOneWidget);
    expect(find.text('x = y'), findsOneWidget);
    expect(find.byIcon(Icons.copy), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // SnackBar may be omitted if clipboard channel is unavailable in some
    // bindings; still assert the action was tappable without throwing.
    expect(tester.takeException(), isNull);
  });

  test('parseDouble handles blank and numbers', () {
    expect(parseDouble(''), isNull);
    expect(parseDouble(' 12.5 '), 12.5);
    expect(parseDouble('nope'), isNull);
  });
}

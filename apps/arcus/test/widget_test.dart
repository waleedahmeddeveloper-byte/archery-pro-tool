import 'package:arcus/app.dart';
import 'package:arcus/core/router/onboarding_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    OnboardingGate.resetCacheForTests();
  });

  testWidgets('Arcus loads onboarding when unseen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: ArcusApp()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Build with confidence'), findsOneWidget);
  });
}

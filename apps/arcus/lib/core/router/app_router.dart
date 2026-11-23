import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/setup_assistant_page.dart';
import '../../features/calculators/generic_calculator_page.dart';
import '../../features/home/calculators_tab.dart';
import '../../features/home/home_tab.dart';
import '../../features/home/library_tab.dart';
import '../../features/home/more_tab.dart';
import '../../features/home/shell_scaffold.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/legal/privacy_page.dart';
import '../../features/legal/terms_page.dart';
import 'onboarding_gate.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final seen = await OnboardingGate.hasSeen();
      final onOnboarding = state.matchedLocation == '/onboarding';
      if (!seen && !onOnboarding) return '/onboarding';
      if (seen && onOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calculators',
                builder: (context, state) => const CalculatorsTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const SetupAssistantPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreTab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/calc/:id',
        builder: (context, state) => GenericCalculatorPage(
          calcId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPage()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsPage()),
    ],
  );
});

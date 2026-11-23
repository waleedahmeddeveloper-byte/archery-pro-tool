import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/assistant/setup_assistant_page.dart';
import '../../features/calculators/arrow_weight_page.dart';
import '../../features/calculators/converter_page.dart';
import '../../features/calculators/draw_length_page.dart';
import '../../features/calculators/drop_page.dart';
import '../../features/calculators/foc_page.dart';
import '../../features/calculators/ibo_speed_page.dart';
import '../../features/calculators/ke_momentum_page.dart';
import '../../features/calculators/shot_angle_page.dart';
import '../../features/calculators/speed_mass_page.dart';
import '../../features/calculators/spine_page.dart';
import '../../features/home/calculators_tab.dart';
import '../../features/home/home_tab.dart';
import '../../features/home/library_tab.dart';
import '../../features/home/more_tab.dart';
import '../../features/home/shell_scaffold.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/legal/privacy_page.dart';
import '../../features/legal/terms_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('arcus_onboarding_seen') ?? false;
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
      GoRoute(path: '/calc/foc', builder: (_, __) => const FocPage()),
      GoRoute(
        path: '/calc/arrow-weight',
        builder: (_, __) => const ArrowWeightPage(),
      ),
      GoRoute(
        path: '/calc/ke-momentum',
        builder: (_, __) => const KeMomentumPage(),
      ),
      GoRoute(
        path: '/calc/speed-mass',
        builder: (_, __) => const SpeedMassPage(),
      ),
      GoRoute(
        path: '/calc/ibo-speed',
        builder: (_, __) => const IboSpeedPage(),
      ),
      GoRoute(path: '/calc/spine', builder: (_, __) => const SpinePage()),
      GoRoute(path: '/calc/drop', builder: (_, __) => const DropPage()),
      GoRoute(
        path: '/calc/draw-length',
        builder: (_, __) => const DrawLengthPage(),
      ),
      GoRoute(
        path: '/calc/shot-angle',
        builder: (_, __) => const ShotAnglePage(),
      ),
      GoRoute(
        path: '/calc/converter',
        builder: (_, __) => const ConverterPage(),
      ),
      GoRoute(path: '/privacy', builder: (_, __) => const PrivacyPage()),
      GoRoute(path: '/terms', builder: (_, __) => const TermsPage()),
    ],
  );
});

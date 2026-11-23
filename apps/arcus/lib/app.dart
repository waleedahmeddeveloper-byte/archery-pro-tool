import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/arcus_theme.dart';
import 'core/theme/theme_mode_provider.dart';

class ArcusApp extends ConsumerWidget {
  const ArcusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ArcusTheme.light(),
      darkTheme: ArcusTheme.darkNavy(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

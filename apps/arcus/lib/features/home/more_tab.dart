import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_mode_provider.dart';
import '../sync/sync_status_provider.dart';

class MoreTab extends ConsumerWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final sync = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Appearance'),
            subtitle: Text(switch (themeMode) {
              ThemeMode.light => 'Light',
              ThemeMode.dark => 'Dark navy',
              ThemeMode.system => 'System default',
            }),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark navy')),
              ],
              onChanged: (m) {
                if (m != null) {
                  ref.read(themeModeProvider.notifier).setMode(m);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Content sync'),
            subtitle: Text(
              [
                sync.message ?? 'Using bundled offline content',
                if (sync.lastUpdatedLabel != null) 'Updated ${sync.lastUpdatedLabel}',
                if (sync.error != null) sync.error!,
              ].join('\n'),
            ),
            isThreeLine: true,
            trailing: TextButton(
              onPressed: () => ref.read(syncStatusProvider.notifier).refresh(),
              child: const Text('Refresh'),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy policy'),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            title: const Text('Terms of use'),
            onTap: () => context.push('/terms'),
          ),
          const ListTile(
            title: Text('About Arcus'),
            subtitle: Text(
              'Offline-first archery calculators with cited formulas. Ads are disabled until you supply AdMob IDs.',
            ),
          ),
        ],
      ),
    );
  }
}

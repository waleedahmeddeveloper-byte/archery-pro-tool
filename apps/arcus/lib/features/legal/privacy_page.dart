import 'package:material_ui/material_ui.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text('''
Arcus is designed offline-first. Calculator inputs and saved rig profiles stay on your device (SharedPreferences / local storage). There is no cloud account for core calculators.

Optional content sync may fetch non-personal guides and charts from an Arcus HTTPS content API (`ARCUS_API_BASE`). Responses are cached on-device for offline use. Sync does not upload your calculator inputs or profiles.

Advertising is disabled by default. If enabled later via AdMob, a consent (UMP/GDPR/ATT) flow will be shown before personalized ads. Analytics/crash reporting hooks may be added later and will be disclosed here before shipping.

APK / app updates are distributed outside the app (store or documented download page) — the app does not download installers.

Contact the developer for data requests related to any optional sync account once that feature exists.
'''),
      ),
    );
  }
}

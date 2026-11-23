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
Arcus is designed offline-first. Calculator inputs stay on your device (theme preference uses local storage). There is no cloud account for core calculators.

Optional content sync is not live yet; when enabled later, the app may fetch non-personal guides/charts from an Arcus content API.

Advertising is disabled by default. If enabled later via AdMob, a consent (UMP/GDPR/ATT) flow will be shown before personalized ads. Analytics/crash reporting hooks may be added later and will be disclosed here before shipping.

Contact the developer for data requests related to any optional sync account once that feature exists.
'''),
      ),
    );
  }
}

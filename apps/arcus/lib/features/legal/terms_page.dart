import 'package:material_ui/material_ui.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of use')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text('''
Arcus provides planning estimates for archery setups. Results are not a substitute for manufacturer specifications, chronograph measurements, or professional bow technician services.

You are responsible for inspecting equipment, following local hunting regulations, and verifying every setup with live fire before hunting or competition.

Arcus is not affiliated with Easton, Gold Tip, Victory, Black Eagle, Carbon Express, or other manufacturers referenced only for publicly documented standards and selection guidance.
'''),
      ),
    );
  }
}

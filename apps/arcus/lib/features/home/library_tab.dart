import 'package:material_ui/material_ui.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  static const _guides = <_Guide>[
    _Guide(
      title: 'Measuring FOC the AMO way',
      blurb: 'Balance point, shaft length, and common errors.',
      body: '''
AMO front-of-center uses a finished arrow.

1. Measure shaft length L from nock throat to the end of the shaft (not the tip of the point).
2. Find the balance point A from the same nock throat reference.
3. FOC% = 100 × (A − L/2) / L.

Common mistakes: measuring to the tip of the broadhead, balancing without the point installed, or mixing component-estimate FOC with a measured claim.

Use the measured FOC calculator for hunting claims. The component estimate is for planning only.
''',
    ),
    _Guide(
      title: 'Kinetic energy vs momentum',
      blurb: 'Why hunters look at both numbers.',
      body: '''
Kinetic energy (ft-lb) = grains × fps² ÷ 450240.
Momentum (slug·ft/s) = grains × fps ÷ 225218.

KE rises with the square of speed; momentum scales linearly with speed. Heavier arrows often keep more momentum for a given bow energy. Neither number replaces shot placement, broadhead design, or ethical range limits.

Always prefer chronographed speed and a weighed arrow over IBO-based estimates.
''',
    ),
    _Guide(
      title: 'Spine is a starting point',
      blurb: 'Static charts vs dynamic tune.',
      body: '''
Static spine is a laboratory deflection number. Dynamic behavior depends on draw weight, arrow length, tip mass, cam aggressiveness, and release style.

Arcus planning charts adjust effective weight for length, tip, and cam, then suggest a spine class. Confirm with the shaft manufacturer’s current chart and finish with paper or bare-shaft tuning.
''',
    ),
    _Guide(
      title: 'IBO is not your hunting speed',
      blurb: 'How ratings are defined and why chronographs win.',
      body: '''
IBO/ATA ratings are laboratory baselines (commonly 70 lb / 30 in / 350 gr). Your hunting setup almost never matches that baseline.

Arcus scales an energy model from the published rating to your draw weight, draw length, and arrow mass. Treat the result as an estimate with labeled assumptions — never as a chronograph substitute.
''',
    ),
    _Guide(
      title: 'Safety before the season',
      blurb: 'Minimum arrow mass, inspection, and broadhead tune.',
      body: '''
Many compounds specify a minimum grains-per-pound (often ~5 gpp). Crossbows list a minimum bolt weight in the owner’s manual — that number wins every time.

Inspect shafts for cracks, nocks for wear, and vanes for tear. Broadhead-tune before the season. Do not invent “safe” lighter setups for speed.
''',
    ),
    _Guide(
      title: 'Crossbow bolt basics',
      blurb: 'Rated speed, mass, and dry-fire risk.',
      body: '''
Crossbow speed ratings assume a stated bolt mass. Scaling speed with √(rated mass / your mass) is a constant-energy estimate only.

Never shoot below the manufacturer’s minimum bolt weight. Dry-fire and underweight bolts can destroy the bow and injure the shooter.
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _guides.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Original offline guides. Formulas show citations and limitations inside each calculator.',
              style: Theme.of(context).textTheme.bodyMedium,
            );
          }
          final g = _guides[index - 1];
          return Card(
            child: ListTile(
              title: Text(g.title),
              subtitle: Text(g.blurb),
              leading: const Icon(Icons.article_outlined),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _GuideDetailPage(guide: g),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Guide {
  const _Guide({
    required this.title,
    required this.blurb,
    required this.body,
  });

  final String title;
  final String blurb;
  final String body;
}

class _GuideDetailPage extends StatelessWidget {
  const _GuideDetailPage({required this.guide});

  final _Guide guide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guide.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(guide.blurb, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Text(guide.body.trim()),
        ],
      ),
    );
  }
}

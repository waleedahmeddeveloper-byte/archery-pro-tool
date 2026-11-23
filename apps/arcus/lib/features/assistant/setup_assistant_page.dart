import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class SetupAssistantPage extends StatefulWidget {
  const SetupAssistantPage({super.key});

  @override
  State<SetupAssistantPage> createState() => _SetupAssistantPageState();
}

class _SetupAssistantPageState extends State<SetupAssistantPage> {
  final _page = PageController();
  int _step = 0;

  BowType bowType = BowType.compound;
  final drawWeight = TextEditingController(text: '60');
  final drawLength = TextEditingController(text: '28');
  final ibo = TextEditingController(text: '335');
  final gpi = TextEditingController(text: '8.5');
  final shaftLen = TextEditingController(text: '28');
  final point = TextEditingController(text: '125');
  final insert = TextEditingController(text: '50');
  final nock = TextEditingController(text: '8');
  final vane = TextEditingController(text: '6');
  String summary = '';

  final engine = const ArcheryEngine();

  void _buildSummary() {
    final components = ArrowComponents(
      gpi: double.parse(gpi.text),
      shaftLengthInches: double.parse(shaftLen.text),
      pointGrains: double.parse(point.text),
      insertGrains: double.parse(insert.text),
      nockGrains: double.parse(nock.text),
      vaneGrainsEach: double.parse(vane.text),
      vaneCount: 3,
    );
    final weight = engine.arrowWeight(
      components: components,
      drawWeightPounds: double.parse(drawWeight.text),
    );
    final foc = engine.focFromComponents(components: components);
    final speed = engine.speedFromIbo(
      iboFps: double.parse(ibo.text),
      drawWeightPounds: double.parse(drawWeight.text),
      drawLengthInches: double.parse(drawLength.text),
      arrowWeightGrains: weight.value.totalGrains,
    );
    final energy = engine.energyMomentum(
      arrowWeightGrains: weight.value.totalGrains,
      speedFps: speed.value.estimatedFps,
    );
    final spine = engine.spine(
      bowType: bowType,
      drawWeightPounds: double.parse(drawWeight.text),
      arrowLengthInches: double.parse(shaftLen.text),
      pointWeightGrains: double.parse(point.text),
    );

    setState(() {
      summary = '''
Total weight: ${weight.value.totalGrains.toStringAsFixed(1)} gr
GPP: ${weight.value.grainsPerPound?.toStringAsFixed(2)}
FOC (component estimate): ${foc.value.focPercent.toStringAsFixed(1)}%
Estimated speed: ${speed.value.estimatedFps.toStringAsFixed(1)} fps
KE: ${energy.value.keFtLb.toStringAsFixed(1)} ft-lb
Momentum: ${energy.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s
Planning spine: ${spine.value.primarySpine} (${spine.value.chartName})

Assumptions: IBO→speed is an estimate; FOC here is component-based — measure balance point before hunting.
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Assistant')),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_step + 1) / 5),
          Expanded(
            child: PageView(
              controller: _page,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepCard(
                  '1. Bow configuration',
                  Column(
                    children: [
                      DropdownButtonFormField<BowType>(
                        initialValue: bowType,
                        items: const [
                          DropdownMenuItem(value: BowType.compound, child: Text('Compound')),
                          DropdownMenuItem(value: BowType.recurve, child: Text('Recurve')),
                          DropdownMenuItem(value: BowType.traditional, child: Text('Traditional')),
                        ],
                        onChanged: (v) => setState(() => bowType = v ?? BowType.compound),
                        decoration: const InputDecoration(labelText: 'Bow type'),
                      ),
                      TextField(controller: drawWeight, decoration: const InputDecoration(labelText: 'Draw weight (lb)')),
                      TextField(controller: drawLength, decoration: const InputDecoration(labelText: 'Draw length (in)')),
                      TextField(controller: ibo, decoration: const InputDecoration(labelText: 'IBO rating (fps)')),
                    ],
                  ),
                ),
                _stepCard(
                  '2. Arrow shaft',
                  Column(
                    children: [
                      TextField(controller: gpi, decoration: const InputDecoration(labelText: 'GPI')),
                      TextField(controller: shaftLen, decoration: const InputDecoration(labelText: 'Shaft length (in)')),
                      TextField(controller: point, decoration: const InputDecoration(labelText: 'Point weight (gr)')),
                    ],
                  ),
                ),
                _stepCard(
                  '3. Components',
                  Column(
                    children: [
                      TextField(controller: insert, decoration: const InputDecoration(labelText: 'Insert (gr)')),
                      TextField(controller: nock, decoration: const InputDecoration(labelText: 'Nock (gr)')),
                      TextField(controller: vane, decoration: const InputDecoration(labelText: 'Vane each (gr) ×3')),
                    ],
                  ),
                ),
                _stepCard(
                  '4. Review',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tap Calculate performance to run the engine across weight, FOC estimate, speed, KE, momentum, and spine.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _buildSummary,
                        child: const Text('Calculate performance'),
                      ),
                      const SizedBox(height: 12),
                      Text(summary),
                    ],
                  ),
                ),
                _stepCard(
                  '5. Next actions',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Deep-link into detailed calculators with this profile mindset:'),
                      TextButton(onPressed: () => context.push('/calc/foc'), child: const Text('Measure FOC')),
                      TextButton(onPressed: () => context.push('/calc/drop'), child: const Text('Plan sight marks')),
                      TextButton(onPressed: () => context.push('/calc/spine'), child: const Text('Recheck spine')),
                      const SizedBox(height: 8),
                      const Text(
                        'Estimates only. Chronograph speed and bare-shaft tune before hunting or competition.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_step > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _step--);
                      _page.jumpToPage(_step);
                    },
                    child: const Text('Back'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    if (_step < 4) {
                      setState(() => _step++);
                      _page.jumpToPage(_step);
                    }
                  },
                  child: Text(_step < 4 ? 'Next' : 'Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(String title, Widget child) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

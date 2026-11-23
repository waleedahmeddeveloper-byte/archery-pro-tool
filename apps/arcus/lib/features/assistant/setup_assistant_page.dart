import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../profile/rig_profile.dart';

class SetupAssistantPage extends StatefulWidget {
  const SetupAssistantPage({super.key});

  @override
  State<SetupAssistantPage> createState() => _SetupAssistantPageState();
}

class _SetupAssistantPageState extends State<SetupAssistantPage> {
  final _page = PageController();
  final _store = RigProfileStore();
  int _step = 0;

  BowType bowType = BowType.compound;
  CamStyle camStyle = CamStyle.standard;
  final profileName = TextEditingController(text: 'Hunting rig');
  final drawWeight = TextEditingController(text: '60');
  final drawLength = TextEditingController(text: '28');
  final ibo = TextEditingController(text: '335');
  final letOff = TextEditingController(text: '80');
  final gpi = TextEditingController(text: '8.5');
  final shaftLen = TextEditingController(text: '28');
  final point = TextEditingController(text: '125');
  final insert = TextEditingController(text: '50');
  final collar = TextEditingController(text: '0');
  final nock = TextEditingController(text: '8');
  final wrap = TextEditingController(text: '5');
  final vane = TextEditingController(text: '6');
  String summary = '';
  String? error;
  String? profileStatus;

  final engine = const ArcheryEngine();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _page.dispose();
    profileName.dispose();
    drawWeight.dispose();
    drawLength.dispose();
    ibo.dispose();
    letOff.dispose();
    gpi.dispose();
    shaftLen.dispose();
    point.dispose();
    insert.dispose();
    collar.dispose();
    nock.dispose();
    wrap.dispose();
    vane.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final p = await _store.load();
    if (p == null || !mounted) return;
    setState(() {
      profileName.text = p.name;
      bowType = p.bowType;
      camStyle = p.camStyle;
      drawWeight.text = p.drawWeightPounds.toString();
      drawLength.text = p.drawLengthInches.toString();
      ibo.text = p.iboFps.toString();
      letOff.text = p.letOffPercent.toString();
      gpi.text = p.gpi.toString();
      shaftLen.text = p.shaftLengthInches.toString();
      point.text = p.pointGrains.toString();
      insert.text = p.insertGrains.toString();
      collar.text = p.collarGrains.toString();
      nock.text = p.nockGrains.toString();
      wrap.text = p.wrapGrains.toString();
      vane.text = p.vaneGrainsEach.toString();
      profileStatus = 'Loaded saved profile “${p.name}”.';
    });
  }

  Future<void> _saveProfile() async {
    try {
      final profile = RigProfile(
        name: profileName.text.trim().isEmpty ? 'Saved rig' : profileName.text.trim(),
        bowType: bowType,
        camStyle: camStyle,
        drawWeightPounds: double.parse(drawWeight.text),
        drawLengthInches: double.parse(drawLength.text),
        iboFps: double.parse(ibo.text),
        letOffPercent: double.parse(letOff.text),
        gpi: double.parse(gpi.text),
        shaftLengthInches: double.parse(shaftLen.text),
        pointGrains: double.parse(point.text),
        insertGrains: double.parse(insert.text),
        collarGrains: double.parse(collar.text),
        nockGrains: double.parse(nock.text),
        wrapGrains: double.parse(wrap.text),
        vaneGrainsEach: double.parse(vane.text),
      );
      await _store.save(profile);
      if (!mounted) return;
      setState(() => profileStatus = 'Saved profile “${profile.name}”.');
    } catch (e) {
      if (!mounted) return;
      setState(() => profileStatus = 'Could not save: $e');
    }
  }

  void _buildSummary() {
    try {
      final components = ArrowComponents(
        gpi: double.parse(gpi.text),
        shaftLengthInches: double.parse(shaftLen.text),
        pointGrains: double.parse(point.text),
        insertGrains: double.parse(insert.text),
        outsertOrCollarGrains: double.parse(collar.text),
        nockGrains: double.parse(nock.text),
        wrapGrains: double.parse(wrap.text),
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
        camStyle: camStyle,
      );
      final holding = engine.letOffHolding(
        peakDrawWeightPounds: double.parse(drawWeight.text),
        letOffPercent: double.parse(letOff.text),
      );

      final warnings = [
        ...weight.warnings,
        ...speed.warnings,
        ...spine.warnings,
      ];
      setState(() {
        error = null;
        summary = '''
Total weight: ${weight.value.totalGrains.toStringAsFixed(1)} gr
Shaft / front / rear: ${weight.value.shaftGrains.toStringAsFixed(1)} / ${weight.value.frontGrains.toStringAsFixed(1)} / ${weight.value.rearGrains.toStringAsFixed(1)} gr
GPP: ${weight.value.grainsPerPound?.toStringAsFixed(2)}
FOC (component estimate): ${foc.value.focPercent.toStringAsFixed(1)}%
Holding weight @ ${letOff.text}% let-off: ${holding.value.holdingWeightPounds.toStringAsFixed(1)} lb
Estimated speed: ${speed.value.estimatedFps.toStringAsFixed(1)} fps
KE: ${energy.value.keFtLb.toStringAsFixed(1)} ft-lb (${energy.value.keJoules.toStringAsFixed(1)} J)
Momentum: ${energy.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s
Planning spine: ${spine.value.primarySpine}${spine.value.alternateSpine == null ? '' : ' / ${spine.value.alternateSpine}'}
Chart: ${spine.value.chartName}

Warnings: ${warnings.isEmpty ? 'none' : warnings.join(' · ')}

Assumptions: IBO→speed is an estimate; FOC here is component-based — measure balance point before hunting. Chronograph before claiming performance.
''';
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('ValidationException: ', '');
        summary = '';
      });
    }
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
                      TextField(
                        controller: profileName,
                        decoration: const InputDecoration(labelText: 'Profile name'),
                      ),
                      if (profileStatus != null) ...[
                        const SizedBox(height: 8),
                        Text(profileStatus!),
                      ],
                      Row(
                        children: [
                          TextButton(onPressed: _loadProfile, child: const Text('Load saved')),
                          TextButton(onPressed: _saveProfile, child: const Text('Save profile')),
                        ],
                      ),
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
                      TextField(controller: letOff, decoration: const InputDecoration(labelText: 'Let-off (%)')),
                      DropdownButtonFormField<CamStyle>(
                        initialValue: camStyle,
                        items: const [
                          DropdownMenuItem(value: CamStyle.standard, child: Text('Standard cam')),
                          DropdownMenuItem(value: CamStyle.aggressive, child: Text('Aggressive cam')),
                          DropdownMenuItem(value: CamStyle.soft, child: Text('Soft cam')),
                        ],
                        onChanged: (v) => setState(() => camStyle = v ?? CamStyle.standard),
                        decoration: const InputDecoration(labelText: 'Cam system'),
                      ),
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
                      TextField(controller: collar, decoration: const InputDecoration(labelText: 'Collar / outsert (gr)')),
                      TextField(controller: nock, decoration: const InputDecoration(labelText: 'Nock (gr)')),
                      TextField(controller: wrap, decoration: const InputDecoration(labelText: 'Wrap (gr)')),
                      TextField(controller: vane, decoration: const InputDecoration(labelText: 'Vane each (gr) ×3')),
                    ],
                  ),
                ),
                _stepCard(
                  '4. Performance',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Runs weight, FOC estimate, IBO→speed, KE, momentum, let-off holding weight, and planning spine in one pass.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _buildSummary,
                        child: const Text('Calculate performance'),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 12),
                      Text(summary),
                    ],
                  ),
                ),
                _stepCard(
                  '5. Results & related tools',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilledButton.tonal(
                        onPressed: _saveProfile,
                        child: const Text('Save profile'),
                      ),
                      if (profileStatus != null) ...[
                        const SizedBox(height: 8),
                        Text(profileStatus!),
                      ],
                      const SizedBox(height: 12),
                      const Text('Open detailed calculators (same formulas, more charts and FAQs):'),
                      TextButton(onPressed: () => context.push('/calc/foc'), child: const Text('Measure FOC (AMO)')),
                      TextButton(onPressed: () => context.push('/calc/ke-momentum'), child: const Text('KE & momentum')),
                      TextButton(onPressed: () => context.push('/calc/drop'), child: const Text('Arrow drop / trajectory')),
                      TextButton(onPressed: () => context.push('/calc/spine'), child: const Text('Spine selection')),
                      TextButton(onPressed: () => context.push('/calc/sight-pin'), child: const Text('Sight pin gaps')),
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
                    } else {
                      context.go('/');
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

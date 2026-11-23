import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class DropPage extends StatefulWidget {
  const DropPage({super.key});
  @override
  State<DropPage> createState() => _DropPageState();
}

class _DropPageState extends State<DropPage> {
  final speed = TextEditingController(text: '280');
  final zero = TextEditingController(text: '20');
  final sight = TextEditingController(text: '3.5');
  bool useDrag = false;
  CalcResult<TrajectoryResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        final s = parseDouble(speed.text)!;
        final z = parseDouble(zero.text)!;
        final h = parseDouble(sight.text) ?? 3.5;
        result = useDrag
            ? engine.trajectoryWithDrag(speedFps: s, zeroYards: z)
            : engine.trajectoryGravity(speedFps: s, zeroYards: z, sightHeightInches: h);
      } catch (e) {
        result = null;
        error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'Arrow drop / trajectory',
      intro: 'Estimate inches relative to line of sight. Gravity-only by default; optional simple drag model.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Sight pin gap', 'Shot angle'],
      inputs: Column(children: [
        NumberField(label: 'Speed', controller: speed, suffix: 'fps'),
        NumberField(label: 'Zero distance', controller: zero, suffix: 'yd'),
        NumberField(label: 'Sight height', controller: sight, suffix: 'in'),
        SwitchListTile(
          title: const Text('Include simple drag model'),
          value: useDrag,
          onChanged: (v) => setState(() => useDrag = v),
        ),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: result!.value.modelName,
              result: result!,
              extra: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in result!.value.points)
                    Text('${p.distanceYards.toStringAsFixed(0)} yd: ${p.dropInchesFromLineOfSight.toStringAsFixed(1)} in'),
                ],
              ),
            ),
    );
  }
}

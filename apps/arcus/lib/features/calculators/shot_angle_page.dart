import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class ShotAnglePage extends StatefulWidget {
  const ShotAnglePage({super.key});
  @override
  State<ShotAnglePage> createState() => _ShotAnglePageState();
}

class _ShotAnglePageState extends State<ShotAnglePage> {
  final los = TextEditingController(text: '40');
  final angle = TextEditingController(text: '30');
  CalcResult<double>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.shotAngleDistance(
          lineOfSightYards: parseDouble(los.text)!,
          angleDegrees: parseDouble(angle.text)!,
        );
      } catch (e) {
        result = null;
        error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'Shot angle',
      intro: 'Convert line-of-sight distance to approximate horizontal distance for uphill/downhill shots.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Arrow drop', 'Sight pin gap'],
      inputs: Column(children: [
        NumberField(label: 'Line-of-sight distance', controller: los, suffix: 'yd'),
        NumberField(label: 'Angle from horizontal', controller: angle, suffix: 'deg'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: '${result!.value.toStringAsFixed(1)} yd horizontal',
              result: result!,
            ),
    );
  }
}

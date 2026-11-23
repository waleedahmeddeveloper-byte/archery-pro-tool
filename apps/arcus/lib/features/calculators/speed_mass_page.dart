import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class SpeedMassPage extends StatefulWidget {
  const SpeedMassPage({super.key});
  @override
  State<SpeedMassPage> createState() => _SpeedMassPageState();
}

class _SpeedMassPageState extends State<SpeedMassPage> {
  final refSpeed = TextEditingController(text: '300');
  final refWeight = TextEditingController(text: '350');
  final newWeight = TextEditingController(text: '450');
  final efficiency = TextEditingController(text: '95');
  CalcResult<SpeedEstimateResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.speedFromMassChange(
          referenceSpeedFps: parseDouble(refSpeed.text)!,
          referenceWeightGrains: parseDouble(refWeight.text)!,
          newWeightGrains: parseDouble(newWeight.text)!,
          efficiencyPercent: parseDouble(efficiency.text) ?? 100,
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
      title: 'Arrow speed (mass change)',
      intro: 'Estimate speed when arrow weight changes from a known chronograph pair.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['IBO speed', 'KE & momentum'],
      inputs: Column(children: [
        NumberField(label: 'Reference speed', controller: refSpeed, suffix: 'fps'),
        NumberField(label: 'Reference weight', controller: refWeight, suffix: 'gr'),
        NumberField(label: 'New weight', controller: newWeight, suffix: 'gr'),
        NumberField(label: 'Efficiency', controller: efficiency, suffix: '%'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: '${result!.value.speedFps.toStringAsFixed(1)} fps (estimate)',
              result: result!,
            ),
    );
  }
}

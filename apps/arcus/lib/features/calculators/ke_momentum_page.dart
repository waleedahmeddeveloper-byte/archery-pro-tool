import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class KeMomentumPage extends StatefulWidget {
  const KeMomentumPage({super.key});
  @override
  State<KeMomentumPage> createState() => _KeMomentumPageState();
}

class _KeMomentumPageState extends State<KeMomentumPage> {
  final weight = TextEditingController(text: '450');
  final speed = TextEditingController(text: '275');
  CalcResult<EnergyMomentumResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.energyMomentum(
          arrowWeightGrains: parseDouble(weight.text)!,
          speedFps: parseDouble(speed.text)!,
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
      title: 'KE & momentum',
      intro: 'Impact energy and linear momentum from finished arrow mass and speed.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Arrow speed', 'Arrow weight', 'Effective range'],
      inputs: Column(children: [
        NumberField(label: 'Arrow weight', controller: weight, suffix: 'gr'),
        NumberField(label: 'Speed', controller: speed, suffix: 'fps', helper: 'Prefer chronograph readings.'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline:
                  '${result!.value.keFtLb.toStringAsFixed(1)} ft-lb · ${result!.value.momentumSlugFtPerSec.toStringAsFixed(3)} slug·ft/s',
              result: result!,
              extra: Text('${result!.value.keJoules.toStringAsFixed(1)} J · ${result!.value.momentumKgMPerSec.toStringAsFixed(2)} kg·m/s'),
            ),
    );
  }
}

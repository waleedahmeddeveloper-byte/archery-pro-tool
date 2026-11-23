import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});
  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final value = TextEditingController(text: '450');
  String output = '';
  final engine = const ArcheryEngine();

  void calc() {
    final v = parseDouble(value.text) ?? 0;
    final grams = engine.convertWeightValue(v, WeightUnit.grains, WeightUnit.grams);
    final ms = engine.convertSpeedValue(280, SpeedUnit.fps, SpeedUnit.metersPerSecond);
    final j = engine.convertEnergyValue(75.6, EnergyUnit.footPounds, EnergyUnit.joules);
    setState(() {
      output =
          '${v.toStringAsFixed(1)} gr = ${grams.toStringAsFixed(2)} g\n280 fps = ${ms.toStringAsFixed(2)} m/s\n75.6 ft-lb = ${j.toStringAsFixed(2)} J';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'Unit converter',
      intro: 'Common archery unit conversions with dimensional round-trips covered in engine tests.',
      onCalculate: calc,
      onReset: () => setState(() => output = ''),
      related: const ['KE & momentum', 'Arrow weight'],
      inputs: Column(children: [
        NumberField(label: 'Grains to convert', controller: value, suffix: 'gr'),
        if (output.isNotEmpty) Text(output),
      ]),
    );
  }
}

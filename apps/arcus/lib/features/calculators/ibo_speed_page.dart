import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class IboSpeedPage extends StatefulWidget {
  const IboSpeedPage({super.key});
  @override
  State<IboSpeedPage> createState() => _IboSpeedPageState();
}

class _IboSpeedPageState extends State<IboSpeedPage> {
  final ibo = TextEditingController(text: '340');
  final dw = TextEditingController(text: '60');
  final dl = TextEditingController(text: '28');
  final aw = TextEditingController(text: '420');
  final stringW = TextEditingController(text: '12');
  CalcResult<IboSpeedResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.speedFromIbo(
          iboFps: parseDouble(ibo.text)!,
          drawWeightPounds: parseDouble(dw.text)!,
          drawLengthInches: parseDouble(dl.text)!,
          arrowWeightGrains: parseDouble(aw.text)!,
          stringAccessoryGrains: parseDouble(stringW.text) ?? 0,
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
      title: 'Bow speed (IBO)',
      intro: 'Adjust a published IBO rating toward your draw weight, draw length, and arrow.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Arrow speed', 'KE & momentum'],
      inputs: Column(children: [
        NumberField(label: 'IBO rating', controller: ibo, suffix: 'fps'),
        NumberField(label: 'Draw weight', controller: dw, suffix: 'lb'),
        NumberField(label: 'Draw length', controller: dl, suffix: 'in'),
        NumberField(label: 'Arrow weight', controller: aw, suffix: 'gr'),
        NumberField(label: 'String accessories', controller: stringW, suffix: 'gr'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: '${result!.value.estimatedFps.toStringAsFixed(1)} fps (estimate)',
              result: result!,
              extra: Text(
                'Energy model ${result!.value.energyModelFps.toStringAsFixed(1)} · rule of thumb ${result!.value.ruleOfThumbFps.toStringAsFixed(1)}',
              ),
            ),
    );
  }
}

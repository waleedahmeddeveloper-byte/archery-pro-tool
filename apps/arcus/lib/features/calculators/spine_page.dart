import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class SpinePage extends StatefulWidget {
  const SpinePage({super.key});
  @override
  State<SpinePage> createState() => _SpinePageState();
}

class _SpinePageState extends State<SpinePage> {
  BowType bowType = BowType.compound;
  CamStyle cam = CamStyle.standard;
  final dw = TextEditingController(text: '60');
  final length = TextEditingController(text: '28');
  final point = TextEditingController(text: '100');
  CalcResult<SpineSelectionResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.spine(
          bowType: bowType,
          drawWeightPounds: parseDouble(dw.text)!,
          arrowLengthInches: parseDouble(length.text)!,
          pointWeightGrains: parseDouble(point.text)!,
          camStyle: cam,
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
      title: 'Spine selection',
      intro: 'Planning spine from effective draw weight. Always confirm on the manufacturer chart for your shaft model.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Arrow length', 'Point weight', 'Paper tuning'],
      inputs: Column(children: [
        DropdownButtonFormField<BowType>(
          initialValue: bowType,
          decoration: const InputDecoration(labelText: 'Bow type'),
          items: const [
            DropdownMenuItem(value: BowType.compound, child: Text('Compound')),
            DropdownMenuItem(value: BowType.recurve, child: Text('Recurve')),
            DropdownMenuItem(value: BowType.traditional, child: Text('Traditional')),
          ],
          onChanged: (v) => setState(() => bowType = v ?? BowType.compound),
        ),
        const SizedBox(height: 12),
        if (bowType == BowType.compound)
          DropdownButtonFormField<CamStyle>(
            initialValue: cam,
            decoration: const InputDecoration(labelText: 'Cam style'),
            items: const [
              DropdownMenuItem(value: CamStyle.standard, child: Text('Standard')),
              DropdownMenuItem(value: CamStyle.aggressive, child: Text('Aggressive')),
              DropdownMenuItem(value: CamStyle.soft, child: Text('Soft / round')),
            ],
            onChanged: (v) => setState(() => cam = v ?? CamStyle.standard),
          ),
        NumberField(label: 'Draw weight', controller: dw, suffix: 'lb'),
        NumberField(label: 'Arrow length', controller: length, suffix: 'in'),
        NumberField(label: 'Point weight', controller: point, suffix: 'gr'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: 'Spine ${result!.value.primarySpine}',
              result: result!,
              extra: Text(
                'Effective ${result!.value.effectiveWeightPounds.toStringAsFixed(1)} lb · ${result!.value.chartName}'
                '${result!.value.alternateSpine == null ? '' : ' · also try ${result!.value.alternateSpine}'}',
              ),
            ),
    );
  }
}

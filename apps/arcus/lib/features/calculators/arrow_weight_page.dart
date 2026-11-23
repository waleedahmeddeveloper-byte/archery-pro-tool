import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class ArrowWeightPage extends StatefulWidget {
  const ArrowWeightPage({super.key});
  @override
  State<ArrowWeightPage> createState() => _ArrowWeightPageState();
}

class _ArrowWeightPageState extends State<ArrowWeightPage> {
  final gpi = TextEditingController(text: '8.2');
  final length = TextEditingController(text: '28');
  final point = TextEditingController(text: '125');
  final insert = TextEditingController(text: '25');
  final nock = TextEditingController(text: '8');
  final vane = TextEditingController(text: '7');
  final vaneCount = TextEditingController(text: '3');
  final draw = TextEditingController(text: '60');
  CalcResult<ArrowWeightResult>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.arrowWeight(
          components: ArrowComponents(
            gpi: parseDouble(gpi.text)!,
            shaftLengthInches: parseDouble(length.text)!,
            pointGrains: parseDouble(point.text) ?? 0,
            insertGrains: parseDouble(insert.text) ?? 0,
            nockGrains: parseDouble(nock.text) ?? 0,
            vaneGrainsEach: parseDouble(vane.text) ?? 0,
            vaneCount: int.tryParse(vaneCount.text) ?? 0,
          ),
          drawWeightPounds: parseDouble(draw.text),
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
      title: 'Arrow weight',
      intro: 'Sum shaft GPI and components, then check grains per pound.',
      onCalculate: calc,
      onReset: () => setState(() {
        result = null;
        error = null;
      }),
      related: const ['FOC', 'GPP', 'KE & momentum'],
      inputs: Column(children: [
        NumberField(label: 'GPI', controller: gpi, helper: 'From shaft specs'),
        NumberField(label: 'Shaft length', controller: length, suffix: 'in'),
        NumberField(label: 'Point / broadhead', controller: point, suffix: 'gr'),
        NumberField(label: 'Insert', controller: insert, suffix: 'gr'),
        NumberField(label: 'Nock', controller: nock, suffix: 'gr'),
        NumberField(label: 'Vane weight each', controller: vane, suffix: 'gr'),
        NumberField(label: 'Vane count', controller: vaneCount),
        NumberField(label: 'Draw weight', controller: draw, suffix: 'lb'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: '${result!.value.totalGrains.toStringAsFixed(1)} gr',
              result: result!,
              extra: Text(
                result!.value.grainsPerPound == null
                    ? ''
                    : 'GPP ${result!.value.grainsPerPound!.toStringAsFixed(2)} · min ~${result!.value.minimumSuggestedGrains!.toStringAsFixed(0)} gr',
              ),
            ),
    );
  }
}

import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class DrawLengthPage extends StatefulWidget {
  const DrawLengthPage({super.key});
  @override
  State<DrawLengthPage> createState() => _DrawLengthPageState();
}

class _DrawLengthPageState extends State<DrawLengthPage> {
  final wingspan = TextEditingController(text: '70');
  CalcResult<double>? result;
  String? error;
  final engine = const ArcheryEngine();

  void calc() {
    setState(() {
      error = null;
      try {
        result = engine.drawLengthFromWingspan(parseDouble(wingspan.text)!);
      } catch (e) {
        result = null;
        error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'Draw length',
      intro: 'Shop estimate from wingspan. Confirm with ATA full-draw measurement.',
      onCalculate: calc,
      onReset: () => setState(() { result = null; error = null; }),
      related: const ['Arrow length', 'Spine selection'],
      inputs: Column(children: [
        NumberField(label: 'Wingspan', controller: wingspan, suffix: 'in', helper: 'Fingertip to fingertip'),
        if (error != null) Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
      resultPanel: result == null
          ? null
          : ResultBreakdown(
              headline: '${result!.value.toStringAsFixed(2)} in (estimate)',
              result: result!,
            ),
    );
  }
}

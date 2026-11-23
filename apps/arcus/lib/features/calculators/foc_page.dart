import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'widgets/calculator_scaffold.dart';

class FocPage extends StatefulWidget {
  const FocPage({super.key});
  @override
  State<FocPage> createState() => _FocPageState();
}

class _FocPageState extends State<FocPage> {
  final _length = TextEditingController(text: '29');
  final _balance = TextEditingController(text: '18.2');
  CalcResult<FocResult>? _result;
  String? _error;
  final _engine = const ArcheryEngine();

  void _calc() {
    setState(() {
      _error = null;
      try {
        _result = _engine.focMeasured(
          arrowLengthInches: parseDouble(_length.text)!,
          balancePointFromNockInches: parseDouble(_balance.text)!,
        );
      } catch (e) {
        _result = null;
        _error = e.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'FOC (measured)',
      intro:
          'Compute front-of-center from a physical balance measurement on a fully assembled arrow.',
      onCalculate: _calc,
      onReset: () => setState(() {
        _length.text = '29';
        _balance.text = '18.2';
        _result = null;
        _error = null;
      }),
      related: const ['Arrow weight', 'Spine selection', 'KE & momentum'],
      inputs: Column(
        children: [
          NumberField(
            label: 'Arrow length (L)',
            controller: _length,
            suffix: 'in',
            helper: 'Nock throat to end of shaft — not the tip of the point.',
          ),
          NumberField(
            label: 'Balance point (A)',
            controller: _balance,
            suffix: 'in',
            helper: 'Nock throat to fulcrum where the arrow balances level.',
          ),
          if (_error != null)
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ),
      resultPanel: _result == null
          ? null
          : ResultBreakdown(
              headline: '${_result!.value.focPercent.toStringAsFixed(2)}% FOC',
              result: _result!,
              extra: Text('Method: ${_result!.value.methodLabel}'),
            ),
    );
  }
}

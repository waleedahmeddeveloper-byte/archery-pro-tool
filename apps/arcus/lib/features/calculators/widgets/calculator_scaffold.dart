import 'package:archery_engine/archery_engine.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_strings.dart';

class CalculatorScaffold extends StatelessWidget {
  const CalculatorScaffold({
    super.key,
    required this.title,
    required this.intro,
    required this.inputs,
    required this.onCalculate,
    required this.onReset,
    this.resultPanel,
    this.related = const [],
    this.onRelatedTap,
    this.breadcrumb = const [],
    this.faqs = const [],
    this.examples = const [],
  });

  final String title;
  final String intro;
  final Widget inputs;
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final Widget? resultPanel;
  final List<String> related;
  final ValueChanged<String>? onRelatedTap;
  final List<String> breadcrumb;
  final List<({String q, String a})> faqs;
  final List<String> examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          if (breadcrumb.isNotEmpty) ...[
            Text(
              breadcrumb.join(' › '),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          Text(intro, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.disclaimerShort,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          inputs,
          if (resultPanel != null) ...[
            const SizedBox(height: 20),
            resultPanel!,
          ],
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Worked examples', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...examples.map((e) => Text('• $e')),
          ],
          if (faqs.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('FAQ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...faqs.map(
              (f) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(f.q),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(f.a),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (related.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(AppStrings.related, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: related
                  .map(
                    (e) => ActionChip(
                      label: Text(e),
                      onPressed: onRelatedTap == null ? null : () => onRelatedTap!(e),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  child: const Text(AppStrings.reset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onCalculate,
                  child: const Text(AppStrings.calculate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultBreakdown extends StatelessWidget {
  const ResultBreakdown({
    super.key,
    required this.headline,
    required this.result,
    this.extra,
  });

  final String headline;
  final CalcResult<dynamic> result;
  final Widget? extra;

  Future<void> _copy(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln(headline)
      ..writeln(result.formulaDisplay)
      ..writeln(result.steps.join('\n'));
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Result copied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    headline,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: AppStrings.copyResult,
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...result.warnings.map(
                (w) => Text(w, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
            if (extra != null) ...[const SizedBox(height: 12), extra!],
            const Divider(height: 28),
            Text(AppStrings.formulaUsed, style: Theme.of(context).textTheme.titleSmall),
            Text(result.formulaDisplay),
            const SizedBox(height: 12),
            Text(AppStrings.stepByStep, style: Theme.of(context).textTheme.titleSmall),
            ...result.steps.map((s) => Text('• $s')),
            const SizedBox(height: 12),
            Text(AppStrings.assumptions, style: Theme.of(context).textTheme.titleSmall),
            ...result.assumptions.map((s) => Text('• $s')),
            const SizedBox(height: 12),
            Text(AppStrings.limitations, style: Theme.of(context).textTheme.titleSmall),
            ...result.limitations.map((s) => Text('• $s')),
            const SizedBox(height: 12),
            Text(AppStrings.safety, style: Theme.of(context).textTheme.titleSmall),
            ...result.safetyNotes.map((s) => Text('• $s')),
            const SizedBox(height: 12),
            Text(AppStrings.citation, style: Theme.of(context).textTheme.titleSmall),
            Text('${result.citation.title} — ${result.citation.source}'),
            Text(result.citation.url, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    this.helper,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          suffixText: suffix,
        ),
      ),
    );
  }
}

double? parseDouble(String raw) => double.tryParse(raw.trim());

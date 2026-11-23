import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../catalog/calculator_catalog.dart';

class CalculatorsTab extends StatefulWidget {
  const CalculatorsTab({super.key});

  @override
  State<CalculatorsTab> createState() => _CalculatorsTabState();
}

class _CalculatorsTabState extends State<CalculatorsTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = CalculatorCatalog.items.where((e) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q);
    }).toList();

    final grouped = <CalculatorCategory, List<CalculatorDef>>{};
    for (final item in filtered) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calculators')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search tools',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tools match “$_query”.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try FOC, spine, kinetic, or crossbow.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            for (final entry in grouped.entries) ...[
              Text(
                CalculatorCatalog.categoryLabel(entry.key),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              ...entry.value.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.subtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(item.route),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../catalog/calculator_catalog.dart';

sealed class _CatalogRow {
  const _CatalogRow();
}

class _HeaderRow extends _CatalogRow {
  const _HeaderRow(this.label);
  final String label;
}

class _ItemRow extends _CatalogRow {
  const _ItemRow(this.item);
  final CalculatorDef item;
}

class CalculatorsTab extends StatefulWidget {
  const CalculatorsTab({super.key});

  @override
  State<CalculatorsTab> createState() => _CalculatorsTabState();
}

class _CalculatorsTabState extends State<CalculatorsTab> {
  String _query = '';

  List<_CatalogRow> _buildRows(List<CalculatorDef> filtered) {
    final grouped = <CalculatorCategory, List<CalculatorDef>>{};
    for (final item in filtered) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final rows = <_CatalogRow>[];
    for (final entry in grouped.entries) {
      rows.add(_HeaderRow(CalculatorCatalog.categoryLabel(entry.key)));
      for (final item in entry.value) {
        rows.add(_ItemRow(item));
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = CalculatorCatalog.items.where((e) {
      final q = _query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return e.title.toLowerCase().contains(q) ||
          e.subtitle.toLowerCase().contains(q);
    }).toList();

    final rows = _buildRows(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Calculators')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Semantics(
              label: 'Search archery calculator tools',
              textField: true,
              child: TextField(
                key: const Key('calculators-search'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search tools',
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Semantics(
                    label: 'No calculators match the search query',
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    key: const Key('calculators-list'),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return switch (row) {
                        _HeaderRow(:final label) => Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 16,
                              bottom: 8,
                            ),
                            child: Semantics(
                              header: true,
                              child: Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        _ItemRow(:final item) => Semantics(
                            button: true,
                            label: '${item.title}. ${item.subtitle}',
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(item.title),
                                subtitle: Text(item.subtitle),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  semanticLabel: 'Open calculator',
                                ),
                                onTap: () => context.push(item.route),
                              ),
                            ),
                          ),
                      };
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
